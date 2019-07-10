//
//  DeviceConfirmView.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/29.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceConfirmView.h"
#import "DeviceConnectView.h"
#import "ApDeviceConfirmView.h"

@interface DeviceConfirmView ()

@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UIButton *checkBtn;

@end

@implementation DeviceConfirmView{
    NSArray *deviceTypeNameArray;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        deviceTypeNameArray = @[LocalString(@"HB-M6G咖啡烘焙机"),LocalString(@"HB-M6E咖啡烘焙机"),LocalString(@"HB-L2咖啡烘焙机"),LocalString(@"PEAK-Edmund咖啡烘焙机"),LocalString(@"其他机型")];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1]];

    
    _image = [self image];
    _nextButton = [self nextButton];
    _checkBtn = [self checkBtn];
    [self setDeviceImage];
    [self setNavItem];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //去掉返回键的文字
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.title = LocalString(@"确认设备处于待连接状态");
}

- (void)setNavItem{
    self.navigationItem.title = LocalString(@"确认设备处于待连接状态");

    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"AP模式") style:UIBarButtonItemStylePlain target:self action:@selector(goApView)];
    self.navigationItem.rightBarButtonItem = rightBar;
}

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
#pragma mark - lazy load
- (UIButton *)nextButton{
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextButton setTitle:LocalString(@"下一步") forState:UIControlStateNormal];
        [_nextButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [_nextButton setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        _nextButton.enabled = NO;
        [_nextButton setButtonStyle1];
        [_nextButton addTarget:self action:@selector(goNextView) forControlEvents:UIControlEventTouchUpInside];
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
        tipLabel1.text = LocalString(@"接通电源，长按时间按钮，直到出现wifi图标闪烁");
        tipLabel1.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        tipLabel1.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        tipLabel1.textAlignment = NSTextAlignmentCenter;
        tipLabel1.numberOfLines = 2;
        [self.view addSubview:tipLabel1];
        
        UILabel *tipLabel2 = [[UILabel alloc] init];
        tipLabel2.text = [NSString stringWithFormat:@"%@%@",LocalString(@"您选择了"),deviceTypeNameArray[[[NetWork shareNetWork].deviceType integerValue]]];
        tipLabel2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        tipLabel2.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        tipLabel2.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:tipLabel2];
        
        [tipLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 40 / HScale));
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
        [_checkBtn setImage:[UIImage imageNamed:@"ic_select"] forState:UIControlStateNormal];
        [_checkBtn.imageView sizeThatFits:CGSizeMake(30.f, 30.f)];
        [_checkBtn setTitle:LocalString(@"已完成上述操作") forState:UIControlStateNormal];
        [_checkBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
        [_checkBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        [_checkBtn addTarget:self action:@selector(checkDevice) forControlEvents:UIControlEventTouchUpInside];
        _checkBtn.tag = unselect;
        [self.view addSubview:_checkBtn];
        [_checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(250 / WScale, 30.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(335 / HScale);
        }];
        
        //文字相对于图片的偏移量
        [_checkBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
        [_checkBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];

    }
    return _checkBtn;
}
#pragma mark - action
- (void)goNextView{
    DeviceConnectView *connectVC = [[DeviceConnectView alloc] init];
    [self.navigationController pushViewController:connectVC animated:YES];
}

- (void)goApView{
    ApDeviceConfirmView *apVC = [[ApDeviceConfirmView alloc] init];
    [self.navigationController pushViewController:apVC animated:YES];
}

- (void)checkDevice{
    if (_checkBtn.tag == unselect) {
        _checkBtn.tag = select;
        [_checkBtn setImage:[UIImage imageNamed:@"ic_selected"] forState:UIControlStateNormal];
        [_nextButton setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        _nextButton.enabled = YES;
    }else{
        _checkBtn.tag = unselect;
        [_checkBtn setImage:[UIImage imageNamed:@"ic_select"] forState:UIControlStateNormal];
        [_nextButton setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        _nextButton.enabled = NO;
    }
}

@end
