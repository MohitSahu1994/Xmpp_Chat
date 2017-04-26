//
//  ChatVC.m
//  XmppChatDemo
//
//  Created by Mohit Sahu on 20/04/17.
//  Copyright © 2017 Craterzone. All rights reserved.
//

#import "ChatVC.h"
#import "AppDelegate.h"
#import "XMPPManager.h"
#import "NSString+Enhancement.h"
#import "MessageViewTableCell.h"
#import <CoreText/CoreText.h>
#import "ImageCaptureVC.h"
#import "MessagePreview.h"
#import "Constants.h"
#import "Message.h"
#import "UserDefaultController.h"

#define Cell_Identifier @"messageCell"
@interface ChatVC ()<UITableViewDelegate ,UITableViewDataSource,SMMessageDelegate ,ImageCaptureDelegate ,MessagePreviewDelegate>




@property (nonatomic,retain) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;
- (IBAction)sendMessageAction:(UIButton *)sender;
- (IBAction)closeChatAction:(UIBarButtonItem *)sender;
@end

@implementation ChatVC{
    NSMutableArray  *messages;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
     XMPPManager *manager = [self manager];
    manager.messageDelegate = self;
   
    
    self.titleLabel.text = self.chatWithUser;
    
    messages = [[NSMutableArray alloc ] init];
    [self.messageField becomeFirstResponder];
       // Do any additional setup after loading the view.
}


-(XMPPManager *)manager{

   return  [XMPPManager sharedInstance];
}
-(XMPPStream *)xmppStream{

    return [[self manager] xmppStream];
}



#pragma mark -
#pragma mark Table view delegates & datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = (Message *) [messages objectAtIndex:indexPath.row];
    MessageViewTableCell *cell = (MessageViewTableCell *)[tableView dequeueReusableCellWithIdentifier:Cell_Identifier];
    
    
    if (cell == nil) {
        cell = [[MessageViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell_Identifier] ;
    }
    
   
    
    CGSize size =  [self heightStringWithEmojis:message.message fontType:[UIFont boldSystemFontOfSize:13] ForWidth:320 ForMinimumLineSpace:3];
    
    if(!message.attachment){
   
    
    cell.messageContentView.text = message.message;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    
    NSUInteger padding = cell.senderAndTimeLabel.frame.size.height + 6;
    UIImage *bgImage = nil;
    
    
    if (![message.sender isEqualToString:@"you"]) { // left aligned
        if (!message.isRead) {
            message.isRead = YES;
            [self updateSenderMessageReadByUser:message];
        }
        
        bgImage = [[UIImage imageNamed:@"orange"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
        
        [cell.messageContentView setFrame:CGRectMake(padding, padding, size.width + padding, size.height+padding)];
        
        [cell.bgImageView setFrame:CGRectMake( cell.messageContentView.frame.origin.x-padding/2,
                                              cell.messageContentView.frame.origin.y-padding/4,
                                              size.width+padding * 1.5,
                                              size.height+(padding * 1.2))];
        [cell.statusLabel setFrame:CGRectMake(cell.messageContentView.frame.origin.x + cell.messageContentView.frame.size.width - 40, cell.messageContentView.frame.origin.y +cell.messageContentView.frame.size.height+15, 40, 20)];
        
        cell.statusLabel.text = message.status;
        
    } else {
        
        bgImage = [[UIImage imageNamed:@"aqua"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
        
        [cell.messageContentView setFrame:CGRectMake(320 - size.width - padding,
                                                     padding*2,
                                                     size.width + padding ,
                                                     size.height + padding)];
        
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2,
                                              cell.messageContentView.frame.origin.y - padding/4,
                                              size.width+padding *1.5,
                                              size.height+(padding * 1.2))];
        
    }
    
    cell.bgImageView.image = bgImage;
    cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", message.time];
        
        
    }
    else{
        
         cell.senderAndTimeLabel.text = message.time;
        
        NSInteger padding = 40;
        if ([message.sender isEqualToString:@"you"]) {
        
    
        [cell.bgImageView setFrame:CGRectMake( cell.senderAndTimeLabel.center.x +padding,
                                              cell.senderAndTimeLabel.frame.size.height + 10,
                                              50,50)];
            
            [cell.messageContentView setFrame:CGRectMake(cell.senderAndTimeLabel.center.x
                                                         , cell.bgImageView.frame.size.height +30,
                                                         size.width +padding,size.height+padding)];
            
            [cell.statusLabel setFrame:CGRectMake(cell.messageContentView.frame.origin.x + cell.messageContentView.frame.size.width - 40, cell.messageContentView.frame.origin.y +cell.messageContentView.frame.size.height+15, 40, 20)];
            
             cell.statusLabel.text = message.status;
            
        }
        else{
            
            if (!message.isRead) {
                message.isRead = YES;
                [self updateSenderMessageReadByUser:message];
            }

            [cell.bgImageView setFrame:CGRectMake( cell.senderAndTimeLabel.frame.origin.x +padding,
                                                  cell.senderAndTimeLabel.frame.size.height + 10,
                                                  50,50)];
            [cell.messageContentView setFrame:CGRectMake(cell.senderAndTimeLabel.center.x
                                                         , cell.bgImageView.frame.size.height +30,
                                                         size.width +padding,size.height + padding)];
        }
        
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:message.attachment options:0];
        UIImage *image = [UIImage imageWithData:imageData];
        cell.bgImageView.image = image;
        cell.messageContentView.text = message.message;
       
        
    }

    return cell;
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [messages count];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    Message *message = (Message *)[messages objectAtIndex:indexPath.row];
    
    NSUInteger padding = 20;
    CGSize size =  [self heightStringWithEmojis:message.message fontType:[UIFont boldSystemFontOfSize:13] ForWidth:320 ForMinimumLineSpace:3];
    
   
    
    CGFloat height = size.height < 130 ? 130 : size.height + padding;
    return height;
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.view endEditing:YES];
    [self.messageField resignFirstResponder];
}

