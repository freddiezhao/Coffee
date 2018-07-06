//
//  BakeViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BakeViewController.h"
#import "DeviceViewController.h"
#import "BakeCurveViewController.h"
@interface BakeViewController ()

@property (nonatomic,strong) UIButton *connectBtn;

@end

@implementation BakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.connectBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 200, 80)];
    [self.connectBtn setTitle:@"未连接" forState:UIControlStateNormal];
    [self.connectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.connectBtn addTarget:self action:@selector(connectMachine) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.connectBtn];
    
    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    testBtn.frame = CGRectMake(100, 400, 200, 80);
    [testBtn setTitle:@"下一页" forState:UIControlStateNormal];
    [testBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}

- (void)test{
    BakeCurveViewController *bakeCurveVC = [[BakeCurveViewController alloc] init];
    [self presentViewController:bakeCurveVC animated:YES completion:nil];
}

- (void)connectMachine{
    DeviceViewController *deviceVC = [[DeviceViewController alloc] init];
    [self.navigationController pushViewController:deviceVC animated:YES];
}


@end
