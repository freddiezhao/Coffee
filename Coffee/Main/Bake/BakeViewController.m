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
#import "BeanModel.h"
#import "AddBeanTableController.h"
#import "DeviceModel.h"

#define buttonHeight 44

@interface BakeViewController ()

@property (nonatomic, strong) NetWork *myNet;

@property (nonatomic, strong) NSMutableArray *beanArray;

//上半部分
@property (nonatomic, strong) UILabel *status;
@property (nonatomic, strong) UIView *statusView;
@property (nonatomic, strong) UIImageView *deviceImage;
@property (nonatomic, strong) UILabel *status1;
@property (nonatomic, strong) UIView *statusView1;
@property (nonatomic, strong) UILabel *status2;
@property (nonatomic, strong) UIView *statusView2;
@property (nonatomic, strong) UILabel *status3;
@property (nonatomic, strong) UIView *statusView3;

//下半部分
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIImageView *pointerImage;
@property (nonatomic, strong) UILabel *beanTempLabel;
@property (nonatomic, strong) UILabel *beanTempUnitLabel;
@property (nonatomic, strong) UILabel *beanTempRateLabel;
@property (nonatomic, strong) UILabel *inTempLabel;
@property (nonatomic, strong) UILabel *outTempLabel;
@property (nonatomic, strong) UILabel *environTempLabel;

@property (nonatomic, strong) UIScrollView *beanNameView;
@property (nonatomic, strong) UILabel *beanNameLabel;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *showControlViewBtn;
@property (nonatomic, strong) UIButton *powerBtn;
@property (nonatomic, strong) UIButton *fireBtn;
@property (nonatomic, strong) UIButton *coldBtn;
@property (nonatomic, strong) UIButton *stirBtn;
@property (nonatomic, strong) UIButton *firePBtn;
@property (nonatomic, strong) UIButton *windPBtn;

@property (nonatomic, strong) UIButton *bakeCurveBtn;
@property (nonatomic, strong) UIButton *addBeanBtn;

@property (nonatomic, strong) NSString *resourcePath;
@end

@implementation BakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = LocalString(@"烘焙机名称");
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1]];
    [self.view setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1]];
    
    NSBundle *bundle = [NSBundle mainBundle];
    _resourcePath = [bundle resourcePath];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setImage:[UIImage imageNamed:@"ic_nav_more_black"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(connectMachine) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;

    _status = [self status];
    _deviceImage = [self deviceImage];
    _status1 = [self status1];
    _status2 = [self status2];
    _status3 = [self status3];
    
    _mainView = [self mainView];
    _pointerImage = [self pointerImage];
    _beanTempLabel = [self beanTempLabel];
    _beanTempRateLabel = [self beanTempRateLabel];
    _inTempLabel = [self inTempLabel];
    _outTempLabel = [self outTempLabel];
    _environTempLabel = [self environTempLabel];
    _beanNameView = [self beanNameView];
    
    
    _bottomView = [self bottomView];
    _showControlViewBtn = [self showControlViewBtn];
    _bakeCurveBtn = [self bakeCurveBtn];
    _addBeanBtn = [self addBeanBtn];
    
    _myNet = [NetWork shareNetWork];
    
    [_myNet addObserver:self forKeyPath:@"tempData" options:NSKeyValueObservingOptionNew context:nil];
    [_myNet addObserver:self forKeyPath:@"powerStatus" options:NSKeyValueObservingOptionNew context:nil];
    [_myNet addObserver:self forKeyPath:@"fireStatus" options:NSKeyValueObservingOptionNew context:nil];
    [_myNet addObserver:self forKeyPath:@"coolStatus" options:NSKeyValueObservingOptionNew context:nil];
    [_myNet addObserver:self forKeyPath:@"stirStatus" options:NSKeyValueObservingOptionNew context:nil];
    [_myNet addObserver:self forKeyPath:@"connectedDevice" options:NSKeyValueObservingOptionNew context:nil];
    [_myNet addObserver:self forKeyPath:@"deviceTimerStatus" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    
    _myNet = [NetWork shareNetWork];
    
    if (_myNet.connectedDevice) {
        self.navigationItem.title = _myNet.connectedDevice.deviceName;
        NSLog(@"%@",_myNet.connectedDevice.deviceName);
        switch ([_myNet.connectedDevice.deviceType integerValue]) {
            case Coffee_HB_M6G:
            case Coffee_HB_M6E:
            {
                _deviceImage.frame = CGRectMake(75/WScale, 18/HScale, 225/WScale, 150/HScale);
                _deviceImage.image = [UIImage imageNamed:@"img_hb_m6g_small"];
            }
                break;
             
            case Coffee_HB_L2:
            {
                _deviceImage.frame = CGRectMake(75/WScale, 18/HScale, 225/WScale, 150/HScale);
                _deviceImage.image = [UIImage imageNamed:@"img_hb_l2_small"];
            }
                break;
                
            case Coffee_PEAK_Edmund:
            {
                _deviceImage.frame = CGRectMake(75/WScale, 18/HScale, 225/WScale, 150/HScale);
                _deviceImage.image = [UIImage imageNamed:@"img_peak_edmund"];
            }
                break;
                
            case Coffee_HB_Another:
            {
                _deviceImage.frame = CGRectMake(75/WScale, 18/HScale, 225/WScale, 150/HScale);
                _deviceImage.image = [UIImage imageNamed:@"img_logo_gray"];
            }
                break;
                
            default:
                _deviceImage.frame = CGRectMake(117/WScale, 37/HScale, 140/WScale, 112/HScale);
                _deviceImage.image = [UIImage imageNamed:@"img_logo_gray"];
                break;
        }
    }else{
        self.navigationItem.title = LocalString(@"烘焙机名称");
        _deviceImage.frame = CGRectMake(117/WScale, 37/HScale, 140/WScale, 112/HScale);
        _deviceImage.image = [UIImage imageNamed:@"img_logo_gray"];
    }
    if (_beanNameView) {
        _beanNameView = [self beanNameView];
    }
    _beanTempRateLabel.text = [NSString stringWithFormat:@"%.1f %@/min",0.0,[DataBase shareDataBase].setting.tempUnit];
    _inTempLabel.text = [NSString stringWithFormat:@"%.1f%@",0.0,[DataBase shareDataBase].setting.tempUnit];
    _outTempLabel.text = [NSString stringWithFormat:@"%.1f%@",0.0,[DataBase shareDataBase].setting.tempUnit];
    _environTempLabel.text = [NSString stringWithFormat:@"%.1f%@",0.0,[DataBase shareDataBase].setting.tempUnit];
    _beanTempUnitLabel.text = [DataBase shareDataBase].setting.tempUnit;
    
    if (_myNet.deviceTimerStatus == 0 && _myNet.connectedDevice) {
        _statusView2.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:221/255.0 blue:51/255.0 alpha:1.0].CGColor;
    }else{
        _statusView2.layer.backgroundColor = [UIColor colorWithRed:213/255.0 green:218/255.0 blue:224/255.0 alpha:1].CGColor;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mysocketDidDisconnect) name:@"mysocketDidDisconnect" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"mysocketDidDisconnect" object:nil];
}

