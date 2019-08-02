//
//  AboutViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/11.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, strong) UITextView *info;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor;
    
    self.navigationItem.title = LocalString(@"关于我们");
    
    _logo = [self logo];
    _info = [self info];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
#pragma mark - Lazyload
- (UIImageView *)logo{
    if (!_logo) {
        _logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_logo"]];
        [self.view addSubview:_logo];
        [_logo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(140/WScale, 112/HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(50/HScale);
        }];
    }
    return _logo;
}

- (UITextView *)info{
    if (!_info) {
        _info = [[UITextView alloc] initWithFrame:CGRectMake(0, 162/HScale, ScreenWidth, ScreenHeight - 162 - getRectNavAndStatusHight)];
        _info.text = LocalString(@"Proin luctus semper lobortis. Nunc efficitur ipsum a nisl euismod porttitor. Phasellus ac imperdiet odio. Proin commodo mattis justo vel gravida. In sollicitudin hendrerit elit eu dapibus. Phasellus ut tortor a dui viverra posuere id id lorem. Nulla et eros efficitur, pharetra felis quis, mollis felis. ");
        _info.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
        _info.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _info.textAlignment = NSTextAlignmentLeft;
        _info.scrollEnabled = YES;
        _info.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _info.editable = NO;
        [self.view addSubview:_info];
    }
    return _info;
}
@end
