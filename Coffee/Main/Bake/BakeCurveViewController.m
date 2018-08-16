//
//  BakeCurveViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/2.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BakeCurveViewController.h"
#import "AppDelegate.h"
#import <Charts/Charts-Swift.h>
#import "FMDB.h"
#import "BeanModel.h"
#import "EventModel.h"
#import "LeftFuncController.h"
#import "RightFuncController.h"

#define buttonHeight 30

@interface BakeCurveViewController () <ChartViewDelegate>

@property (nonatomic, strong) LineChartView *chartView;

///@brief UI Component
@property (nonatomic, strong) UILabel *bakeTime;
@property (nonatomic, strong) UILabel *developRate;
@property (nonatomic, strong) UILabel *developTime;
@property (nonatomic, strong) UILabel *beanTempLabel;
@property (nonatomic, strong) UILabel *inTempLabel;
@property (nonatomic, strong) UILabel *outTempLabel;
@property (nonatomic, strong) UILabel *environTempLabel;
@property (nonatomic, strong) UILabel *beanTempRateLabel;
@property (nonatomic, strong) UIButton *leftPopBtn;
@property (nonatomic, strong) UIButton *rightPopBtn;
@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) NetWork *myNet;

@property (nonatomic, strong) NSArray *eventArray;

@end

@implementation BakeCurveViewController
{
    double leftAxisMax;
    NSInteger curveId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //强制亮屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    _myNet = [NetWork shareNetWork];
    
    _chartView = [self chartView];
    _bakeTime = [self bakeTime];
    _developRate = [self developRate];
    _developTime = [self developTime];
    _beanTempLabel = [self beanTempLabel];
    _inTempLabel = [self inTempLabel];
    _outTempLabel = [self outTempLabel];
    _environTempLabel = [self environTempLabel];
    _beanTempRateLabel = [self beanTempRateLabel];
    _leftPopBtn = [self leftPopBtn];
    _rightPopBtn = [self rightPopBtn];
    _backBtn = [self backBtn];
    [self uiMasonry];
    
    [_myNet addObserver:self forKeyPath:@"tempData" options:NSKeyValueObservingOptionNew context:nil];
    [_myNet addObserver:self forKeyPath:@"timerValue" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bakeCompelete) name:@"bakeCompelete" object:nil];
    
    [self setDataValue:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)dealloc{
    [_myNet removeObserver:self forKeyPath:@"tempData"];
    [_myNet removeObserver:self forKeyPath:@"timerValue"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"bakeCompelete" object:nil];
}

