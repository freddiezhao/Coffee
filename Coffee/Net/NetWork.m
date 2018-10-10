//
//  NetWork.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/28.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "NetWork.h"
#import <Charts/Charts-Swift.h>
#import "BeanModel.h"
#import "FMDB.h"
#import "EventModel.h"
#import "DeviceModel.h"
#import "BakeReportController.h"
#import "MainViewController.h"

///@brife 可判断的数据帧类型数量
#define LEN 8

///@brife 一次最大读取温度
#define maxTempCount 20

static NetWork *_netWork = nil;
static NSInteger gotTempCount = 0;
static NSString *curveUid;

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
        if (!_mySocket) {
            _mySocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
        }
        if (!_recivedData68) {
            _recivedData68 = [[NSMutableArray alloc] init];
        }
        if (!_yVals_Out) {
            _yVals_Out = [[NSMutableArray alloc] init];
        }
        if (!_yVals_In) {
            _yVals_In = [[NSMutableArray alloc] init];
        }
        if (!_yVals_Bean) {
            _yVals_Bean = [[NSMutableArray alloc] init];
        }
        if (!_yVals_Environment) {
            _yVals_Environment = [[NSMutableArray alloc] init];
        }
        if (!_yVals_Diff) {
            _yVals_Diff = [[NSMutableArray alloc] init];
        }
        if (!_OutArr) {
            _OutArr = [[NSMutableArray alloc] init];
        }
        if (!_InArr) {
            _InArr = [[NSMutableArray alloc] init];
        }
        if (!_BeanArr) {
            _BeanArr = [[NSMutableArray alloc] init];
        }
        if (!_EnvironmentArr) {
            _EnvironmentArr = [[NSMutableArray alloc] init];
        }
        _beanArray = [[NSMutableArray alloc] init];
        if (!_eventArray) {
            _eventArray = [[NSMutableArray alloc] init];
        }
        _frameCount = 0;
        _myTimer = [self myTimer];
        _queue = dispatch_queue_create("com.thingcom.queue", DISPATCH_QUEUE_SERIAL);
        if (!_signal) {
            _signal = dispatch_semaphore_create(0);
        }
        if (!_sendSignal) {
            _sendSignal = dispatch_semaphore_create(2);
        }
    }
    return self;
}

#pragma mark - Lazy load
- (NSTimer *)myTimer{
    if (!_myTimer) {
        _myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTemp) userInfo:nil repeats:YES];
        [_myTimer setFireDate:[NSDate distantFuture]];
    }
    return _myTimer;
}

#pragma mark - Tcp Delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接成功");
    
    _frameCount = 0;
    isGetTimerStatus = NO;
    isGetFireStatus = NO;
    isGetPowerStatus = NO;
    sendCount = 0;
    recvCount = 0;
    resendCount = 0;
    tempCountVer = 1000;
    _timerValue = 0;
    [_yVals_In removeAllObjects];
    [_yVals_Out removeAllObjects];
    [_yVals_Bean removeAllObjects];
    [_yVals_Environment removeAllObjects];
    [_yVals_Diff removeAllObjects];
    [_InArr removeAllObjects];
    [_OutArr removeAllObjects];
    [_BeanArr removeAllObjects];
    [_EnvironmentArr removeAllObjects];
    
    [_beanArray removeAllObjects];
    [_eventArray removeAllObjects];
    _isCurveOn = NO;
    _relaCurve = nil;
    _isDevelop = NO;
    _developTime = 0;
    _developRate = 0.0;
    _deviceTimerStatus = 0;
    _eventCount = 0;
    
    _ssid = @"";
    _bssid = @"";
    _apPwd = @"";

    [self inquireTimer];
    
    [_mySocket readDataWithTimeout:-1 tag:1];
    [_mySocket readDataWithTimeout:-1 tag:1];
    [_mySocket readDataWithTimeout:-1 tag:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"连接失败");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject showHudTipStr:LocalString(@"连接已断开")];
    });
    [self setConnectedDevice:nil];
    [_myTimer setFireDate:[NSDate distantFuture]];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"接收到消息%@",data);
    NSLog(@"socket成功收到帧, tag: %ld", tag);
    [self checkOutFrame:data];
    dispatch_semaphore_signal(_sendSignal);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    _frameCount++;
    //NSLog(@"发送了一条帧");
}

#pragma mark - Actions
//tcp connect
- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError *__autoreleasing *)errPtr{
    if (![_mySocket isDisconnected]) {
        NSLog(@"主动断开");
        [_mySocket disconnect];
    }
    return [_mySocket connectToHost:host onPort:port error:errPtr];
}

