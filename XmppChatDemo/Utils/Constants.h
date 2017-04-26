//
//  Constants.h
//  XmppChatDemo
//
//  Created by Mohit Sahu on 26/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject



typedef enum {
    MESSAGE_STATUS_WAITING, // local waiting or queued 0
    MESSAGE_STATUS_SEND, // sent to server 1
    MESSAGE_STATUS_DELIVERED,   // recieved by user 2
    MESSAGE_STATUS_READ,   // read by user 3
    MESSAGE_STATUS_FAILED  // failed to send 4
}MessageStatus;

@end
