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
#import "AddBeanTableViewCell.h"
#import "BeanModel.h"
#import "AddBeanTableController.h"

#define buttonHeight 44

NSString *const kCellIdentifier_addBean = @"cellID_addBean";

@interface BakeViewController () <UITableViewDelegate,UITableViewDataSource>

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
@property (nonatomic, strong) UILabel *beanTempRateLabel;
@property (nonatomic, strong) UILabel *inTempLabel;
@property (nonatomic, strong) UILabel *outTempLabel;
@property (nonatomic, strong) UILabel *environTempLabel;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *showControlViewBtn;
@property (nonatomic, strong) UIButton *bakeCurveBtn;
@property (nonatomic, strong) UIButton *addBeanBtn;


@end

@implementation BakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = LocalString(@"烘焙");
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1]];
    [self.view setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1]];
    
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
    
    _bottomView = [self bottomView];
    _showControlViewBtn = [self showControlViewBtn];
    _bakeCurveBtn = [self bakeCurveBtn];
    _addBeanBtn = [self addBeanBtn];
    
    _myNet = [NetWork shareNetWork];
    [_myNet addObserver:self forKeyPath:@"tempData" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
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
        _statusView.layer.backgroundColor = [UIColor colorWithRed:126/255.0 green:211/255.0 blue:33/255.0 alpha:1].CGColor;
        _statusView.layer.shadowColor = [UIColor colorWithRed:106/255.0 green:255/255.0 blue:77/255.0 alpha:1].CGColor;
        _statusView.layer.shadowOffset = CGSizeMake(0,0);
        _statusView.layer.shadowOpacity = 1;
        _statusView.layer.shadowRadius = 8;
        _statusView.layer.cornerRadius = 3/WScale;
        [self.view addSubview:_statusView];
    }
    return _status;
}

