//
//  ChatMenuVC.m
//  XmppChatDemo
//
//  Created by Mohit Sahu on 20/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import "ChatMenuVC.h"
#import "LoginVC.h"
#import "UserDefaultController.h"
#import "ChatListCell.h"
#import "User.h"
#define CELL_IDENTIFIER @"cell"

#import "ChatVC.h"
#import "XMPPManager.h"
#import "NewBuddyVC.h"

@interface ChatMenuVC ()<UITableViewDelegate,UITableViewDataSource,SMChatDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginbtn;

@end

@implementation ChatMenuVC{

    NSMutableArray *buddies;
    NSMutableArray *onlineBuddies;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XMPPManager *manager = [XMPPManager sharedInstance];
    manager._chatDelegate = self;
    [self tableViewSetup];
    // Do any additional setup after loading the view.
    
}

-(XMPPManager *)xmppManager{

    return [XMPPManager sharedInstance];
}


-(void)viewDidAppear:(BOOL)animated{

    NSString *userId = [[UserDefaultController sharedInstance] getUserId];
    
    if(userId){
        self.navigationItem.title = userId;
    if ([[self xmppManager] connect]) {
            
        
            
        
    }
    }
    else{
       [self showLogin];
    }
}


-(void)fetchBuddyList{
    
    [[self xmppManager] fetchBuddyList];

}



-(void)tableViewSetup{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"ChatListCell" bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
    
    buddies = [[NSMutableArray alloc ] init];
    onlineBuddies = [[NSMutableArray alloc] init];

}


#pragma mark -
#pragma mark Table view delegates & datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    User *user = (User *) [buddies objectAtIndex:indexPath.row];
   
    ChatListCell *cell = (ChatListCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    cell.userNamelbl.text = user.name;
    if (user.isOnline) {
        cell.statusImageView.hidden = NO;
        cell.statusImageView.image = [UIImage imageNamed:@"online"];
    }
    else{
        cell.statusImageView.hidden = YES;
    }
   
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [buddies count];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
     [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // start a chat
    User *user = (User *) [buddies objectAtIndex:indexPath.row];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChatVC *chatController = [storyBoard instantiateViewControllerWithIdentifier:@"ChatVC"];
    chatController.chatWithUser = user.name;
    [self presentViewController:chatController animated:YES completion:nil];
    
    
}


- (IBAction)showLoginAction:(UIBarButtonItem *)sender {
    [self showLogin];
    }
- (IBAction)addBuddyAction:(UIBarButtonItem *)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewBuddyVC *chatController = [storyBoard instantiateViewControllerWithIdentifier:@"NewBuddyVC"];
    [self.navigationController pushViewController:chatController animated:YES];

}


-(void)showLogin{
    
    [onlineBuddies removeAllObjects];
    [buddies removeAllObjects];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginVC *loginVC =  (LoginVC *)[storyBoard instantiateViewControllerWithIdentifier:@"LoginVC"];
    [self.navigationController pushViewController:loginVC animated:YES];

}

#pragma mark-
#pragma mark- SMChatDelegate Methods
- (void)newBuddyOnline:(NSString *)buddyName {
    if (![onlineBuddies containsObject:buddyName]) {
        [onlineBuddies addObject:buddyName];
        [self updateUserStatus:buddyName isOnline:YES];
    }
    
   
}

- (void)buddyWentOffline:(NSString *)buddyName {
    [onlineBuddies removeObject:buddyName];
    [self updateUserStatus:buddyName isOnline:NO];
}


-(void)didfetchBuddies:(NSMutableArray *)buddiesArray{

    if (buddiesArray.count) {
       
        [self populateBuddiesFromArray:buddiesArray];
    }
}


-(void)populateBuddiesFromArray:(NSMutableArray *)array{
    
    for (NSInteger index =0;index<array.count;index++) {
        
        NSString *userName = [array objectAtIndex:index];
        NSPredicate  *predicate = [NSPredicate predicateWithFormat:@"self.name MATCHES[cd] %@",userName];
       User *oldUser = [self checkArrayContainsUser:buddies UsingPredicate:predicate];
        
        if (oldUser== nil && ![userName isEqualToString:[[UserDefaultController sharedInstance] getUserId]]) {
        User *user =  [[User alloc] init];
            user.name = userName;
        if ([onlineBuddies containsObject:user.name]) {
            user.isOnline = YES;
        }
       
        
        [buddies addObject:user];
    }
    
    [self.tableView reloadData];
    }

}

-(void)updateUserStatus:(NSString *)user isOnline:(BOOL)isOnline{

    if (buddies.count) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name MATCHES[cd] %@",user];
        NSArray *resultArray = [buddies filteredArrayUsingPredicate:predicate];
        User *user = [resultArray lastObject];
        NSInteger index = [buddies indexOfObject:user];
         user.isOnline = isOnline;
        if (index != NSNotFound) {
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }
    
    

}


-(User *)checkArrayContainsUser:(NSMutableArray *)userArray UsingPredicate:(NSPredicate *)predicate{

    User *user;
    NSArray *resultArray = [userArray filteredArrayUsingPredicate:predicate];
    if (resultArray.count) {
        user =  (User *)[resultArray lastObject];
    }
    return user;
}

-(void)didDisconnect{

//    [[[self xmppManager] xmppStream] remo];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