//帧的发送
- (void)send:(NSMutableArray *)msg withTag:(NSUInteger)tag
{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2.f * 1000 * 1000 * 1000);
    dispatch_semaphore_wait(_sendSignal, time);
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
        if (tag == 100) {
            [self.mySocket writeData:sendData withTimeout:-1 tag:1];
            [_mySocket readDataWithTimeout:-1 tag:1];
            //重发
            if (resendCount > 3) {
                NSLog(@"四次重发没回信息，断开连接");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject showHudTipStr:LocalString(@"wifi断开")];
                    [_myTimer setFireDate:[NSDate distantFuture]];
                });
                if (![_mySocket isDisconnected]) {
                    NSLog(@"主动断开");
                    [_mySocket disconnect];
                }
            }
            resendCount++;
            
        }else if(tag == 101){
            [self.mySocket writeData:sendData withTimeout:-1 tag:2];
            if (sendCount - recvCount == 4) {
                NSLog(@"四秒没回信息，断开连接");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject showHudTipStr:LocalString(@"wifi断开")];
                    [_myTimer setFireDate:[NSDate distantFuture]];
                });
                if (![_mySocket isDisconnected]) {
                    NSLog(@"主动断开");
                    [_mySocket disconnect];
                }
            }
            sendCount++;
        }else if(tag == 102){
            //设置
            [self.mySocket writeData:sendData withTimeout:-1 tag:1];
            [_mySocket readDataWithTimeout:-1 tag:1];
            
            if (resendCount > 3) {
                NSLog(@"四次重发没回信息，断开连接");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject showHudTipStr:LocalString(@"wifi断开")];
                    [_myTimer setFireDate:[NSDate distantFuture]];
                });
                if (![_mySocket isDisconnected]) {
                    NSLog(@"主动断开");
                    [_mySocket disconnect];
                }
            }
            resendCount++;
        }
        
        //[NSThread sleepForTimeInterval:0.6];
        
    }
    else
    {
        NSLog(@"Socket未连接");
    }

//    @synchronized(self) {
//        //NSLog(@"%D",[self.mySocket isDisconnected]);
//        if (![self.mySocket isDisconnected])
//        {
//            NSUInteger len = msg.count;
//            UInt8 sendBuffer[len];
//            for (int i = 0; i < len; i++)
//            {
//                sendBuffer[i] = [[msg objectAtIndex:i] unsignedCharValue];
//            }
//
//            NSData *sendData = [NSData dataWithBytes:sendBuffer length:len];
//            NSLog(@"发送一条帧： %@",sendData);
//            if (tag == 100) {
//                [self.mySocket writeData:sendData withTimeout:-1 tag:1];
//                [_mySocket readDataWithTimeout:-1 tag:1];
//                //重发
//                if (resendCount > 3) {
//                    NSLog(@"四次重发没回信息，断开连接");
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [NSObject showHudTipStr:LocalString(@"wifi断开")];
//                        [_myTimer setFireDate:[NSDate distantFuture]];
//                    });
//                    if (![_mySocket isDisconnected]) {
//                        NSLog(@"主动断开");
//                        [_mySocket disconnect];
//                    }
//                }
//                resendCount++;
//
//            }else if(tag == 101){
//                [self.mySocket writeData:sendData withTimeout:-1 tag:2];
//                if (sendCount - recvCount == 4) {
//                    NSLog(@"四秒没回信息，断开连接");
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [NSObject showHudTipStr:LocalString(@"wifi断开")];
//                        [_myTimer setFireDate:[NSDate distantFuture]];
//                    });
//                    if (![_mySocket isDisconnected]) {
//                        NSLog(@"主动断开");
//                        [_mySocket disconnect];
//                    }
//                }
//                sendCount++;
//            }else if(tag == 102){
//                //设置
//                [self.mySocket writeData:sendData withTimeout:-1 tag:1];
//                [_mySocket readDataWithTimeout:-1 tag:1];
//            }
//
//            [NSThread sleepForTimeInterval:0.6];
//
//        }
//        else
//        {
//            NSLog(@"Socket未连接");
//        }
//    }
}

/**
 *先查询计数器，未开始计时不需要操作
 *暂停或正在计时，则首先查询已存的温度数据数量
 *再判断之前是否有数据已经读取，有读取则从之前断的地方开始继续读
 *之前没有数据，则全部读出来
 */
//查询计时器
- (void)inquireTimer{
    NSMutableArray *getTimer = [[NSMutableArray alloc ] init];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:_frameCount]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x10]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:getTimer]]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:getTimer withTag:100];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(inquireTimer) withObject:nil afterDelay:3.f];
    });
}

//查询温度数量
- (void)inquireTempCount{
    NSMutableArray *getTimer = [[NSMutableArray alloc ] init];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:_frameCount]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x04]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:getTimer]]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:getTimer withTag:100];
    });
}

//查询count量的数据
- (void)inquireTempWithCount:(UInt8)count startPosition:(int)start{
    UInt8 highStart = start / 256;
    UInt8 lowStart = start % 256;
    NSMutableArray *getTimer = [[NSMutableArray alloc ] init];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:_frameCount]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x04]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:highStart]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:lowStart]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:count]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:getTimer]]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:getTimer withTag:100];
    });
}

