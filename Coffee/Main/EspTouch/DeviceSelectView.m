//
//  DeviceSelectView.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/29.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceSelectView.h"
#import "DeviceConfirmView.h"

@interface DeviceSelectView ()

@end

@implementation DeviceSelectView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = LocalString(@"烘焙机选择");
    
    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    testBtn.frame = CGRectMake(100, 400, 200, 80);
    [testBtn setTitle:@"烘焙机" forState:UIControlStateNormal];
    [testBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)test{
    DeviceConfirmView *confirmVC = [[DeviceConfirmView alloc] init];
    [self.navigationController pushViewController:confirmVC animated:YES];
}

@end
