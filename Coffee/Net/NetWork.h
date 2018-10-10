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
@class ReportModel;

typedef enum{
    fire,
    coolAndStir,
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

///@brief 接收到的温度帧数量和查询温度帧数量
static int recvCount = 0;
static int sendCount = 0;

///@brief 每个函数重发的次数
static int resendCount = 0;
///@brief 是否获取计时器状态，用来防止多次查询
static BOOL isGetTimerStatus = NO;
static BOOL isGetPowerStatus = NO;
static BOOL isGetFireStatus = NO;

///@brief 读取数据数量版本
static NSInteger tempCountVer = 1000;

@interface NetWork : NSObject <GCDAsyncSocketDelegate>

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_semaphore_t signal;
@property (nonatomic, strong) dispatch_semaphore_t sendSignal;

///@brief 连接上的设备
@property (nonatomic, strong) DeviceModel *connectedDevice;

///@brief Wi-Fi信息
@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *bssid;
@property (nonatomic, strong) NSString *apPwd;
@property (nonatomic, strong) NSNumber *deviceType;//咖啡机机型
@property (nonatomic, strong) NSString *ipAddr;

///@brief TCPSocket
@property (nonatomic, strong) GCDAsyncSocket *mySocket;

///@brief 接收数据
@property (nonatomic, strong) NSMutableArray *recivedData68;

///@brief 消息类型
@property (nonatomic, assign) MsgType68 msg68Type;
///@brief 帧类型
@property (nonatomic, assign) FrameType68 frame68Type;

///@brief 重复读温度延时器
@property (nonatomic, strong) NSTimer *myTimer;

///@brief 用于KVO传参数
@property (nonatomic, strong) NSArray *tempData;

///@brief 温度数据(float)
@property (nonatomic, strong) NSMutableArray *OutArr;
@property (nonatomic, strong) NSMutableArray *InArr;
@property (nonatomic, strong) NSMutableArray *BeanArr;
@property (nonatomic, strong) NSMutableArray *EnvironmentArr;
///@brief 温度数据(chartDataEntry)
@property (nonatomic, strong) NSMutableArray *yVals_Out;
@property (nonatomic, strong) NSMutableArray *yVals_In;
@property (nonatomic, strong) NSMutableArray *yVals_Bean;
@property (nonatomic, strong) NSMutableArray *yVals_Environment;
@property (nonatomic, strong) NSMutableArray *yVals_Diff;

//曲线页面数据全局化
///@brief 每次烘焙添加的豆数组
@property (nonatomic, strong) NSMutableArray *beanArray;
@property (nonatomic) BOOL isCurveOn;
@property (nonatomic, strong) ReportModel *relaCurve;//参考曲线
///@brief 发展时间发展率
@property (nonatomic, assign) BOOL isDevelop;
@property (nonatomic, assign) int developTime;
@property (nonatomic, assign) float developRate;
///@brief 计时器数据,app中所有计时都以秒为单位
@property (nonatomic, assign) int timerValue;
///@brief 计时器状态
@property (nonatomic, assign) int deviceTimerStatus;//0是计时状态，1和2是停止
///@brief 事件数组
@property (nonatomic, strong) NSMutableArray *eventArray;
@property (nonatomic, assign) int eventCount;//用来判断是否新加了event，设置entry的tag
//设备控制
///@brief 电源状态
@property (nonatomic) BOOL powerStatus;
@property (nonatomic) BOOL fireStatus;
@property (nonatomic) BOOL coolStatus;
@property (nonatomic) BOOL stirStatus;

///@brief 帧计数器
@property (nonatomic, assign) UInt8 frameCount;

///@brief 单例模式
+ (instancetype)shareNetWork;

///@brief 发送数据
- (void)send:(NSMutableArray *)msg withTag:(NSUInteger)tag;

///@brief 连接
- (BOOL)connectToHost:(NSString*)host onPort:(uint16_t)port error:(NSError **)errPtr;

//- (void)inquireTimer;
//- (void)bakeFire;
- (void)setFire:(NSNumber *)isFire;
- (void)setPower:(NSNumber *)isPower;
- (void)setColdAndStir:(NSNumber *)isColdAndStir;
- (void)setTimerStatusOn;
- (void)setTimerStatusOff;

- (void)showBakeOverAlertAction;
@end
