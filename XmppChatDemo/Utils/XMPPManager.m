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
#import "Constants.h"

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
    
    
    XMPPMessageDeliveryReceipts* xmppMessageDeliveryRecipts = [[XMPPMessageDeliveryReceipts alloc] init];
    
//    Automatically send message delivery receipts when a message with a delivery request is received
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryReceipts = YES;
//     Message MUST NOT be of type 'error' or 'groupchat' - Message MUST have an id - Message MUST NOT have a delivery receipt or request - To must either be a bare JID or a full JID that advertises the urn:xmpp:receipts capability
    
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryRequests = YES;
    
    [xmppMessageDeliveryRecipts addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppMessageDeliveryRecipts activate:self.xmppStream];

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
    _isOpen = YES;
    NSError *error = nil;
    BOOL res = [[self xmppStream] authenticateWithPassword:password error:&error];
    NSLog(@"%zd", res);
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    
    // authentication successful
    [self goOnline];
    
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {

    if ([message isChatMessageWithBody]) {
        
        MessageStatus status = MESSAGE_STATUS_SEND;
        NSString *messageID = [message elementID];
    
    if (_messageDelegate && [_messageDelegate respondsToSelector:@selector(updateMessageStateForJID:messageId:status:)]) {
        [_messageDelegate updateMessageStateForJID:[message.to bare] messageId:messageID status:status];
    }
    }

}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{

    if ([message isChatMessageWithBody]) {
    MessageStatus status = MESSAGE_STATUS_FAILED;
    NSString *messageID = [message elementID];
    if (_messageDelegate && [_messageDelegate respondsToSelector:@selector(updateMessageStateForJID:messageId:status:)]) {
        [_messageDelegate updateMessageStateForJID:[message.to bare] messageId:messageID status:status];
    }

    }

}


- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    
    // message received
    
    if ([message hasReceiptResponse]) {
        
        [self handleReceiptResponse:message];
        
    }
    else if([message isChatMessageWithBody]){
        
        [self handleChatMessageWithBody:message];
    }
    
    
}

-(void)handleChatMessageWithBody:(XMPPMessage *)message{

    
        
    
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    NSString *attachement;
    if ([message elementsForName:@"attachment"]) {
       attachement =  [[message elementForName:@"attachment"] stringValue];
    }
    
   
    
    
    NSLog(@"%@",attachement);
    
    if (msg != nil && from != nil) {
        NSMutableDictionary *messageDictionary = [[NSMutableDictionary alloc] init];
        [messageDictionary setObject:msg forKey:@"msg"];
        [messageDictionary setObject:from forKey:@"sender"];
        [messageDictionary setObject:[NSString getCurrentTime] forKey:@"time"];
        
       
        if (_messageDelegate && [_messageDelegate respondsToSelector:@selector(newMessageReceived:)]) {
            
            [_messageDelegate newMessageReceived:messageDictionary];
        }
        
        
    }
        

}


-(void)handleReceiptResponse:(XMPPMessage *)message{

    MessageStatus status = MESSAGE_STATUS_DELIVERED;
    NSXMLElement *received = [message elementForName:@"received" xmlns:@"urn:xmpp:receipts"];
    if( received ){
        NSString* readValue = [received attributeStringValueForName:@"read"];
        if( [readValue isEqualToString:@"true"] )
            status = MESSAGE_STATUS_READ;
    }
    
    
    NSString *messageID = [[[message elementForName:@"received"] attributeForName:@"id"] stringValue];
    NSString *senderId = [message.from bare];
    
    if (_messageDelegate && [_messageDelegate respondsToSelector:@selector(updateMessageStateForJID:messageId:status:)]) {
       
        [_messageDelegate updateMessageStateForJID:senderId messageId:messageID status:status];
    }

}




- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    
    // a buddy went offline/online
    
    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    if (![presenceFromUser isEqualToString:myUsername]) {
        
        if ([presenceType isEqualToString:@"available"]) {
            
            if (_chatDelegate && [_chatDelegate respondsToSelector:@selector(newBuddyOnline:)]) {
                   [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"localhost"]];
           
                 }
           
            
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            
            if (_chatDelegate && [_chatDelegate respondsToSelector:@selector(buddyWentOffline:)]) {
                  [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"localhost"]];
           
               }
            
            
        }
        else if ([presenceType isEqualToString:@"subscribe"]){
        
        }
        
    }
    
}


#pragma mark
#pragma mark- Roseter Delegate Methods

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    
    [xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
   
    
}


- (void)fetchBuddyList
{
    NSError *error = [[NSError alloc] init];
    NSXMLElement *query = [[NSXMLElement alloc] initWithXMLString:@"<query xmlns='jabber:iq:roster'/>"error:&error];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"ANY_ID_NAME"];
    [iq addAttributeWithName:@"from" stringValue:@"ANY_ID_NAME@localhost"];
    [iq addChild:query];
    [_xmppStream sendElement:iq];
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSXMLElement *queryElement = [iq elementForName: @"query" xmlns: @"jabber:iq:roster"];
    if (queryElement)
    {
        NSArray *itemElements = [queryElement elementsForName: @"item"];
        if (itemElements.count) {
        
        
        NSMutableArray *chatListArray = [[NSMutableArray alloc] init];
        for (int i=0; i<[itemElements count]; i++)
        {
           [chatListArray addObject:[[itemElements[i] attributeForName:@"jid"]stringValue]];
            
        }
            if (_chatDelegate && [_chatDelegate respondsToSelector:@selector(didfetchBuddies:)]) {
                
                [_chatDelegate didfetchBuddies:chatListArray];
            }
            
       }
    
    }
    
    return NO;
}


#pragma mark
#pragma mark- Reconnection Delegate Methods



- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@"didDetectAccidentalDisconnect:%u",connectionFlags);
}
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@"shouldAttemptAutoReconnect:%u",connectionFlags);
        return YES;
}

@end
