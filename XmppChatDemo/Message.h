//
//  Message.h
//  XmppChatDemo
//
//  Created by Mohit Sahu on 26/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject
@property (nonatomic ,strong)NSString*messageID;
@property (nonatomic ,strong) NSString *sender;
@property (nonatomic ,strong)NSString *message;
@property (nonatomic ,strong)NSString *time;
@property (nonatomic ,strong)NSString *attachment;
@property (nonatomic)BOOL isRead;
@property (nonatomic ,strong)NSString *status;
@end
