//
//  BakeViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BakeViewController.h"
#import "DeviceViewController.h"


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
    [testBtn setTitle:@"test" forState:UIControlStateNormal];
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
    NSArray *array = [[NSArray alloc] initWithObjects:[NSNumber numberWithUnsignedInteger:0x68],[NSNumber numberWithUnsignedInteger:0x00],[NSNumber numberWithUnsignedInteger:0x00],[NSNumber numberWithUnsignedInteger:0x00],[NSNumber numberWithUnsignedInteger:0x01],[NSNumber numberWithUnsignedInteger:0x00],[NSNumber numberWithUnsignedInteger:0x69],[NSNumber numberWithUnsignedInteger:0x16],[NSNumber numberWithUnsignedInteger:0x0D],[NSNumber numberWithUnsignedInteger:0x0A], nil];
    
    [[NetWork shareNetWork] send:[array mutableCopy] withTag:101];
}

- (void)connectMachine{
    DeviceViewController *deviceVC = [[DeviceViewController alloc] init];
    [self.navigationController pushViewController:deviceVC animated:YES];
}


@end
