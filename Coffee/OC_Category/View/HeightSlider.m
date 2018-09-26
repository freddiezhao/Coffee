//
//  HeightSlider.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HeightSlider.h"

@implementation HeightSlider

// 控制slider的宽和高，这个方法才是真正的改变slider滑道的高的
- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return CGRectMake(0, 0, CGRectGetWidth(self.frame), 15/HScale);
}

@end
