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
@interface BakeViewController ()

@property (nonatomic, strong) UIButton *bakeCurveBtn;
@property (nonatomic, strong) UIButton *addBeanBtn;

@property (nonatomic, strong) UIView *beanTempView;
@property (nonatomic, strong) UILabel *beanTempLabel;
@property (nonatomic, strong) UILabel *beanTempRateLabel;
@property (nonatomic, strong) UILabel *status;

@property (nonatomic, strong) UIView *inTempView;
@property (nonatomic, strong) UIView *outTempView;
@property (nonatomic, strong) UIView *environTempView;

@property (nonatomic, strong) UIView *line1;
@property (nonatomic, strong) UIView *line2;
@property (nonatomic, strong) UIView *line3;

@end

@implementation BakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LocalString(@"烘焙");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setImage:[UIImage imageNamed:@"ic_details"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(connectMachine) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;

    _beanTempView = [self beanTempView];
    _inTempView = [self inTempView];
    _outTempView = [self outTempView];
    _environTempView = [self environTempView];
    _bakeCurveBtn = [self bakeCurveBtn];
    _addBeanBtn = [self addBeanBtn];
    _line1 = [self line1];
    [self uiMasonry];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _line2 = [self line2];
    _line3 = [self line3];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}

#pragma mark - Lazy Load
- (UIView *)beanTempView{
    if (!_beanTempView) {
        _beanTempView = [[UIView alloc] init];
        _beanTempView.backgroundColor = [UIColor whiteColor];
        _beanTempView.layer.cornerRadius = 90;
        _beanTempView.layer.masksToBounds = YES;
        _beanTempView.layer.borderWidth = 1;
        _beanTempView.layer.borderColor = [[UIColor blackColor] CGColor];
        
        //图片
        UIImageView *beanImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_bake_bean"]];
        [_beanTempView addSubview:beanImage];
        UILabel *beanLabel = [[UILabel alloc] init];
        beanLabel.text = LocalString(@"豆温");
        beanLabel.font = [UIFont systemFontOfSize:20.0];
        [_beanTempView addSubview:beanLabel];
        
        UIView *line = [[UIView alloc] init];
        
        [beanImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.right.equalTo(_beanTempView.mas_centerX).offset(-5);
            make.top.equalTo(_beanTempView.mas_top).offset(20);
        }];
        [beanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 40));
            make.left.equalTo(_beanTempView.mas_centerX).offset(5);
            make.centerY.equalTo(beanImage.mas_centerY);
        }];
        
        [self.view addSubview:_beanTempView];
    }
    return _beanTempView;
}

- (UIView *)inTempView{
    if (!_inTempView) {
        _inTempView = [[UIView alloc] init];
        _inTempView.backgroundColor = [UIColor whiteColor];
        _inTempView.layer.cornerRadius = 45;
        _inTempView.layer.masksToBounds = YES;
        _inTempView.layer.borderWidth = 1;
        _inTempView.layer.borderColor = [[UIColor blackColor] CGColor];
        
        [self.view addSubview:_inTempView];
    }
    return _inTempView;
}

- (UIView *)outTempView{
    if (!_outTempView) {
        _outTempView = [[UIView alloc] init];
        _outTempView.backgroundColor = [UIColor whiteColor];
        _outTempView.layer.cornerRadius = 45;
        _outTempView.layer.masksToBounds = YES;
        _outTempView.layer.borderWidth = 1;
        _outTempView.layer.borderColor = [[UIColor blackColor] CGColor];
        
        [self.view addSubview:_outTempView];
    }
    return _outTempView;
}

- (UIView *)environTempView{
    if (!_environTempView) {
        _environTempView = [[UIView alloc] init];
        _environTempView.backgroundColor = [UIColor whiteColor];
        _environTempView.layer.cornerRadius = 45;
        _environTempView.layer.masksToBounds = YES;
        _environTempView.layer.borderWidth = 1;
        _environTempView.layer.borderColor = [[UIColor blackColor] CGColor];
        
        [self.view addSubview:_environTempView];
    }
    return _environTempView;
}

- (UIView *)line1{
    if (!_line1) {
        _line1 = [[UIView alloc] init];
        _line1.backgroundColor = [UIColor blackColor];
        
        [self.view addSubview:_line1];
    }
    return _line1;
}

