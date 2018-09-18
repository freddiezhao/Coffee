//
//  CupModel.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/14.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CupModel : NSObject

@property (nonatomic) NSInteger cupId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger curveId;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) float light;
@property (nonatomic) float bakeDegree;
@property (nonatomic) float dryAndWet;
@property (nonatomic) float flavor;
@property (nonatomic) float aftermath;
@property (nonatomic) float acid;
@property (nonatomic) float taste;
@property (nonatomic) float sweet;
@property (nonatomic) float balance;
@property (nonatomic) float overFeel;
@property (nonatomic) float deveUnfull;
@property (nonatomic) float overDeve;
@property (nonatomic) float bakePaste;
@property (nonatomic) float injure;
@property (nonatomic) float germInjure;
@property (nonatomic) float beanFaceInjure;

@property (nonatomic) float bakeGrade;//优点分
@property (nonatomic) float defectGrade;//缺点分
@property (nonatomic) float grade;//优点减缺点

@end
