//
//  BuyDateSelController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BuyDateSelController.h"

@interface BuyDateSelController ()

@property (nonatomic, strong) UIView *dateSelView;
@property (nonatomic, strong) UIDatePicker *dateSelPicker;
@property (nonatomic, strong) UIButton *dismissBtn;

@end

@implementation BuyDateSelController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];

    _dateSelView = [self dateSelView];
    _dismissBtn = [self dismissBtn];
    _dateSelPicker = [self dateSelPicker];
}

#pragma mark - Lazy Load
- (UIView *)dateSelView{
    if (!_dateSelView) {
        _dateSelView = [[UIView alloc] init];
        _dateSelView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor;
        [self.view addSubview:_dateSelView];
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.text = LocalString(@"选择购买日期");
        textLabel.textColor = [UIColor colorWithHexString:@"222222"];
        textLabel.font = [UIFont systemFontOfSize:18.f];
        textLabel.textAlignment = NSTextAlignmentCenter;
        [_dateSelView addSubview:textLabel];
        
        [_dateSelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 257/HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
        
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 25/HScale));
            make.centerX.equalTo(self.dateSelView.mas_centerX);
            make.top.equalTo(self.dateSelView.mas_top).offset(15/HScale);
        }];
    }
    return _dateSelView;
}

- (UIDatePicker *)dateSelPicker{
    if (!_dateSelPicker) {
        _dateSelPicker = [[UIDatePicker alloc] init];
        //[_dateSelPicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_Hans_CN"]];
        [_dateSelPicker setCalendar:[NSCalendar currentCalendar]];
        [_dateSelPicker setDatePickerMode:UIDatePickerModeDate];
        [_dateSelPicker setValue:[UIColor colorWithHexString:@"222222"] forKey:@"textColor"];
        [self.dateSelView addSubview:_dateSelPicker];
        
        [_dateSelPicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 217/HScale));
            make.centerX.equalTo(self.dateSelView.mas_centerX);
            make.top.equalTo(self.dateSelView.mas_top).offset(40/HScale);
        }];
    }
    return _dateSelPicker;
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 257/HScale);
        [_dismissBtn setBackgroundColor:[UIColor clearColor]];
        [_dismissBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_dismissBtn];
    }
    return _dismissBtn;
}

#pragma mark - Actions
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.dateBlock) {
            self.dateBlock(_dateSelPicker.date);
        }
    }];
}

@end