//先判断之前是否有温度数据，然后多次查询获得所有需要的温度数据
- (void)inquireNeedTempWithLoop:(NSInteger)count tempVersion:(NSInteger)ver{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.5 * 1000 * 1000 * 1000);
    
    if (ver != tempCountVer) {
        [_yVals_Out removeAllObjects];
        [_yVals_In removeAllObjects];
        [_yVals_Bean removeAllObjects];
        [_yVals_Environment removeAllObjects];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = 0; i < count; i += maxTempCount) {
                if (i + maxTempCount < count) {
                    [self inquireTempWithCount:maxTempCount startPosition:i];
                }else if (i != count){
                    [self inquireTempWithCount:count - i startPosition:i];
                }
                sendCount++;
                if (dispatch_semaphore_wait(_signal, DISPATCH_TIME_FOREVER) != 0) {
                    if (sendCount - recvCount >= 3) {
                        if (![_mySocket isDisconnected]) {
                            NSLog(@"主动断开");
                            [_mySocket disconnect];
                        }
                    }
                    i -= maxTempCount;
                }
                
            }
        });
        tempCountVer = ver;
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = (int)[_yVals_Out count]; i < count; i += maxTempCount) {
                if (i + maxTempCount < count) {
                    [self inquireTempWithCount:maxTempCount startPosition:i];
                }else if (i != count){
                    [self inquireTempWithCount:count - i startPosition:i];
                }
                if (dispatch_semaphore_wait(_signal, time) != 0) {//返回非0表示超时，返回0则正常
                    i -= maxTempCount;
                }
            }
        });
        
    }
}

- (void)getTemp{
    [self setTimerValue:_timerValue + 1];
    if (_isDevelop) {
        [self setDevelopTime:_developTime+1];
    }
    NSMutableArray *getTemp = [[NSMutableArray alloc ] init];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:_frameCount]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x02]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:getTemp]]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    
    dispatch_async(_queue, ^{
        [self send:getTemp withTag:101];
        [_mySocket readDataWithTimeout:-1 tag:2];
    });
}

- (void)bakeFire{
    NSMutableArray *bakeFire = [[NSMutableArray alloc ] init];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:_frameCount]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:bakeFire]]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_sync(_queue, ^{
        [self send:bakeFire withTag:100];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(bakeFire) withObject:nil afterDelay:3.f];
    });

}

- (void)bakeColdAndStir{
    NSMutableArray *bakeColdAndStir = [[NSMutableArray alloc ] init];
    [bakeColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [bakeColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [bakeColdAndStir addObject:[NSNumber numberWithUnsignedChar:_frameCount]];
    [bakeColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [bakeColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [bakeColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [bakeColdAndStir addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:bakeColdAndStir]]];
    [bakeColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [bakeColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [bakeColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:bakeColdAndStir withTag:100];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(bakeColdAndStir) withObject:nil afterDelay:3.f];
    });
}

- (void)getTime{
    NSMutableArray *bakeFire = [[NSMutableArray alloc ] init];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:_frameCount]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x11]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:bakeFire]]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [bakeFire addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:bakeFire withTag:100];
    });
}

- (void)inquirePowerStatus{
    NSMutableArray *powerStatus = [[NSMutableArray alloc ] init];
    [powerStatus addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [powerStatus addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [powerStatus addObject:[NSNumber numberWithUnsignedChar:_frameCount]];
    [powerStatus addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [powerStatus addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [powerStatus addObject:[NSNumber numberWithUnsignedChar:0x06]];
    [powerStatus addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:powerStatus]]];
    [powerStatus addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [powerStatus addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [powerStatus addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:powerStatus withTag:100];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(inquirePowerStatus) withObject:nil afterDelay:3.0f];
    });
}

- (void)setFire:(NSNumber *)isFire{
    NSMutableArray *setFire = [[NSMutableArray alloc ] init];
    [setFire addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [setFire addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [setFire addObject:[NSNumber numberWithUnsignedChar:_frameCount]];
    [setFire addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [setFire addObject:[NSNumber numberWithUnsignedChar:0x02]];
    [setFire addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [setFire addObject:isFire];
    [setFire addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:setFire]]];
    [setFire addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [setFire addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [setFire addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:setFire withTag:102];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(setFire:) withObject:isFire afterDelay:3.0f];
    });
}

- (void)setPower:(NSNumber *)isPower{
    NSLog(@"%@",isPower);
    NSMutableArray *setPower = [[NSMutableArray alloc ] init];
    [setPower addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [setPower addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [setPower addObject:[NSNumber numberWithUnsignedChar:_frameCount]];
    [setPower addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [setPower addObject:[NSNumber numberWithUnsignedChar:0x02]];
    [setPower addObject:[NSNumber numberWithUnsignedChar:0x06]];
    [setPower addObject:isPower];
    [setPower addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:setPower]]];
    [setPower addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [setPower addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [setPower addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:setPower withTag:102];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(setPower:) withObject:isPower afterDelay:3.0f];
    });
}

- (void)setColdAndStir:(NSNumber *)isColdAndStir{
    NSLog(@"%@",isColdAndStir);
    NSMutableArray *setColdAndStir = [[NSMutableArray alloc ] init];
    [setColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [setColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [setColdAndStir addObject:[NSNumber numberWithUnsignedChar:_frameCount]];
    [setColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [setColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x02]];
    [setColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [setColdAndStir addObject:isColdAndStir];
    [setColdAndStir addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:setColdAndStir]]];
    [setColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [setColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [setColdAndStir addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:setColdAndStir withTag:102];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(setColdAndStir:) withObject:isColdAndStir afterDelay:3.0f];
    });
}

- (void)setTimerStatusOn{
    NSMutableArray *setTimerStatus = [[NSMutableArray alloc ] init];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:_frameCount]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x02]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x10]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:setTimerStatus]]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:setTimerStatus withTag:102];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(setTimerStatusOn) withObject:nil afterDelay:3.0f];
    });
}