- (UIImageView *)deviceImage{
    if (!_deviceImage) {
        _deviceImage = [[UIImageView alloc] initWithFrame:CGRectMake(75/WScale, 18/HScale, 225/WScale, 150/HScale)];
        _deviceImage.image = [UIImage imageNamed:@"img_peak_edmund"];
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
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 210/HScale, ScreenWidth, 420/HScale)];
        _mainView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor;
        _mainView.layer.cornerRadius = 16;
        _mainView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.03].CGColor;
        _mainView.layer.shadowOffset = CGSizeMake(0,-6);
        _mainView.layer.shadowOpacity = 1;
        _mainView.layer.shadowRadius = 20;
        [self.view addSubview:_mainView];
        
        UIButton *power = [[UIButton alloc] init];
        power = [UIButton buttonWithType:UIButtonTypeCustom];
        [power setImage:[UIImage imageNamed:@"btn_power_off"] forState:UIControlStateNormal];
        [power addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:power];
        
        UIButton *fire = [[UIButton alloc] init];
        fire = [UIButton buttonWithType:UIButtonTypeCustom];
        [fire setImage:[UIImage imageNamed:@"btn_fire_off"] forState:UIControlStateNormal];
        [fire addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:fire];
        
        UIButton *stir = [[UIButton alloc] init];
        stir = [UIButton buttonWithType:UIButtonTypeCustom];
        [stir setImage:[UIImage imageNamed:@"btn_stir_off"] forState:UIControlStateNormal];
        [stir addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:stir];
        
        UIButton *cold = [[UIButton alloc] init];
        cold = [UIButton buttonWithType:UIButtonTypeCustom];
        [cold setImage:[UIImage imageNamed:@"btn_cold_off"] forState:UIControlStateNormal];
        [cold addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:cold];
        
        UIButton *fireP = [[UIButton alloc] init];
        fireP = [UIButton buttonWithType:UIButtonTypeCustom];
        [fireP setImage:[UIImage imageNamed:@"btn_firepower_disable"] forState:UIControlStateNormal];
        [fireP addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:fireP];
        
        UIButton *windP = [[UIButton alloc] init];
        windP = [UIButton buttonWithType:UIButtonTypeCustom];
        [windP setImage:[UIImage imageNamed:@"btn_windpower_disable"] forState:UIControlStateNormal];
        [windP addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:windP];
        
        
        [power mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 50/WScale));
            make.centerX.equalTo(_mainView.mas_centerX).offset(-125/WScale);
            make.top.equalTo(_mainView.mas_top).offset(246/HScale);
        }];
        [fire mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 50/WScale));
            make.centerX.equalTo(_mainView.mas_centerX);
            make.top.equalTo(_mainView.mas_top).offset(246/HScale);
        }];
        [stir mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 50/WScale));
            make.centerX.equalTo(_mainView.mas_centerX).offset(125/WScale);
            make.top.equalTo(_mainView.mas_top).offset(246/HScale);
        }];
        [cold mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 50/WScale));
            make.centerX.equalTo(_mainView.mas_centerX).offset(-125/WScale);
            make.top.equalTo(_mainView.mas_top).offset(326/HScale);
        }];
        [fireP mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 50/WScale));
            make.centerX.equalTo(_mainView.mas_centerX);
            make.top.equalTo(_mainView.mas_top).offset(326/HScale);
        }];
        [windP mas_makeConstraints:^(MASConstraintMaker *make) {
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
            make.centerX.equalTo(power.mas_centerX);
            make.top.equalTo(power.mas_bottom).offset(2/HScale);
        }];
        [fireLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 19/HScale));
            make.centerX.equalTo(fire.mas_centerX);
            make.top.equalTo(fire.mas_bottom).offset(2/HScale);
        }];
        [stirLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 19/HScale));
            make.centerX.equalTo(stir.mas_centerX);
            make.top.equalTo(stir.mas_bottom).offset(2/HScale);
        }];
        [coldLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 19/HScale));
            make.centerX.equalTo(cold.mas_centerX);
            make.top.equalTo(cold.mas_bottom).offset(2/HScale);
        }];
        [firepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 19/HScale));
            make.centerX.equalTo(fireP.mas_centerX);
            make.top.equalTo(fireP.mas_bottom).offset(2/HScale);
        }];
        [windpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50/WScale, 19/HScale));
            make.centerX.equalTo(windP.mas_centerX);
            make.top.equalTo(windP.mas_bottom).offset(2/HScale);
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
        _pointerImage.transform = CGAffineTransformMakeRotation(140.0 / 180 * M_PI);
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
        
        UILabel *unitLabel = [[UILabel alloc] init];
        unitLabel.text = LocalString(@"°C");
        unitLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        unitLabel.textAlignment = NSTextAlignmentLeft;
        unitLabel.font = [UIFont fontWithName:@"Avenir" size:20.f];
        [_mainView addSubview:unitLabel];
        [unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
        _beanTempRateLabel.text = [NSString stringWithFormat:@"%.1f %@",0.0,LocalString(@"°C/min")];
        _beanTempRateLabel.textAlignment = NSTextAlignmentLeft;
        _beanTempRateLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        _beanTempRateLabel.font = [UIFont fontWithName:@"Avenir" size:16.f];
        [_mainView addSubview:_beanTempRateLabel];
    }
    return _beanTempRateLabel;
}

