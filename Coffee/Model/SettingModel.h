//
//  SettingModel.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingModel : NSObject

@property (nonatomic, strong) NSArray  *events;
@property (nonatomic, strong) NSString *weightUnit;
@property (nonatomic, strong) NSString *tempUnit;
@property (nonatomic, strong) NSString *bakeChromaReferStandard;
@property (nonatomic, strong) NSString *timeAxis;
@property (nonatomic, strong) NSString *tempAxis;
@property (nonatomic, strong) NSNumber *tempCurveSmooth;
@property (nonatomic, strong) NSNumber *tempRateSmooth;
@property (nonatomic, strong) NSString *curveColorJson;
@property (nonatomic, strong) NSString *language;

@end
