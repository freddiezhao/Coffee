//
//  RightFuncController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/16.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "RightFuncController.h"
#import "EventModel.h"
#import "BakeSliderAlertVC.h"

#define WScaleT (667.f / ScreenWidth)
#define HScaleT (375.f / ScreenHeight)

@interface RightFuncController ()

@property (nonatomic, strong) UIView *rightFuncView;
@property (nonatomic, strong) UIButton *dismissBtn;

@property (nonatomic, strong) UIButton *startBake;
@property (nonatomic, strong) UIButton *dehyOver;
@property (nonatomic, strong) UIButton *firstBurst;
@property (nonatomic, strong) UIButton *firstBurstOver;
@property (nonatomic, strong) UIButton *secondBurst;
@property (nonatomic, strong) UIButton *secondBurstOver;
@property (nonatomic, strong) UIButton *bakeOver;
@property (nonatomic, strong) UIButton *fireorwindPower;
@property (nonatomic, strong) UIButton *remark;
@property (nonatomic, strong) UISwitch *curveSwitch;

@end

@implementation RightFuncController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];
    
    _rightFuncView = [self rightFuncView];
    _dismissBtn = [self dismissBtn];
    [self drawRightViewContent];
}


- (UIView *)rightFuncView{
    if (!_rightFuncView) {
        _rightFuncView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth - 224.5 / WScaleT, 0, 224.5 / WScaleT, ScreenHeight)];
        _rightFuncView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:0.96];
        [self.view addSubview:_rightFuncView];
    }
    return _rightFuncView;
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.frame = CGRectMake(0, 0, ScreenWidth - 224.5 / WScaleT, ScreenHeight);
        [_dismissBtn setBackgroundColor:[UIColor clearColor]];
        [_dismissBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_dismissBtn];
    }
    return _dismissBtn;
}

