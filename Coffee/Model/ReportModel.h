//
//  reportModel.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/29.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportModel : NSObject

@property (nonatomic) NSInteger curveId;
@property (nonatomic, strong) NSString *curveName;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic) NSInteger rawBeanWeight;
@property (nonatomic) NSInteger bakeBeanWeight;
@property (nonatomic, strong) NSString *outWaterRate;
@property (nonatomic) NSInteger light;
@property (nonatomic, strong) NSString *curveValueJson;
@property (nonatomic) NSInteger bakeTime;
@property (nonatomic) NSInteger developTime;
@property (nonatomic, strong) NSString *developRate;
@property (nonatomic, strong) NSString *bakerName;
@property (nonatomic, strong) NSString *tempBake_event;
@property (nonatomic, strong) NSString *firstBoom_event;
@property (nonatomic, strong) NSString *startTemp;
@property (nonatomic, strong) NSString *endTemp;

@end