- (UILabel *)inTempLabel{
    if (!_inTempLabel) {
        _inTempLabel = [[UILabel alloc] init];
        _inTempLabel.frame = CGRectMake(70/WScale,181/HScale,80/WScale,25/WScale);
        _inTempLabel.text = [NSString stringWithFormat:@"%.1f%@",0.0,LocalString(@"°C")];
        _inTempLabel.textAlignment = NSTextAlignmentLeft;
        _inTempLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        _inTempLabel.font = [UIFont fontWithName:@"Avenir" size:18.f];
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
        _outTempLabel.text = [NSString stringWithFormat:@"%.1f%@",0.0,LocalString(@"°C")];
        _outTempLabel.textAlignment = NSTextAlignmentLeft;
        _outTempLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        _outTempLabel.font = [UIFont fontWithName:@"Avenir" size:18.f];
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
        _environTempLabel.text = [NSString stringWithFormat:@"%.1f%@",0.0,LocalString(@"°C")];
        _environTempLabel.textAlignment = NSTextAlignmentLeft;
        _environTempLabel.textColor = [UIColor colorWithHexString:@"4778CC"];
        _environTempLabel.font = [UIFont fontWithName:@"Avenir" size:18.f];
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

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 461/HScale, ScreenWidth, 110/HScale)];
        _bottomView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor;
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIButton *)bakeCurveBtn{
    if (!_bakeCurveBtn) {
        _bakeCurveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bakeCurveBtn.frame = CGRectMake(87/WScale, 10/HScale, 201/WScale, 50/HScale);
        [_bakeCurveBtn setTitle:LocalString(@"烘焙曲线") forState:UIControlStateNormal];
        [_bakeCurveBtn.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
        [_bakeCurveBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_bakeCurveBtn addTarget:self action:@selector(goBakeCurveViewController) forControlEvents:UIControlEventTouchUpInside];
        
        _bakeCurveBtn.layer.borderColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1].CGColor;
        // gradient
        CAGradientLayer *gl = [CAGradientLayer layer];
        gl.frame = CGRectMake(87.5/HScale,0.5/HScale,200/WScale,49/HScale);
        gl.position = _bakeCurveBtn.center;
        [_bottomView.layer addSublayer:gl];
        gl.cornerRadius = 24.5/HScale;
        gl.startPoint = CGPointMake(0.41318634152412415, 1);
        gl.endPoint = CGPointMake(0.41318634152412415, 0);
        gl.colors = @[(__bridge id)[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor];
        gl.locations = @[@(0), @(1.0f)];
        
        _bakeCurveBtn.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
        _bakeCurveBtn.layer.shadowOffset = CGSizeMake(0,0);
        _bakeCurveBtn.layer.shadowOpacity = 1;
        _bakeCurveBtn.layer.shadowRadius = 10;
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

#pragma mark - Actions

- (void)goBakeCurveViewController{
    BakeCurveViewController *bakeCurveVC = [[BakeCurveViewController alloc] init];
    [self presentViewController:bakeCurveVC animated:YES completion:nil];
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
            _mainView.frame = CGRectMake(0, 50/HScale, size.width, size.height);
            [sender setImage:[UIImage imageNamed:@"btn_collapse"] forState:UIControlStateNormal];
        }];
    }else{
        sender.tag = unselect;
        [UIView animateWithDuration:0.5 animations:^{
            CGSize size = _mainView.frame.size;
            _mainView.frame = CGRectMake(0, 210/HScale, size.width, size.height);
            [sender setImage:[UIImage imageNamed:@"btn_expand"] forState:UIControlStateNormal];
        }];
    }
}

- (void)connectMachine{
    DeviceViewController *deviceVC = [[DeviceViewController alloc] init];
    [self.navigationController pushViewController:deviceVC animated:YES];
}

- (void)setPower{
    
}

- (void)setFire{
    [[NetWork shareNetWork] bakeFire];
}


- (void)getCurve{
    
}

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _beanArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddBeanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_addBean];
    if (cell == nil) {
        cell = [[AddBeanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier_addBean];
    }
    BeanModel *cellModel = _beanArray[indexPath.row];
    cell.numLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    cell.beanName.text = cellModel.name;
    cell.delBlock = ^{
        [_beanArray removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    };
    return cell;
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"tempData"] && object == _myNet) {
        NSMutableArray *data = [_myNet.recivedData68 copy];
        double tempOut = ([data[6] intValue] * 256 + [data[7] intValue]) / 10.0;
        double tempIn = ([data[8] intValue] * 256 + [data[9] intValue]) / 10.0;
        double tempBean = ([data[10] intValue] * 256 + [data[11] intValue]) / 10.0;
        double tempEnvironment = ([data[12] intValue] * 256 + [data[13] intValue]) / 10.0;
        
       // _beanTempRateLabel.text = [NSString stringWithFormat:@"%f℃/min",tempOut];
        dispatch_async(dispatch_get_main_queue(), ^{
            _beanTempLabel.text = [NSString stringWithFormat:@"%f℃",tempBean];
            _inTempLabel.text = [NSString stringWithFormat:@"%f℃",tempIn];
            _outTempLabel.text = [NSString stringWithFormat:@"%f℃",tempOut];
            _environTempLabel.text = [NSString stringWithFormat:@"%f℃",tempEnvironment];
        });
        
    }
}

@end
