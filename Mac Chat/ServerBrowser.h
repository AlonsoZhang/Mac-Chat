//
//  ServerBrowser.h
//  Mac Chat
//
//  Created by Alonso Zhang on 16/3/21.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServerBrowserDelegate;

@protocol ServerBrowserDelegate

- (void)updateServerList;

@end

@interface ServerBrowser : NSObject <NSNetServiceBrowserDelegate>
{
    NSNetServiceBrowser *       netServiceBrowser;
}

@property(nonatomic, retain)    NSString *severname;
@property(nonatomic, readonly)  NSMutableArray* servers;
@property(nonatomic, retain)    id<ServerBrowserDelegate> delegate;

// Start browsing for Bonjour services
- (BOOL)start;

// Stop everything
- (void)stop;

@end