//
//  BaseViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //去掉返回键的文字
    //self.navigationController.navigationBar.topItem.title = @"";
}

@end
