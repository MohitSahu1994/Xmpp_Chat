//
//  LoginVC.m
//  XmppChatDemo
//
//  Created by Mohit Sahu on 20/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import "LoginVC.h"
#import "UserDefaultController.h"
#import "XMPPManager.h"

@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeBtn;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


#pragma mark-
#pragma mark- Actions

- (IBAction)LoginAction:(UIButton *)sender {
    
    if ([_emailField.text isEqualToString:@""]||[_passwordField.text isEqualToString:@""]) {
        [self showAlertWithTilte:@"Alert" message:@"Please enter Jid and password"];
        return;
    }
    [[UserDefaultController sharedInstance] setUserId:_emailField.text];
    [[UserDefaultController sharedInstance] setPassword:_passwordField.text];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self didDisconnect];
   
}




- (IBAction)closeLoginAction:(UIBarButtonItem *)sender {
    
   [self.navigationController popViewControllerAnimated:YES];
}

-(void)didDisconnect{
    
    [[XMPPManager sharedInstance] disconnect];
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)showAlertWithTilte:(NSString *)title message:(NSString *)message{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
    
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