- (void)setTimerStatusOff{
    NSMutableArray *setTimerStatus = [[NSMutableArray alloc ] init];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:_frameCount]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x02]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x10]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x02]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:setTimerStatus]]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [setTimerStatus addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:setTimerStatus withTag:102];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(setTimerStatusOff) withObject:nil afterDelay:3.0f];
    });
}

#pragma mark - Frame68 接收处理
- (void)checkOutFrame:(NSData *)data{
    //把读到的数据复制一份
    NSData *recvBuffer = [NSData dataWithData:data];
    NSUInteger recvLen = [recvBuffer length];
    //NSLog(@"%lu",(unsigned long)recvLen);
    UInt8 *recv = (UInt8 *)[recvBuffer bytes];
    if (recvLen > 1000) {
        return;
    }
    //把接收到的数据存放在recvData数组中
    NSMutableArray *recvData = [[NSMutableArray alloc] init];
    NSUInteger j = 0;
    while (j < recvLen) {
        [recvData addObject:[NSNumber numberWithUnsignedChar:recv[j]]];
        j++;
    }
    [self handle68Message:recvData];
}

- (void)handle68Message:(NSArray *)data
{
    if (![self frameIsRight:data])
    {
        //68帧数据错误
        return;
    }
    if (_recivedData68)
    {
        [_recivedData68 removeAllObjects];
        [_recivedData68 addObjectsFromArray:data];
        self.msg68Type = [self checkOutMsgType:data];
        self.frame68Type = [self checkOutFrameType:data];
        
        if (self.frame68Type == readReplyFrame) {
            if (self.msg68Type == fire) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self];
                });
                resendCount = 0;
                
                if ([_recivedData68[6] unsignedIntegerValue] == 0x00) {
                    [self setFireStatus:NO];
                    NSLog(@"关闭");
                }else if ([_recivedData68[6] unsignedIntegerValue] == 0xFF){
                    [self setFireStatus:YES];
                    NSLog(@"开启");
                }
                if (!isGetFireStatus) {
                    [self bakeColdAndStir];
                }
                isGetFireStatus = YES;
                
                
            }else if (self.msg68Type == coolAndStir){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self];
                });
                resendCount = 0;

                switch ([_recivedData68[6] unsignedIntegerValue]) {
                    case 0:
                    {
                        [self setCoolStatus:NO];
                        [self setStirStatus:NO];
                        NSLog(@"all off");
                    }
                        break;
                        
                    case 1:
                    {
                        [self setCoolStatus:YES];
                        [self setStirStatus:NO];
                        NSLog(@"stir off,cool on");
                    }
                        break;
                        
                    case 2:
                    {
                        [self setCoolStatus:NO];
                        [self setStirStatus:YES];
                        NSLog(@"stir on,cool off");
                    }
                        break;
                        
                    case 3:
                    {
                        [self setCoolStatus:YES];
                        [self setStirStatus:YES];
                        NSLog(@"all on");
                    }
                        break;
                        
                    default:
                        break;
                }
                [_myTimer setFireDate:[NSDate distantFuture]];
                [_myTimer setFireDate:[NSDate date]];
                
            }else if (self.msg68Type == getTemp){
                if (!_yVals_Out) {
                    _yVals_Out = [[NSMutableArray alloc] init];
                }
                if (!_yVals_In) {
                    _yVals_In = [[NSMutableArray alloc] init];
                }
                if (!_yVals_Bean) {
                    _yVals_Bean = [[NSMutableArray alloc] init];
                }
                if (!_yVals_Environment) {
                    _yVals_Environment = [[NSMutableArray alloc] init];
                }
                if (!_yVals_Diff) {
                    _yVals_Diff = [[NSMutableArray alloc] init];
                }
                
                double tempOut = ([data[6] intValue] * 256 + [data[7] intValue]) / 10.0;
                double tempIn = ([data[8] intValue] * 256 + [data[9] intValue]) / 10.0;
                double tempBean = ([data[10] intValue] * 256 + [data[11] intValue]) / 10.0;
                double tempEnvironment = ([data[12] intValue] * 256 + [data[13] intValue]) / 10.0;
                
                //NSLog(@"%f,%f,%f,%f",tempOut,tempIn,tempBean,tempEnvironment);
                
                //保存纯数字而不是曲线数据
                [_OutArr addObject:[NSNumber numberWithDouble:tempOut]];
                [_InArr addObject:[NSNumber numberWithDouble:tempIn]];
                [_BeanArr addObject:[NSNumber numberWithDouble:tempBean]];
                [_EnvironmentArr addObject:[NSNumber numberWithDouble:tempEnvironment]];
                //数组保存在这里防止页面不慎退出后所有数据丢失
                [_yVals_Out addObject:[[ChartDataEntry alloc] initWithX:[_yVals_Out count] y:tempOut]];
                [_yVals_In addObject:[[ChartDataEntry alloc] initWithX:[_yVals_In count] y:tempIn]];
                ChartDataEntry *entry = [[ChartDataEntry alloc] initWithX:[_yVals_Bean count] y:tempBean];
                if (_eventArray.count > _eventCount) {
                    EventModel *event = [_eventArray lastObject];
                    entry.tag = event.eventText;
                    _eventCount = (int)_eventArray.count;
                }
                [_yVals_Bean addObject:entry];
                [_yVals_Environment addObject:[[ChartDataEntry alloc] initWithX:[_yVals_Environment count] y:tempEnvironment]];
                
                
                [self setTempData:_recivedData68];
                
                recvCount++;
                NSLog(@"%d",sendCount);
                NSLog(@"%d",recvCount);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [NSObject showHudTipStr:[NSString stringWithFormat:@"%d,%d",sendCount,recvCount] withTime:0.5];
//                });
                
                if (sendCount != recvCount) {
                    //丢了一帧，重新开始相同计数，连续丢两条才断连
                    recvCount = sendCount;
                }
                
            }else if (self.msg68Type == getTempCount){
                gotTempCount = [_recivedData68[6] unsignedIntegerValue] * 256 + [_recivedData68[7] unsignedIntegerValue];
                NSInteger tempVersion = [_recivedData68[8] unsignedIntegerValue];
                [self inquireNeedTempWithLoop:gotTempCount tempVersion:tempVersion];
            }else if (self.msg68Type == getCountTemp){
                
                NSInteger size = [_recivedData68[3] unsignedIntegerValue] * 256 + [_recivedData68[4] unsignedIntegerValue];
                for (int i = 0; i < (size - 1)/8; i++) {
                    double tempOut = ([data[6 + i * 8] intValue] * 256 + [data[7 + i * 8] intValue]) / 10.0;
                    double tempIn = ([data[8 + i * 8] intValue] * 256 + [data[9 + i * 8] intValue]) / 10.0;
                    double tempBean = ([data[10 + i * 8] intValue] * 256 + [data[11 + i * 8] intValue]) / 10.0;
                    double tempEnvironment = ([data[12 + i * 8] intValue] * 256 + [data[13 + i * 8] intValue]) / 10.0;
                    
                    //数组保存在这里防止页面不慎退出后所有数据丢失
                    [_yVals_Out addObject:[[ChartDataEntry alloc] initWithX:[_yVals_Out count] y:tempOut]];
                    [_yVals_In addObject:[[ChartDataEntry alloc] initWithX:[_yVals_In count] y:tempIn]];
                    [_yVals_Bean addObject:[[ChartDataEntry alloc] initWithX:[_yVals_In count] y:tempBean]];
                    [_yVals_Environment addObject:[[ChartDataEntry alloc] initWithX:[_yVals_Environment count] y:tempEnvironment]];
                }
                
                sendCount = 0;
                gotTempCount -= maxTempCount;
                if (gotTempCount <= 0) {
                    [_myTimer setFireDate:[NSDate date]];
                }
                dispatch_semaphore_signal(_signal);
                
            }else if (self.msg68Type == getTimerStatus){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self];
                });
                resendCount = 0;
                switch ([_recivedData68[6] unsignedIntegerValue]) {
                    case 0:
                    {
                        _deviceTimerStatus = 0;
                        [_myTimer setFireDate:[NSDate date]];
                        //[self inquirePowerStatus];
                        //[self inquireTempCount];
                    }
                        break;
                      
                    case 1:
                    {
                        _deviceTimerStatus = 1;
                        if (!isGetTimerStatus) {
                            [self inquirePowerStatus];
                        }
                        isGetTimerStatus = YES;
                    }
                        break;
                        
                    case 2:
                    {
                        _deviceTimerStatus = 2;
                        if (!isGetTimerStatus) {
                            [self inquirePowerStatus];
                        }
                        isGetTimerStatus = YES;
                    }
                        break;
                    
                    default:
                        break;
                }
            }else if (self.msg68Type == getTimerValue){
                
                int value = [_recivedData68[6] intValue] * 256 + [_recivedData68[7] intValue];
                _timerValue = value;
                
            }else if (self.msg68Type == getPowerStatus){
                resendCount = 0;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self];
                });
                //查询电源状态结果
                if ([_recivedData68[6] intValue] == 0x00) {
                    [self setPowerStatus:NO];
                }else if ([_recivedData68[6] intValue] == 0xFF){
                    [self setPowerStatus:YES];
                }
                if (!isGetPowerStatus) {
                    [self bakeFire];
                }
                isGetPowerStatus = YES;
            }
            
        }else if (self.frame68Type == writeReplyFrame){
            if (self.msg68Type == getTimerStatus) {
                //设置计时器
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self];
                });
                resendCount = 0;
                if (_deviceTimerStatus == 0) {
                    NSLog(@"adssd");
                    [_OutArr removeAllObjects];
                    [_InArr removeAllObjects];
                    [_BeanArr removeAllObjects];
                    [_EnvironmentArr removeAllObjects];

                    [_yVals_In removeAllObjects];
                    [_yVals_Out removeAllObjects];
                    [_yVals_Bean removeAllObjects];
                    [_yVals_Environment removeAllObjects];
                    _timerValue = 0;
                    [_myTimer setFireDate:[NSDate distantFuture]];
                    [_myTimer setFireDate:[NSDate date]];
                }
            }else if (self.msg68Type == getPowerStatus){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self];
                });
                resendCount = 0;
            }else if (self.msg68Type == fire){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self];
                });
                resendCount = 0;
            }else if (self.msg68Type == coolAndStir){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self];
                });
                resendCount = 0;
            }
        }else if (self.frame68Type == commandFrame){
            if (self.msg68Type == getTimerStatus) {
                if ([_recivedData68[6] unsignedIntegerValue] == 0) {
                    [_myTimer setFireDate:[NSDate distantFuture]];
                    [_OutArr removeAllObjects];
                    [_InArr removeAllObjects];
                    [_BeanArr removeAllObjects];
                    [_EnvironmentArr removeAllObjects];
                    
                    [_yVals_In removeAllObjects];
                    [_yVals_Out removeAllObjects];
                    [_yVals_Bean removeAllObjects];
                    [_yVals_Environment removeAllObjects];
                    _timerValue = 0;
                    _eventCount = 0;
                    
                    _deviceTimerStatus = 0;
                    
                    EventModel *event = [[EventModel alloc] init];
                    event.eventId = 0;
                    event.eventTime = 0;
                    event.eventText = LocalString(@"烘焙开始");
                    for (EventModel *event in _eventArray) {
                        if (event.eventId == 0) {
                            [_eventArray removeObject:event];
                            break;
                        }
                    }
                    [_eventArray addObject:event];

                    [_myTimer setFireDate:[NSDate date]];
                }else if ([_recivedData68[6] unsignedIntegerValue] == 1 || [_recivedData68[6] unsignedIntegerValue] == 2){
                    //烘焙结束，保存数据生成报告
                    //[[NSNotificationCenter defaultCenter] postNotificationName:@"bakeCompelete" object:nil userInfo:nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showBakeOverAlertAction];
                    });
                }
            }else if (self.msg68Type == fire) {
                
                if ([_recivedData68[6] unsignedIntegerValue] == 0x00) {
                    [self setFireStatus:NO];
                    NSLog(@"关闭");
                }else if ([_recivedData68[6] unsignedIntegerValue] == 0xFF){
                    [self setFireStatus:YES];
                    NSLog(@"开启");
                }
                
            }else if (self.msg68Type == coolAndStir){
                switch ([_recivedData68[6] unsignedIntegerValue]) {
                    case 0:
                    {
                        [self setCoolStatus:NO];
                        [self setStirStatus:NO];
                        NSLog(@"all off");
                    }
                        break;
                        
                    case 1:
                    {
                        [self setCoolStatus:YES];
                        [self setStirStatus:NO];
                        NSLog(@"stir off,cool on");
                    }
                        break;
                        
                    case 2:
                    {
                        [self setCoolStatus:NO];
                        [self setStirStatus:YES];
                        NSLog(@"stir on,cool off");
                    }
                        break;
                        
                    case 3:
                    {
                        [self setCoolStatus:YES];
                        [self setStirStatus:YES];
                        NSLog(@"all on");
                    }
                        break;
                        
                    default:
                        break;
                }
                [_myTimer setFireDate:[NSDate distantFuture]];
                [_myTimer setFireDate:[NSDate date]];
                
            }else if (self.msg68Type == getPowerStatus){
                if ([_recivedData68[6] intValue] == 0x00) {
                    [self setPowerStatus:NO];
                }else if ([_recivedData68[6] intValue] == 0xFF){
                    [self setPowerStatus:YES];
                }
            }
        }
    }
    
}

