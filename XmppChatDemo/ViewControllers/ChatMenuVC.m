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
#define CELL_IDENTIFIER @"cell"
//#import "AppDelegate.h"
#import "ChatVC.h"
#import "XMPPManager.h"
#import "NewBuddyVC.h"

@interface ChatMenuVC ()<UITableViewDelegate,UITableViewDataSource,SMChatDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginbtn;

@end

@implementation ChatMenuVC{

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
            
        NSLog(@"show buddy list");
            
        
    }
    }
    else{
       [self showLogin];
    }
}


-(void)tableViewSetup{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.tableView registerClass:[UITableViewCell.self class] forCellReuseIdentifier:CELL_IDENTIFIER];
    onlineBuddies = [[NSMutableArray alloc ] init];


}


#pragma mark -
#pragma mark Table view delegates & datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *buddy = (NSString *) [onlineBuddies objectAtIndex:indexPath.row];
   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    cell.textLabel.text = buddy;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [onlineBuddies count];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
     [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // start a chat
    NSString *userName = (NSString *) [onlineBuddies objectAtIndex:indexPath.row];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChatVC *chatController = [storyBoard instantiateViewControllerWithIdentifier:@"ChatVC"];
    chatController.chatWithUser = userName;
    [self.navigationController pushViewController:chatController animated:YES];
    
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
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginVC *loginVC =  (LoginVC *)[storyBoard instantiateViewControllerWithIdentifier:@"LoginVC"];
    [self.navigationController pushViewController:loginVC animated:YES];

}

#pragma mark-
#pragma mark- SMChatDelegate Methods
- (void)newBuddyOnline:(NSString *)buddyName {
    if (![onlineBuddies containsObject:buddyName]) {
         [onlineBuddies addObject:buddyName];
         [self.tableView reloadData];
    }
    
   
}

- (void)buddyWentOffline:(NSString *)buddyName {
    [onlineBuddies removeObject:buddyName];
    [self.tableView reloadData];
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