- (void)dealloc{
    [_myNet removeObserver:self forKeyPath:@"tempData"];
    [_myNet removeObserver:self forKeyPath:@"powerStatus"];
    [_myNet removeObserver:self forKeyPath:@"fireStatus"];
    [_myNet removeObserver:self forKeyPath:@"coolStatus"];
    [_myNet removeObserver:self forKeyPath:@"stirStatus"];
    [_myNet removeObserver:self forKeyPath:@"connectedDevice"];
    [_myNet removeObserver:self forKeyPath:@"deviceTimerStatus"];
}

#pragma mark - Actions
- (void)goBakeCurveViewController{
    if (_myNet.connectedDevice) {
        BakeCurveViewController *bakeCurveVC = [[BakeCurveViewController alloc] init];
        bakeCurveVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:bakeCurveVC animated:YES completion:nil];
    }else{
        YAlertViewController *alert = [[YAlertViewController alloc] init];
        alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        alert.rBlock = ^{
            [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
        };
        alert.lBlock = ^{
            [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
        };
        [self presentViewController:alert animated:NO completion:^{
            [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
            alert.WScale_alert = WScale;
            alert.HScale_alert = HScale;
            [alert showView];
            alert.titleLabel.text = LocalString(@"提示");
            alert.messageLabel.text = LocalString(@"请先连接咖啡机设备");
            [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
            [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
        }];
    }
}

- (void)addCoffeeBean{
    AddBeanTableController *addBeanVC = [[AddBeanTableController alloc] init];
    [self.navigationController pushViewController:addBeanVC animated:YES];
}

- (void)showControlView:(UIButton *)sender{
    if (sender.tag == unselect) {
        sender.tag = select;
        [UIView animateWithDuration:0.5 animations:^{
            CGSize size = _mainView.frame.size;
            _mainView.frame = CGRectMake(0, (ScreenHeight - 64 - (tabbarHeight + kSafeArea_Bottom) - 400/HScale - 90/HScale), size.width, size.height);//154是控制按钮view高度，刚好把控制按钮隐藏，90是bottonview高度
            [sender setImage:[UIImage imageNamed:@"btn_collapse"] forState:UIControlStateNormal];
        }];
    }else{
        sender.tag = unselect;
        [UIView animateWithDuration:0.5 animations:^{
            CGSize size = _mainView.frame.size;
            _mainView.frame = CGRectMake(0, (ScreenHeight - 64 - (tabbarHeight + kSafeArea_Bottom) - 400/HScale + 154/HScale - 90/HScale), size.width, size.height);//154是控制按钮view高度，刚好把控制按钮隐藏，90是bottonview高度
            [sender setImage:[UIImage imageNamed:@"btn_expand"] forState:UIControlStateNormal];
        }];
    }
}

- (void)connectMachine{
    DeviceViewController *deviceVC = [[DeviceViewController alloc] init];
    [self.navigationController pushViewController:deviceVC animated:YES];
}

- (void)setPower{
    _myNet.setPowerCount = 2;
    if (_myNet.powerStatus) {
        [_myNet setPower:[NSNumber numberWithUnsignedInteger:0x00]];
        _myNet.isPower = [NSNumber numberWithUnsignedInteger:0x00];
    }else{
        [_myNet setPower:[NSNumber numberWithUnsignedInteger:0xFF]];
        _myNet.isPower = [NSNumber numberWithUnsignedInteger:0xFF];
    }
    _myNet.powerStatus = !_myNet.powerStatus;
}

- (void)setFire{
    _myNet.setFireCount = 2;
    if (_myNet.fireStatus) {
        [[NetWork shareNetWork] setFire:[NSNumber numberWithUnsignedInteger:0x00]];
        _myNet.isFire = [NSNumber numberWithUnsignedInteger:0x00];
    }else{
        [[NetWork shareNetWork] setFire:[NSNumber numberWithUnsignedInteger:0xFF]];
        _myNet.isFire = [NSNumber numberWithUnsignedInteger:0xFF];
    }
    _myNet.fireStatus = !_myNet.fireStatus;
}

- (void)setStir{
    _myNet.setColdAndStirCount = 2;
    if (_myNet.stirStatus && _myNet.coolStatus) {
        [_myNet setColdAndStir:[NSNumber numberWithUnsignedInteger:0x01]];
        _myNet.isColdAndStir = [NSNumber numberWithUnsignedInteger:0x01];
    }else if (!_myNet.stirStatus && _myNet.coolStatus){
        [_myNet setColdAndStir:[NSNumber numberWithUnsignedInteger:0x03]];
        _myNet.isColdAndStir = [NSNumber numberWithUnsignedInteger:0x03];
    }else if (_myNet.stirStatus && !_myNet.coolStatus){
        [_myNet setColdAndStir:[NSNumber numberWithUnsignedInteger:0x00]];
        _myNet.isColdAndStir = [NSNumber numberWithUnsignedInteger:0x00];
    }else if (!_myNet.stirStatus && !_myNet.coolStatus){
        [_myNet setColdAndStir:[NSNumber numberWithUnsignedInteger:0x02]];
        _myNet.isColdAndStir = [NSNumber numberWithUnsignedInteger:0x02];
    }
    _myNet.stirStatus = !_myNet.stirStatus;
}

- (void)setCold{
    _myNet.setColdAndStirCount = 3;
    if (_myNet.stirStatus && _myNet.coolStatus) {
        [_myNet setColdAndStir:[NSNumber numberWithUnsignedInteger:0x02]];
        _myNet.isColdAndStir = [NSNumber numberWithUnsignedInteger:0x02];
    }else if (!_myNet.stirStatus && _myNet.coolStatus){
        [_myNet setColdAndStir:[NSNumber numberWithUnsignedInteger:0x00]];
        _myNet.isColdAndStir = [NSNumber numberWithUnsignedInteger:0x00];
    }else if (_myNet.stirStatus && !_myNet.coolStatus){
        [_myNet setColdAndStir:[NSNumber numberWithUnsignedInteger:0x03]];
        _myNet.isColdAndStir = [NSNumber numberWithUnsignedInteger:0x03];
    }else if (!_myNet.stirStatus && !_myNet.coolStatus){
        [_myNet setColdAndStir:[NSNumber numberWithUnsignedInteger:0x01]];
        _myNet.isColdAndStir = [NSNumber numberWithUnsignedInteger:0x01];
    }
    _myNet.coolStatus = !_myNet.coolStatus;
}

- (void)getCurve{
    
}

//豆名滚动UI点击动作
-(void)handleTapGesture:( UITapGestureRecognizer *)tapRecognizer
{
    // 先取消任何操作???????这句话存在的意义？？？
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    AddBeanTableController *addBeanVC = [[AddBeanTableController alloc] init];
    [self.navigationController pushViewController:addBeanVC animated:YES];
}

- (void)mysocketDidDisconnect{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.title = LocalString(@"烘焙机名称");
        self.deviceImage.frame = CGRectMake(117/WScale, 37/HScale, 140/WScale, 112/HScale);
        self.deviceImage.image = [UIImage imageNamed:@"img_logo_gray"];
    });
}
#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NetWork *net = [NetWork shareNetWork];
    if ([keyPath isEqualToString:@"tempData"]) {
        NSMutableArray *data = [_myNet.recivedData68 copy];
        double tempOut = ([data[6] intValue] * 256 + [data[7] intValue]) / 10.0;
        double tempIn = ([data[8] intValue] * 256 + [data[9] intValue]) / 10.0;
        double tempBean = ([data[10] intValue] * 256 + [data[11] intValue]) / 10.0;
        double tempEnvironment = ([data[12] intValue] * 256 + [data[13] intValue]) / 10.0;
        
        //_beanTempRateLabel.text = [NSString stringWithFormat:@"%f℃/min",tempOut];
        dispatch_async(dispatch_get_main_queue(), ^{
            //当顺时针旋转120度时，指针转到129
            _pointerImage.transform = CGAffineTransformMakeRotation((tempBean / 129.f * 120.0) / 180 * M_PI);
            _beanTempLabel.text = [NSString stringWithFormat:@"%.1f",[NSString diffTempUnitStringWithTemp:tempBean]];
            _inTempLabel.text = [NSString stringWithFormat:@"%.1f%@",[NSString diffTempUnitStringWithTemp:tempIn],[DataBase shareDataBase].setting.tempUnit];
            _outTempLabel.text = [NSString stringWithFormat:@"%.1f%@",[NSString diffTempUnitStringWithTemp:tempOut],[DataBase shareDataBase].setting.tempUnit];
            _environTempLabel.text = [NSString stringWithFormat:@"%.1f%@",[NSString diffTempUnitStringWithTemp:tempEnvironment],[DataBase shareDataBase].setting.tempUnit];
            if (net.BeanArr.count > 5) {
                _beanTempRateLabel.text = [NSString stringWithFormat:@"%.1f%@/min",([NSString diffTempUnitStringWithTemp:[net.BeanArr[net.BeanArr.count-1] doubleValue]] - [NSString diffTempUnitStringWithTemp:[net.BeanArr[net.BeanArr.count-6] doubleValue]])/5*60,[DataBase shareDataBase].setting.tempUnit];
            }
        });
        
    }else if ([keyPath isEqualToString:@"powerStatus"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            _powerBtn.enabled = YES;
            
            if (_myNet.powerStatus) {
                [_powerBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_power_on@2x.png"]] forState:UIControlStateNormal];
                _fireBtn.enabled = YES;
                _coldBtn.enabled = YES;
                _stirBtn.enabled = YES;
                _windPBtn.enabled = NO;
                _firePBtn.enabled = NO;
                _status.text = LocalString(@"电源开启");
                _statusView.layer.backgroundColor = [UIColor colorWithRed:126/255.0 green:211/255.0 blue:33/255.0 alpha:1].CGColor;
                _statusView.layer.shadowColor = [UIColor colorWithRed:106/255.0 green:255/255.0 blue:77/255.0 alpha:1].CGColor;
                _statusView.layer.shadowOffset = CGSizeMake(0,0);
                _statusView.layer.shadowOpacity = 1;
                _statusView.layer.shadowRadius = 8;
            }else{
                //电源关闭后所有按钮关闭
                [_powerBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_power_off@2x.png"]] forState:UIControlStateNormal];
                [_fireBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_fire_off@2x.png"]] forState:UIControlStateNormal];
                [_coldBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_cold_off@2x.png"]] forState:UIControlStateNormal];
                [_stirBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_stir_off@2x.png"]] forState:UIControlStateNormal];
                
                //所有状态为关闭
                _myNet.coolStatus = NO;
                _myNet.fireStatus = NO;
                _myNet.stirStatus = NO;
                
                //所有功能不能使用
                _fireBtn.enabled = NO;
                _coldBtn.enabled = NO;
                _stirBtn.enabled = NO;
                _windPBtn.enabled = NO;
                _firePBtn.enabled = NO;
                _status.text = LocalString(@"电源关闭");
                _statusView.layer.backgroundColor = [UIColor colorWithRed:254/255.0 green:71/255.0 blue:51/255.0 alpha:1].CGColor;
                _statusView.layer.shadowColor = [UIColor colorWithRed:254/255.0 green:71/255.0 blue:52/255.0 alpha:1].CGColor;
                _statusView.layer.shadowOffset = CGSizeMake(0,0);
                _statusView.layer.shadowOpacity = 1;
            }
        });
    }else if ([keyPath isEqualToString:@"fireStatus"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_myNet.fireStatus) {
                [_fireBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_fire_on@2x.png"]] forState:UIControlStateNormal];
                
                _status1.textColor = [UIColor colorWithHexString:@"333333"];
                
                _statusView1.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:128/255.0 blue:0/255.0 alpha:1].CGColor;
                _statusView1.layer.shadowColor = [UIColor colorWithRed:255/255.0 green:128/255.0 blue:0/255.0 alpha:1].CGColor;
                _statusView1.layer.shadowOffset = CGSizeMake(0,0);
                _statusView1.layer.shadowOpacity = 1;
                _statusView1.layer.shadowRadius = 8;
            }else{
                [_fireBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_fire_off@2x.png"]] forState:UIControlStateNormal];
                
                _status1.textColor = [UIColor colorWithHexString:@"999999"];
                
                _statusView1.layer.backgroundColor = [UIColor colorWithRed:213/255.0 green:218/255.0 blue:224/255.0 alpha:1].CGColor;
                _statusView1.layer.shadowOpacity = 0;
            }
        });
    }else if ([keyPath isEqualToString:@"coolStatus"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_myNet.coolStatus) {
                [_coldBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_cold_on@2x.png"]] forState:UIControlStateNormal];
                
                _status3.textColor = [UIColor colorWithHexString:@"333333"];
                
                _statusView3.layer.backgroundColor = [UIColor colorWithRed:73/255.0 green:152/255.0 blue:242/255.0 alpha:1].CGColor;
                _statusView3.layer.shadowColor = [UIColor colorWithRed:73/255.0 green:152/255.0 blue:242/255.0 alpha:1].CGColor;
                _statusView3.layer.shadowOffset = CGSizeMake(0,0);
                _statusView3.layer.shadowOpacity = 1;
                _statusView3.layer.shadowRadius = 8;
            }else{
                [_coldBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_cold_off@2x.png"]] forState:UIControlStateNormal];
                
                _status3.textColor = [UIColor colorWithHexString:@"999999"];
                
                _statusView3.layer.backgroundColor = [UIColor colorWithRed:213/255.0 green:218/255.0 blue:224/255.0 alpha:1].CGColor;
                _statusView3.layer.shadowOpacity = 0;
            }
        });
    }else if ([keyPath isEqualToString:@"stirStatus"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_myNet.stirStatus) {
                [_stirBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_stir_on@2x.png"]] forState:UIControlStateNormal];
            }else{
                [_stirBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_stir_off@2x.png"]] forState:UIControlStateNormal];
            }
        });
    }
    else if ([keyPath isEqualToString:@"connectedDevice"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_myNet.connectedDevice != nil) {
                _status.text = LocalString(@"设备已连接");
            }else{
                _status.text = LocalString(@"设备未连接");
                _statusView.layer.backgroundColor = [UIColor colorWithRed:254/255.0 green:71/255.0 blue:51/255.0 alpha:1].CGColor;
                _statusView.layer.shadowColor = [UIColor colorWithRed:254/255.0 green:71/255.0 blue:52/255.0 alpha:1].CGColor;
                _statusView.layer.shadowOffset = CGSizeMake(0,0);
                _statusView.layer.shadowOpacity = 1;
                
                _beanTempLabel.text = [NSString stringWithFormat:@"%.1f",0.0];
                _inTempLabel.text = [NSString stringWithFormat:@"%.1f%@",0.0,[DataBase shareDataBase].setting.tempUnit];
                _outTempLabel.text = [NSString stringWithFormat:@"%.1f%@",0.0,[DataBase shareDataBase].setting.tempUnit];
                _environTempLabel.text = [NSString stringWithFormat:@"%.1f%@",0.0,[DataBase shareDataBase].setting.tempUnit];
                _beanTempRateLabel.text = [NSString stringWithFormat:@"%.1f%@/min",0.0,[DataBase shareDataBase].setting.tempUnit];
                
                _deviceImage.frame = CGRectMake(117/WScale, 37/HScale, 140/WScale, 112/HScale);
                _deviceImage.image = [UIImage imageNamed:@"img_logo_gray"];
            }
        });
    }else if ([keyPath isEqualToString:@"deviceTimerStatus"]){
        NSLog(@"adsas");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!_myNet.deviceTimerStatus && _myNet.connectedDevice) {
                _statusView2.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:221/255.0 blue:51/255.0 alpha:1.0].CGColor;
            }else{
                _statusView2.layer.backgroundColor = [UIColor colorWithRed:213/255.0 green:218/255.0 blue:224/255.0 alpha:1].CGColor;
            }
        });
    }
}