#pragma mark - lazy load
- (LineChartView *)chartView{
    if (!_chartView) {
        _chartView = [[LineChartView alloc] init];
        _chartView.frame = CGRectMake(45/HScale, 87/WScale, ScreenHeight - 87/HScale, ScreenWidth - 100/WScale);
        [self.view addSubview:_chartView];
        
        UILabel *leftLabel = [[UILabel alloc] init];
        leftLabel.text = LocalString(@"(℃)");
        leftLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        leftLabel.textColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        leftLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:leftLabel];

        UILabel *rightLabel = [[UILabel alloc] init];
        rightLabel.text = LocalString(@"(℃/min)");
        rightLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        rightLabel.textColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        rightLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:rightLabel];

        UILabel *bottomLabel = [[UILabel alloc] init];
        bottomLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        bottomLabel.textColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        bottomLabel.text = LocalString(@"(min)");
        [self.view addSubview:bottomLabel];

        [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(22/HScale, 15/WScale));
            make.left.equalTo(_chartView.mas_left);
            make.bottom.equalTo(_chartView.mas_top).offset(3);
        }];
        [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(47/HScale, 12/WScale));
            make.right.equalTo(_chartView.mas_right);
            make.bottom.equalTo(_chartView.mas_top).offset(3);
        }];
        [bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(29/HScale, 12/WScale));
            make.left.equalTo(_chartView.mas_right).offset(-15/HScale);
            make.bottom.equalTo(_chartView.mas_bottom);
        }];
        
        _chartView.noDataText = LocalString(@"暂无数据");
        _chartView.delegate = self;
        
        _chartView.chartDescription.enabled = NO;
        
        _chartView.dragEnabled = YES;
        [_chartView setScaleEnabled:YES];//缩放
        [_chartView setScaleYEnabled:NO];
        
        
        _chartView.drawGridBackgroundEnabled = NO;//网格线
        _chartView.pinchZoomEnabled = YES;
        //_chartView.doubleTapToZoomEnabled = NO;//取消双击缩放
        //_chartView.dragDecelerationEnabled = NO;//拖拽后是否有惯性效果
        //_chartView.dragDecelerationFrictionCoef = 0;//拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
        
        _chartView.backgroundColor = [UIColor clearColor];
        
        
        //_chartView.legend.enabled = NO;//不显示图例说明
        ChartLegend *l = _chartView.legend;
        l.form = ChartLegendFormLine;
        l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
        l.textColor = UIColor.whiteColor;
        l.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
        l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
        l.orientation = ChartLegendOrientationHorizontal;
        l.drawInside = YES;//legend显示在图表里
        
        ChartXAxis *xAxis = _chartView.xAxis;
        xAxis.labelFont = [UIFont fontWithName:@"Avenir-Light" size:12];
        xAxis.labelTextColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        xAxis.drawGridLinesEnabled = NO;
        xAxis.drawAxisLineEnabled = NO;
        xAxis.labelPosition = XAxisLabelPositionBottom;
        //xAxis.axisRange = 30;
        //xAxis.granularityEnabled = YES;
        //xAxis.granularity = 10.0;
        
        
        ChartYAxis *leftAxis = _chartView.leftAxis;
        leftAxis.labelTextColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        leftAxis.labelFont = [UIFont fontWithName:@"Avenir-Light" size:12];
        leftAxis.axisMaximum = 140 - 0.5;
        leftAxisMax = 140 - 0.5;
        leftAxis.axisMinimum = 0.0;
        leftAxis.spaceTop = 30.f;
        leftAxis.drawGridLinesEnabled = YES;
        leftAxis.gridLineWidth = 0.6f;
        leftAxis.gridColor = [UIColor colorWithHexString:@"EBEDF0"];
        //leftAxis.gridLineDashLengths = @[@5.f,@5.f];//虚线
        leftAxis.drawZeroLineEnabled = NO;
        leftAxis.granularityEnabled = YES;
        
        ChartYAxis *rightAxis = _chartView.rightAxis;
        rightAxis.labelFont = [UIFont fontWithName:@"Avenir-Light" size:12];
        rightAxis.labelTextColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        rightAxis.axisMaximum = 10.0;
        rightAxis.axisMinimum = 0;
        rightAxis.drawGridLinesEnabled = NO;
        rightAxis.granularityEnabled = NO;
        
        [_chartView animateWithXAxisDuration:1.0];
        
    }
    
    return _chartView;
}

- (UILabel *)bakeTime{
    if (!_bakeTime) {
        _bakeTime = [[UILabel alloc] init];
        _bakeTime.textAlignment = NSTextAlignmentLeft;
        _bakeTime.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _bakeTime.text = @"07:45";
        _bakeTime.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.view addSubview:_bakeTime];
    }
    return _bakeTime;
}

- (UILabel *)developRate{
    if (!_developRate) {
        _developRate = [[UILabel alloc] init];
        _developRate.textAlignment = NSTextAlignmentLeft;
        _developRate.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _developRate.text = @"70.2%";
        _developRate.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.view addSubview:_developRate];
    }
    return _developRate;
}

- (UILabel *)developTime{
    if (!_developTime) {
        _developTime = [[UILabel alloc] init];
        _developTime.textAlignment = NSTextAlignmentLeft;
        _developTime.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _developTime.text = @"05:40";
        _developTime.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.view addSubview:_developTime];
    }
    return _developTime;
}

