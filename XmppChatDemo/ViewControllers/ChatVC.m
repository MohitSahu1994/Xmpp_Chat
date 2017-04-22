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


#define Cell_Identifier @"messageCell"
@interface ChatVC ()<UITableViewDelegate ,UITableViewDataSource,SMMessageDelegate>
@property (nonatomic,retain) IBOutlet UITextField *messageField;
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
    manager._messageDelegate = self;
    self.navigationItem.title = self.chatWithUser;
    
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
    NSDictionary *messageDictionary = (NSDictionary *) [messages objectAtIndex:indexPath.row];
    MessageViewTableCell *cell = (MessageViewTableCell *)[tableView dequeueReusableCellWithIdentifier:Cell_Identifier];
    
    if (cell == nil) {
        cell = [[MessageViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell_Identifier] ;
    }
    
    NSString *sender = [messageDictionary objectForKey:@"sender"];
    NSString *message = [messageDictionary objectForKey:@"msg"];
    NSString *time = [messageDictionary objectForKey:@"time"];
    
   
    CGSize size =  [self heightStringWithEmojis:message fontType:[UIFont boldSystemFontOfSize:13] ForWidth:320 ForMinimumLineSpace:3];
    cell.messageContentView.text = message;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    
    NSUInteger padding = cell.senderAndTimeLabel.frame.size.height + 6;
    UIImage *bgImage = nil;
    
    
    if (![sender isEqualToString:@"you"]) { // left aligned
        
        bgImage = [[UIImage imageNamed:@"orange"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
        
        [cell.messageContentView setFrame:CGRectMake(padding, padding, size.width + padding, size.height+padding)];
        
        [cell.bgImageView setFrame:CGRectMake( cell.messageContentView.frame.origin.x-padding/2,
                                              cell.messageContentView.frame.origin.y-padding/4,
                                              size.width+padding * 1.5,
                                              size.height+(padding * 1.2))];
        
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
    cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", time];

    
    return cell;
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [messages count];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSDictionary *dict = (NSDictionary *)[messages objectAtIndex:indexPath.row];
    NSString *message = [dict objectForKey:@"msg"];
    NSUInteger padding = 20;
    CGSize size =  [self heightStringWithEmojis:message fontType:[UIFont boldSystemFontOfSize:13] ForWidth:320 ForMinimumLineSpace:3];
    
   
    
    CGFloat height = size.height < 90 ? 90 : size.height + padding;
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

- (IBAction)closeChatAction:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];

    
}

#pragma mark-
#pragma mark- SMMessageDelegate Methods
- (void)sendMessage {
    
    NSString *messageStr = self.messageField.text;
    
    if([messageStr length] > 0) {
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:self.chatWithUser];
        [message addChild:body];
        
        [self.xmppStream sendElement:message];
        
        
        self.messageField.text = @"";
        
        NSMutableDictionary *messageDictionary = [[NSMutableDictionary alloc] init];
        [messageDictionary setObject:[NSString getCurrentTime] forKey:@"time"];
        [messageDictionary setObject:messageStr forKey:@"msg"];
        [messageDictionary setObject:@"you" forKey:@"sender"];
        
        [messages addObject:messageDictionary];
        [self.messageTableView reloadData];
        
        
    }
}


-(void)newMessageReceived:(NSDictionary *)messageContent{

    [messages addObject:messageContent];
    [self.messageTableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