-(BOOL)frameIsRight:(NSArray *)data
{
    NSUInteger count = data.count;
    UInt8 front = [data[0] unsignedCharValue];
    UInt8 end1 = [data[count-3] unsignedCharValue];
    UInt8 end2 = [data[count-2] unsignedCharValue];
    UInt8 end3 = [data[count-1] unsignedCharValue];
    
    //判断帧头帧尾
    if (front != 0x68 || end1 != 0x16 || end2 != 0x0D || end3 != 0x0A)
    {
        NSLog(@"帧头帧尾错误");
        return NO;
    }
    //判断cs位
    UInt8 csTemp = 0x00;
    for (int i = 0; i < count - 4; i++)
    {
        csTemp += [data[i] unsignedCharValue];
    }
    if (csTemp != [data[count-4] unsignedCharValue])
    {
        NSLog(@"校验错误");
        return NO;
    }
    return YES;
}

//判断是什么信息
- (MsgType68)checkOutMsgType:(NSArray *)data{
    unsigned char dataType;
    
    unsigned char type[LEN] = {
      0x00,0x01,0x02,0x04,0x05,0x06,0x10,0x11
    };
    
    dataType = [data[5] unsignedIntegerValue];
    //NSLog(@"%d",dataType);
    
    MsgType68 returnVal = otherMsgType;
    
    for (int i = 0; i < LEN; i++) {
        if (dataType == type[i]) {
            switch (i) {
                case 0:
                    returnVal = fire;
                    break;
                    
                case 1:
                    returnVal = coolAndStir;
                    break;
                    
                case 2:
                    returnVal = getTemp;
                    break;
                    
                case 3:
                    returnVal = getTempCount;
                    break;
                    
                case 4:
                    returnVal = getCountTemp;
                    break;
                    
                case 5:
                    returnVal = getPowerStatus;
                    break;
                    
                case 6:
                    returnVal = getTimerStatus;
                    break;
                    
                case 7:
                    returnVal = getTimerValue;
                    break;
                    
                default:
                    returnVal = otherMsgType;
                    break;
            }
        }
    }
    return returnVal;
}

