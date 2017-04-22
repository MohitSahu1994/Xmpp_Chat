//
//  UserDefaultController.h
//  XmppChatDemo
//
//  Created by Mohit Sahu on 20/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultController : NSObject
+(instancetype)sharedInstance;

-(void)setUserId:(NSString *)userId;
-(NSString *)getUserId;

-(void)setPassword:(NSString *)password;
-(NSString *)getPassword;

@end
