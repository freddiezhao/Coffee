//
//  LeftFuncController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/16.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "LeftFuncController.h"

#define WScaleT (667.f / ScreenWidth)
#define HScaleT (375.f / ScreenHeight)

@interface LeftFuncController ()

@property (nonatomic, strong) UIView *leftFuncView;
@property (nonatomic, strong) UIButton *dismissBtn;

@end

@implementation LeftFuncController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];
    
    _leftFuncView = [self leftFuncView];
    _dismissBtn = [self dismissBtn];
    [self drawLeftViewContent];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (UIView *)leftFuncView{
    if (!_leftFuncView) {
        _leftFuncView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160 / WScaleT, ScreenHeight)];
        _leftFuncView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:0.96];
        [self.view addSubview:_leftFuncView];
    }
    return _leftFuncView;
}

- (void)drawLeftViewContent{
    UIButton *power = [[UIButton alloc] initWithFrame:CGRectMake(20/WScaleT, 31/HScaleT, 40/WScaleT, 40/HScaleT)];
    [power setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [power addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
    [_leftFuncView addSubview:power];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(27/WScaleT,76.5/HScaleT,26/WScaleT,18.5/HScaleT);
    label1.text = @"电源";
    label1.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    label1.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [_leftFuncView addSubview:label1];
    
    UIButton *fire = [[UIButton alloc] initWithFrame:CGRectMake(100/WScaleT, 31/HScaleT, 40/WScaleT, 40/HScaleT)];
    [fire setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [fire addTarget:self action:@selector(clickFire) forControlEvents:UIControlEventTouchUpInside];
    [_leftFuncView addSubview:fire];
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(107/WScaleT,76.5/HScaleT,26/WScaleT,18.5/HScaleT);
    label2.text = @"点火";
    label2.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    label2.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [_leftFuncView addSubview:label2];
    
    UIButton *stir = [[UIButton alloc] initWithFrame:CGRectMake(20/WScaleT, 156/HScaleT, 40/WScaleT, 40/HScaleT)];
    [stir setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [stir addTarget:self action:@selector(clickStir) forControlEvents:UIControlEventTouchUpInside];
    [_leftFuncView addSubview:stir];
    
    UILabel *label3 = [[UILabel alloc] init];
    label3.frame = CGRectMake(27/WScaleT,201.5/HScaleT,26/WScaleT,18.5/HScaleT);
    label3.text = @"搅拌";
    label3.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    label3.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [_leftFuncView addSubview:label3];
    
    UIButton *cooling = [[UIButton alloc] initWithFrame:CGRectMake(100/WScaleT, 156/HScaleT, 40/WScaleT, 40/HScaleT)];
    [cooling setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [cooling addTarget:self action:@selector(clickCool) forControlEvents:UIControlEventTouchUpInside];
    [_leftFuncView addSubview:cooling];
    
    UILabel *label4 = [[UILabel alloc] init];
    label4.frame = CGRectMake(107/WScaleT,201.5/HScaleT,26/WScaleT,18.5/HScaleT);
    label4.text = @"冷却";
    label4.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    label4.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [_leftFuncView addSubview:label4];
    
    UIButton *firePower = [[UIButton alloc] initWithFrame:CGRectMake(20/WScaleT, 281/HScaleT, 40/WScaleT, 40/HScaleT)];
    [firePower setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [firePower addTarget:self action:@selector(clickFP) forControlEvents:UIControlEventTouchUpInside];
    [_leftFuncView addSubview:firePower];
    
    UILabel *label5 = [[UILabel alloc] init];
    label5.frame = CGRectMake(27/WScaleT,326.5/HScaleT,26/WScaleT,18.5/HScaleT);
    label5.text = @"火力";
    label5.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    label5.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [_leftFuncView addSubview:label5];
    
    UIButton *windPower = [[UIButton alloc] initWithFrame:CGRectMake(100/WScaleT, 281/HScaleT, 40/WScaleT, 40/HScaleT)];
    [windPower setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [windPower addTarget:self action:@selector(clickWP) forControlEvents:UIControlEventTouchUpInside];
    [_leftFuncView addSubview:windPower];
    
    UILabel *label6 = [[UILabel alloc] init];
    label6.frame = CGRectMake(107/WScaleT,326.5/HScaleT,26/WScaleT,18.5/HScaleT);
    label6.text = @"风力";
    label6.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    label6.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [_leftFuncView addSubview:label6];
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.frame = CGRectMake(160 / WScaleT, 0, ScreenWidth, ScreenHeight);
        [_dismissBtn setBackgroundColor:[UIColor clearColor]];
        [_dismissBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_dismissBtn];
    }
    return _dismissBtn;
}

#pragma mark - Actions
- (void)setPower{
    
}

- (void)clickFire{
    
}

- (void)clickStir{
    
}

- (void)clickCool{
    
}

- (void)clickFP{
    
}

- (void)clickWP{
    
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
