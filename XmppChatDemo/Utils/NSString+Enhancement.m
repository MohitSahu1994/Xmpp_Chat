//
//  NSString+Enhancement.m
//  XmppChatDemo
//
//  Created by Mohit Sahu on 22/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import "NSString+Enhancement.h"



@implementation NSString (Enhancement)
+ (NSString *) getCurrentTime{

    NSDate *nowUTC = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:nowUTC];
}




@end