- (UILabel *)beanTempLabel{
    if (!_beanTempLabel) {
        _beanTempLabel = [[UILabel alloc] init];
        _beanTempLabel.textAlignment = NSTextAlignmentLeft;
        _beanTempLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _beanTempLabel.text = @"200.5℃";
        _beanTempLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.view addSubview:_beanTempLabel];
    }
    return _beanTempLabel;
}

- (UILabel *)inTempLabel{
    if (!_inTempLabel) {
        _inTempLabel = [[UILabel alloc] init];
        _inTempLabel.textAlignment = NSTextAlignmentLeft;
        _inTempLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _inTempLabel.text = @"25.3℃";
        _inTempLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.view addSubview:_inTempLabel];
    }
    return _inTempLabel;
}

- (UILabel *)outTempLabel{
    if (!_outTempLabel) {
        _outTempLabel = [[UILabel alloc] init];
        _outTempLabel.textAlignment = NSTextAlignmentLeft;
        _outTempLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _outTempLabel.text = @"212.2℃";
        _outTempLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.view addSubview:_outTempLabel];
    }
    return _outTempLabel;
}

- (UILabel *)environTempLabel{
    if (!_environTempLabel) {
        _environTempLabel = [[UILabel alloc] init];
        _environTempLabel.textAlignment = NSTextAlignmentLeft;
        _environTempLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _environTempLabel.text = @"212.0℃";
        _environTempLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.view addSubview:_environTempLabel];
    }
    return _environTempLabel;
}

- (UILabel *)beanTempRateLabel{
    if (!_beanTempRateLabel) {
        _beanTempRateLabel = [[UILabel alloc] init];
        _beanTempRateLabel.textAlignment = NSTextAlignmentLeft;
        _beanTempRateLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _beanTempRateLabel.text = @"-5.4℃/min";
        _beanTempRateLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.view addSubview:_beanTempRateLabel];
    }
    return _beanTempRateLabel;
}

- (UIButton *)leftPopBtn{
    if (!_leftPopBtn) {
        _leftPopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftPopBtn setImage:[UIImage imageNamed:@"ic_leftpop"] forState:UIControlStateNormal];
        [_leftPopBtn addTarget:self action:@selector(popLeftControlView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_leftPopBtn];
    }
    return _leftPopBtn;
}

- (UIButton *)rightPopBtn{
    if (!_rightPopBtn) {
        _rightPopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightPopBtn setImage:[UIImage imageNamed:@"ic_leftpop"] forState:UIControlStateNormal];
        [_rightPopBtn addTarget:self action:@selector(popRightControlView) forControlEvents:UIControlEventTouchUpInside];
        CGAffineTransform transform = CGAffineTransformMakeRotation(-180 * M_PI / 180.0);
        [_rightPopBtn setTransform:transform];
        [self.view addSubview:_rightPopBtn];
    }
    return _rightPopBtn;
}

- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(15/WScale,19/HScale,22/WScale,22/HScale);
        [_backBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_backBtn];

    }
    return _backBtn;
}