#pragma mark - Lazy Load
- (NSMutableArray *)beanArray{
    if (!_beanArray) {
        _beanArray = [[NSMutableArray alloc] init];
        
    }
    return _beanArray;
}

- (UILabel *)status{
    if (!_status) {
        _status = [[UILabel alloc] initWithFrame:CGRectMake(159/WScale, 0, 80/WScale, 19/HScale)];
        _status.text = @"设备未连接";
        _status.textAlignment = NSTextAlignmentLeft;
        _status.textColor = [UIColor colorWithHexString:@"333333"];
        _status.font = [UIFont systemFontOfSize:13.f];
        [self.view addSubview:_status];
        
        _statusView = [[UIView alloc] init];
        _statusView.frame = CGRectMake(148/WScale,6.5/HScale,6/WScale,6/WScale);
        _statusView.layer.backgroundColor = [UIColor colorWithRed:254/255.0 green:71/255.0 blue:51/255.0 alpha:1].CGColor;
        _statusView.layer.shadowColor = [UIColor colorWithRed:254/255.0 green:71/255.0 blue:52/255.0 alpha:1].CGColor;
        _statusView.layer.shadowOffset = CGSizeMake(0,0);
        _statusView.layer.shadowOpacity = 1;
        _statusView.layer.cornerRadius = 3/WScale;
        [self.view addSubview:_statusView];
    }
    return _status;
}

