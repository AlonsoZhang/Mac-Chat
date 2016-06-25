//
//  ServerBrowser.m
//  Mac Chat
//
//  Created by Alonso Zhang on 16/3/21.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import "ServerBrowser.h"

@implementation ServerBrowser

// Initialize
- (id) init
{
    self = [super init];
    if (self)
    {
        _servers = [[NSMutableArray alloc] init];
    }
    return self;
}

// Cleanup
- (void) dealloc
{
    if ( _servers != nil )
    {
        _servers = nil;
    }
    self.delegate = nil;
}

// Start browsing for servers
- (BOOL) start
{
    // Restarting?
    if ( netServiceBrowser != nil )
    {
        [self stop];
    }
    netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    if( !netServiceBrowser )
    {
        return NO;
    }
    netServiceBrowser.delegate = self;
    [netServiceBrowser searchForServicesOfType:@"_chatty._tcp." inDomain:@""];
    return YES;
}

// Terminate current service browser and clean up
- (void) stop
{
    if ( netServiceBrowser == nil )
    {
        return;
    }
    [netServiceBrowser stop];
    netServiceBrowser = nil;
    [_servers removeAllObjects];
}

#pragma mark -
#pragma mark NSNetServiceBrowser Delegate Method Implementations

// New service was found
- (void) netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
            didFindService:(NSNetService *)netService
                moreComing:(BOOL)moreServicesComing
{
    // Make sure that we don't have such service already (why would this happen? not sure)
    if ( ! [_servers containsObject:netService] && [netService.name isNotEqualTo:_severname])
    {
        // Add it to our list
        [_servers addObject:netService];
    }
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing )
    {
        return;
    }
    [_delegate updateServerList];
}

// Service was removed
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
    // Remove from list
    [_servers removeObject:netService];
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing )
    {
        return;
    }
    [_delegate updateServerList];
}

@end
