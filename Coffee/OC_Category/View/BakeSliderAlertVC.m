//
//  BakeSliderAlertVC.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BakeSliderAlertVC.h"
#import "HeightSlider.h"
#import "EventModel.h"

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
        _alertView.frame = CGRectMake(52.5 / _WScale_alert, 137 / _HScale_alert, 340 / _WScale_alert, 180 / _HScale_alert);
        _alertView.center = self.view.center;
        _alertView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        _alertView.layer.cornerRadius = 24.f;
        [self.view addSubview:_alertView];
        
        _mySlider1 = [[HeightSlider alloc] initWithFrame:CGRectMake(20/_WScale_alert, 50/_HScale_alert, 300/_WScale_alert, 30/_HScale_alert)];
        [self.alertView addSubview:_mySlider1];
        _mySlider1.minimumValue = 0;
        _mySlider1.maximumValue = 100;
        _mySlider1.value = [NetWork shareNetWork].fireP * 10;
        _mySlider1.continuous = YES;
        _mySlider1.layer.cornerRadius = 15/2.f/HScale;
        _mySlider1.layer.masksToBounds = YES;
        [_mySlider1 setMaximumTrackTintColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]];
        [_mySlider1 setMinimumTrackTintColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]];
        [_mySlider1 setThumbImage:[UIImage imageNamed:@"img_slider"] forState:UIControlStateNormal];
        [_mySlider1 addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.alertView bringSubviewToFront:_mySlider1];
        
        _sliderValue1 = [[UILabel alloc] init];
        _sliderValue1.frame = CGRectMake(80/_WScale_alert, 20/_HScale_alert, 180/_WScale_alert, 20/_HScale_alert);
        _sliderValue1.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        _sliderValue1.textColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:61/255.0 alpha:1];
        _sliderValue1.textAlignment = NSTextAlignmentCenter;
        _sliderValue1.adjustsFontSizeToFitWidth = YES;
        _sliderValue1.text = [NSString stringWithFormat:@"%@:%.1f",LocalString(@"火力大小"),[NetWork shareNetWork].fireP];
        [self.alertView addSubview:_sliderValue1];
        
        _mySlider2 = [[HeightSlider alloc] initWithFrame:CGRectMake(20/_WScale_alert, 130/_HScale_alert, 300/_WScale_alert, 30/_HScale_alert)];
        [self.alertView addSubview:_mySlider2];
        _mySlider2.minimumValue = 0;
        _mySlider2.maximumValue = 100;
        _mySlider2.value = [NetWork shareNetWork].windP * 10;
        _mySlider2.continuous = YES;
        _mySlider2.layer.cornerRadius = 15/2.f/HScale;
        _mySlider2.layer.masksToBounds = YES;
        [_mySlider2 setMaximumTrackTintColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]];
        [_mySlider2 setMinimumTrackTintColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]];
        [_mySlider2 setThumbImage:[UIImage imageNamed:@"img_slider"] forState:UIControlStateNormal];
        [_mySlider2 addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.alertView bringSubviewToFront:_mySlider2];
        
        _sliderValue2 = [[UILabel alloc] init];
        _sliderValue2.frame = CGRectMake(80/_WScale_alert, 100/_HScale_alert, 180/_WScale_alert, 20/_HScale_alert);
        _sliderValue2.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        _sliderValue2.textColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:61/255.0 alpha:1];
        _sliderValue2.textAlignment = NSTextAlignmentCenter;
        _sliderValue2.adjustsFontSizeToFitWidth = YES;
        _sliderValue2.text = [NSString stringWithFormat:@"%@:%.1f",LocalString(@"风力大小"),[NetWork shareNetWork].windP];
        [self.alertView addSubview:_sliderValue2];


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
    if (slider == _mySlider1) {
        _sliderValue1.text = [NSString stringWithFormat:@"%@:%.1f",LocalString(@"火力大小"),slider.value/10.f];
    }else{
        _sliderValue2.text = [NSString stringWithFormat:@"%@:%.1f",LocalString(@"风力大小"),slider.value/10.f];
    }
}

- (void)showView{
    _alertView = [self alertView];
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:NO completion:nil];
    NetWork *net = [NetWork shareNetWork];
    EventModel *event = [[EventModel alloc] init];
    event.eventId = 8;//类型为8
    event.eventTime = net.timerValue;
    if (net.BeanArr.count > 0) {
        event.eventBeanTemp = [net.BeanArr[net.BeanArr.count - 1] floatValue];
    }else{
        event.eventBeanTemp = 0.0;
    }
    if (net.fireP != _mySlider1.value/10.f && net.windP != _mySlider2.value/10.f) {
        event.eventText = [NSString stringWithFormat:@"%@%.1f,%@%.1f",LocalString(@"火力调整为"),_mySlider1.value/10.f,LocalString(@"风力调整为"),_mySlider2.value/10.f];
        [net.eventArray addObject:event];
        net.fireP = _mySlider1.value/10.f;
        net.windP = _mySlider2.value/10.f;
    }else if (net.fireP == _mySlider1.value/10.f && net.windP != _mySlider2.value/10.f){
        event.eventText = [NSString stringWithFormat:@"%@%.1f",LocalString(@"风力调整为"),_mySlider2.value/10.f];
        [net.eventArray addObject:event];
        net.windP = _mySlider2.value/10.f;
    }else if (net.fireP != _mySlider1.value/10.f && net.windP == _mySlider2.value/10.f){
        event.eventText = [NSString stringWithFormat:@"%@%.1f",LocalString(@"火力调整为"),_mySlider1.value/10.f];
        [net.eventArray addObject:event];
        net.fireP = _mySlider1.value/10.f;
    }
    
}

@end