- (UIImageView *)deviceImage{
    if (!_deviceImage) {
        _deviceImage = [[UIImageView alloc] initWithFrame:CGRectMake(117/WScale, 37/HScale, 140/WScale, 112/HScale)];
        _deviceImage.image = [UIImage imageNamed:@"img_logo_gray"];
        [self.view addSubview:_deviceImage];
        
    }
    return _deviceImage;
}

- (UILabel *)status1{
    if (!_status1) {
        _status1 = [[UILabel alloc] initWithFrame:CGRectMake(87/WScale, 175/HScale, 50/WScale, 17/HScale)];
        _status1.text = @"热机中";
        _status1.textAlignment = NSTextAlignmentLeft;
        _status1.textColor = [UIColor colorWithHexString:@"999999"];
        _status1.font = [UIFont systemFontOfSize:12.f];
        [self.view addSubview:_status1];
        
        _statusView1 = [[UIView alloc] init];
        _statusView1.frame = CGRectMake(74/WScale,180/HScale,6/WScale,6/WScale);
        _statusView1.layer.backgroundColor = [UIColor colorWithRed:213/255.0 green:218/255.0 blue:224/255.0 alpha:1].CGColor;
        _statusView1.layer.cornerRadius = 3/WScale;
        [self.view addSubview:_statusView1];
    }
    return _status1;
}

