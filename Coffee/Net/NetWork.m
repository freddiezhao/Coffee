//
//  NetWork.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/28.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "NetWork.h"
#import <Charts/Charts-Swift.h>

///@brife 可判断的数据帧类型数量
#define LEN 6

static NetWork *_netWork = nil;
static NSInteger gotTempCount = 0;

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
        _frameCount = 0;
    }
    return self;
}

#pragma mark - Tcp Delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接成功");
    [self inquireTimer];
    
    [_mySocket readDataWithTimeout:-1 tag:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"连接失败");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject showHudTipStr:LocalString(@"连接已断开")];
    });
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"接收到消息%@",data);
    NSLog(@"socket成功收到帧, tag: %ld", tag);
    [self checkOutFrame:data];
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
    @synchronized(self) {
        //NSLog(@"%D",[self.mySocket isDisconnected]);
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
                //fire
                [self.mySocket writeData:sendData withTimeout:-1 tag:1];
            }else if(tag == 101){
                [self.mySocket writeData:sendData withTimeout:-1 tag:1];
            }
            else if(tag == 102){
                [self.mySocket writeData:sendData withTimeout:-1 tag:2];
                if (sendCount - recvCount == 4) {
                    NSLog(@"两秒没回信息，断开连接");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NSObject showHudTipStr:LocalString(@"wifi断开")];
                        
                    });
                    if (![_mySocket isDisconnected]) {
                        NSLog(@"主动断开");
                        [_mySocket disconnect];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"tcpDisconnect" object:nil userInfo:nil];
                    }
                }
                sendCount++;
            }
            
            [NSThread sleepForTimeInterval:0.5];
            
        }
        else
        {
            NSLog(@"Socket未连接");
        }
    }
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
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x10]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:getTimer]]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self send:getTimer withTag:100];
    });
}

//查询温度数量
- (void)inquireTempCount{
    NSMutableArray *getTimer = [[NSMutableArray alloc ] init];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x04]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:getTimer]]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self send:getTimer withTag:101];
    });
}

//查询count量的数据
- (void)inquireTempWithCount:(UInt8)count startPosition:(UInt8)start{
    NSMutableArray *getTimer = [[NSMutableArray alloc ] init];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x03]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:start]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:count]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:getTimer]]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [getTimer addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self send:getTimer withTag:101];
    });
}

//先判断之前是否有温度数据，然后多次查询获得所有需要的温度数据
- (void)inquireNeedTempWithLoop:(NSInteger)count tempVersion:(NSInteger)ver{
    if (ver != tempCountVer) {
        [_yVals_Out removeAllObjects];
        [_yVals_In removeAllObjects];
        [_yVals_Bean removeAllObjects];
        [_yVals_Environment removeAllObjects];
        
        for (int i = 0; i < count; i += 126) {
            if (i + 126 < count) {
                [self inquireTempWithCount:0x7e startPosition:i];
            }else if (i != count){
                [self inquireTempWithCount:count - i startPosition:i];
            }
        }
        tempCountVer = ver;
    }else{
        for (int i = (int)[_yVals_Out count]; i < count; i += 126) {
            if (i + 126 < count) {
                [self inquireTempWithCount:0x7e startPosition:i];
            }else if (i != count){
                [self inquireTempWithCount:count - i startPosition:i];
            }
        }
    }
}

#pragma mark - Frame68 接收处理
- (void)checkOutFrame:(NSData *)data{
    //把读到的数据复制一份
    NSData *recvBuffer = [NSData dataWithData:data];
    NSUInteger recvLen = [recvBuffer length];
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
                if ([_recivedData68[6] unsignedIntegerValue] == 0x00) {
                    NSLog(@"关闭");
                }
            }else if (self.msg68Type == cool){
                if ([_recivedData68[6] unsignedIntegerValue] == 0x00) {
                    NSLog(@"关闭");
                }
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
                
                //数组保存在这里防止页面不慎退出后所有数据丢失
                [_yVals_Out addObject:[[ChartDataEntry alloc] initWithX:[_yVals_Out count] y:tempOut]];
                [_yVals_In addObject:[[ChartDataEntry alloc] initWithX:[_yVals_In count] y:tempIn]];
                [_yVals_Bean addObject:[[ChartDataEntry alloc] initWithX:[_yVals_Bean count] y:tempBean]];
                [_yVals_Environment addObject:[[ChartDataEntry alloc] initWithX:[_yVals_Environment count] y:tempEnvironment]];
                
                
                [self setTempData:_recivedData68];
                
                recvCount++;
                NSLog(@"%d",sendCount);
                NSLog(@"%d",recvCount);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject showHudTipStr:[NSString stringWithFormat:@"%d,%d",sendCount,recvCount] withTime:0.5];
                });
                
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
                for (int i = 0; i < size; i++) {
                    double tempOut = ([data[6 + i * 8] intValue] * 256 + [data[7 + i * 8] intValue]) / 10.0;
                    double tempIn = ([data[8 + i * 8] intValue] * 256 + [data[9 + i * 8] intValue]) / 10.0;
                    double tempBean = ([data[10 + i * 8] intValue] * 256 + [data[11 + i * 8] intValue]) / 10.0;
                    double tempEnvironment = ([data[12 + i * 8] intValue] * 256 + [data[13 + i * 8] intValue]) / 10.0;
                    
                    //数组保存在这里防止页面不慎退出后所有数据丢失
                    [_yVals_Out addObject:[[ChartDataEntry alloc] initWithX:[_yVals_Out count] y:tempOut]];
                    [_yVals_In addObject:[[ChartDataEntry alloc] initWithX:[_yVals_In count] y:tempIn]];
                    [_yVals_Bean addObject:[[ChartDataEntry alloc] initWithX:[_yVals_Bean count] y:tempBean]];
                    [_yVals_Environment addObject:[[ChartDataEntry alloc] initWithX:[_yVals_Environment count] y:tempEnvironment]];
                }
                
                //无法判断是否全部温度读完了
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"gotCountTempSucc" object:nil userInfo:nil];
            }else if (self.msg68Type == getTimer){
                switch ([_recivedData68[6] unsignedIntegerValue]) {
                        //暂停计时的时候无法进入曲线页面
                    case 0:
                    case 1:
                        [self inquireTempCount];
                        break;
                        
                    case 2:
                    default:
                        break;
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
      0x00,0x01,0x02,0x04,0x05,0x10
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
                    returnVal = cool;
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
                    returnVal = getTimer;
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
        0x80,0x81,0x01
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
                returnVal = commandFrame;
                break;
                
                default:
                returnVal = otherFrameType;
                break;
            }
        }
    }
    return returnVal;
}

@end