- (void)uiMasonry{
    UILabel *bakeTimeL = [[UILabel alloc] init];
    bakeTimeL.textAlignment = NSTextAlignmentLeft;
    bakeTimeL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    bakeTimeL.text = @"烘焙时间";
    bakeTimeL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:bakeTimeL];
    
    UILabel *developRateL = [[UILabel alloc] init];
    developRateL.textAlignment = NSTextAlignmentLeft;
    developRateL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    developRateL.text = @"发展率";
    developRateL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:developRateL];
    
    UILabel *developTimeL = [[UILabel alloc] init];
    developTimeL.textAlignment = NSTextAlignmentLeft;
    developTimeL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    developTimeL.text = @"发展时间";
    developTimeL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:developTimeL];
    
    UILabel *beanTempLabelL = [[UILabel alloc] init];
    beanTempLabelL.textAlignment = NSTextAlignmentLeft;
    beanTempLabelL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    beanTempLabelL.text = @"豆温";
    beanTempLabelL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:beanTempLabelL];
    
    UIView *view1 = [[UIView alloc] init];
    view1.frame = CGRectMake(282/HScale,17/WScale,5/HScale,5/WScale);
    view1.backgroundColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1];
    view1.layer.cornerRadius = 2.5f/WScale;
    [self.view addSubview:view1];
    
    UILabel *inTempLabelL = [[UILabel alloc] init];
    inTempLabelL.textAlignment = NSTextAlignmentLeft;
    inTempLabelL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    inTempLabelL.text = @"进风温";
    inTempLabelL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:inTempLabelL];
    
    UIView *view2 = [[UIView alloc] init];
    view2.frame = CGRectMake(357/HScale,17/WScale,5/HScale,5/WScale);
    view2.backgroundColor = [UIColor colorWithRed:123/255.0 green:179/255.0 blue:64/255.0 alpha:1];
    view2.layer.cornerRadius = 2.5f/WScale;
    [self.view addSubview:view2];
    
    UILabel *outTempLabelL = [[UILabel alloc] init];
    outTempLabelL.textAlignment = NSTextAlignmentLeft;
    outTempLabelL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    outTempLabelL.text = @"出风温";
    outTempLabelL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:outTempLabelL];
    
    UIView *view3 = [[UIView alloc] init];
    view3.frame = CGRectMake(432/HScale,17/WScale,5/HScale,5/WScale);
    view3.backgroundColor = [UIColor colorWithRed:80/255.0 green:227/255.0 blue:194/255.0 alpha:1];
    view3.layer.cornerRadius = 2.5f/WScale;
    [self.view addSubview:view3];
    
    UILabel *environTempLabelL = [[UILabel alloc] init];
    environTempLabelL.textAlignment = NSTextAlignmentLeft;
    environTempLabelL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    environTempLabelL.text = @"环境温";
    environTempLabelL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:environTempLabelL];
    
    UIView *view4 = [[UIView alloc] init];
    view4.frame = CGRectMake(507/HScale,17/WScale,5/HScale,5/WScale);
    view4.backgroundColor = [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1];
    view4.layer.cornerRadius = 2.5f/WScale;
    [self.view addSubview:view4];
    
    UILabel *beanTempRateLabelL = [[UILabel alloc] init];
    beanTempRateLabelL.textAlignment = NSTextAlignmentLeft;
    beanTempRateLabelL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    beanTempRateLabelL.text = @"升温率";
    beanTempRateLabelL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:beanTempRateLabelL];
    
    UIView *view5 = [[UIView alloc] init];
    view5.frame = CGRectMake(582/HScale,17/WScale,5/HScale,5/WScale);
    view5.backgroundColor = [UIColor colorWithRed:255/255.0 green:71/255.0 blue:51/255.0 alpha:1];
    view5.layer.cornerRadius = 2.5f/WScale;
    [self.view addSubview:view5];
    
    [bakeTimeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(48/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(self.view.mas_left).offset(47/HScale);
    }];
    [_bakeTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36/HScale, 13/WScale));
        make.top.mas_equalTo(bakeTimeL.mas_bottom).offset(8/WScale);
        make.left.mas_equalTo(self.view.mas_left).offset(47/HScale);
    }];
    
    [developTimeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(48/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(bakeTimeL.mas_right).offset(27/HScale);
    }];
    [_developTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(37/HScale, 13/WScale));
        make.top.mas_equalTo(developTimeL.mas_bottom).offset(8/WScale);
        make.left.mas_equalTo(_bakeTime.mas_right).offset(39/HScale);
    }];
    
    [developRateL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(developTimeL.mas_right).offset(27/HScale);
    }];
    [_developRate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(39/HScale, 13/WScale));
        make.top.mas_equalTo(developRateL.mas_bottom).offset(8/WScale);
        make.left.mas_equalTo(_developTime.mas_right).offset(37/HScale);
    }];
    
    UIView *separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
    [self.view addSubview:separatorView];
    
    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(0.5/HScale, 34/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(developRateL.mas_right).offset(24/HScale);
    }];
    
    [beanTempLabelL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(24/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(developRateL.mas_right).offset(56/HScale);
    }];
    [_beanTempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(52/HScale, 13/WScale));
        make.top.mas_equalTo(beanTempLabelL.mas_bottom).offset(8/WScale);
        make.left.mas_equalTo(_developRate.mas_right).offset(47/HScale);
    }];
    
    [inTempLabelL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(beanTempLabelL.mas_right).offset(51/HScale);
    }];
    [_inTempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(43/HScale, 13/WScale));
        make.top.mas_equalTo(inTempLabelL.mas_bottom).offset(8/WScale);
        make.left.mas_equalTo(_beanTempLabel.mas_right).offset(24/HScale);
    }];
    
    [outTempLabelL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(inTempLabelL.mas_right).offset(39/HScale);
    }];
    [_outTempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(49/HScale, 13/WScale));
        make.top.mas_equalTo(outTempLabelL.mas_bottom).offset(8/WScale);
        make.left.mas_equalTo(_inTempLabel.mas_right).offset(32/HScale);
    }];
    
    [environTempLabelL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(outTempLabelL.mas_right).offset(39/HScale);
    }];
    [_environTempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(49/HScale, 13/WScale));
        make.top.mas_equalTo(environTempLabelL.mas_bottom).offset(8/WScale);
        make.left.mas_equalTo(_outTempLabel.mas_right).offset(26/HScale);
    }];
    
    [beanTempRateLabelL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(environTempLabelL.mas_right).offset(39/HScale);
    }];
    [_beanTempRateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(69/HScale, 13/WScale));
        make.top.mas_equalTo(beanTempRateLabelL.mas_bottom).offset(8/WScale);
        make.left.mas_equalTo(_environTempLabel.mas_right).offset(26/HScale);
    }];
    
    [_leftPopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.left.equalTo(self.view.mas_left);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    [_rightPopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.right.equalTo(self.view.mas_right);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    
    //用来点击隐藏曲线，覆盖在温度文字上面
    UIButton *beanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    beanBtn.frame = CGRectMake(272/HScale,0,75/HScale,60/WScale);
    [beanBtn setBackgroundColor:[UIColor clearColor]];
    [beanBtn addTarget:self action:@selector(beanCurveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:beanBtn];
    
    UIButton *inBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    inBtn.frame = CGRectMake(347/HScale,0,75/HScale,60/WScale);
    [inBtn setBackgroundColor:[UIColor clearColor]];
    [inBtn addTarget:self action:@selector(inCurveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inBtn];
    
    UIButton *outBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    outBtn.frame = CGRectMake(422/HScale,0,75/HScale,60/WScale);
    [outBtn setBackgroundColor:[UIColor clearColor]];
    [outBtn addTarget:self action:@selector(outCurveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:outBtn];
    
    UIButton *environBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    environBtn.frame = CGRectMake(497/HScale,0,75/HScale,60/WScale);
    [environBtn setBackgroundColor:[UIColor clearColor]];
    [environBtn addTarget:self action:@selector(environCurveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:environBtn];
    
    UIButton *upTempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    upTempBtn.frame = CGRectMake(572/HScale,0,75/HScale,60/WScale);
    [upTempBtn setBackgroundColor:[UIColor clearColor]];
    [upTempBtn addTarget:self action:@selector(upTempCurveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:upTempBtn];
}

#pragma mark - 设置横屏
- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}

#pragma mark - actions
- (void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)popLeftControlView{
    LeftFuncController *lfVC = [[LeftFuncController alloc] init];
    lfVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    lfVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:lfVC animated:YES completion:nil];

}

- (void)popRightControlView{
    RightFuncController *rfVC = [[RightFuncController alloc] init];
    rfVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    rfVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:rfVC animated:YES completion:nil];

}

- (void)beanCurveAction{
    NSLog(@"1");
}

- (void)inCurveAction{
    NSLog(@"2");
}

- (void)outCurveAction{
    NSLog(@"3");
}

- (void)environCurveAction{
    NSLog(@"4");
}

- (void)upTempCurveAction{
    NSLog(@"5");
}

- (void)setPower{
    
}

- (void)setDataValue:(NSArray *)dataArray
{
    NSDictionary *tempDic = [NSObject readLocalFileWithName:@"数据"];
    NSArray *beanTemp = tempDic[@"temp2"];
    NSMutableArray *yVals = [NSMutableArray array];
    for (int i = 0, j = 0; i < [beanTemp count]; i++) {
        [yVals addObject:[[ChartDataEntry alloc] initWithX:i y:[beanTemp[i] doubleValue]]];

//        if (i != 0) {
//            [_yVals_diff addObject:[[ChartDataEntry alloc] initWithX:i y:([beanTemp[i] doubleValue] - [beanTemp[i-1] doubleValue])]];
//        }
//
//        j = i * 10;
//        if (j != 0 && j < [beanTemp count]) {
//            [_yVals_diff addObject:[[ChartDataEntry alloc] initWithX:j y:([beanTemp[j] doubleValue] - [beanTemp[j-10] doubleValue])/10]];
//        }
    }
    
    LineChartDataSet *set1 = nil, *set2 = nil, *set3 = nil, *set4 = nil, *test = nil;
    
    if (_chartView.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
        set1.values = _myNet.yVals_Out;
        
        //set2 = (LineChartDataSet *)_chartView.data.dataSets[1];
        //set2.values = _myNet.yVals_In;
        
        set3 = (LineChartDataSet *)_chartView.data.dataSets[1];
        set3.values = _myNet.yVals_Bean;
        
       // set4 = (LineChartDataSet *)_chartView.data.dataSets[3];
       // set4.values = _myNet.yVals_Environment;
        
//        //实时调整y轴最大值
//        if (tempOut > leftAxisMax) {
//            _chartView.leftAxis.axisMaximum = tempOut + 30;
//        }
        
        if (_myNet.yVals_Out.count > 150) {
            _chartView.xAxis.axisRange = 15;
            [_chartView setVisibleXRangeWithMinXRange:0.5 maxXRange:UI_IS_IPHONE5?4:5];
        }
        
        [_chartView.data notifyDataChanged];
        [_chartView notifyDataSetChanged];
    }
    else
    {
        test = [[LineChartDataSet alloc] initWithValues:yVals label:LocalString(@"test")];
        test.axisDependency = AxisDependencyLeft;
        [test setColor:[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]];
        [test setCircleColor:UIColor.whiteColor];
        test.lineWidth = 2.0;
        test.circleRadius = 0.0;
        test.fillAlpha = 65/255.0;
        test.fillColor = [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
        test.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        test.drawCircleHoleEnabled = NO;
        test.drawValuesEnabled = NO;//是否在拐点处显示数据
        test.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        
        set1 = [[LineChartDataSet alloc] initWithValues:_myNet.yVals_Out label:LocalString(@"进风温")];
        set1.axisDependency = AxisDependencyLeft;
        [set1 setColor:[UIColor colorWithRed:123/255.0 green:179/255.0 blue:64/255.0 alpha:1]];
        [set1 setCircleColor:UIColor.whiteColor];
        set1.lineWidth = 2.0;
        set1.circleRadius = 0.0;
        set1.fillAlpha = 65/255.0;
        set1.fillColor = [UIColor colorWithRed:123/255.0 green:179/255.0 blue:64/255.0 alpha:1];
        //set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        set1.drawCircleHoleEnabled = NO;
        set1.drawValuesEnabled = NO;//是否在拐点处显示数据
        //set1.cubicIntensity = 5;//曲线弧度
        set1.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        //set1.mode = LineChartModeCubicBezier;
        
        set2 = [[LineChartDataSet alloc] initWithValues:_myNet.yVals_In label:LocalString(@"出风温")];
        set2.axisDependency = AxisDependencyLeft;
        [set2 setColor:[UIColor colorWithRed:80/255.0 green:227/255.0 blue:194/255.0 alpha:1]];
        [set2 setCircleColor:UIColor.whiteColor];
        set2.lineWidth = 2.0;
        set2.circleRadius = 0.0;
        set2.fillAlpha = 65/255.0;
        set2.fillColor = [UIColor colorWithRed:80/255.0 green:227/255.0 blue:194/255.0 alpha:1];
        set2.drawCircleHoleEnabled = NO;
        set2.drawValuesEnabled = NO;//是否在拐点处显示数据
        //set1.cubicIntensity = 1;//曲线弧度
        set2.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        
        set3 = [[LineChartDataSet alloc] initWithValues:_myNet.yVals_Bean label:LocalString(@"豆温")];
        set3.axisDependency = AxisDependencyLeft;
        [set3 setColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        [set3 setCircleColor:UIColor.whiteColor];
        set3.lineWidth = 2.0;
        set3.circleRadius = 0.0;
        set3.fillAlpha = 65/255.0;
        set3.fillColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1];
        set3.drawCircleHoleEnabled = NO;
        set3.drawValuesEnabled = NO;//是否在拐点处显示数据
        //set1.cubicIntensity = 1;//曲线弧度
        set3.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        
        set4 = [[LineChartDataSet alloc] initWithValues:_myNet.yVals_Environment label:LocalString(@"环境温")];
        set4.axisDependency = AxisDependencyLeft;
        [set4 setColor:[UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1]];
        [set4 setCircleColor:UIColor.whiteColor];
        set4.lineWidth = 2.0;
        set4.circleRadius = 0.0;
        set4.fillAlpha = 65/255.0;
        set4.fillColor = [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1];
        set4.drawCircleHoleEnabled = NO;
        set4.drawValuesEnabled = NO;//是否在拐点处显示数据
        //set1.cubicIntensity = 1;//曲线弧度
        set4.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:test];
        //[dataSets addObject:set1];
        //[dataSets addObject:set2];
        //[dataSets addObject:set3];
        //[dataSets addObject:set4];
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        [data setValueTextColor:UIColor.whiteColor];
        [data setValueFont:[UIFont systemFontOfSize:9.f]];
        
        _chartView.xAxis.axisRange = 15;
        [_chartView setVisibleXRangeWithMinXRange:0.5 maxXRange:UI_IS_IPHONE5?4:5];

        _chartView.xAxis.labelCount = 6;
        _chartView.data = data;
    }
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

- (void)chartScaled:(ChartViewBase * _Nonnull)chartView scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY{
    NSLog(@"图表缩放");
}

- (void)chartTranslated:(ChartViewBase * _Nonnull)chartView dX:(CGFloat)dX dY:(CGFloat)dY{
    NSLog(@"图表移动");
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"tempData"] && object == _myNet) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setDataValue:_myNet.tempData];
        });
        NSMutableArray *data = [_myNet.recivedData68 copy];
        double tempOut = ([data[6] intValue] * 256 + [data[7] intValue]) / 10.0;
        double tempIn = ([data[8] intValue] * 256 + [data[9] intValue]) / 10.0;
        double tempBean = ([data[10] intValue] * 256 + [data[11] intValue]) / 10.0;
        double tempEnvironment = ([data[12] intValue] * 256 + [data[13] intValue]) / 10.0;
        
        //_beanTempRateLabel.text = [NSString stringWithFormat:@"△豆温:%f℃/min",tempOut];
        _beanTempLabel.text = [NSString stringWithFormat:@"豆温:%f℃",tempBean];
        _inTempLabel.text = [NSString stringWithFormat:@"进风温:%f℃",tempIn];
        _outTempLabel.text = [NSString stringWithFormat:@"出风温:%f℃",tempOut];
        _environTempLabel.text = [NSString stringWithFormat:@"环境温:%f℃",tempEnvironment];

    }else if ([keyPath isEqualToString:@"timerValue"] && object == _myNet){
        long minute = _myNet.timerValue / 60;
        long second = _myNet.timerValue % 60;
        _bakeTime.text = [NSString stringWithFormat:@"%@ %ld:%ld",LocalString(@"已烘焙时间:"),minute,second];
    }
}

