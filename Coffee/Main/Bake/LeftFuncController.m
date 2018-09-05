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
@property (nonatomic, strong) UIButton *powerBtn;
@property (nonatomic, strong) UIButton *fireBtn;
@property (nonatomic, strong) UIButton *stirBtn;
@property (nonatomic, strong) UIButton *coolingBtn;
@property (nonatomic, strong) UIButton *firePowerBtn;
@property (nonatomic, strong) UIButton *windPowerBtn;

@property (nonatomic, strong) UIButton *dismissBtn;

@property (nonatomic, strong) NetWork *myNet;

@end

@implementation LeftFuncController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];
    
    _myNet = [NetWork shareNetWork];

    _leftFuncView = [self leftFuncView];
    _dismissBtn = [self dismissBtn];
    [self drawLeftViewContent];
    [self getAllStatus];
    
    [_myNet addObserver:self forKeyPath:@"powerStatus" options:NSKeyValueObservingOptionNew context:nil];
    [_myNet addObserver:self forKeyPath:@"fireStatus" options:NSKeyValueObservingOptionNew context:nil];
    [_myNet addObserver:self forKeyPath:@"coolStatus" options:NSKeyValueObservingOptionNew context:nil];
    [_myNet addObserver:self forKeyPath:@"stirStatus" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)dealloc{
    [_myNet removeObserver:self forKeyPath:@"powerStatus"];
    [_myNet removeObserver:self forKeyPath:@"fireStatus"];
    [_myNet removeObserver:self forKeyPath:@"coolStatus"];
    [_myNet removeObserver:self forKeyPath:@"stirStatus"];
}

#pragma mark - Lazy load

- (UIView *)leftFuncView{
    if (!_leftFuncView) {
        _leftFuncView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160 / WScaleT, ScreenHeight)];
        _leftFuncView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:0.96];
        [self.view addSubview:_leftFuncView];
    }
    return _leftFuncView;
}

