//
//  Chatroom.m
//  Mac Chat
//
//  Created by Alonso Zhang on 16/3/21.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import "Chatroom.h"

@interface Chatroom ()

@end

@implementation Chatroom

- (id)initWithconnection:(Connection *)connection ownname:(NSString *) ownname rusername:(NSString *) rusername;
{
    self = [super initWithWindowNibName:@"Chatroom" ];
    if (self)
    {
        connection.delegate=self;
        _connection=connection;
        _ownname   =ownname;
        _rusername =rusername;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [_remoteusername setStringValue:_rusername];
    NSImage *image = [NSImage imageNamed:@"start.png"];
    [_remoteimage setImage:image];
}

- (void) changeownname:(NSString*)newname
{
    _ownname =newname;
}

#pragma mark -
#pragma mark ConnectionDelegate

- (void)connectionwillclose
{
    if (_rusername != nil && [self.window isVisible])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = [NSString stringWithFormat:@"通知:聯繫人－－－%@－－－－已經離線,對話框即將關閉！",_rusername];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    [_connection close];
    [self.window close];
    _rusername=nil;
    _ownname=nil;
    _connection=nil;
    NSLog(@"Chat room close!");
}

- (void) receivedNetworkPacket:(NSDictionary*)packet
{
    NSDateFormatter *dateFormatter;
    dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *msg;
    if ( [packet objectForKey:@"file"] !=nil)
    {
        NSArray*  paths=NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory,NSUserDomainMask,YES);
        NSString*  file = [[paths objectAtIndex:0] stringByAppendingPathComponent:[packet objectForKey:@"message"]];
        _connection.filename=nil;
        if ([[packet objectForKey:@"file"]writeToFile:file atomically:NO])
        {
            NSLog(@"保存成功.");
        }
        msg = [NSString stringWithFormat:@"%@:(%@)\n    成功接受：%@\n", [packet objectForKey:@"from"], [dateFormatter stringFromDate:[NSDate date]],[packet objectForKey:@"message"]];
    }
    else if ( [[packet objectForKey:@"type"] isEqualToString:@"sendfile"])
    {
        _connection.filename=[packet objectForKey:@"message"];
        msg = [NSString stringWithFormat:@"%@:(%@)\n    準備接受：%@\n", [packet objectForKey:@"from"], [dateFormatter stringFromDate:[NSDate date]],[packet objectForKey:@"message"]];
        NSDictionary* filepacket = [NSDictionary dictionaryWithObjectsAndKeys:[packet objectForKey:@"message"], @"message", _ownname, @"from", [packet objectForKey:@"filepath"], @"filepath",@"needfile", @"type",nil];
        [_connection  sendNetworkPacket:filepacket];
    }
    else if ( [[packet objectForKey:@"type"] isEqualToString:@"needfile"])
    {
        msg = [NSString stringWithFormat:@"%@:(%@)\n    請求發送：%@\n", [packet objectForKey:@"from"], [dateFormatter stringFromDate:[NSDate date]],[packet objectForKey:@"message"]];
        NSData* fileToSend = [NSData dataWithContentsOfFile:[packet objectForKey:@"filepath"]];
        NSDictionary* filepacket = [NSDictionary dictionaryWithObjectsAndKeys:[ packet objectForKey:@"message"], @"message", [ packet objectForKey:@"from"], @"from", fileToSend, @"file",nil];
        [_connection  sendNetworkPacket:filepacket];
    }
    else
    {
        msg = [NSString stringWithFormat:@"%@:(%@)\n    %@\n", [packet objectForKey:@"from"], [dateFormatter stringFromDate:[NSDate date]],[packet objectForKey:@"message"]];
    }
    if (_rusername == nil)
    {
        _rusername= [packet objectForKey:@"from"];
    }
    if ([[packet objectForKey:@"from"]isNotEqualTo:@"System send"] && [[packet objectForKey:@"from"]isNotEqualTo:@"System received"])
    {
        [self showWindow:self];
    }
    NSString * currentString = [NSString stringWithFormat:@"%@%@",[_messageview string], msg];
    [_messageview setString:currentString];
    NSRange range = [currentString rangeOfString:msg options:NSBackwardsSearch];
    [_messageview scrollRangeToVisible:range];
}

#pragma mark -
#pragma mark sendmessage or sendfile

- (IBAction)sendfile:(id)sender
{
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    NSString *filepath;
    if ([oPanel runModal] == NSModalResponseOK)
    {
        filepath = [[[oPanel URLs] objectAtIndex:0] path];
        NSString  *filename   =  filepath;
        NSRange   namerrange  = [filename rangeOfString:@"/"];
        while (namerrange .length!=0)
        {
            filename  = [filename substringFromIndex:namerrange .location + namerrange .length];
            namerrange  = [filename rangeOfString:@"/"];
        }
        NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:filename, @"message", _ownname, @"from", filepath, @"filepath",@"sendfile", @"type",nil];
        [_connection  sendNetworkPacket:packet];
    }
}

- (IBAction)sendmessage:(id)sender
{
    NSTextField * textField = (NSTextField *)sender;
    NSString * text = [textField stringValue];
    [textField setStringValue:@""];
    if (text && [text length] > 0)
    {
        NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:text, @"message", _ownname, @"from", nil];
        [self  receivedNetworkPacket:packet];
        [_connection  sendNetworkPacket:packet];
    }
}

- (IBAction)clearmessage:(id)sender
{
    
}

- (IBAction)sendmsg:(NSButton *)sender {
    NSString * text = [self.sendtextfield stringValue];
    [self.sendtextfield setStringValue:@""];
    if (text && [text length] > 0)
    {
        NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:text, @"message", _ownname, @"from", nil];
        [self  receivedNetworkPacket:packet];
        [_connection  sendNetworkPacket:packet];
    }
}
@end