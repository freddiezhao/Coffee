//
//  BakeSliderAlertVC.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BakeSliderAlertVC : UIViewController
@property (nonatomic) float WScale_alert;
@property (nonatomic) float HScale_alert;

@property (nonatomic, strong) UISlider *mySlider1;
@property (nonatomic, strong) UILabel *sliderValue1;
@property (nonatomic, strong) UISlider *mySlider2;
@property (nonatomic, strong) UILabel *sliderValue2;

- (void)showView;
@end

NS_ASSUME_NONNULL_END
