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


-(void)setupCellForMessage:(Message *)message textSize:(CGSize)size{

    if(!message.attachment){
        
        
        self.messageContentView.text = message.message;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.userInteractionEnabled = NO;
        
        NSUInteger padding = self.senderAndTimeLabel.frame.size.height + 6;
        UIImage *bgImage = nil;
        
        
        
        if (![message.sender isEqualToString:@"you"]) { // left aligned
            
            if (!message.isRead) {
                message.isRead = YES;
                if (_delegate && [_delegate respondsToSelector:@selector(updateMessageStatusReadByUser:)]) {
                    [_delegate updateMessageStatusReadByUser:message];
                }
            }
            
            bgImage = [[UIImage imageNamed:@"orange"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
            
            [_messageContentView setFrame:CGRectMake(padding, padding, size.width + padding, size.height+padding)];
            
            [_bgImageView setFrame:CGRectMake( _messageContentView.frame.origin.x-padding/2,
                                                  _messageContentView.frame.origin.y-padding/4,
                                                  size.width+padding * 1.5,
                                                  size.height+(padding * 1.2))];
            
            _statusLabel.hidden = YES;
        } else {
            
            
            
            bgImage = [[UIImage imageNamed:@"aqua"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
            
            [_messageContentView setFrame:CGRectMake(320 - size.width - padding,
                                                         padding*2,
                                                         size.width + padding ,
                                                         size.height + padding)];
            
            [_bgImageView setFrame:CGRectMake(_messageContentView.frame.origin.x - padding/2,
                                                  _messageContentView.frame.origin.y - padding/4,
                                                  size.width+padding *1.5,
                                                  size.height+(padding * 1.2))];
            
            [_statusLabel setFrame:CGRectMake(_messageContentView.frame.origin.x + _messageContentView.frame.size.width - 60, _messageContentView.frame.origin.y +_messageContentView.frame.size.height+15, 60, 20)];
            
            _statusLabel.text = message.status;
            
        }
        
        _bgImageView.image = bgImage;
        _senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", message.time];
        
        
    }
    else{
        
        _senderAndTimeLabel.text = message.time;
        
        NSInteger padding = 40;
        if ([message.sender isEqualToString:@"you"]) {
            
            
            [_bgImageView setFrame:CGRectMake( _senderAndTimeLabel.center.x +padding,
                                                  _senderAndTimeLabel.frame.size.height + 10,
                                                  50,50)];
            
            [_messageContentView setFrame:CGRectMake(_bgImageView.frame.origin.x, _bgImageView.frame.origin.y +_bgImageView.frame.size.height,size.width +padding,size.height + padding)];
            
            [_statusLabel setFrame:CGRectMake(_messageContentView.frame.origin.x+_messageContentView.frame.size.width - 60,_messageContentView.frame.origin.y + _messageContentView.frame.size.height - 20 , 60, 20)];
            
            _statusLabel.text = message.status;
            
        }
        else{
            
            if (!message.isRead) {
                message.isRead = YES;
                if (_delegate && [_delegate respondsToSelector:@selector(updateMessageStatusReadByUser:)]) {
                    [_delegate updateMessageStatusReadByUser:message];
                }
              
            }
            
            [_bgImageView setFrame:CGRectMake( _senderAndTimeLabel.frame.origin.x +padding,
                                                  _senderAndTimeLabel.frame.size.height + 10,
                                                  50,50)];
            [_messageContentView setFrame:CGRectMake(_bgImageView.frame.origin.x + _bgImageView.frame.size.width + 15
                                                         , _bgImageView.center.y,
                                                         size.width +padding,size.height + padding)];
            _statusLabel.hidden = YES;
        }
        
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:message.attachment options:0];
        UIImage *image = [UIImage imageWithData:imageData];
        _bgImageView.image = image;
        _messageContentView.text = message.message;
        
        
    }


}


@end
