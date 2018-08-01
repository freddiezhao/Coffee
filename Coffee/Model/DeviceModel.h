//
//  DeviceModel.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/1.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceModel : NSObject

@property (nonatomic) NSInteger deviceId;
@property (nonatomic, strong) NSString *deviceMac;
@property (nonatomic, strong) NSString *deviceName;

@end
