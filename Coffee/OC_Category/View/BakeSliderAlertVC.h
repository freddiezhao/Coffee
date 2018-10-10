//
//  BakeSliderAlertVC.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^sliderBlock)(int value);

NS_ASSUME_NONNULL_BEGIN

@interface BakeSliderAlertVC : UIViewController
@property (nonatomic) float WScale_alert;
@property (nonatomic) float HScale_alert;

@property (nonatomic, strong) UISlider *mySlider;
@property (nonatomic, strong) UILabel *sliderValue;
@property (nonatomic) sliderBlock sliderBlock;

- (void)showView;
@end

NS_ASSUME_NONNULL_END
