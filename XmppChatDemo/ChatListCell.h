//
//  ChatListCell.h
//  XmppChatDemo
//
//  Created by Mohit Sahu on 25/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userNamelbl;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

@end
