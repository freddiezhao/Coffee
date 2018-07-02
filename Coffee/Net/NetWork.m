//
//  NetWork.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/28.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "NetWork.h"


static NetWork *_netWork = nil
;
@implementation NetWork

+ (instancetype)shareNetWork{
    if (_netWork == nil) {
        _netWork = [[self alloc] init];
    }
    return _netWork;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
        if (_netWork == nil) {
            _netWork = [super allocWithZone:zone];
        }
    });
    
    return _netWork;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        dispatch_queue_t queue = dispatch_queue_create("netQueue", DISPATCH_QUEUE_SERIAL);
        _mySocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
    }
    return self;
}

#pragma mark - tcp delegate
- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError *__autoreleasing *)errPtr{
    if (![_mySocket isDisconnected]) {
        NSLog(@"主动断开");
        [_mySocket disconnect];
    }
    return [_mySocket connectToHost:host onPort:port error:errPtr];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接成功");
    [_mySocket readDataWithTimeout:-1 tag:100];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"连接失败");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"接收到消息%@",data);
    NSLog(@"socket成功收到帧, tag: %ld", tag);
    [self setValue:data forKey:@"inputData"];
}

//帧的发送和读取
- (void)send:(NSMutableArray *)msg withTag:(NSUInteger)tag
{
    @synchronized(self) {
        NSLog(@"%D",[self.mySocket isDisconnected]);
        if (![self.mySocket isDisconnected])
        {
            NSUInteger len = msg.count;
            UInt8 sendBuffer[len];
            for (int i = 0; i < len; i++)
            {
                sendBuffer[i] = [[msg objectAtIndex:i] unsignedCharValue];
            }
            
            NSData *sendData = [NSData dataWithBytes:sendBuffer length:len];
            NSLog(@"发送一条帧： %@",sendData);
            
            [self.mySocket writeData:sendData withTimeout:-1 tag:tag];
            
        }
        else
        {
            NSLog(@"Socket未连接");
        }
    }
}




@end