- (void)drawLeftViewContent{
    _powerBtn = [[UIButton alloc] initWithFrame:CGRectMake(15/WScaleT, 26/HScaleT, 50/WScaleT, 50/WScaleT)];
    [_powerBtn setImage:[UIImage imageNamed:@"btn_power_off"] forState:UIControlStateNormal];
    [_powerBtn addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
    _powerBtn.tag = btn_unselect;
    [_leftFuncView addSubview:_powerBtn];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(27/WScaleT,76.5/HScaleT,26/WScaleT,18.5/HScaleT);
    label1.text = @"电源";
    label1.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    label1.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [_leftFuncView addSubview:label1];
    
    _fireBtn = [[UIButton alloc] initWithFrame:CGRectMake(95/WScaleT, 26/HScaleT, 50/WScaleT, 50/HScaleT)];
    [_fireBtn setImage:[UIImage imageNamed:@"btn_fire_off"] forState:UIControlStateNormal];
    [_fireBtn addTarget:self action:@selector(clickFire) forControlEvents:UIControlEventTouchUpInside];
    _fireBtn.tag = btn_unselect;
    _fireBtn.enabled = NO;
    [_leftFuncView addSubview:_fireBtn];
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(107/WScaleT,76.5/HScaleT,26/WScaleT,18.5/HScaleT);
    label2.text = @"点火";
    label2.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    label2.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [_leftFuncView addSubview:label2];
    
    _stirBtn = [[UIButton alloc] initWithFrame:CGRectMake(15/WScaleT, 151/HScaleT, 50/WScaleT, 50/HScaleT)];
    [_stirBtn setImage:[UIImage imageNamed:@"btn_stir_off"] forState:UIControlStateNormal];
    [_stirBtn addTarget:self action:@selector(clickStir) forControlEvents:UIControlEventTouchUpInside];
    _stirBtn.tag = btn_unselect;
    _stirBtn.enabled = NO;
    [_leftFuncView addSubview:_stirBtn];
    
    UILabel *label3 = [[UILabel alloc] init];
    label3.frame = CGRectMake(27/WScaleT,201.5/HScaleT,26/WScaleT,18.5/HScaleT);
    label3.text = @"搅拌";
    label3.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    label3.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [_leftFuncView addSubview:label3];
    
    _coolingBtn = [[UIButton alloc] initWithFrame:CGRectMake(95/WScaleT, 151/HScaleT, 50/WScaleT, 50/HScaleT)];
    [_coolingBtn setImage:[UIImage imageNamed:@"btn_cold_off"] forState:UIControlStateNormal];
    [_coolingBtn addTarget:self action:@selector(clickCool) forControlEvents:UIControlEventTouchUpInside];
    _coolingBtn.tag = btn_unselect;
    _coolingBtn.enabled = NO;
    [_leftFuncView addSubview:_coolingBtn];
    
    UILabel *label4 = [[UILabel alloc] init];
    label4.frame = CGRectMake(107/WScaleT,201.5/HScaleT,26/WScaleT,18.5/HScaleT);
    label4.text = @"冷却";
    label4.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    label4.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [_leftFuncView addSubview:label4];
    
    _firePowerBtn = [[UIButton alloc] initWithFrame:CGRectMake(15/WScaleT, 276/HScaleT, 50/WScaleT, 50/HScaleT)];
    [_firePowerBtn setImage:[UIImage imageNamed:@"btn_firepower_disable"] forState:UIControlStateNormal];
    [_firePowerBtn addTarget:self action:@selector(clickFP) forControlEvents:UIControlEventTouchUpInside];
    _firePowerBtn.tag = btn_unselect;
    _firePowerBtn.enabled = NO;
    [_leftFuncView addSubview:_firePowerBtn];
    
    UILabel *label5 = [[UILabel alloc] init];
    label5.frame = CGRectMake(27/WScaleT,326.5/HScaleT,26/WScaleT,18.5/HScaleT);
    label5.text = @"火力";
    label5.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    label5.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [_leftFuncView addSubview:label5];
    
    _windPowerBtn = [[UIButton alloc] initWithFrame:CGRectMake(95/WScaleT, 276/HScaleT, 50/WScaleT, 50/HScaleT)];
    [_windPowerBtn setImage:[UIImage imageNamed:@"btn_windpower_disable"] forState:UIControlStateNormal];
    [_windPowerBtn addTarget:self action:@selector(clickWP) forControlEvents:UIControlEventTouchUpInside];
    _windPowerBtn.tag = btn_unselect;
    _windPowerBtn.enabled = NO;
    [_leftFuncView addSubview:_windPowerBtn];
    
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
- (void)getAllStatus{
    if (_myNet.powerStatus) {
        [_powerBtn setImage:[UIImage imageNamed:@"btn_power_on"] forState:UIControlStateNormal];
        _fireBtn.enabled = YES;
        _coolingBtn.enabled = YES;
        _stirBtn.enabled = YES;
        _windPowerBtn.enabled = YES;
        _firePowerBtn.enabled = YES;
    }else{
        [_powerBtn setImage:[UIImage imageNamed:@"btn_power_off"] forState:UIControlStateNormal];
        _fireBtn.enabled = NO;
        _coolingBtn.enabled = NO;
        _stirBtn.enabled = NO;
        _windPowerBtn.enabled = NO;
        _firePowerBtn.enabled = NO;
    }
    if (_myNet.fireStatus) {
        [_fireBtn setImage:[UIImage imageNamed:@"btn_fire_on"] forState:UIControlStateNormal];
    }else{
        [_fireBtn setImage:[UIImage imageNamed:@"btn_fire_off"] forState:UIControlStateNormal];
    }
    if (_myNet.coolStatus) {
        [_coolingBtn setImage:[UIImage imageNamed:@"btn_cold_on"] forState:UIControlStateNormal];
    }else{
        [_coolingBtn setImage:[UIImage imageNamed:@"btn_cold_off"] forState:UIControlStateNormal];
    }
    if (_myNet.stirStatus) {
        [_stirBtn setImage:[UIImage imageNamed:@"btn_stir_on"] forState:UIControlStateNormal];
    }else{
        [_stirBtn setImage:[UIImage imageNamed:@"btn_stir_off"] forState:UIControlStateNormal];
    }
}

- (void)setPower{
    if (_myNet.powerStatus) {
        [_powerBtn setImage:[UIImage imageNamed:@"btn_power_on"] forState:UIControlStateNormal];
        _fireBtn.enabled = YES;
        _coolingBtn.enabled = YES;
        _stirBtn.enabled = YES;
        _windPowerBtn.enabled = YES;
        _firePowerBtn.enabled = YES;
        [_myNet setPower:0x00];
    }else{
        [_powerBtn setImage:[UIImage imageNamed:@"btn_power_off"] forState:UIControlStateNormal];
        _fireBtn.enabled = NO;
        _coolingBtn.enabled = NO;
        _stirBtn.enabled = NO;
        _windPowerBtn.enabled = NO;
        _firePowerBtn.enabled = NO;
        [_myNet setPower:0xFF];
    }
    _myNet.powerStatus = !_myNet.powerStatus;
}

- (void)clickFire{
    if (_myNet.fireStatus) {
        [[NetWork shareNetWork] setFire:0x00];
    }else{
        [[NetWork shareNetWork] setFire:0xFF];
    }
    _myNet.fireStatus = !_myNet.fireStatus;
}

- (void)clickStir{
    if (_myNet.stirStatus) {
        [_stirBtn setImage:[UIImage imageNamed:@"btn_stir_off"] forState:UIControlStateNormal];
    }else{
        [_stirBtn setImage:[UIImage imageNamed:@"btn_stir_on"] forState:UIControlStateNormal];
    }
    if (_myNet.stirStatus && _myNet.coolStatus) {
        [_myNet setColdAndStir:0x01];
    }else if (!_myNet.stirStatus && _myNet.coolStatus){
        [_myNet setColdAndStir:0x11];
    }else if (_myNet.stirStatus && !_myNet.coolStatus){
        [_myNet setColdAndStir:0x00];
    }else if (!_myNet.stirStatus && !_myNet.coolStatus){
        [_myNet setColdAndStir:0x10];
    }
    _myNet.stirStatus = !_myNet.stirStatus;
}

- (void)clickCool{
    if (_myNet.coolStatus) {
        [_coolingBtn setImage:[UIImage imageNamed:@"btn_cold_off"] forState:UIControlStateNormal];
    }else{
        [_coolingBtn setImage:[UIImage imageNamed:@"btn_cold_on"] forState:UIControlStateNormal];
    }
    if (_myNet.stirStatus && _myNet.coolStatus) {
        [_myNet setColdAndStir:0x10];
    }else if (!_myNet.stirStatus && _myNet.coolStatus){
        [_myNet setColdAndStir:0x00];
    }else if (_myNet.stirStatus && !_myNet.coolStatus){
        [_myNet setColdAndStir:0x11];
    }else if (!_myNet.stirStatus && !_myNet.coolStatus){
        [_myNet setColdAndStir:0x01];
    }
    _myNet.coolStatus = !_myNet.coolStatus;
}

- (void)clickFP{
    
}

- (void)clickWP{
    
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"powerStatus"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            _powerBtn.enabled = YES;
            if (_myNet.powerStatus) {
                [_powerBtn setImage:[UIImage imageNamed:@"btn_power_on"] forState:UIControlStateNormal];
                _fireBtn.enabled = YES;
                _coolingBtn.enabled = YES;
                _stirBtn.enabled = YES;
                _windPowerBtn.enabled = YES;
                _firePowerBtn.enabled = YES;
            }else{
                [_powerBtn setImage:[UIImage imageNamed:@"btn_power_off"] forState:UIControlStateNormal];
                _fireBtn.enabled = NO;
                _coolingBtn.enabled = NO;
                _stirBtn.enabled = NO;
                _windPowerBtn.enabled = NO;
                _firePowerBtn.enabled = NO;
            }
        });
    }else if ([keyPath isEqualToString:@"fireStatus"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_myNet.fireStatus) {
                [_fireBtn setImage:[UIImage imageNamed:@"btn_fire_on"] forState:UIControlStateNormal];
            }else{
                [_fireBtn setImage:[UIImage imageNamed:@"btn_fire_off"] forState:UIControlStateNormal];
            }
        });
    }else if ([keyPath isEqualToString:@"coolStatus"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_myNet.coolStatus) {
                [_coolingBtn setImage:[UIImage imageNamed:@"btn_cold_on"] forState:UIControlStateNormal];
            }else{
                [_coolingBtn setImage:[UIImage imageNamed:@"btn_cold_off"] forState:UIControlStateNormal];
            }
        });
    }else if ([keyPath isEqualToString:@"stirStatus"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_myNet.stirStatus) {
                [_stirBtn setImage:[UIImage imageNamed:@"btn_stir_on"] forState:UIControlStateNormal];
            }else{
                [_stirBtn setImage:[UIImage imageNamed:@"btn_stir_off"] forState:UIControlStateNormal];
            }
        });
    }
}

@end