- (UILabel *)status2{
    if (!_status2) {
        _status2 = [[UILabel alloc] initWithFrame:CGRectMake(177/WScale, 175/HScale, 50/WScale, 17/HScale)];
        _status2.text = @"烘焙中";
        _status2.textAlignment = NSTextAlignmentLeft;
        _status2.textColor = [UIColor colorWithHexString:@"999999"];
        _status2.font = [UIFont systemFontOfSize:12.f];
        [self.view addSubview:_status2];
        
        _statusView2 = [[UIView alloc] init];
        _statusView2.frame = CGRectMake(163/WScale,180/HScale,6/WScale,6/WScale);
        _statusView2.layer.backgroundColor = [UIColor colorWithRed:213/255.0 green:218/255.0 blue:224/255.0 alpha:1].CGColor;
        _statusView2.layer.cornerRadius = 3/WScale;
        [self.view addSubview:_statusView2];
    }
    return _status2;
}

- (UILabel *)status3{
    if (!_status3) {
        _status3 = [[UILabel alloc] initWithFrame:CGRectMake(266/WScale, 175/HScale, 50/WScale, 17/HScale)];
        _status3.text = @"冷却中";
        _status3.textAlignment = NSTextAlignmentLeft;
        _status3.textColor = [UIColor colorWithHexString:@"999999"];
        _status3.font = [UIFont systemFontOfSize:12.f];
        [self.view addSubview:_status3];
        
        _statusView3 = [[UIView alloc] init];
        _statusView3.frame = CGRectMake(253/WScale,180/HScale,6/WScale,6/WScale);
        _statusView3.layer.backgroundColor = [UIColor colorWithRed:213/255.0 green:218/255.0 blue:224/255.0 alpha:1].CGColor;
        _statusView3.layer.cornerRadius = 3/WScale;
        [self.view addSubview:_statusView3];
    }
    return _status3;
}