//判断是命令帧还是回复帧
- (FrameType68)checkOutFrameType:(NSArray *)data{
    unsigned char dataType;
    
    unsigned char type[3] = {
        0x80,0x81,0x03
    };
    
    dataType = [data[1] unsignedIntegerValue];
    //NSLog(@"%d",dataType);
    
    FrameType68 returnVal = otherFrameType;
    
    for (int i = 0; i < 3; i++) {
        if (dataType == type[i]) {
            switch (i) {
                case 0:
                returnVal = readReplyFrame;
                break;
                
                case 1:
                returnVal = writeReplyFrame;
                break;
                
                case 2:
                {
                    returnVal = commandFrame;
                }
                break;
                
                default:
                returnVal = otherFrameType;
                break;
            }
        }
    }
    return returnVal;
}

#pragma mark - Global Actions
- (void)showBakeOverAlertAction{
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.rBlock = ^{
        [self getCurveUidByApi];
    };
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [[self getCurrentVC] presentViewController:alert animated:NO completion:^{
        if (ScreenWidth > ScreenHeight) {
            alert.WScale_alert = 667.0 / ScreenWidth;
            alert.HScale_alert = 375.0 / ScreenHeight;
        }else{
            alert.WScale_alert = WScale;
            alert.HScale_alert = HScale;
        }
        [alert showView];
        alert.titleLabel.text = LocalString(@"提示");
        alert.messageLabel.text = LocalString(@"烘焙已结束，是否保存该烘焙曲线");
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
    }];
}

