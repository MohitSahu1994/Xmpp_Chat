//
//  MessagePreview.m
//  XmppChatDemo
//
//  Created by Mohit Sahu on 25/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import "MessagePreview.h"

@interface MessagePreview ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *captionField;
@end

@implementation MessagePreview

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_image) {
        _imageView.image = _image;
    }
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)sendAction:(UIButton *)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(sendMessageWithImage:text:)]) {
        
        [_delegate sendMessageWithImage:_imageView.image text:_captionField.text];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelAction:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.view endEditing:YES];
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
