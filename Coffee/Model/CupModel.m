//
//  CupModel.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/14.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CupModel.h"

@implementation CupModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.light = 0.f;
        self.dryAndWet = 5.f;
        self.flavor = 5.f;
        self.aftermath = 5.f;
        self.acid = 5.f;
        self.taste = 5.f;
        self.sweet = 5.f;
        self.balance = 5.f;
        self.overFeel = 5.f;
        self.deveUnfull = 0.f;
        self.overDeve = 0.f;
        self.bakePaste = 0.f;
        self.injure = 0.f;
        self.germInjure = 0.f;
        self.beanFaceInjure = 0.f;

    }
    return self;
}

- (void)caculateGrade{
    self.bakeGrade = self.dryAndWet/2 + self.flavor/2 + self.aftermath + self.acid*2 + self.taste*2 + self.sweet*2 + self.balance + self.overFeel;
    self.defectGrade = (self.deveUnfull + self.overDeve + self.bakePaste + self.injure + self.germInjure + self.beanFaceInjure) / 2;
    self.grade = self.bakeGrade - self.defectGrade;
}

@end
