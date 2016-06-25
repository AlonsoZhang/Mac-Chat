//
//  Chatroom.h
//  Mac Chat
//
//  Created by Alonso Zhang on 16/3/21.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Connection.h"

@interface Chatroom : NSWindowController <ConnectionDelegate>

@property (nonatomic, strong, readwrite) NSString *ownname;
@property (nonatomic, strong, readwrite) NSString *rusername;
@property (nonatomic, strong, readwrite) Connection *connection;

@property (weak) IBOutlet NSImageView *remoteimage;
@property (weak) IBOutlet NSTextField *remoteusername;
@property (unsafe_unretained) IBOutlet NSTextView *messageview;
@property (weak) IBOutlet NSTextField *sendtextfield;

- (IBAction)sendfile:(id)sender;
- (IBAction)sendmessage:(id)sender;
- (IBAction)clearmessage:(id)sender;
- (IBAction)sendmsg:(NSButton *)sender;

- (void) changeownname:(NSString*)newname;
- (id)initWithconnection:(Connection *)connection ownname:(NSString *) ownname rusername:(NSString *) rusername;

@end