- (UIView *)mainView{
    if (!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, (ScreenHeight - 64 - (tabbarHeight + kSafeArea_Bottom) - 400/HScale + 154/HScale - 90/HScale), ScreenWidth, 400/HScale)];//154是控制按钮view高度，刚好把控制按钮隐藏，90是bottonview高度
        _mainView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor;
        _mainView.layer.cornerRadius = 16;
        _mainView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.03].CGColor;
        _mainView.layer.shadowOffset = CGSizeMake(0,-6);
        _mainView.layer.shadowOpacity = 1;
        _mainView.layer.shadowRadius = 20;
        [self.view addSubview:_mainView];
        
        _powerBtn = [[UIButton alloc] init];
        _powerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (_myNet.powerStatus) {
            [_powerBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_power_on@2x.png"]] forState:UIControlStateNormal];
        }else{
            [_powerBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_power_off@2x.png"]] forState:UIControlStateNormal];
        }
        [_powerBtn addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        //_powerBtn.enabled = NO;
        [_mainView addSubview:_powerBtn];
        
        _fireBtn = [[UIButton alloc] init];
        _fireBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (_myNet.fireStatus) {
            [_fireBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_fire_on@2x.png"]] forState:UIControlStateNormal];
        }else{
            [_fireBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_fire_off@2x.png"]] forState:UIControlStateNormal];
        }
        [_fireBtn addTarget:self action:@selector(setFire) forControlEvents:UIControlEventTouchUpInside];
        _fireBtn.enabled = NO;
        [_mainView addSubview:_fireBtn];
        
        _stirBtn = [[UIButton alloc] init];
        _stirBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (_myNet.stirStatus) {
            [_stirBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_stir_on@2x.png"]] forState:UIControlStateNormal];
        }else{
            [_stirBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_stir_off@2x.png"]] forState:UIControlStateNormal];
        }
        [_stirBtn addTarget:self action:@selector(setStir) forControlEvents:UIControlEventTouchUpInside];
        _stirBtn.enabled = NO;
        [_mainView addSubview:_stirBtn];
        
        _coldBtn = [[UIButton alloc] init];
        _coldBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (_myNet.coolStatus) {
            [_coldBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_cold_on@2x.png"]] forState:UIControlStateNormal];
        }else{
            [_coldBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_cold_off@2x.png"]] forState:UIControlStateNormal];
        }
        [_coldBtn addTarget:self action:@selector(setCold) forControlEvents:UIControlEventTouchUpInside];
        _coldBtn.enabled = NO;
        [_mainView addSubview:_coldBtn];
        
        _firePBtn = [[UIButton alloc] init];
        _firePBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_firePBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_firepower_disable@2x.png"]] forState:UIControlStateNormal];
        [_firePBtn addTarget:self action:@selector(setFirePower) forControlEvents:UIControlEventTouchUpInside];
        _firePBtn.enabled = NO;
        [_mainView addSubview:_firePBtn];
        
        _windPBtn = [[UIButton alloc] init];
        _windPBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_windPBtn setImage:[UIImage imageWithContentsOfFile:[_resourcePath stringByAppendingPathComponent:@"btn_windpower_disable@2x.png"]] forState:UIControlStateNormal];
        [_windPBtn addTarget:self action:@selector(setWindPower) forControlEvents:UIControlEventTouchUpInside];
        _windPBtn.enabled = NO;
        [_mainView addSubview:_windPBtn];
        
        
        [_powerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 50/WScale));
            make.centerX.equalTo(_mainView.mas_centerX).offset(-125/WScale);
            make.top.equalTo(_mainView.mas_top).offset(246/HScale);
        }];
        [_fireBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 50/WScale));
            make.centerX.equalTo(_mainView.mas_centerX);
            make.top.equalTo(_mainView.mas_top).offset(246/HScale);
        }];
        [_stirBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 50/WScale));
            make.centerX.equalTo(_mainView.mas_centerX).offset(125/WScale);
            make.top.equalTo(_mainView.mas_top).offset(246/HScale);
        }];
        [_coldBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 50/WScale));
            make.centerX.equalTo(_mainView.mas_centerX).offset(-125/WScale);
            make.top.equalTo(_mainView.mas_top).offset(326/HScale);
        }];
        [_firePBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 50/WScale));
            make.centerX.equalTo(_mainView.mas_centerX);
            make.top.equalTo(_mainView.mas_top).offset(326/HScale);
        }];
        [_windPBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 50/WScale));
            make.centerX.equalTo(_mainView.mas_centerX).offset(125/WScale);
            make.top.equalTo(_mainView.mas_top).offset(326/HScale);
        }];
        
        UILabel *powerLabel = [[UILabel alloc] init];
        powerLabel.text = LocalString(@"电源");
        powerLabel.textAlignment = NSTextAlignmentCenter;
        powerLabel.textColor = [UIColor colorWithHexString:@"333333"];
        powerLabel.font = [UIFont systemFontOfSize:13.f];
        [_mainView addSubview:powerLabel];
        
        UILabel *fireLabel = [[UILabel alloc] init];
        fireLabel.text = LocalString(@"点火");
        fireLabel.textAlignment = NSTextAlignmentCenter;
        fireLabel.textColor = [UIColor colorWithHexString:@"333333"];
        fireLabel.font = [UIFont systemFontOfSize:13.f];
        [_mainView addSubview:fireLabel];
        
        UILabel *stirLabel = [[UILabel alloc] init];
        stirLabel.text = LocalString(@"搅拌");
        stirLabel.textAlignment = NSTextAlignmentCenter;
        stirLabel.textColor = [UIColor colorWithHexString:@"333333"];
        stirLabel.font = [UIFont systemFontOfSize:13.f];
        [_mainView addSubview:stirLabel];
        
        UILabel *coldLabel = [[UILabel alloc] init];
        coldLabel.text = LocalString(@"冷却");
        coldLabel.textAlignment = NSTextAlignmentCenter;
        coldLabel.textColor = [UIColor colorWithHexString:@"333333"];
        coldLabel.font = [UIFont systemFontOfSize:13.f];
        [_mainView addSubview:coldLabel];
        
        UILabel *firepLabel = [[UILabel alloc] init];
        firepLabel.text = LocalString(@"火力");
        firepLabel.textAlignment = NSTextAlignmentCenter;
        firepLabel.textColor = [UIColor colorWithHexString:@"333333"];
        firepLabel.font = [UIFont systemFontOfSize:13.f];
        [_mainView addSubview:firepLabel];
        
        UILabel *windpLabel = [[UILabel alloc] init];
        windpLabel.text = LocalString(@"风力");
        windpLabel.textAlignment = NSTextAlignmentCenter;
        windpLabel.textColor = [UIColor colorWithHexString:@"333333"];
        windpLabel.font = [UIFont systemFontOfSize:13.f];
        [_mainView addSubview:windpLabel];
        
        [powerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 19/HScale));
            make.centerX.equalTo(_powerBtn.mas_centerX);
            make.top.equalTo(_powerBtn.mas_bottom).offset(2/HScale);
        }];
        [fireLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 19/HScale));
            make.centerX.equalTo(_fireBtn.mas_centerX);
            make.top.equalTo(_fireBtn.mas_bottom).offset(2/HScale);
        }];
        [stirLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 19/HScale));
            make.centerX.equalTo(_stirBtn.mas_centerX);
            make.top.equalTo(_stirBtn.mas_bottom).offset(2/HScale);
        }];
        [coldLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 19/HScale));
            make.centerX.equalTo(_coldBtn.mas_centerX);
            make.top.equalTo(_coldBtn.mas_bottom).offset(2/HScale);
        }];
        [firepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 19/HScale));
            make.centerX.equalTo(_firePBtn.mas_centerX);
            make.top.equalTo(_firePBtn.mas_bottom).offset(2/HScale);
        }];
        [windpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 19/HScale));
            make.centerX.equalTo(_windPBtn.mas_centerX);
            make.top.equalTo(_windPBtn.mas_bottom).offset(2/HScale);
        }];
    }
    return _mainView;
}

- (UIImageView *)pointerImage{
    if (!_pointerImage) {
        UIImageView *scaleImage = [[UIImageView alloc] initWithFrame:CGRectMake(30/WScale, 30/HScale, 150/WScale, 150/HScale)];
        scaleImage.image = [UIImage imageNamed:@"img_scale"];
        [_mainView addSubview:scaleImage];
        
        _pointerImage = [[UIImageView alloc] initWithFrame:CGRectMake(30/WScale, 30/HScale, 150/WScale, 150/HScale)];
        _pointerImage.image = [UIImage imageNamed:@"img_pointer"];
        //当顺时针旋转120度时，指针转到129
        float temp = [_beanTempLabel.text floatValue];
        _pointerImage.transform = CGAffineTransformMakeRotation((temp / 129.f * 120.0) / 180 * M_PI);
        [_mainView addSubview:_pointerImage];
    }
    return _pointerImage;
}

