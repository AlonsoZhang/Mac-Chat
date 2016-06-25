//
//  Server.m
//  Mac Chat
//
//  Created by Alonso Zhang on 16/3/21.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import "Server.h"
#include <netinet/in.h>
#include <unistd.h>
#include <CFNetwork/CFSocketStream.h>

@implementation Server

#pragma mark -
#pragma mark Lifecycle

// Cleanup
- (void) dealloc
{
    self->netService = nil;
}

// Create server and announce it
- (BOOL) start
{
    // Start the socket server
    BOOL succeed = [self createServer];
    if ( !succeed )
    {
        return NO;
    }
    // Announce the server via Bonjour
    succeed = [self publishService];
    if ( !succeed ) {
        [self terminateServer];
        return NO;
    }
    return YES;
}

// Close everything
- (void) stop
{
    [self terminateServer];
    [self unpublishService];
}

#pragma mark -
#pragma mark  Callbacks
// Handle new connections
- (void) handleNewNativeSocket:(CFSocketNativeHandle)nativeSocketHandle
{
    Connection *connection = [[Connection alloc] initWithCFSocketNativeHandle:nativeSocketHandle];
    // In case of errors, close native socket handle
    if ( connection == nil )
    {
        close(nativeSocketHandle);
        return;
    }
    // finish connecting
    BOOL succeed = [connection open];
    if ( !succeed )
    {
        [connection close];
        return;
    }
    // Pass this on to our delegate
    [_delegate handleNewConnectionformNSNetService: connection rusername:nil];
}

// This function will be used as a callback while creating our listening socket via 'CFSocketCreate'
static void serverAcceptCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    // We can only process "connection accepted" calls here
    if ( type != kCFSocketAcceptCallBack )
    {
        return;
    }
    // for an AcceptCallBack, the data parameter is a pointer to a CFSocketNativeHandle
    CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
    Server *server = (__bridge Server *)info;
    [server handleNewNativeSocket:nativeSocketHandle];
}

#pragma mark -
#pragma mark  Sockets and streams
- (BOOL) createServer
{
    CFSocketContext socketCtxt = {0, (__bridge void *) self, NULL, NULL, NULL};
    listeningSocket = CFSocketCreate(kCFAllocatorDefault, AF_INET,  SOCK_STREAM, 0, kCFSocketAcceptCallBack,
                                     (CFSocketCallBack)&serverAcceptCallback, &socketCtxt);
    static const int yes = 1;
    (void) setsockopt(CFSocketGetNative(listeningSocket), SOL_SOCKET, SO_REUSEADDR, (const void *) &yes, sizeof(yes));
    // Set up the IPv4 listening socket; port is 0, which will cause the kernel to choose a port for us.
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(0);
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    CFSocketSetAddress(listeningSocket, (__bridge CFDataRef) [NSData dataWithBytes:&addr4 length:sizeof(addr4)]);
    // Now that the IPv4 binding was successful, we get the port number to check.
    NSData *addr = (__bridge_transfer NSData *)CFSocketCopyAddress(listeningSocket);
    assert([addr length] == sizeof(struct sockaddr_in));
    self->port = ntohs(((const struct sockaddr_in *)[addr bytes])->sin_port);
    // Set up the run loop sources for the sockets.
    CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, listeningSocket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source4, kCFRunLoopCommonModes);
    CFRelease(source4);
    return YES;
}

- (void) terminateServer
{
    if ( listeningSocket != nil )
    {
        CFSocketInvalidate(listeningSocket);
        CFRelease(listeningSocket);
        listeningSocket = nil;
    }
}

#pragma mark -
#pragma mark Bonjour

- (BOOL) publishService
{
    // come up with a name for our chat room
    if (_severname ==NULL)
    {
        NSString* chatRoomName = [NSString stringWithFormat:@"%@", NSFullUserName()];
        _severname=NSFullUserName();
        netService = [[NSNetService alloc] initWithDomain:@"" type:@"_chatty._tcp." name:chatRoomName port:port];
    }
    else
    {
        NSString* chatRoomName = [NSString stringWithFormat:@"%@", _severname];
        netService = [[NSNetService alloc] initWithDomain:@"" type:@"_chatty._tcp." name:chatRoomName port:port];
    }
    // create new instance of netService
    if (netService == nil)
        return NO;
    // Add service to current run loop
    [netService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    // NetService will let us know about what's happening via delegate methods
    [netService setDelegate:self];
    // Publish the service
    [netService publish];
    return YES;
}


- (void) unpublishService
{
    if ( netService )
    {
        [netService stop];
        [netService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        netService = nil;
    }
}


#pragma mark -
#pragma mark NSNetService Delegate Method Implementations

// Delegate method, called by NSNetService in case service publishing fails for whatever reason
- (void) netService:(NSNetService*)sender didNotPublish:(NSDictionary*)errorDict
{
    if ( sender != netService )
    {
        return;
    }
    // Stop socket server
    [self terminateServer];
    // Stop Bonjour
    [self unpublishService];
    // Let delegate know about failure
    [_delegate serverFailed];
}

- (void) netServiceDidPublish:(NSNetService *)sender
{
    NSLog(@" >> netServiceDidPublish: %@", [sender name]);
    [_delegate serverstatus:@"start"];
}

- (void) netServiceDidStop:(NSNetService *)sender
{
    NSLog(@" >> netServiceDidStop: %@", [sender name]);
    [_delegate serverstatus:@"stop"];
}

@end