- (void)bakeCompelete{
    //ToDo 弹框
    
    //如果烘焙时间不再增加的话使用下行代码
    [_myNet removeObserver:self forKeyPath:@"timerValue"];
    [_myNet removeObserver:self forKeyPath:@"timeData"];
    
    DataBase *myDB = [DataBase shareDataBase];
    
    //曲线名字
    NSString *curveName = @"";
    if (_beanArray.count > 2) {
        curveName = [NSString stringWithFormat:@"拼配豆(%@)",myDB.deviceName];
    }else if (_beanArray.count == 1){
        BeanModel *bean = _beanArray[0];
        curveName = [NSString stringWithFormat:@"%@(%@)",bean.beanName,myDB.deviceName];
    }
    
    //生豆重量
    NSUInteger totolWeight = 0;
    if (_beanArray) {
        for (BeanModel *bean in _beanArray) {
            totolWeight += bean.weight;
        }
    }
    
    //曲线数据
    NSString *curveValueJson;
    if (_myNet.yVals_Out && _myNet.yVals_In && _myNet.yVals_Bean && _myNet.yVals_Environment && _myNet.yVals_Diff) {
        NSArray *outTArray = [_myNet.yVals_Out copy];
        NSArray *inTArray = [_myNet.yVals_In copy];
        NSArray *beanTArray = [_myNet.yVals_Bean copy];
        NSArray *enTArray = [_myNet.yVals_Environment copy];
        NSArray *diffTArray = [_myNet.yVals_Diff copy];
        
        NSDictionary *curveValueDic = @{@"out":outTArray,@"in":inTArray,@"bean":beanTArray,@"environment":enTArray,@"diff":diffTArray};
        NSData *curveData = [NSJSONSerialization dataWithJSONObject:curveValueDic options:NSJSONWritingPrettyPrinted error:nil];
        curveValueJson = [[NSString alloc] initWithData:curveData encoding:NSUTF8StringEncoding];
    }
    
    //添加报告并更新数据的事务
    [myDB.queueDB inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        BOOL result = [db executeUpdate:@"INSERT INTO curveInfo (curveName,date,deviceName,rawBeanWeight,bakeBeanWeight,light,bakeTime,developTime,developRate,bakerName,curveValue) VALUES (?,?,?,?,?,?,?,?,?,?,?)",curveName,[NSDate localStringFromUTCDate:[NSDate date]],myDB.deviceName,totolWeight,@0,@0,_myNet.timerValue,[_developTime.text integerValue],_developRate.text,myDB.userName,curveValueJson];
        //test
        //BOOL result = [db executeUpdate:@"INSERT INTO curveInfo (curveName,date,deviceName,rawBeanWeight,bakeBeanWeight,light,bakeTime,developTime,developRate,bakerName,curveValue) VALUES (?,?,?,?,?,?,?,?,?,?,?)",@"",[NSDate localStringFromUTCDate:[NSDate date]],@"",@0,@0,@0,@0,@0,@"",@"",@""];
        if (!result) {
            *rollback = YES;
            return;
        }
        
        FMResultSet *set = [db executeQuery:@"SELECT last_insert_rowid() FROM curveInfo"];
        while ([set next]) {
            curveId = [set intForColumnIndex:0];
        }
        NSLog(@"%ld",(long)curveId);
        [set close];
        
        //插入曲线事件关联
        for (int i = 0; i < _eventArray.count; i++) {
            EventModel *event = _eventArray[i];
            result = [db executeUpdate:@"INSERT INTO curve_event (curveId,eventId,eventTime,eventBeanTemp) VALUES (?,?,?,?)",curveId,event.eventId,event.eventTime,event.eventBeanTemp];
            if (!result) {
                *rollback = YES;
                return;
            }
        }
        
        //插入曲线生豆关联
        for (int i = 0; i < _beanArray.count; i++) {
            BeanModel *bean = _beanArray[i];
            result = [db executeUpdate:@"INSERT INTO bean_curve (beanId,curveId,beanWeight) VALUES (?,?,?)",bean.beanId,[NSNumber numberWithInteger:curveId],bean.weight];
            if (!result) {
                *rollback = YES;
                return;
            }
        }
    }];
}

@end