#pragma mark -
#pragma mark Chat delegates

// react to the message received


- (IBAction)sendMessageAction:(UIButton *)sender {
    [self.messageField resignFirstResponder];
    [self sendMessage];
    }


- (IBAction)closeChatAction:(UIButton *)sender {
    
    [[XMPPManager sharedInstance] setMessageDelegate:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cameraButtonAction:(UIButton *)sender {
    
    ImageCaptureVC *imageCaptureVC = [[ImageCaptureVC alloc] initWithNibName:@"ImageCaptureVC" bundle:nil];
    imageCaptureVC.delegate = self;
    [self presentViewController:imageCaptureVC animated:YES completion:nil];
    
}

#pragma mark-
#pragma mark- SMMessageDelegate Methods
- (void)sendMessage {
    
    NSString *messageStr = self.messageField.text;
    
    if([messageStr length] > 0) {
         NSString *messageID=[NSString uuid];
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:self.chatWithUser];
        [message addAttributeWithName:@"id" stringValue:messageID];
        
        [message addChild:body];
        
        [self.xmppStream sendElement:message];
        
        
        self.messageField.text = @"";
        
        NSMutableDictionary *messageDictionary = [[NSMutableDictionary alloc] init];
        [messageDictionary setObject:[NSString getCurrentTime] forKey:@"time"];
        [messageDictionary setObject:messageStr forKey:@"msg"];
        [messageDictionary setObject:@"you" forKey:@"sender"];
        
        Message *newMessage = [self populateMessageFromContent:messageDictionary];
        [messages addObject:newMessage];
        [self.messageTableView reloadData];
        
        
    }
}


-(void)newMessageReceived:(NSDictionary *)messageContent{

    Message *message = [self populateMessageFromContent:messageContent];
    [messages addObject:message];
    [self.messageTableView reloadData];

}

-(Message *)populateMessageFromContent:(NSDictionary *)messageContent{
    NSString *sender = [messageContent objectForKey:@"sender"];
    NSString *message = [messageContent objectForKey:@"msg"];
    NSString *time = [messageContent objectForKey:@"time"];
    NSString *attachment = [messageContent objectForKey:@"attachment"];
    
    
    NSString *messageId = [messageContent objectForKey:@"id"];
    Message *newMessage = [[Message alloc] init];
    newMessage.sender = sender;
    newMessage.time =time;
    newMessage.message = message;
    if (attachment) {
        newMessage.attachment = attachment;
    }
    
    newMessage.isRead = false;
    newMessage.messageID = messageId;

    return newMessage;
}


-(void)updateMessageStateForJID:(NSString *)jid messageId:(NSString *)messageId status:(NSInteger)status{

    NSString *statusString;
    
    switch (status) {
        case 0:
            statusString = @"waiting";
            break;
        case 1:
            statusString = @"send";
            break;

        case 2:
            statusString = @"delivered";
            break;

        case 3:
            statusString = @"read";
            break;
        case 4:
            statusString = @"failed";
            break;
        default:
            break;
    }
    _statusLabel.text = statusString;
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.messageId MATCHS[cd] %@",messageId];
    NSArray *filteredArray = [messages filteredArrayUsingPredicate:predicate];
    Message *newMessage = (Message *)[filteredArray firstObject];
    
    
}




-(void)updateSenderMessageReadByUser:(Message *)message{

    NSXMLElement *receivedelement = [NSXMLElement elementWithName:@"received" xmlns:@"urn:xmpp:receipts"];
    NSString *myJid = [[UserDefaultController sharedInstance] getUserId];
    
    NSXMLElement *messageElement = [NSXMLElement elementWithName:@"message" xmlns:@"jabber:client"];
    [messageElement addAttributeWithName:@"to" stringValue:message.sender];
    [messageElement addAttributeWithName:@"from" stringValue:myJid];
    [receivedelement addAttributeWithName:@"id" stringValue:message.messageID];
    [receivedelement addAttributeWithName:@"read" stringValue:@"true"];
    [messageElement addChild:receivedelement];
    
       [self.xmppStream sendElement:messageElement];
    }


- (CGSize)heightStringWithEmojis:(NSString*)str fontType:(UIFont *)uiFont ForWidth:(CGFloat)width ForMinimumLineSpace:(CGFloat)lineSpace{
    
    // Get text
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), (CFStringRef) str );
    CFIndex stringLength = CFStringGetLength((CFStringRef) attrString);
    
    // Change font
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef) uiFont.fontName, uiFont.pointSize, NULL);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, stringLength), kCTFontAttributeName, ctFont);
    
    // For Line Space
    const CTParagraphStyleSetting styleSettings[] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpace},
    };
    CTParagraphStyleRef style = CTParagraphStyleCreate((const CTParagraphStyleSetting*)styleSettings, 1);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, stringLength), kCTParagraphStyleAttributeName, style);
    
    // Calc the size
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
    CFRange fitRange;
    CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, stringLength), NULL, CGSizeMake(width, 9999), &fitRange);
    
    CFRelease(ctFont);
    
    CFRelease(style);
    
    CFRelease(framesetter);
    CFRelease(attrString);
    
    return frameSize;
    
}