- (void)bakeCompelete{
    DataBase *myDB = [DataBase shareDataBase];
    
    //曲线名字
    NSString *curveName = @"";
    if (_beanArray.count >= 2) {
        curveName = [NSString stringWithFormat:@"拼配豆(%@)",_connectedDevice.deviceName];
    }else if (_beanArray.count == 1){
        BeanModel *bean = _beanArray[0];
        curveName = [NSString stringWithFormat:@"%@(%@)",bean.name,_connectedDevice.deviceName];
    }
    
    //生豆重量
    double totolWeight = 0;
    if (_beanArray) {
        for (BeanModel *bean in _beanArray) {
            totolWeight += bean.weight;
        }
    }
    
    //曲线数据
    NSString *curveValueJson;
    if (self.OutArr && self.InArr && self.BeanArr && self.EnvironmentArr) {
        NSArray *outTArray = [self.OutArr copy];
        NSArray *inTArray = [self.InArr copy];
        NSArray *beanTArray = [self.BeanArr copy];
        NSArray *enTArray = [self.EnvironmentArr copy];
        //NSArray *diffTArray = [self.yVals_Diff copy];
        
        NSDictionary *curveValueDic = @{@"out":outTArray,@"in":inTArray,@"bean":beanTArray,@"environment":enTArray};
        NSData *curveData = [NSJSONSerialization dataWithJSONObject:curveValueDic options:NSJSONWritingPrettyPrinted error:nil];
        curveValueJson = [[NSString alloc] initWithData:curveData encoding:NSUTF8StringEncoding];
    }
    static BOOL isSucc = NO;
    //添加报告并更新数据的事务
    [myDB.queueDB inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        BOOL result = [db executeUpdate:@"INSERT INTO curveInfo (curveName,date,deviceName,sn,rawBeanWeight,bakeBeanWeight,light,bakeTime,developTime,developRate,bakerName,curveValue,shareName,isShare) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)",curveName,[NSDate localStringFromUTCDate:[NSDate date]],_connectedDevice.deviceName,_connectedDevice.sn,[NSNumber numberWithDouble:totolWeight],@0,@0,[NSNumber numberWithInt:_timerValue],[NSNumber numberWithInt:_developTime],[NSNumber numberWithFloat:_developRate],myDB.userName,curveValueJson,@"",@0];
        //test
        //BOOL result = [db executeUpdate:@"INSERT INTO curveInfo (curveName,date,deviceName,rawBeanWeight,bakeBeanWeight,light,bakeTime,developTime,developRate,bakerName,curveValue) VALUES (?,?,?,?,?,?,?,?,?,?,?)",@"",[NSDate localStringFromUTCDate:[NSDate date]],@"",@0,@0,@0,@0,@0,@"",@"",@""];
        if (!result) {
            *rollback = YES;
            [SVProgressHUD dismiss];
            NSLog(@"插入曲线失败");
            [NSObject showHudTipStr:@"插入曲线失败"];
            return;
        }
        //本来是获取最后存储的数据的主键值的，现在用curveUid，不需要了
//        FMResultSet *set = [db executeQuery:@"SELECT last_insert_rowid() FROM curveInfo"];
//        while ([set next]) {
//            curveId = [set intForColumnIndex:0];
//        }
//        NSLog(@"%ld",(long)curveId);
//        [set close];
        
        //插入曲线事件关联
        for (int i = 0; i < _eventArray.count; i++) {
            EventModel *event = _eventArray[i];
            result = [db executeUpdate:@"INSERT INTO curve_event (curveUid,eventId,eventText,eventTime,eventBeanTemp) VALUES (?,?,?,?)",curveUid,[NSNumber numberWithInteger:event.eventId],event.eventText,[NSNumber numberWithInteger:event.eventTime],[NSNumber numberWithDouble:event.eventBeanTemp]];
            if (!result) {
                *rollback = YES;
                [SVProgressHUD dismiss];
                NSLog(@"插入曲线失败，事件信息有误");
                [NSObject showHudTipStr:@"插入曲线失败，事件信息有误"];
                return;
            }
        }
        
        //插入曲线生豆关联
        for (int i = 0; i < _beanArray.count; i++) {
            BeanModel *bean = _beanArray[i];
            result = [db executeUpdate:@"INSERT INTO bean_curve (beanUid,curveUid,beanWeight) VALUES (?,?,?)",bean.beanUid,curveUid,[NSNumber numberWithFloat:bean.weight]];
            if (!result) {
                *rollback = YES;
                [SVProgressHUD dismiss];
                NSLog(@"插入曲线失败，生豆信息有误");
                [NSObject showHudTipStr:@"插入曲线失败，生豆信息有误"];
                return;
            }
        }
        isSucc = YES;
    }];
    
    if (isSucc) {
        _frameCount = 0;
        isGetTimerStatus = NO;
        isGetFireStatus = NO;
        isGetPowerStatus = NO;
        sendCount = 0;
        recvCount = 0;
        resendCount = 0;
        tempCountVer = 1000;
        _timerValue = 0;
        [_yVals_In removeAllObjects];
        [_yVals_Out removeAllObjects];
        [_yVals_Bean removeAllObjects];
        [_yVals_Environment removeAllObjects];
        [_yVals_Diff removeAllObjects];
        [_InArr removeAllObjects];
        [_OutArr removeAllObjects];
        [_BeanArr removeAllObjects];
        [_EnvironmentArr removeAllObjects];
        
        [_beanArray removeAllObjects];
        [_eventArray removeAllObjects];
        _isCurveOn = NO;
        _relaCurve = nil;
        _isDevelop = YES;
        _developTime = 0;
        _developRate = 0.0;
        _deviceTimerStatus = 0;
        _eventCount = 0;
        
        _ssid = @"";
        _bssid = @"";
        _apPwd = @"";
        
        [SVProgressHUD dismiss];
        
        MainViewController *mainVC = [[MainViewController alloc] init];
        [self restoreRootViewController:mainVC];
        mainVC.selectedIndex = 1;
        
        BakeReportController *reportVC = [[BakeReportController alloc] init];
        reportVC.curveUid = curveUid;
        //因为mainVC.selectedViewController是一个自己生成的UINavigationController，所以要获得根vc
        UINavigationController *nav = (UINavigationController *)mainVC.selectedViewController;
        [[nav viewControllers][0].navigationController pushViewController:reportVC animated:YES];
    }
}

