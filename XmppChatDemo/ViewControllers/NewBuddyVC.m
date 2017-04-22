//
//  NewBuddyVC.m
//  XmppChatDemo
//
//  Created by Mohit Sahu on 21/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import "NewBuddyVC.h"
#import "XMPPManager.h"

@interface NewBuddyVC ()
@property (weak, nonatomic) IBOutlet UITextField *accountNameField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;

@end

@implementation NewBuddyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addBuddyAction:(UIButton *)sender {
    if ([_accountNameField.text isEqualToString:@""]) {
        [self showAlertWithTilte:@"Alert" message:@"Account name can't be empty"];
        return;
    }
    [[XMPPManager sharedInstance] addNewBuddy:_accountNameField.text nickName:_nameField.text];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)backButton:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)showAlertWithTilte:(NSString *)title message:(NSString *)message{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.view endEditing:YES];
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
