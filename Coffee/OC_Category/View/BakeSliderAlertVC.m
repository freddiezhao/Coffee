//
//  BakeSliderAlertVC.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BakeSliderAlertVC.h"
#import "HeightSlider.h"

@interface BakeSliderAlertVC ()

@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UIButton *dismissBtn;

@end

@implementation BakeSliderAlertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];

    _dismissBtn = [self dismissBtn];
}

#pragma mark - Lazyload
- (UIView *)alertView{
    if (!_alertView) {
        _alertView = [[UIView alloc] init];
        _alertView.frame = CGRectMake(52.5 / _WScale_alert, 172 / _HScale_alert, 340 / _WScale_alert, 111 / _HScale_alert);
        _alertView.center = self.view.center;
        _alertView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        _alertView.layer.cornerRadius = 24.f;
        [self.view addSubview:_alertView];
        
        _mySlider = [[HeightSlider alloc] initWithFrame:CGRectMake(20/_WScale_alert, 80/_HScale_alert, 300/_WScale_alert, 30/_HScale_alert)];
        [self.alertView addSubview:_mySlider];
        _mySlider.minimumValue = 0;
        _mySlider.maximumValue = 10;
        _mySlider.value = 0;
        _mySlider.continuous = YES;
        _mySlider.layer.cornerRadius = 15/2.f/HScale;
        _mySlider.layer.masksToBounds = YES;
        [_mySlider setMaximumTrackTintColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]];
        [_mySlider setMinimumTrackTintColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]];
        //[_mySlider setThumbImage:[UIImage imageNamed:@"img_slider"] forState:UIControlStateNormal];
        [_mySlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.alertView bringSubviewToFront:_mySlider];
        
        _sliderValue = [[UILabel alloc] init];
        _sliderValue.frame = CGRectMake(80/_WScale_alert, 20/_HScale_alert, 180/_WScale_alert, 20/_HScale_alert);
        _sliderValue.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17];
        _sliderValue.textColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:61/255.0 alpha:1];
        _sliderValue.textAlignment = NSTextAlignmentCenter;
        _sliderValue.adjustsFontSizeToFitWidth = YES;
        _sliderValue.text = @"0";
        [self.alertView addSubview:_sliderValue];

    }
    return _alertView;
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        [_dismissBtn setBackgroundColor:[UIColor clearColor]];
        [_dismissBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_dismissBtn];
    }
    return _dismissBtn;
}
#pragma mark - Actions
- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    _sliderValue.text = [NSString stringWithFormat:@"%d",(int)slider.value];
    if (self.sliderBlock) {
        self.sliderBlock((int)slider.value);
    }
}

- (void)showView{
    _alertView = [self alertView];
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
