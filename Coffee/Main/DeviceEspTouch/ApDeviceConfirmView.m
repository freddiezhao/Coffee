//
//  ApDeviceConfirmView.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2019/3/25.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "ApDeviceConfirmView.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "APProcessController.h"

@interface ApDeviceConfirmView ()

@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UIButton *checkBtn;

@end

@implementation ApDeviceConfirmView{
    NSArray *deviceTypeNameArray;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        deviceTypeNameArray = @[@"HB-M6G咖啡烘焙机",@"HB-M6E咖啡烘焙机",@"HB-L2咖啡烘焙机",@"PEAK-Edmund咖啡烘焙机",@"其他机型"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1]];
    
    self.navigationItem.title = LocalString(@"AP模式");
    
    _image = [self image];
    _nextButton = [self nextButton];
    _checkBtn = [self checkBtn];
    [self setDeviceImage];
    [self applicationWillEnterForeground];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //去掉返回键的文字
    self.navigationController.navigationBar.topItem.title = @"";
}

#pragma mark - private methods
- (void)setDeviceImage{
    switch ([[NetWork shareNetWork].deviceType integerValue]) {
        case 0:
        {
            _image.image = [UIImage imageNamed:@"img_hb_m6g_small"];
        }
            break;
            
        case 1:
        {
            _image.image = [UIImage imageNamed:@"img_hb_m6g_small"];
        }
            break;
            
        case 2:
        {
            _image.image = [UIImage imageNamed:@"img_hb_l2_small"];
        }
            break;
            
        case 3:
        {
            _image.image = [UIImage imageNamed:@"img_peak_edmund_small"];
        }
            break;
            
        case 4:{
            _image.image = [UIImage imageNamed:@"img_logo_gray"];
        }
            break;
            
        default:
            break;
    }
}

- (void)applicationWillEnterForeground{
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter]addObserverForName:UIApplicationWillEnterForegroundNotification  object:app queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self confirmWifiName];
    }];
}

- (void)confirmWifiName{
    NSDictionary *netInfo = [self fetchNetInfo];
    NSString *ssid = [netInfo objectForKey:@"SSID"];
    if ([ssid hasPrefix:@"ESP"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self goAPProcess];
        });
    }
}

- (NSDictionary *)fetchNetInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    //    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        //NSLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

- (void)jump2Settings{
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)goAPProcess{
    APProcessController *apVC = [[APProcessController alloc] init];
    [self.navigationController pushViewController:apVC animated:YES];
}

- (void)checkDevice{
    if (_checkBtn.tag == unselect) {
        _checkBtn.tag = select;
        [_checkBtn setImage:[UIImage imageNamed:@"tick"] forState:UIControlStateNormal];
        [_nextButton setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        _nextButton.enabled = YES;
    }else{
        _checkBtn.tag = unselect;
        [_checkBtn setImage:[UIImage imageNamed:@"untick"] forState:UIControlStateNormal];
        [_nextButton setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        _nextButton.enabled = NO;
    }
}
#pragma mark - lazy load
- (UIButton *)nextButton{
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextButton setTitle:LocalString(@"去连接") forState:UIControlStateNormal];
        [_nextButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [_nextButton setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        _nextButton.enabled = NO;
        [_nextButton setButtonStyle1];
        [_nextButton addTarget:self action:@selector(jump2Settings) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_nextButton];
        
        [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(345.f / WScale, 50.f / HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.checkBtn.mas_bottom).offset(20 / HScale);
        }];

    }
    return _nextButton;
}

- (UIImageView *)image{
    if (!_image) {
        _image = [[UIImageView alloc] init];
        _image.image = [UIImage imageNamed:@"img_peak_edmund"];
        [self.view addSubview:_image];
        
        [_image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(225 / WScale, 150 / HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(82 / HScale);
        }];
        
        UILabel *tipLabel1 = [[UILabel alloc] init];
        tipLabel1.text = LocalString(@"接通电源，长按点火键和冷却键，直到Wi-Fi指示灯闪烁");
        tipLabel1.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        tipLabel1.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        tipLabel1.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:tipLabel1];
        
        UILabel *tipLabel2 = [[UILabel alloc] init];
        tipLabel2.text = [NSString stringWithFormat:@"%@%@",LocalString(@"您选择了 "),deviceTypeNameArray[[[NetWork shareNetWork].deviceType integerValue]]];
        tipLabel2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        tipLabel2.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        tipLabel2.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:tipLabel2];
        
        [tipLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 20 / HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.image.mas_bottom).offset(18 / HScale);
        }];
        [tipLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 20 / HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(tipLabel1.mas_bottom).offset(8 / HScale);
        }];
    }
    return _image;
}

- (UIButton *)checkBtn{
    if (!_checkBtn) {
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkBtn setImage:[UIImage imageNamed:@"untick"] forState:UIControlStateNormal];
        [_checkBtn addTarget:self action:@selector(checkDevice) forControlEvents:UIControlEventTouchUpInside];
        _checkBtn.tag = unselect;
        [self.view addSubview:_checkBtn];
        [_checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(18 / WScale, 18 / HScale));
            make.left.equalTo(self.view.mas_left).offset(127 / WScale);
            make.top.equalTo(self.view.mas_top).offset(335 / HScale);
        }];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.text = LocalString(@"已完成上述操作");
        tipLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        tipLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.view addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100 / WScale, 20 / HScale));
            make.centerY.equalTo(self.checkBtn.mas_centerY);
            make.left.equalTo(_checkBtn.mas_right).offset(6 / WScale);
        }];
    }
    return _checkBtn;
}



@end