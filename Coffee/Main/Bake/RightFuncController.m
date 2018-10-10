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
        _dismissBtn.frame = CGRectMake(0, 0, (ScreenWidth - 224.5) / WScaleT, ScreenHeight);
        [_dismissBtn setBackgroundColor:[UIColor clearColor]];
        [_dismissBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_dismissBtn];
    }
    return _dismissBtn;
}

- (void)drawRightViewContent{
    UIButton *startBake = [[UIButton alloc] initWithFrame:CGRectMake(458/WScaleT,15/HScaleT,90/WScaleT,40/HScaleT)];
    [startBake setTitle:LocalString(@"烘焙开始") forState:UIControlStateNormal];
    [startBake.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    [startBake setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    [startBake setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [startBake setBackgroundColor:[UIColor whiteColor]];
    [startBake addTarget:self action:@selector(startBake) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBake];
    
    UIButton *dehyOver = [[UIButton alloc] initWithFrame:CGRectMake(563/WScaleT,15/HScaleT,90/WScaleT,40/HScaleT)];
    [dehyOver setTitle:LocalString(@"脱水结束") forState:UIControlStateNormal];
    [dehyOver.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    [dehyOver setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    [dehyOver setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [dehyOver setBackgroundColor:[UIColor whiteColor]];
    [dehyOver addTarget:self action:@selector(devyOver) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dehyOver];
    
    UIButton *firstBurst = [[UIButton alloc] initWithFrame:CGRectMake(458/WScaleT,70/HScaleT,90/WScaleT,40/HScaleT)];
    [firstBurst setTitle:LocalString(@"一爆开始") forState:UIControlStateNormal];
    [firstBurst.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    [firstBurst setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    [firstBurst setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [firstBurst setBackgroundColor:[UIColor whiteColor]];
    [firstBurst addTarget:self action:@selector(firstBurst) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:firstBurst];
    
    UIButton *firstBurstOver = [[UIButton alloc] initWithFrame:CGRectMake(563/WScaleT,70/HScaleT,90/WScaleT,40/HScaleT)];
    [firstBurstOver setTitle:LocalString(@"一爆结束") forState:UIControlStateNormal];
    [firstBurstOver.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    [firstBurstOver setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    [firstBurstOver setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [firstBurstOver setBackgroundColor:[UIColor whiteColor]];
    [firstBurstOver addTarget:self action:@selector(firstBurstOver) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:firstBurstOver];
    
    UIButton *secondBurst = [[UIButton alloc] initWithFrame:CGRectMake(458/WScaleT,125/HScaleT,90/WScaleT,40/HScaleT)];
    [secondBurst setTitle:LocalString(@"二爆开始") forState:UIControlStateNormal];
    [secondBurst.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    [secondBurst setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    [secondBurst setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [secondBurst setBackgroundColor:[UIColor whiteColor]];
    [secondBurst addTarget:self action:@selector(secondBurst) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:secondBurst];
    
    UIButton *secondBurstOver = [[UIButton alloc] initWithFrame:CGRectMake(563/WScaleT,125/HScaleT,90/WScaleT,40/HScaleT)];
    [secondBurstOver setTitle:LocalString(@"二爆结束") forState:UIControlStateNormal];
    [secondBurstOver.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    [secondBurstOver setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    [secondBurstOver setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [secondBurstOver setBackgroundColor:[UIColor whiteColor]];
    [secondBurstOver addTarget:self action:@selector(secondBurstOver) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:secondBurstOver];
    
    UIButton *bakeOver = [[UIButton alloc] initWithFrame:CGRectMake(458/WScaleT,180/HScaleT,90/WScaleT,40/HScaleT)];
    [bakeOver setTitle:LocalString(@"烘焙结束") forState:UIControlStateNormal];
    [bakeOver.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    [bakeOver setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    [bakeOver setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [bakeOver setBackgroundColor:[UIColor whiteColor]];
    [bakeOver addTarget:self action:@selector(bakeOver) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bakeOver];
    
    UIButton *fireorwindPower = [[UIButton alloc] initWithFrame:CGRectMake(563/WScaleT,180/HScaleT,90/WScaleT,40/HScaleT)];
    [fireorwindPower setTitle:LocalString(@"火力/风力") forState:UIControlStateNormal];
    [fireorwindPower.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    [fireorwindPower setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    [fireorwindPower setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [fireorwindPower setBackgroundColor:[UIColor whiteColor]];
    [fireorwindPower addTarget:self action:@selector(fireWindSlide) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fireorwindPower];
    
    UIButton *remark = [[UIButton alloc] initWithFrame:CGRectMake(458/WScaleT,235/HScaleT,90/WScaleT,40/HScaleT)];
    [remark setTitle:LocalString(@"备注记录") forState:UIControlStateNormal];
    [remark.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    [remark setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    [remark setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [remark setBackgroundColor:[UIColor whiteColor]];
    [remark addTarget:self action:@selector(startBake) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:remark];
    
    UIButton *saveCurve = [[UIButton alloc] initWithFrame:CGRectMake(563/WScaleT,235/HScaleT,90/WScaleT,40/HScaleT)];
    [saveCurve setTitle:LocalString(@"保存曲线") forState:UIControlStateNormal];
    [saveCurve.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:15]];
    [saveCurve setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
    [saveCurve setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:20/HScaleT];
    [saveCurve setBackgroundColor:[UIColor whiteColor]];
    [saveCurve addTarget:self action:@selector(saveCurve) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveCurve];
    
    UILabel *curveLabel = [[UILabel alloc] init];
    curveLabel.frame = CGRectMake(472.5/WScaleT,327.5/HScaleT,60/WScaleT,21/HScaleT);
    curveLabel.text = @"参考曲线";
    curveLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    curveLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [self.view addSubview:curveLabel];
    
    UISwitch *curveSwitch = [[UISwitch alloc] init];
    curveSwitch.frame = CGRectMake(582/WScaleT,322.5/HScaleT,51/WScaleT,31/HScaleT);
    curveSwitch.layer.masksToBounds = YES;
    [curveSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:curveSwitch];
}

#pragma mark - Actions
- (void)startBake{
    NetWork *net = [NetWork shareNetWork];
    [net.myTimer setFireDate:[NSDate distantFuture]];
    
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.lBlock = ^{
        [net.myTimer setFireDate:[NSDate date]];
    };
    alert.rBlock = ^{
        net.deviceTimerStatus = 0;
        [net setTimerStatusOn];
        
        EventModel *event = [[EventModel alloc] init];
        event.eventId = 0;//类型为0
        event.eventTime = 0;
        event.eventText = LocalString(@"烘焙开始");
        for (EventModel *event in net.eventArray) {
            if (event.eventId == 0) {
                [net.eventArray removeObject:event];
                break;
            }
        }
        [net.eventArray addObject:event];
        
    };
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:alert animated:NO completion:^{
        alert.WScale_alert = WScaleT;
        NSLog(@"%f",alert.WScale_alert);
        alert.HScale_alert = HScaleT;
        [alert showView];
        alert.titleLabel.text = LocalString(@"提示");
        alert.messageLabel.text = LocalString(@"确认烘焙开始?");
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
    }];
}

- (void)devyOver{
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.lBlock = ^{
    };
    alert.rBlock = ^{
        NetWork *net = [NetWork shareNetWork];
        EventModel *event = [[EventModel alloc] init];
        event.eventId = 2;//类型为2
        event.eventTime = net.timerValue;
        event.eventText = LocalString(@"脱水结束");
        for (EventModel *event in net.eventArray) {
            if (event.eventId == 2) {
                [net.eventArray removeObject:event];
                break;
            }
        }
        [net.eventArray addObject:event];
    };
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:alert animated:NO completion:^{
        alert.WScale_alert = WScaleT;
        NSLog(@"%f",alert.WScale_alert);
        alert.HScale_alert = HScaleT;
        [alert showView];
        alert.titleLabel.text = LocalString(@"提示");
        alert.messageLabel.text = LocalString(@"确认脱水结束?");
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
    }];
}

- (void)firstBurst{
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.lBlock = ^{
    };
    alert.rBlock = ^{
        NetWork *net = [NetWork shareNetWork];
        net.isDevelop = YES;
        EventModel *event = [[EventModel alloc] init];
        event.eventId = 3;//类型为3
        event.eventTime = net.timerValue;
        event.eventText = LocalString(@"一爆开始");
        for (EventModel *event in net.eventArray) {
            if (event.eventId == 3) {
                [net.eventArray removeObject:event];
                break;
            }
        }
        [net.eventArray addObject:event];
    };
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:alert animated:NO completion:^{
        alert.WScale_alert = WScaleT;
        NSLog(@"%f",alert.WScale_alert);
        alert.HScale_alert = HScaleT;
        [alert showView];
        alert.titleLabel.text = LocalString(@"提示");
        alert.messageLabel.text = LocalString(@"确认一爆开始?");
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
    }];
}

- (void)firstBurstOver{
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.lBlock = ^{
    };
    alert.rBlock = ^{
        NetWork *net = [NetWork shareNetWork];
        EventModel *event = [[EventModel alloc] init];
        event.eventId = 4;//类型为4
        event.eventTime = net.timerValue;
        event.eventText = LocalString(@"一爆结束");
        for (EventModel *event in net.eventArray) {
            if (event.eventId == 4) {
                [net.eventArray removeObject:event];
                break;
            }
        }
        [net.eventArray addObject:event];
    };
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:alert animated:NO completion:^{
        alert.WScale_alert = WScaleT;
        NSLog(@"%f",alert.WScale_alert);
        alert.HScale_alert = HScaleT;
        [alert showView];
        alert.titleLabel.text = LocalString(@"提示");
        alert.messageLabel.text = LocalString(@"确认一爆结束?");
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
    }];
}

- (void)secondBurst{
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.lBlock = ^{
    };
    alert.rBlock = ^{
        NetWork *net = [NetWork shareNetWork];
        net.isDevelop = NO;
        EventModel *event = [[EventModel alloc] init];
        event.eventId = 5;//类型为5
        event.eventTime = net.timerValue;
        event.eventText = LocalString(@"二爆开始");
        for (EventModel *event in net.eventArray) {
            if (event.eventId == 5) {
                [net.eventArray removeObject:event];
                break;
            }
        }
        [net.eventArray addObject:event];
    };
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:alert animated:NO completion:^{
        alert.WScale_alert = WScaleT;
        NSLog(@"%f",alert.WScale_alert);
        alert.HScale_alert = HScaleT;
        [alert showView];
        alert.titleLabel.text = LocalString(@"提示");
        alert.messageLabel.text = LocalString(@"确认二爆开始?");
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
    }];
}

- (void)secondBurstOver{
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.lBlock = ^{
    };
    alert.rBlock = ^{
        NetWork *net = [NetWork shareNetWork];
        EventModel *event = [[EventModel alloc] init];
        event.eventId = 6;//类型为6
        event.eventTime = net.timerValue;
        event.eventText = LocalString(@"二爆结束");
        for (EventModel *event in net.eventArray) {
            if (event.eventId == 6) {
                [net.eventArray removeObject:event];
                break;
            }
        }
        [net.eventArray addObject:event];
    };
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:alert animated:NO completion:^{
        alert.WScale_alert = WScaleT;
        NSLog(@"%f",alert.WScale_alert);
        alert.HScale_alert = HScaleT;
        [alert showView];
        alert.titleLabel.text = LocalString(@"提示");
        alert.messageLabel.text = LocalString(@"确认二爆结束?");
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
    }];
}

- (void)bakeOver{
    NetWork *net = [NetWork shareNetWork];
    [net.myTimer setFireDate:[NSDate distantFuture]];
    
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.lBlock = ^{
        [net.myTimer setFireDate:[NSDate date]];
    };
    alert.rBlock = ^{
        [net setTimerStatusOff];
        net.deviceTimerStatus = 2;
        
        net.developRate = 1.0*net.developTime/net.timerValue;

        EventModel *event = [[EventModel alloc] init];
        event.eventId = 7;//类型为7
        event.eventTime = net.timerValue;
        event.eventText = LocalString(@"烘焙结束");
        for (EventModel *event in net.eventArray) {
            if (event.eventId == 7) {
                [net.eventArray removeObject:event];
                break;
            }
        }
        [net.eventArray addObject:event];
    };
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:alert animated:NO completion:^{
        alert.WScale_alert = WScaleT;
        NSLog(@"%f",alert.WScale_alert);
        alert.HScale_alert = HScaleT;
        [alert showView];
        alert.titleLabel.text = LocalString(@"提示");
        alert.messageLabel.text = LocalString(@"确认烘焙结束?");
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
    }];
}

- (void)saveCurve{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NetWork shareNetWork] showBakeOverAlertAction];
}

- (void)fireWindSlide{
    NetWork *net = [NetWork shareNetWork];

    BakeSliderAlertVC *sliderAlert = [[BakeSliderAlertVC alloc] init];
    sliderAlert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:sliderAlert animated:NO completion:^{
        sliderAlert.WScale_alert = WScaleT;
        NSLog(@"%f",sliderAlert.WScale_alert);
        sliderAlert.HScale_alert = HScaleT;
        [sliderAlert showView];
        sliderAlert.sliderBlock = ^(int value) {
            EventModel *event = [[EventModel alloc] init];
            event.eventId = 8;//类型为8
            event.eventTime = net.timerValue;
            event.eventText = [NSString stringWithFormat:@"%@%d",LocalString(@"风力/火力调整为"),value];
            //风力火力调整可能有多次，不需要删除
//            for (EventModel *event in net.eventArray) {
//                if (event.eventId == 8) {
//                    [net.eventArray removeObject:event];
//                    break;
//                }
//            }
            [net.eventArray addObject:event];
        };
    }];
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchAction:(UISwitch *)sender{
    
}

@end
