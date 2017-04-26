//
//  MessageViewTableCell.m
//  XmppChatDemo
//
//  Created by Mohit Sahu on 22/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import "MessageViewTableCell.h"

@implementation MessageViewTableCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _senderAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 300, 20)];
        _senderAndTimeLabel.textAlignment = NSTextAlignmentCenter;
        _senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
        _senderAndTimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_senderAndTimeLabel];
        
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_bgImageView];
        
        _messageContentView = [[UITextView alloc] init];
        _messageContentView.backgroundColor = [UIColor clearColor];
        _messageContentView.editable = NO;
        _messageContentView.scrollEnabled = NO;
        [_messageContentView sizeToFit];
        [self.contentView addSubview:_messageContentView];
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.font = [UIFont boldSystemFontOfSize:11.0];
        _statusLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_statusLabel];
        
    }
    
    return self;
    
}

@end
