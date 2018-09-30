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
    self.bakeGrade = self.dryAndWet + self.flavor + self.aftermath + self.acid + self.taste + self.sweet + self.balance + self.overFeel;
    self.defectGrade = self.deveUnfull + self.overDeve + self.bakePaste + self.injure + self.germInjure + self.beanFaceInjure;
    self.grade = self.bakeGrade - self.defectGrade;
}

@end
