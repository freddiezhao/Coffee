//
//  DeviceModel.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/1.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HBCoffeeDeviceType) {
    Coffee_HB_M6G = 0,
    Coffee_HB_M6E = 1,
    Coffee_HB_L2 = 2,
    Coffee_PEAK_Edmund = 3,
    Coffee_HB_Another = 4,
};

@interface DeviceModel : NSObject

@property (nonatomic) NSInteger deviceId;
@property (nonatomic, strong) NSString *sn;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) NSString *ipAddress;
@property (nonatomic, strong) NSNumber *deviceType;

@end
