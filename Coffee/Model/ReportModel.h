//
//  reportModel.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/29.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportModel : NSObject

@property (nonatomic, strong) NSString *curveUid;
@property (nonatomic, strong) NSString *curveName;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) NSString *sn;//设备sn码
@property (nonatomic) double rawBeanWeight;
@property (nonatomic) double bakeBeanWeight;
@property (nonatomic) double light;
@property (nonatomic, strong) NSString *curveValueJson;
@property (nonatomic) NSInteger bakeTime;
@property (nonatomic) NSInteger developTime;
@property (nonatomic) float developRate;
@property (nonatomic, strong) NSString *bakerName;
@property (nonatomic, strong) NSString *sharerName;
@property (nonatomic) NSInteger isShare;

@property (nonatomic) NSRange searchRange;//用来改变搜索字体的颜色

@end
