//
//  SettingModel.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingModel : NSObject

@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSString *weightUnit;
@property (nonatomic, strong) NSString *tempUnit;
@property (nonatomic, strong) NSString *bakeChromaReferStandard;
@property (nonatomic, assign) NSInteger timeAxis;
@property (nonatomic, assign) NSInteger tempAxis;
@property (nonatomic, assign) NSInteger tempCurveSmooth;
@property (nonatomic, assign) NSInteger tempRateSmooth;
@property (nonatomic, strong) NSString *curveColorJson;
@property (nonatomic, strong) NSString *language;

@end