#pragma mark--
#pragma mark-- ImageCaptureDelegate Methods
-(void)capturedImageByUser:(UIImage *)image{
    MessagePreview *messagePreview = [[MessagePreview alloc] initWithNibName:@"MessagePreview" bundle:nil];
    messagePreview.image = image;
    messagePreview.delegate = self;
    [self presentViewController:messagePreview animated:YES completion:nil];

}


#pragma mark--
#pragma mark-- MessagePreviewDelegate Methods

-(void)sendMessageWithImage:(UIImage *)image text:(NSString *)text{
    
    if([text length] > 0)
        
    {
        NSString *messageID=[NSString uuid];
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        
        [body setStringValue:text];
        
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        
        [message addAttributeWithName:@"to" stringValue:self.chatWithUser];
        [message addAttributeWithName:@"id" stringValue:messageID];
        
        [message addChild:body];
        
        
            
            UIGraphicsBeginImageContext(CGSizeMake(60,60));
    
            [image drawInRect: CGRectMake(0, 0, 60, 60)];
            
            UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
           
            
            NSData *dataF = UIImagePNGRepresentation(smallImage);
            NSString *imgStr=[dataF base64EncodedStringWithOptions:0];
            
            NSXMLElement *ImgAttachement = [NSXMLElement elementWithName:@"attachment"];
            [ImgAttachement setStringValue:imgStr];
            [message addChild:ImgAttachement];
            

            
        
        
        [self.xmppStream sendElement:message];
        
        NSMutableDictionary *messageDictionary = [[NSMutableDictionary alloc] init];
        [messageDictionary setObject:[NSString getCurrentTime] forKey:@"time"];
        [messageDictionary setObject:text forKey:@"msg"];
        [messageDictionary setObject:@"you" forKey:@"sender"];
        [messageDictionary setObject:imgStr forKey:@"attachment"];
        
        Message *newMessage = [self populateMessageFromContent:messageDictionary];
        [messages addObject:newMessage];
        [self.messageTableView reloadData];
        
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
