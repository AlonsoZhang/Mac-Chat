//
//  ViewController.h
//  Mac Chat
//
//  Created by Alonso Zhang on 16/3/21.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Server.h"
#import "ServerBrowser.h"
#import "Connection.h"
#import "Chatroom.h"

@interface ViewController : NSViewController<ServerBrowserDelegate,ServerDelegate>
{
    NSMutableArray *Chatrooms;
    ServerBrowser *serverBrowser;
    Server *server;
}

@property (weak) IBOutlet NSImageView *myimage;
@property (weak) IBOutlet NSTextField *servername;
@property (weak) IBOutlet NSTableView *serverList;

- (IBAction)stop:(id)sender;
- (IBAction)start:(id)sender;
- (IBAction)changeusername:(id)sender;
- (IBAction)serviceTableClickedAction:(id)sender;


@end