- (UILabel *)beanTempLabel{
    if (!_beanTempLabel) {
        _beanTempLabel = [[UILabel alloc] init];
        _beanTempLabel.frame = CGRectMake(205/WScale,47/HScale,60/WScale,50/HScale);
        _beanTempLabel.text = LocalString(@"0.0");
        _beanTempLabel.textAlignment = NSTextAlignmentLeft;
        _beanTempLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        _beanTempLabel.font = [UIFont fontWithName:@"Avenir" size:40.f];
        _beanTempLabel.adjustsFontSizeToFitWidth = YES;
        [_mainView addSubview:_beanTempLabel];
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.text = LocalString(@"豆温");
        textLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.font = [UIFont systemFontOfSize:13.f];
        [_mainView addSubview:textLabel];
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40/WScale, 19/HScale));
            make.left.equalTo(_beanTempLabel.mas_right).offset(4/WScale);
            make.top.equalTo(_mainView.mas_top).offset(47/HScale);
        }];
        
        _beanTempUnitLabel = [[UILabel alloc] init];
        _beanTempUnitLabel.text = [DataBase shareDataBase].setting.tempUnit;
        _beanTempUnitLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        _beanTempUnitLabel.textAlignment = NSTextAlignmentLeft;
        _beanTempUnitLabel.font = [UIFont fontWithName:@"Avenir" size:20.f];
        [_mainView addSubview:_beanTempUnitLabel];
        [_beanTempUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40/WScale, 25/HScale));
            make.left.equalTo(_beanTempLabel.mas_right).offset(4/WScale);
            make.top.equalTo(_mainView.mas_top).offset(65/HScale);
        }];
    }
    return _beanTempLabel;
}

- (UILabel *)beanTempRateLabel{
    if (!_beanTempRateLabel) {
        _beanTempRateLabel = [[UILabel alloc] init];
        _beanTempRateLabel.frame = CGRectMake(210/WScale,93/HScale,100/WScale,20/HScale);
        _beanTempRateLabel.text = [NSString stringWithFormat:@"%.1f %@/min",0.0,[DataBase shareDataBase].setting.tempUnit];
        _beanTempRateLabel.textAlignment = NSTextAlignmentLeft;
        _beanTempRateLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        _beanTempRateLabel.font = [UIFont fontWithName:@"Avenir" size:16.f];
        _beanTempRateLabel.adjustsFontSizeToFitWidth = YES;
        [_mainView addSubview:_beanTempRateLabel];
    }
    return _beanTempRateLabel;
}

- (UILabel *)inTempLabel{
    if (!_inTempLabel) {
        _inTempLabel = [[UILabel alloc] init];
        _inTempLabel.frame = CGRectMake(70/WScale,181/HScale,80/WScale,25/WScale);
        _inTempLabel.text = [NSString stringWithFormat:@"%.1f%@",0.0,[DataBase shareDataBase].setting.tempUnit];
        _inTempLabel.textAlignment = NSTextAlignmentLeft;
        _inTempLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        _inTempLabel.font = [UIFont fontWithName:@"Avenir" size:18.f];
        _inTempLabel.adjustsFontSizeToFitWidth = YES;
        [_mainView addSubview:_inTempLabel];
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.text = LocalString(@"入风温");
        textLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.font = [UIFont systemFontOfSize:12.f];
        [_mainView addSubview:textLabel];
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 17/HScale));
            make.left.equalTo(_inTempLabel.mas_left);
            make.top.equalTo(_inTempLabel.mas_bottom);
        }];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_fan1"]];
        [_mainView addSubview:image];
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40/WScale, 40/WScale));
            make.right.equalTo(_inTempLabel.mas_left);
            make.top.equalTo(_inTempLabel.mas_top);
        }];
    }
    return _inTempLabel;
}

- (UILabel *)outTempLabel{
    if (!_outTempLabel) {
        _outTempLabel = [[UILabel alloc] init];
        _outTempLabel.frame = CGRectMake(182/WScale,181/HScale,80/WScale,25/WScale);
        _outTempLabel.text = [NSString stringWithFormat:@"%.1f%@",0.0,[DataBase shareDataBase].setting.tempUnit];
        _outTempLabel.textAlignment = NSTextAlignmentLeft;
        _outTempLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        _outTempLabel.font = [UIFont fontWithName:@"Avenir" size:18.f];
        _outTempLabel.adjustsFontSizeToFitWidth = YES;
        [_mainView addSubview:_outTempLabel];
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.text = LocalString(@"出风温");
        textLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.font = [UIFont systemFontOfSize:12.f];
        [_mainView addSubview:textLabel];
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 17/HScale));
            make.left.equalTo(_outTempLabel.mas_left);
            make.top.equalTo(_outTempLabel.mas_bottom);
        }];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_fan2"]];
        [_mainView addSubview:image];
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40/WScale, 40/WScale));
            make.right.equalTo(_outTempLabel.mas_left);
            make.top.equalTo(_outTempLabel.mas_top);
        }];
    }
    return _outTempLabel;
}

- (UILabel *)environTempLabel{
    if (!_environTempLabel) {
        _environTempLabel = [[UILabel alloc] init];
        _environTempLabel.frame = CGRectMake(294/WScale,181/HScale,80/WScale,25/WScale);
        _environTempLabel.text = [NSString stringWithFormat:@"%.1f%@",0.0,[DataBase shareDataBase].setting.tempUnit];
        _environTempLabel.textAlignment = NSTextAlignmentLeft;
        _environTempLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        _environTempLabel.font = [UIFont fontWithName:@"Avenir" size:18.f];
        _environTempLabel.adjustsFontSizeToFitWidth = YES;
        [_mainView addSubview:_environTempLabel];
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.text = LocalString(@"环境温");
        textLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.font = [UIFont systemFontOfSize:12.f];
        [_mainView addSubview:textLabel];
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 17/HScale));
            make.left.equalTo(_environTempLabel.mas_left);
            make.top.equalTo(_environTempLabel.mas_bottom);
        }];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_thermometer"]];
        [_mainView addSubview:image];
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40/WScale, 40/WScale));
            make.right.equalTo(_environTempLabel.mas_left);
            make.top.equalTo(_environTempLabel.mas_top);
        }];
    }
    return _environTempLabel;
}

