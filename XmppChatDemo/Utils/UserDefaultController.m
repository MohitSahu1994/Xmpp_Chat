//
//  UserDefaultController.m
//  XmppChatDemo
//
//  Created by Mohit Sahu on 20/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import "UserDefaultController.h"

@implementation UserDefaultController

+(instancetype)sharedInstance{

    static UserDefaultController *userDefaultController = nil;
    static dispatch_once_t once;
    dispatch_once(&once,^{
        userDefaultController = [[UserDefaultController alloc] init];
    });
    return userDefaultController;

}

-(void)setObject:(id)obj forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
}

-(id)getObjForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}



-(void)setUserId:(NSString *)userId{
    [self setObject:userId forKey:@"userId"];

}
-(NSString *)getUserId{
    return [self getObjForKey:@"userId"];
}

-(void)setPassword:(NSString *)password{

    [self setObject:password forKey:@"password"];
}
-(NSString *)getPassword{

    return [self getObjForKey:@"password"];
}

@end
