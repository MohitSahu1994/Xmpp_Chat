//
//  ImageCaptureVC.h
//  XmppChatDemo
//
//  Created by Mohit Sahu on 25/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageCaptureDelegate <NSObject>

-(void)capturedImageByUser:(UIImage *)image;

@end


@interface ImageCaptureVC : UIViewController
@property(nonatomic , strong) id<ImageCaptureDelegate> delegate;


@end