- (UIScrollView *)beanNameView{
    if (_beanNameView) {
        [_beanNameView removeFromSuperview];
        _beanNameView = nil;
    }
    if (_beanNameLabel) {
        [_beanNameLabel removeFromSuperview];
        _beanNameLabel = nil;
    }
    NSString *string = @"";
    for (BeanModel *bean in _myNet.beanArray) {
        string = [string stringByAppendingString:bean.name];
        string = [string stringByAppendingString:@"、"];
    }
    if (![string isEqualToString:@""]) {
        string = [string substringWithRange:NSMakeRange(0, string.length - 1)];
    }
    _beanNameLabel = [[UILabel alloc] init];
    _beanNameLabel.text = string;
    _beanNameLabel.font = [UIFont systemFontOfSize:14.f];
    _beanNameLabel.textColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1];
    NSDictionary *attr = @{NSFontAttributeName:[UIFont systemFontOfSize:14.f]};
    CGSize size = [_beanNameLabel.text boundingRectWithSize:CGSizeMake(ScreenWidth, ScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    _beanNameLabel.frame = (CGRect){CGPointZero,size};
    
    
    _beanNameView = [[UIScrollView alloc] init];
    _beanNameView.contentSize = size;
    _beanNameView.showsHorizontalScrollIndicator = NO;
    [_beanNameView addSubview:_beanNameLabel];
    [_mainView addSubview:_beanNameView];
    
    [_beanNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(155/WScale, size.height));
        make.left.equalTo(_mainView.mas_left).offset(205/WScale);
        make.top.equalTo(_beanTempRateLabel.mas_bottom).offset(18/HScale);
    }];
    
    //对srcollView添加点击响应
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [_beanNameView addGestureRecognizer:singleTapRecognizer];

    
    if (size.width > 155/WScale) {
        [UIView animateWithDuration:5
                              delay:0
                            options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationCurveLinear
                         animations:^{
                             CGPoint point = _beanNameView.contentOffset;
                             point.x = size.width - 155/WScale;
                             _beanNameView.contentOffset = point;
                         }
                         completion:^(BOOL finished) {
                             
                         }
         ];
    }
    return _beanNameView;
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, (ScreenHeight - 64 - (tabbarHeight + kSafeArea_Bottom) - 90/HScale), ScreenWidth, 90/HScale)];
        _bottomView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor;
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIButton *)bakeCurveBtn{
    if (!_bakeCurveBtn) {
        _bakeCurveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bakeCurveBtn.frame = CGRectMake(87/WScale, 10/HScale, 201/WScale, 50/HScale);
        //[_bakeCurveBtn setImage:[UIImage imageNamed:@"btn_baking_curve"] forState:UIControlStateNormal];
        [_bakeCurveBtn setTitle:LocalString(@"烘焙曲线") forState:UIControlStateNormal];
        [_bakeCurveBtn.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
        [_bakeCurveBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_bakeCurveBtn addTarget:self action:@selector(goBakeCurveViewController) forControlEvents:UIControlEventTouchUpInside];
        
        // gradient
        CAGradientLayer *gl = [CAGradientLayer layer];
        gl.frame = CGRectMake(87.5/HScale,0.5/HScale,200/WScale,49/HScale);
        gl.position = _bakeCurveBtn.center;
        [_bottomView.layer addSublayer:gl];
        gl.cornerRadius = 24.5/HScale;
        gl.startPoint = CGPointMake(0.41, 1);
        gl.endPoint = CGPointMake(0.41, 0);
        gl.colors = @[(__bridge id)[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor];
        gl.locations = @[@(0), @(1.0f)];

        _bakeCurveBtn.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
        _bakeCurveBtn.layer.shadowOffset = CGSizeMake(0,0);
        _bakeCurveBtn.layer.shadowOpacity = 1;
        _bakeCurveBtn.layer.shadowRadius = 10;
        _bakeCurveBtn.layer.borderColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1].CGColor;
        _bakeCurveBtn.layer.borderWidth = 1.f;
        _bakeCurveBtn.layer.cornerRadius = 24.5;
        [_bottomView addSubview:_bakeCurveBtn];
    }
    return _bakeCurveBtn;
}

- (UIButton *)addBeanBtn{
    if (!_addBeanBtn) {
        _addBeanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBeanBtn.frame = CGRectMake(309/WScale,10/HScale,50/WScale,50/WScale);
        [_addBeanBtn setImage:[UIImage imageNamed:@"btn_add"] forState:UIControlStateNormal];
        [_addBeanBtn addTarget:self action:@selector(addCoffeeBean) forControlEvents:UIControlEventTouchUpInside];
        _addBeanBtn.tag = unselect;
        [_bottomView addSubview:_addBeanBtn];
        
        _addBeanBtn.layer.cornerRadius = 25/WScale;
        _addBeanBtn.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
        _addBeanBtn.layer.shadowOffset = CGSizeMake(0,0);
        _addBeanBtn.layer.shadowOpacity = 1;
        _addBeanBtn.layer.shadowRadius = 10;
    }
    return _addBeanBtn;
}

- (UIButton *)showControlViewBtn{
    if (!_showControlViewBtn) {
        _showControlViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _showControlViewBtn.frame = CGRectMake(16/WScale,10/HScale,50/WScale,50/WScale);
        [_showControlViewBtn setImage:[UIImage imageNamed:@"btn_expand"] forState:UIControlStateNormal];
        [_showControlViewBtn addTarget:self action:@selector(showControlView:) forControlEvents:UIControlEventTouchUpInside];
        _showControlViewBtn.tag = unselect;
        [_bottomView addSubview:_showControlViewBtn];
        
        _showControlViewBtn.layer.cornerRadius = 25/WScale;
        _showControlViewBtn.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
        _showControlViewBtn.layer.shadowOffset = CGSizeMake(0,0);
        _showControlViewBtn.layer.shadowOpacity = 1;
        _showControlViewBtn.layer.shadowRadius = 10;
    }
    return _showControlViewBtn;

}


@end
