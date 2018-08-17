//
//  NetWork.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/28.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
@class DeviceModel;

typedef enum{
    fire,
    cool,
    getTemp,
    getTempCount,
    getCountTemp,
    getPowerStatus,
    getTimerStatus,
    getTimerValue,
    otherMsgType
}MsgType68;

typedef enum{
    readReplyFrame,
    writeReplyFrame,
    commandFrame,
    otherFrameType
}FrameType68;

///@接收到的温度帧数量和查询温度帧数量
static int recvCount = 0;
static int sendCount = 0;

///@读取数据数量版本
static NSInteger tempCountVer = 1000;

@interface NetWork : NSObject <GCDAsyncSocketDelegate>

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_semaphore_t signal;

///@brief 连接上的设备
@property (nonatomic, strong) DeviceModel *connectedDevice;
///@brief Wi-Fi信息
@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *bssid;
@property (nonatomic, strong) NSString *apPwd;

@property (nonatomic, strong) GCDAsyncSocket *mySocket;

///@brief 接收数据
@property (nonatomic, strong) NSMutableArray *recivedData68;

///@brief 消息类型
@property (nonatomic, assign) MsgType68 msg68Type;
///@brief 帧类型
@property (nonatomic, assign) FrameType68 frame68Type;

///@brief 计时器和计时总数
@property (nonatomic, strong) NSTimer *myTimer;
///@brief 用于kvo
@property (nonatomic, strong) NSArray *tempData;

///@brief 豆温数据
@property (nonatomic, strong) NSMutableArray *yVals_Out;
@property (nonatomic, strong) NSMutableArray *yVals_In;
@property (nonatomic, strong) NSMutableArray *yVals_Bean;
@property (nonatomic, strong) NSMutableArray *yVals_Environment;
@property (nonatomic, strong) NSMutableArray *yVals_Diff;

//曲线页面数据全局化
///@brief 每次烘焙添加的豆数组
@property (nonatomic, strong) NSArray *beanArray;
///@brief 发展时间发展率
@property (nonatomic) NSInteger developTime;
@property (nonatomic, strong) NSString *developRate;
///@brief 计时器数据,app中所有计时都以秒为单位
@property (nonatomic, assign) int timerValue;
///@brief 事件数组
@property (nonatomic, strong) NSArray *eventArray;

///@brief 帧计数器
@property (nonatomic, assign) UInt8 frameCount;

///@brief 单例模式
+ (instancetype)shareNetWork;

///@brief 发送数据
- (void)send:(NSMutableArray *)msg withTag:(NSUInteger)tag;

///@brief 连接
- (BOOL)connectToHost:(NSString*)host onPort:(uint16_t)port error:(NSError **)errPtr;

- (void)inquireTimer;
- (void)bakeFire;
@end
