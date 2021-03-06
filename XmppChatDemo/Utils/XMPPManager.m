//
//  XMPPManager.m
//  XmppChatDemo
//
//  Created by Mohit Sahu on 21/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import "XMPPManager.h"
#import "UserDefaultController.h"
#define localhost @"192.168.1.10"
#import "XMPP.h"
#import "NSString+Enhancement.h"

@implementation XMPPManager{
  
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPReconnect *xmppReconnect;
    
}



+(instancetype)sharedInstance{
static XMPPManager *xmppManager = nil;
static dispatch_once_t once;
dispatch_once(&once,^{
    xmppManager = [[XMPPManager alloc] init];
});
return xmppManager;
}




#pragma mark
#pragma mark- Xmpp Setup Methods

-(void)setupStream{
    
    _xmppStream = [[XMPPStream alloc] init];
     [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    xmppRosterStorage = [XMPPRosterCoreDataStorage sharedInstance];
    xmppRosterStorage.autoRemovePreviousDatabaseFile = NO;
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
   
    [xmppRoster activate:_xmppStream];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];

#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        _xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif

    xmppReconnect = [[XMPPReconnect alloc] init];
    [xmppReconnect activate:self.xmppStream];
    [xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    NSString *domin = _xmppStream.myJID.domain;
    
    if ([domin  isEqual: @"gmail.com"]|| [domin  isEqual: @"gtalk.com"] || [domin  isEqual: @"talk.google.com"]) {
        DDXMLElement *priority = [DDXMLElement elementWithName:@"priority" numberValue:[NSNumber numberWithInteger:24]];
        [presence addChild:priority];
    }
    
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

- (BOOL)connect {
    
    [self setupStream];
    
    NSString *jabberID =  [[UserDefaultController sharedInstance] getUserId];
    NSString *myPassword = [[UserDefaultController sharedInstance] getPassword];
    
    if (![_xmppStream isDisconnected]) {
        return YES;
    }
    
    if (jabberID == nil || myPassword == nil) {
        
        return NO;
    }
    
    [_xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
    password = myPassword;
    _xmppStream.hostPort = 5222;
    [_xmppStream setHostName:localhost];
    
    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        
        
        return NO;
    }
    
    
    
    return YES;
}


- (void)disconnect {
    
    [self goOffline];
    [_xmppStream disconnectAfterSending];
   
    
}

-(void)addNewBuddy:(NSString *)jid nickName:(NSString *)nickName{

    XMPPJID *newBuddy = [XMPPJID jidWithString:jid];
    
    [xmppRoster addUser:newBuddy withNickname:nickName];
}


#pragma mark
#pragma mark- XmppStream Delegate Methods

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    
    // connection to the server successful
    isOpen = YES;
    NSError *error = nil;
    BOOL res = [[self xmppStream] authenticateWithPassword:password error:&error];
    NSLog(@"%zd", res);
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    
    // authentication successful
    [self goOnline];
    
}


- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    
    // message received
    
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];

    if (msg != nil && from != nil) {
    NSMutableDictionary *messageDictionary = [[NSMutableDictionary alloc] init];
    [messageDictionary setObject:msg forKey:@"msg"];
    [messageDictionary setObject:from forKey:@"sender"];
     [messageDictionary setObject:[NSString getCurrentTime] forKey:@"time"];
        if (self._messageDelegate && [self._messageDelegate respondsToSelector:@selector(newMessageReceived:)]) {
            [self._messageDelegate newMessageReceived:messageDictionary];
        }
    
    }
    
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    
    // a buddy went offline/online
    
    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    if (![presenceFromUser isEqualToString:myUsername]) {
        
        if ([presenceType isEqualToString:@"available"]) {
            
            if (self._chatDelegate && [self._chatDelegate respondsToSelector:@selector(newBuddyOnline:)]) {
                   [self._chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"localhost"]];
           
                 }
           
            
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            
            if (self._chatDelegate && [self._chatDelegate respondsToSelector:@selector(buddyWentOffline:)]) {
                  [self._chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"localhost"]];
           
               }
            
            
        }
        else if ([presenceType isEqualToString:@"subscribe"]){
        
        }
        
    }
    
}


#pragma mark--
#pragma mark-- Roseter Delegate Methods

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    
    [xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
   
    
    
}

#pragma mark--
#pragma mark-- Reconnection Delegate Methods



- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@"didDetectAccidentalDisconnect:%u",connectionFlags);
}
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@"shouldAttemptAutoReconnect:%u",connectionFlags);
        return YES;
}

@end