- (void)drawRightViewContent{
    NetWork *net = [NetWork shareNetWork];
    
    _startBake = [[UIButton alloc] initWithFrame:CGRectMake(458/WScaleT,15/HScaleT,90/WScaleT,40/HScaleT)];
    [_startBake setTitle:LocalString(@"烘焙开始") forState:UIControlStateNormal];
    [_startBake.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    if (net.isStartBake) {
        [_startBake setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _startBake.enabled = NO;
    }else{
        [_startBake setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _startBake.enabled = YES;
    }
    [_startBake setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [_startBake setBackgroundColor:[UIColor whiteColor]];
    [_startBake addTarget:self action:@selector(clickStartBake) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startBake];
    
    _dehyOver = [[UIButton alloc] initWithFrame:CGRectMake(563/WScaleT,15/HScaleT,90/WScaleT,40/HScaleT)];
    [_dehyOver setTitle:LocalString(@"脱水结束") forState:UIControlStateNormal];
    [_dehyOver.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    if (net.isStartBake && !net.isDevyOver) {
        [_dehyOver setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _dehyOver.enabled = YES;
    }else{
        [_dehyOver setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _dehyOver.enabled = NO;
    }
    [_dehyOver setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [_dehyOver setBackgroundColor:[UIColor whiteColor]];
    [_dehyOver addTarget:self action:@selector(clickDevyOver) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_dehyOver];
    
    _firstBurst = [[UIButton alloc] initWithFrame:CGRectMake(458/WScaleT,70/HScaleT,90/WScaleT,40/HScaleT)];
    [_firstBurst setTitle:LocalString(@"一爆开始") forState:UIControlStateNormal];
    [_firstBurst.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    if (net.isStartBake && !net.isFirstBurst) {
        [_firstBurst setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _firstBurst.enabled = YES;
    }else{
        [_firstBurst setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _firstBurst.enabled = NO;
    }
    [_firstBurst setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [_firstBurst setBackgroundColor:[UIColor whiteColor]];
    [_firstBurst addTarget:self action:@selector(clickFirstBurst) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_firstBurst];
    
    _firstBurstOver = [[UIButton alloc] initWithFrame:CGRectMake(563/WScaleT,70/HScaleT,90/WScaleT,40/HScaleT)];
    [_firstBurstOver setTitle:LocalString(@"一爆结束") forState:UIControlStateNormal];
    [_firstBurstOver.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    if (net.isStartBake && !net.isFirstBurstOver) {
        [_firstBurstOver setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _firstBurst.enabled = YES;
    }else{
        [_firstBurstOver setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _firstBurst.enabled = NO;
    }
    [_firstBurstOver setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [_firstBurstOver setBackgroundColor:[UIColor whiteColor]];
    [_firstBurstOver addTarget:self action:@selector(clickFirstBurstOver) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_firstBurstOver];
    
    _secondBurst = [[UIButton alloc] initWithFrame:CGRectMake(458/WScaleT,125/HScaleT,90/WScaleT,40/HScaleT)];
    [_secondBurst setTitle:LocalString(@"二爆开始") forState:UIControlStateNormal];
    [_secondBurst.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    if (net.isStartBake && !net.isSecondBurst) {
        [_secondBurst setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _secondBurst.enabled = YES;
    }else{
        [_secondBurst setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _secondBurst.enabled = NO;
    }
    [_secondBurst setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [_secondBurst setBackgroundColor:[UIColor whiteColor]];
    [_secondBurst addTarget:self action:@selector(clickSecondBurst) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_secondBurst];
    
    _secondBurstOver = [[UIButton alloc] initWithFrame:CGRectMake(563/WScaleT,125/HScaleT,90/WScaleT,40/HScaleT)];
    [_secondBurstOver setTitle:LocalString(@"二爆结束") forState:UIControlStateNormal];
    [_secondBurstOver.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    if (net.isStartBake && !net.isSecondBurstOver) {
        [_secondBurstOver setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _secondBurstOver.enabled = YES;
    }else{
        [_secondBurstOver setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _secondBurstOver.enabled = NO;
    }
    [_secondBurstOver setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [_secondBurstOver setBackgroundColor:[UIColor whiteColor]];
    [_secondBurstOver addTarget:self action:@selector(clickSecondBurstOver) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_secondBurstOver];
    
    _bakeOver = [[UIButton alloc] initWithFrame:CGRectMake(458/WScaleT,180/HScaleT,90/WScaleT,40/HScaleT)];
    [_bakeOver setTitle:LocalString(@"烘焙结束") forState:UIControlStateNormal];
    [_bakeOver.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    if (net.isStartBake && !net.isBakeOver) {
        [_bakeOver setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _bakeOver.enabled = YES;
    }else{
        [_bakeOver setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _bakeOver.enabled = NO;
    }
    [_bakeOver setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [_bakeOver setBackgroundColor:[UIColor whiteColor]];
    [_bakeOver addTarget:self action:@selector(clickBakeOver) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_bakeOver];
    
    _fireorwindPower = [[UIButton alloc] initWithFrame:CGRectMake(563/WScaleT,180/HScaleT,90/WScaleT,40/HScaleT)];
    [_fireorwindPower setTitle:LocalString(@"火力/风力") forState:UIControlStateNormal];
    [_fireorwindPower.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    if (net.isStartBake) {
        [_fireorwindPower setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _fireorwindPower.enabled = YES;
    }else{
        [_fireorwindPower setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _fireorwindPower.enabled = NO;
    }
    [_fireorwindPower setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [_fireorwindPower setBackgroundColor:[UIColor whiteColor]];
    [_fireorwindPower addTarget:self action:@selector(fireWindSlide) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_fireorwindPower];
    
    _remark = [[UIButton alloc] initWithFrame:CGRectMake(458/WScaleT,235/HScaleT,90/WScaleT,40/HScaleT)];
    [_remark setTitle:LocalString(@"备注记录") forState:UIControlStateNormal];
    [_remark.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    if (net.isStartBake) {
        [_remark setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    }else{
        [_remark setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
    }
    [_remark setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [_remark setBackgroundColor:[UIColor whiteColor]];
    _remark.enabled = NO;
    [_remark addTarget:self action:@selector(startBake) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_remark];
    
    
    UILabel *curveLabel = [[UILabel alloc] init];
    curveLabel.frame = CGRectMake(472.5/WScaleT,327.5/HScaleT,60/WScaleT,21/HScaleT);
    curveLabel.text = @"参考曲线";
    curveLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    curveLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [self.view addSubview:curveLabel];
    
    _curveSwitch = [[UISwitch alloc] init];
    _curveSwitch.frame = CGRectMake(582/WScaleT,322.5/HScaleT,51/WScaleT,31/HScaleT);
    _curveSwitch.layer.masksToBounds = YES;
    [_curveSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    _curveSwitch.on = _isRelaOn;
    [self.view addSubview:_curveSwitch];
}

#pragma mark - Actions
- (void)clickStartBake{
    NetWork *net = [NetWork shareNetWork];
    [net.myTimer setFireDate:[NSDate distantFuture]];
    net.deviceTimerStatus = 0;
    [net setTimerStatusOn];
    
    net.isStartBake = YES;
    NSArray *statusArray = @[@0,@1,@1,@1,@1,@1,@1,@1,@1];
    [self eventButtonStatusControl:statusArray];
}

- (void)clickDevyOver{
    NetWork *net = [NetWork shareNetWork];
    EventModel *event = [[EventModel alloc] init];
    event.eventId = 1;//类型为1
    event.eventTime = net.timerValue;
    event.eventText = LocalString(@"脱水结束");
    if (net.BeanArr.count > 0) {
        event.eventBeanTemp = [net.BeanArr[net.BeanArr.count - 1] floatValue];
    }else{
        event.eventBeanTemp = 0.0;
    }
    for (EventModel *event in net.eventArray) {
        if (event.eventId == 1) {
            [net.eventArray removeObject:event];
            break;
        }
    }
    [net.eventArray addObject:event];
    
    net.isDevyOver = YES;
    NSArray *statusArray = @[@0,@0,@1,@1,@1,@1,@1,@1,@1];
    [self eventButtonStatusControl:statusArray];

}

- (void)clickFirstBurst{
    NetWork *net = [NetWork shareNetWork];
    net.isDevelop = YES;
    EventModel *event = [[EventModel alloc] init];
    event.eventId = 2;//类型为2
    event.eventTime = net.timerValue;
    event.eventText = LocalString(@"一爆开始");
    if (net.BeanArr.count > 0) {
        event.eventBeanTemp = [net.BeanArr[net.BeanArr.count - 1] floatValue];
    }else{
        event.eventBeanTemp = 0.0;
    }
    for (EventModel *event in net.eventArray) {
        if (event.eventId == 2) {
            [net.eventArray removeObject:event];
            break;
        }
    }
    [net.eventArray addObject:event];
    
    net.isFirstBurst = YES;
    NSArray *statusArray = @[@0,@0,@0,@1,@1,@1,@1,@1,@1];
    [self eventButtonStatusControl:statusArray];

}

- (void)clickFirstBurstOver{
    NetWork *net = [NetWork shareNetWork];
    EventModel *event = [[EventModel alloc] init];
    event.eventId = 3;//类型为3
    event.eventTime = net.timerValue;
    event.eventText = LocalString(@"一爆结束");
    if (net.BeanArr.count > 0) {
        event.eventBeanTemp = [net.BeanArr[net.BeanArr.count - 1] floatValue];
    }else{
        event.eventBeanTemp = 0.0;
    }
    for (EventModel *event in net.eventArray) {
        if (event.eventId == 3) {
            [net.eventArray removeObject:event];
            break;
        }
    }
    [net.eventArray addObject:event];
    
    net.isFirstBurstOver = YES;
    NSArray *statusArray = @[@0,@0,@0,@0,@1,@1,@1,@1,@1];
    [self eventButtonStatusControl:statusArray];
}

- (void)clickSecondBurst{
    NetWork *net = [NetWork shareNetWork];
    net.isDevelop = NO;
    EventModel *event = [[EventModel alloc] init];
    event.eventId = 4;//类型为4
    event.eventTime = net.timerValue;
    event.eventText = LocalString(@"二爆开始");
    if (net.BeanArr.count > 0) {
        event.eventBeanTemp = [net.BeanArr[net.BeanArr.count - 1] floatValue];
    }else{
        event.eventBeanTemp = 0.0;
    }
    for (EventModel *event in net.eventArray) {
        if (event.eventId == 4) {
            [net.eventArray removeObject:event];
            break;
        }
    }
    [net.eventArray addObject:event];
    
    net.isSecondBurst = YES;
    NSArray *statusArray = @[@0,@0,@0,@0,@0,@1,@1,@1,@1];
    [self eventButtonStatusControl:statusArray];

}

- (void)clickSecondBurstOver{
    NetWork *net = [NetWork shareNetWork];
    net.isDevelop = NO;

    EventModel *event = [[EventModel alloc] init];
    event.eventId = 5;//类型为5
    event.eventTime = net.timerValue;
    event.eventText = LocalString(@"二爆结束");
    if (net.BeanArr.count > 0) {
        event.eventBeanTemp = [net.BeanArr[net.BeanArr.count - 1] floatValue];
    }else{
        event.eventBeanTemp = 0.0;
    }
    for (EventModel *event in net.eventArray) {
        if (event.eventId == 5) {
            [net.eventArray removeObject:event];
            break;
        }
    }
    [net.eventArray addObject:event];
    
    net.isSecondBurstOver = YES;
    NSArray *statusArray = @[@0,@0,@0,@0,@0,@0,@1,@1,@1];
    [self eventButtonStatusControl:statusArray];

}

- (void)clickBakeOver{
    NetWork *net = [NetWork shareNetWork];
    net.isDevelop = NO;

    EventModel *event = [[EventModel alloc] init];
    event.eventId = 6;//类型为6
    event.eventTime = net.timerValue;
    event.eventText = LocalString(@"烘焙结束");
    if (net.BeanArr.count > 0) {
        event.eventBeanTemp = [net.BeanArr[net.BeanArr.count - 1] floatValue];
    }else{
        event.eventBeanTemp = 0.0;
    }
    for (EventModel *event in net.eventArray) {
        if (event.eventId == 6) {
            [net.eventArray removeObject:event];
            break;
        }
    }
    [net.eventArray addObject:event];
    
    net.isBakeOver = YES;
    NSArray *statusArray = @[@0,@0,@0,@0,@0,@0,@0,@0,@0];
    [self eventButtonStatusControl:statusArray];

    //保存烘焙报告
    [net showBakeOverAlertAction];
}

- (void)fireWindSlide{
    BakeSliderAlertVC *sliderAlert = [[BakeSliderAlertVC alloc] init];
    sliderAlert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:sliderAlert animated:NO completion:^{
        sliderAlert.WScale_alert = WScaleT;
        NSLog(@"%f",sliderAlert.WScale_alert);
        sliderAlert.HScale_alert = HScaleT;
        [sliderAlert showView];
    }];
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchAction:(UISwitch *)sender{
    if (self.relaSwitch) {
        self.relaSwitch(sender.isOn);
    }
}

//所有按钮的状态控制
- (void)eventButtonStatusControl:(NSArray *)statusArray{
    if ([statusArray[0] boolValue]) {
        [_startBake setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _startBake.enabled = YES;
    }else{
        [_startBake setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _startBake.enabled = NO;
    }
    if ([statusArray[1] boolValue]) {
        [_dehyOver setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _dehyOver.enabled = YES;
    }else{
        [_dehyOver setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _dehyOver.enabled = NO;
    }
    if ([statusArray[2] boolValue]) {
        [_firstBurst setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _firstBurst.enabled = YES;
    }else{
        [_firstBurst setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _firstBurst.enabled = NO;
    }
    if ([statusArray[3] boolValue]) {
        [_firstBurstOver setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _firstBurstOver.enabled = YES;
    }else{
        [_firstBurstOver setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _firstBurstOver.enabled = NO;
    }
    if ([statusArray[4] boolValue]) {
        [_secondBurst setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _secondBurst.enabled = YES;
    }else{
        [_secondBurst setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _secondBurst.enabled = NO;
    }
    if ([statusArray[5] boolValue]) {
        [_secondBurstOver setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _secondBurstOver.enabled = YES;
    }else{
        [_secondBurstOver setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _secondBurstOver.enabled = NO;
    }
    if ([statusArray[6] boolValue]) {
        [_bakeOver setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _bakeOver.enabled = YES;
    }else{
        [_bakeOver setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _bakeOver.enabled = NO;
    }
    if ([statusArray[7] boolValue]) {
        [_fireorwindPower setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _fireorwindPower.enabled = YES;
    }else{
        [_fireorwindPower setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _fireorwindPower.enabled = NO;
    }
    if ([statusArray[8] boolValue]) {
        [_remark setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _remark.enabled = YES;
    }else{
        [_remark setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _remark.enabled = NO;
    }
}

@end