- (UIView *)line2{
    if (!_line2) {
        _line2 = [[UIView alloc] init];
        _line2.backgroundColor = [UIColor blackColor];
        
        //计算中心点和长度
        //三条边
        float a = fabs(_beanTempView.center.x - _inTempView.center.x);
        float b = fabs(_beanTempView.center.y - _inTempView.center.y);
        float c = sqrtf(a*a + b*b);
        //小三角形三条边
        float c1 = 90.0;
        float a1 = a * (c1 / c);
        float b1 = b * (c1 / c);
        //大圆上的点坐标
        float bigX = _beanTempView.center.x - a1;
        float bigY = _beanTempView.center.y + b1;
        //求小圆上的点坐标
        float c2 = c - 45.0;
        float a2 = a - a * (c2 / c);
        float b2 = b - b * (c2 / c);
        float smallX = _inTempView.center.x + a2;
        float smallY = _inTempView.center.y - b2;
        //线的中心点
        _line2.frame = CGRectMake(0, 0, 1, c - 90 - 45 - 2);
        _line2.center = CGPointMake((bigX + smallX)/2, (smallY + bigY)/2);
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(30 * M_PI / 180.0);
        [_line2 setTransform:transform];
        
        [self.view addSubview:_line2];
    }
    return _line2;
}

- (UIView *)line3{
    if (!_line3) {
        _line3 = [[UIView alloc] init];
        _line3.backgroundColor = [UIColor blackColor];
        
        //计算中心点和长度
        //三条边
        float a = fabs(_beanTempView.center.x - _environTempView.center.x);
        float b = fabs(_beanTempView.center.y - _environTempView.center.y);
        float c = sqrtf(a*a + b*b);
        //小三角形三条边
        float c1 = 90.0;
        float a1 = a * (c1 / c);
        float b1 = b * (c1 / c);
        //大圆上的点坐标
        float bigX = _beanTempView.center.x + a1;
        float bigY = _beanTempView.center.y + b1;
        //求小圆上的点坐标
        float c2 = c - 45.0;
        float a2 = a - a * (c2 / c);
        float b2 = b - b * (c2 / c);
        float smallX = _environTempView.center.x - a2;
        float smallY = _environTempView.center.y - b2;
        //线的中心点
        _line3.frame = CGRectMake(0, 0, 1, c - 90 - 45 - 2);
        _line3.center = CGPointMake((bigX + smallX)/2, (smallY + bigY)/2);
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(-30 * M_PI / 180.0);
        [_line3 setTransform:transform];
        
        [self.view addSubview:_line3];
    }
    return _line3;
}

- (UIButton *)bakeCurveBtn{
    if (!_bakeCurveBtn) {
        _bakeCurveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //_bakeCurveBtn.frame = CGRectMake(100, 400, 200, 80);
        [_bakeCurveBtn setTitle:LocalString(@"烘焙曲线") forState:UIControlStateNormal];
        [_bakeCurveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_bakeCurveBtn setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.1];
        [_bakeCurveBtn setBackgroundColor:[UIColor colorWithHexString:@"996640"]];
        [_bakeCurveBtn addTarget:self action:@selector(goBakeCurveViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_bakeCurveBtn];
    }
    return _bakeCurveBtn;
}

- (UIButton *)addBeanBtn{
    if (!_addBeanBtn) {
        _addBeanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBeanBtn setTitle:LocalString(@"添加咖啡豆") forState:UIControlStateNormal];
        [_addBeanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addBeanBtn setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.3];
        [_addBeanBtn setBackgroundColor:[UIColor colorWithHexString:@"996640"]];
        [_addBeanBtn addTarget:self action:@selector(addCoffeeBean) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_addBeanBtn];
    }
    return _addBeanBtn;
}

- (void)uiMasonry{
    [_beanTempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(180, 180));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(30);
    }];
    
    [_inTempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 90));
        make.centerX.equalTo(self.view.mas_centerX).offset(-(90/2 + (ScreenWidth - 90*3)/4 + 90/2));
        make.top.equalTo(self.beanTempView.mas_bottom).offset(45);
    }];
    
    [_outTempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 90));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.beanTempView.mas_bottom).offset(90);
    }];
    
    [_environTempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 90));
        make.centerX.equalTo(self.view.mas_centerX).offset(90/2 + (ScreenWidth - 90*3)/4 + 90/2);
        make.top.equalTo(self.beanTempView.mas_bottom).offset(45);
    }];
    
    [_line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(1, 86));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.beanTempView.mas_bottom).offset(2);
    }];
    
    [_bakeCurveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.8, buttonHeight));
        make.bottom.equalTo(self.view.mas_bottom).offset(-(tabbarHeight) - 10);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [_addBeanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.33, buttonHeight));
        make.bottom.equalTo(_bakeCurveBtn.mas_top).offset(-20);
        make.right.equalTo(_bakeCurveBtn.mas_right);
    }];
}

#pragma mark - Actions
- (void)addCoffeeBean{
    
}

- (void)goBakeCurveViewController{
    BakeCurveViewController *bakeCurveVC = [[BakeCurveViewController alloc] init];
    [self presentViewController:bakeCurveVC animated:YES completion:nil];
}

- (void)connectMachine{
    DeviceViewController *deviceVC = [[DeviceViewController alloc] init];
    [self.navigationController pushViewController:deviceVC animated:YES];
}


@end
