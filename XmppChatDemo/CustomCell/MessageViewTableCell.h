//
//  MessageViewTableCell.h
//  XmppChatDemo
//
//  Created by Mohit Sahu on 22/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@protocol MessageTableViewCellDelegate <NSObject>

-(void)updateMessageStatusReadByUser:(Message *)message;

@end



@interface MessageViewTableCell : UITableViewCell


@property (nonatomic,strong) UILabel *senderAndTimeLabel;
@property (nonatomic,strong) UITextView *messageContentView;
@property (nonatomic,strong) UIImageView *bgImageView;
@property (nonatomic ,strong) UILabel *statusLabel;
@property (nonatomic ,strong) id <MessageTableViewCellDelegate> delegate;

-(void)setupCellForMessage:(Message *)message textSize:(CGSize)size;

@end
