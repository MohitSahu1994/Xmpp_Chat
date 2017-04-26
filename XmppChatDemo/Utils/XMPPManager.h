//
//  XMPPManager.h
//  XmppChatDemo
//
//  Created by Mohit Sahu on 21/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import <Foundation/Foundation.h>

@import XMPPFramework;
@class ChatMenuVC;

@protocol SMChatDelegate

- (void)newBuddyOnline:(NSString *)buddyName;
- (void)buddyWentOffline:(NSString *)buddyName;
-(void)didfetchBuddies:(NSMutableArray *)buddiesArray;
- (void)didDisconnect;

@end

@protocol SMMessageDelegate

- (void)newMessageReceived:(NSDictionary *)messageContent;
-(void)updateMessageStateForJID:(NSString *)jid messageId:(NSString *)messageId status:(NSInteger)status;



@end

@interface XMPPManager : NSObject{

    NSString *password;
    
  
}

@property (nonatomic, retain) IBOutlet ChatMenuVC *viewController;
@property (nonatomic, readonly) XMPPStream *xmppStream;

@property (nonatomic, assign) id  chatDelegate;
@property (nonatomic, assign) id  messageDelegate;
@property (nonatomic)BOOL isOpen;

+(instancetype)sharedInstance;

- (void)setupStream;
- (void)goOnline;
- (void)goOffline;

- (BOOL)connect;
- (void)disconnect;
-(void)addNewBuddy:(NSString *)jid nickName:(NSString *)nickName;
- (void)fetchBuddyList;

@end