- (void)getCurveUidByApi{
    [SVProgressHUD showWithStatus:LocalString(@"生成烘焙报告中")];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roastCurve/id"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSLog(@"success:%@",daetr);
            if ([responseDic objectForKey:@"data"]) {
                NSDictionary *data = [responseDic objectForKey:@"data"];
                curveUid = [data objectForKey:@"curveUid"];
                NSLog(@"%@",curveUid);
                [self bakeCompelete];
            }else{
                [SVProgressHUD dismiss];
                [NSObject showHudTipStr:@"后台出现问题，存储曲线失败"];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
    }];
}

#pragma mark - VC的操作

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    while (currentVC.presentedViewController && ![currentVC.presentedViewController isKindOfClass:[YAlertViewController class]]) {
        currentVC = [self getCurrentVCFrom:currentVC.presentedViewController];
    }
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
//    if ([rootVC presentedViewController]) {
//        // 视图是被presented出来的
//        rootVC = [rootVC presentedViewController];
//    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        
        currentVC = rootVC;
    }
    
    return currentVC;
}

- (void)restoreRootViewController:(UIViewController *)rootViewController {
    
    typedef void (^Animation)(void);
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    
    
    rootViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    Animation animation = ^{
        
        BOOL oldState = [UIView areAnimationsEnabled];
        
        [UIView setAnimationsEnabled:NO];
        
        window.rootViewController = rootViewController;
        
        [UIView setAnimationsEnabled:oldState];
        
    };
    
    
    
    [UIView transitionWithView:window
     
                      duration:0.5f
     
                       options:UIViewAnimationOptionTransitionCrossDissolve
     
                    animations:animation
     
                    completion:nil];
    
}

@end
