//
//  YAlertViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/14.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "YAlertViewController.h"

@interface YAlertViewController ()

@property (nonatomic, strong) UIView *alertView;

@end

@implementation YAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];
    _alertView = [self alertView];
}

- (UIView *)alertView{
    if (!_alertView) {
        _alertView = [[UIView alloc] init];
        _alertView.frame = CGRectMake(52.5 / WScale, 172 / HScale, 270 / WScale, 203 / HScale);
        _alertView.center = self.view.center;
        _alertView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        _alertView.layer.cornerRadius = 10.f;
        [self.view addSubview:_alertView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(44 / WScale,20 / HScale,182 / WScale,21 / HScale);
        _titleLabel.text = @"添加过程中出现了小问题";
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        _titleLabel.textColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:61/255.0 alpha:1];
        [_alertView addSubview:_titleLabel];
        
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.frame = CGRectMake(16 / WScale,57 / HScale,238 / WScale,42 / HScale);
        _messageLabel.text = @"配置失败，请检测当前网络。请选择同一个Wi-Fi环境，再试一次吧~";
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        _messageLabel.textColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:61/255.0 alpha:1];
        [_alertView addSubview:_messageLabel];
        
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(15 / WScale,129 / HScale,114 / WScale,44 / HScale);
        [_leftBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        [_leftBtn setTitle:LocalString(@"以后再说") forState:UIControlStateNormal];
        [_leftBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [_leftBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        [_leftBtn setButtonStyleWithColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] Width:1 cornerRadius:18.f / HScale];
        [_leftBtn addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:_leftBtn];
        
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(141 / WScale,129 / HScale,114 / WScale,44 / HScale);
        [_rightBtn setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
        [_rightBtn setTitle:LocalString(@"重新添加") forState:UIControlStateNormal];
        [_rightBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [_rightBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        [_rightBtn setButtonStyleWithColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] Width:1 cornerRadius:18.f / HScale];
        [_rightBtn addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:_rightBtn];
    }
    return _alertView;
}

- (void)leftAction{
    if (self.lBlock) {
        self.lBlock();
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)rightAction{
    if (self.rBlock) {
        self.rBlock();
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
