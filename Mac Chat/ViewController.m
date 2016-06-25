//
//  ViewController.m
//  Mac Chat
//
//  Created by Alonso Zhang on 16/3/21.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_servername setStringValue:NSFullUserName()];//初始系统用户名
    Chatrooms = [[NSMutableArray alloc]init];//初始动态数组
    server = [[Server alloc] init];
    server.severname=NSFullUserName();
    server.delegate = self;
    [server start];
    
    serverBrowser = [[ServerBrowser alloc] init];
    serverBrowser.severname=NSFullUserName();
    serverBrowser.delegate = self;
    [serverBrowser start];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark -
#pragma mark ServerDelegate
- (void) serverstatus:(NSString *)status
{
    NSImage *image;
    if ([status isEqualToString:@"start"])
    {
        image = [NSImage imageNamed:@"start.png"];
    }
    else
    {
        image = [NSImage imageNamed:@"stop.png"];
    }
    [_myimage setImage:image];
}

- (void) serverFailed
{
    NSLog(@"此用户已登陆");
    NSString *servername = [NSString stringWithFormat:@"%@%d",NSFullUserName(),arc4random()%10];//当前用户的完整用户名+随机一位数
    [_servername setStringValue: servername];
    [self changeusername:self];
}

- (void) handleNewConnectionformNSNetService:(Connection *)connection rusername:(NSString *)rusername
{
    Chatroom *room = [[Chatroom alloc]initWithconnection:connection ownname:_servername.stringValue rusername:rusername];
    if (rusername !=nil)
    {
        [room showWindow:self];
    }
    [Chatrooms addObject:room];
}

#pragma mark -
#pragma mark ServerBrowserDelegate

- (void) updateServerList
{
    [_serverList reloadData];
    NSLog(@"1234%@",serverBrowser.servers);
}

#pragma mark -
#pragma mark TableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSLog(@"%lu",(unsigned long)[serverBrowser.servers count]);
    NSLog(@"%@",serverBrowser.servers);
    return [serverBrowser.servers count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSNetService* rserver = [serverBrowser.servers objectAtIndex:row];
    NSString *text = [rserver name];
    return text;
}

- (IBAction)stop:(id)sender
{
    [server stop];
}

- (IBAction)start:(id)sender
{
    server.severname = _servername.stringValue;
    [server start];
}

- (IBAction)changeusername:(id)sender
{
    if ( [_servername.stringValue isNotEqualTo: server.severname] )
    {
        [serverBrowser stop];
        [server stop];
        [Chatrooms makeObjectsPerformSelector:@selector(changeownname:) withObject:_servername.stringValue ];
        server.severname = _servername.stringValue;
        serverBrowser.severname=_servername.stringValue;
        [server start];
        [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow:1]];
        [serverBrowser start];
    }
}

- (IBAction)serviceTableClickedAction:(id)sender
{
    NSTableView * table = (NSTableView *) sender;
    NSInteger selectedRow = [table selectedRow];
    if (selectedRow >= 0)
    {
        NSNetService * selectedService = [serverBrowser.servers  objectAtIndex:(NSUInteger) selectedRow];
        if ([selectedService.name isNotEqualTo: server.severname])
        {
            BOOL Notfind=YES;
            for (Chatroom *check in Chatrooms)
            {
                if ([check.rusername isEqual:selectedService.name ])
                {
                    [check showWindow:self];
                    Notfind = NO;
                    break;
                }
            }
            if (Notfind)
            {
                Connection* connection = [[Connection alloc] initWithNSNetService:selectedService];
                BOOL succeed = [connection open];
                if ( !succeed )
                {
                    [connection close];
                }
                [self handleNewConnectionformNSNetService:connection rusername:selectedService.name];
            }
        }
    }
}


@end
