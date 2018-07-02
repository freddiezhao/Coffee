//
//  NetWork.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/28.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface NetWork : NSObject <GCDAsyncSocketDelegate>

///@brief Wi-Fi信息
@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *bssid;
@property (nonatomic, strong) NSString *apPwd;

@property (nonatomic, strong) GCDAsyncSocket *mySocket;

///@brief 单例模式
+ (instancetype)shareNetWork;

///@brief 发送数据
- (void)send:(NSMutableArray *)msg withTag:(NSUInteger)tag;

///@brief 连接
- (BOOL)connectToHost:(NSString*)host onPort:(uint16_t)port error:(NSError **)errPtr;

@end
