//
//  MessagePreview.h
//  XmppChatDemo
//
//  Created by Mohit Sahu on 25/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessagePreviewDelegate <NSObject>

-(void)sendMessageWithImage:(UIImage *)image text:(NSString *)text;
@end

@interface MessagePreview : UIViewController

@property (strong ,nonatomic)id <MessagePreviewDelegate>delegate;

@property (strong ,nonatomic)UIImage *image;

@end
