//
//  Connection.h
//  Mac Chat
//
//  Created by Alonso Zhang on 16/3/21.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

@class Connection;

@protocol ConnectionDelegate <NSObject>
- (void) connectionwillclose;
- (void) receivedNetworkPacket:(NSDictionary *)Packet;
@end

@interface Connection : NSObject <NSNetServiceDelegate,NSStreamDelegate>
{
    int packetBodySize;
    double postsize;
}

@property (nonatomic, strong, readwrite) NSString *filename;
@property (nonatomic, retain) id<ConnectionDelegate> delegate;
@property (nonatomic, strong, readwrite) NSInputStream  *  inputStream;
@property (nonatomic, strong, readwrite) NSOutputStream *  outputStream;
@property (nonatomic, strong, readwrite) NSMutableData  *  inputBuffer;
@property (nonatomic, strong, readwrite) NSMutableData  *  outputBuffer;

- (id)initWithNSNetService:(NSNetService *)netService;
- (id)initWithCFSocketNativeHandle:(CFSocketNativeHandle)nativeSocketHandle;
- (BOOL)open;
- (void)close;
- (void)sendNetworkPacket:(NSDictionary *)packet;

@end
