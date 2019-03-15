//
//  CupModel.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/14.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CupModel.h"

@implementation CupModel

- (void)caculateGrade{
    self.bakeGrade = self.dryAndWet/2 + self.flavor/2 + self.aftermath + self.acid*2 + self.taste*2 + self.sweet*2 + self.balance + self.overFeel;
    self.defectGrade = (self.deveUnfull + self.overDeve + self.bakePaste + self.injure + self.germInjure + self.beanFaceInjure) / 2;
    self.grade = self.bakeGrade - self.defectGrade;
}

@end
