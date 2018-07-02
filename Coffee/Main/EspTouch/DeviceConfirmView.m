//
//  DeviceConfirmView.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/29.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceConfirmView.h"
#import "DeviceConnectView.h"

@interface DeviceConfirmView ()

@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation DeviceConfirmView

- (void)viewDidLoad {
    [super viewDidLoad];
    _nextButton = [self nextButton];
    [self uiMasonry];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)uiMasonry{
    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.4, 44));
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-100);
    }];
}

#pragma mark - lazy load
- (UIButton *)nextButton{
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_nextButton setTitle:LocalString(@"下一步") forState:UIControlStateNormal];
        [_nextButton setBackgroundColor:[UIColor colorWithHexString:@"99664D"]];
        [_nextButton setButtonStyle1];
        [_nextButton addTarget:self action:@selector(goNextView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_nextButton];
    }
    return _nextButton;
}

#pragma mark - action
- (void)goNextView{
    DeviceConnectView *connectVC = [[DeviceConnectView alloc] init];
    [self.navigationController pushViewController:connectVC animated:YES];
}

@end
