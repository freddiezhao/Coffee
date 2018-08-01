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
@property (nonatomic, strong) UIView *leftControlView;
@property (nonatomic, strong) UIButton *rightPopBtn;
@property (nonatomic, strong) UIView *rightControlView;

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
    [self uiMasonry];
    _leftControlView = [self leftControlView];
    _rightControlView = [self rightControlView];
    
    [_myNet addObserver:self forKeyPath:@"tempData" options:NSKeyValueObservingOptionNew context:nil];
    [_myNet addObserver:self forKeyPath:@"timerValue" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bakeCompelete) name:@"bakeCompelete" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        _chartView.frame = CGRectMake(60, 70, ScreenHeight - 120, ScreenWidth - 70 - 30);
        [self.view addSubview:_chartView];
        
        UILabel *leftLabel = [[UILabel alloc] init];
        leftLabel.font = [UIFont systemFontOfSize:13.f];
        leftLabel.text = LocalString(@"温度(℃)");
        leftLabel.textAlignment = NSTextAlignmentCenter;
        CGAffineTransform transform = CGAffineTransformMakeRotation(-90 * M_PI / 180.0);
        [leftLabel setTransform:transform];
        [self.view addSubview:leftLabel];
        
        UILabel *rightLabel = [[UILabel alloc] init];
        rightLabel.font = [UIFont systemFontOfSize:13.f];
        rightLabel.text = LocalString(@"升温速率(℃)");
        rightLabel.textAlignment = NSTextAlignmentCenter;
        CGAffineTransform transform1 = CGAffineTransformMakeRotation(-90 * M_PI / 180.0);
        [rightLabel setTransform:transform1];
        [self.view addSubview:rightLabel];
        
        UILabel *bottomLabel = [[UILabel alloc] init];
        bottomLabel.font = [UIFont systemFontOfSize:13.f];
        bottomLabel.text = LocalString(@"时间(min)");
        [self.view addSubview:bottomLabel];
        
        [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 30));
            make.right.equalTo(_chartView.mas_left).offset(35);
            make.centerY.equalTo(_chartView.mas_centerY);
        }];
        [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 30));
            make.left.equalTo(_chartView.mas_right).offset(-35);
            make.centerY.equalTo(_chartView.mas_centerY);
        }];
        [bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 30));
            make.top.equalTo(_chartView.mas_bottom);
            make.centerX.equalTo(_chartView.mas_centerX);
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
        
        _chartView.backgroundColor = [UIColor colorWithWhite:204/255.f alpha:1.f];
        
        
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
        xAxis.labelFont = [UIFont systemFontOfSize:11.f];
        xAxis.labelTextColor = UIColor.whiteColor;
        xAxis.drawGridLinesEnabled = NO;
        xAxis.drawAxisLineEnabled = NO;
        //xAxis.axisRange = 30;
        //xAxis.granularityEnabled = YES;
        //xAxis.granularity = 10.0;
        
        
        ChartYAxis *leftAxis = _chartView.leftAxis;
        leftAxis.labelTextColor = [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
        leftAxis.axisMaximum = 50 - 0.5;
        leftAxisMax = 50 - 0.5;
        leftAxis.axisMinimum = 0.0;
        leftAxis.drawGridLinesEnabled = YES;
        //leftAxis.gridLineDashLengths = @[@5.f,@5.f];//虚线
        leftAxis.drawZeroLineEnabled = NO;
        leftAxis.granularityEnabled = YES;
        
        ChartYAxis *rightAxis = _chartView.rightAxis;
        rightAxis.labelTextColor = UIColor.redColor;
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
        _bakeTime.font = [UIFont systemFontOfSize:13.0];
        _bakeTime.text = @"已烘焙时间: 02:35";
        [self.view addSubview:_bakeTime];
    }
    return _bakeTime;
}

- (UILabel *)developRate{
    if (!_developRate) {
        _developRate = [[UILabel alloc] init];
        _developRate.textAlignment = NSTextAlignmentCenter;
        _developRate.font = [UIFont systemFontOfSize:13.0];
        _developRate.text = @"发展率: 20%";
        [self.view addSubview:_developRate];
    }
    return _developRate;
}

- (UILabel *)developTime{
    if (!_developTime) {
        _developTime = [[UILabel alloc] init];
        _developTime.textAlignment = NSTextAlignmentRight;
        _developTime.font = [UIFont systemFontOfSize:13.0];
        _developTime.text = @"发展时间: 01:35";
        [self.view addSubview:_developTime];
    }
    return _developTime;
}

- (UILabel *)beanTempLabel{
    if (!_beanTempLabel) {
        _beanTempLabel = [[UILabel alloc] init];
        _beanTempLabel.textAlignment = NSTextAlignmentLeft;
        _beanTempLabel.font = [UIFont systemFontOfSize:13.0];
        _beanTempLabel.text = @"豆温:200℃";
        [self.view addSubview:_beanTempLabel];
    }
    return _beanTempLabel;
}

- (UILabel *)inTempLabel{
    if (!_inTempLabel) {
        _inTempLabel = [[UILabel alloc] init];
        _inTempLabel.textAlignment = NSTextAlignmentLeft;
        _inTempLabel.font = [UIFont systemFontOfSize:13.0];
        _inTempLabel.text = @"进风温:20℃";
        [self.view addSubview:_inTempLabel];
    }
    return _inTempLabel;
}

- (UILabel *)outTempLabel{
    if (!_outTempLabel) {
        _outTempLabel = [[UILabel alloc] init];
        _outTempLabel.textAlignment = NSTextAlignmentLeft;
        _outTempLabel.font = [UIFont systemFontOfSize:13.0];
        _outTempLabel.text = @"出风温:50℃";
        [self.view addSubview:_outTempLabel];
    }
    return _outTempLabel;
}

- (UILabel *)environTempLabel{
    if (!_environTempLabel) {
        _environTempLabel = [[UILabel alloc] init];
        _environTempLabel.textAlignment = NSTextAlignmentLeft;
        _environTempLabel.font = [UIFont systemFontOfSize:13.0];
        _environTempLabel.text = @"环境温:240℃";
        [self.view addSubview:_environTempLabel];
    }
    return _environTempLabel;
}

- (UILabel *)beanTempRateLabel{
    if (!_beanTempRateLabel) {
        _beanTempRateLabel = [[UILabel alloc] init];
        _beanTempRateLabel.textAlignment = NSTextAlignmentLeft;
        _beanTempRateLabel.font = [UIFont systemFontOfSize:13.0];
        _beanTempRateLabel.text = @"△豆温:5.19℃/min";
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

- (UIView *)leftControlView{
    if (!_leftControlView) {
        _leftControlView = [[UIView alloc] initWithFrame:CGRectMake(-90, 0, 90, ScreenWidth)];
        _leftControlView.backgroundColor = [UIColor colorWithHexString:yColor_back];
        _leftControlView.alpha = 0.9;
        _leftControlView.tag = unselect;
        [self.view addSubview:_leftControlView];
        [self.view bringSubviewToFront:_leftControlView];
        
        float gap = (ScreenWidth - buttonHeight * 7) / 8;
        UIButton *power = [[UIButton alloc] initWithFrame:CGRectMake(15, gap, 60, buttonHeight)];
        [power setTitle:LocalString(@"电源") forState:UIControlStateNormal];
        [power setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [power.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [power setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [power setBackgroundColor:[UIColor darkGrayColor]];
        [power addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_leftControlView addSubview:power];
        
        UIButton *fire = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 2 + buttonHeight, 60, buttonHeight)];
        [fire setTitle:LocalString(@"点火") forState:UIControlStateNormal];
        [fire setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [fire.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [fire setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [fire setBackgroundColor:[UIColor darkGrayColor]];
        [fire addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_leftControlView addSubview:fire];
        
        UIButton *stir = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 3 + buttonHeight * 2, 60, buttonHeight)];
        [stir setTitle:LocalString(@"搅拌") forState:UIControlStateNormal];
        [stir setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [stir.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [stir setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [stir setBackgroundColor:[UIColor darkGrayColor]];
        [stir addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_leftControlView addSubview:stir];
        
        UIButton *cooling = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 4 + buttonHeight * 3, 60, buttonHeight)];
        [cooling setTitle:LocalString(@"冷却") forState:UIControlStateNormal];
        [cooling setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cooling.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [cooling setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [cooling setBackgroundColor:[UIColor darkGrayColor]];
        [cooling addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_leftControlView addSubview:cooling];
        
        UIButton *firePower = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 5 + buttonHeight * 4, 60, buttonHeight)];
        [firePower setTitle:LocalString(@"火力") forState:UIControlStateNormal];
        [firePower setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [firePower.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [firePower setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [firePower setBackgroundColor:[UIColor darkGrayColor]];
        [firePower addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_leftControlView addSubview:firePower];
        
        UIButton *windPower = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 6 + buttonHeight * 5, 60, buttonHeight)];
        [windPower setTitle:LocalString(@"风力") forState:UIControlStateNormal];
        [windPower setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [windPower.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [windPower setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [windPower setBackgroundColor:[UIColor darkGrayColor]];
        [windPower addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_leftControlView addSubview:windPower];
        
        UIButton *switchBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 7 + buttonHeight * 6, 60, buttonHeight)];
        [switchBtn setTitle:LocalString(@"切换") forState:UIControlStateNormal];
        [switchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [switchBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [switchBtn setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [switchBtn setBackgroundColor:[UIColor darkGrayColor]];
        [switchBtn addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_leftControlView addSubview:switchBtn];
    }
    return _leftControlView;
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

- (UIView *)rightControlView{
    if (!_rightControlView) {
        _rightControlView = [[UIView alloc] initWithFrame:CGRectMake(ScreenHeight, 0, 90, ScreenWidth)];
        _rightControlView.backgroundColor = [UIColor colorWithHexString:yColor_back];
        _rightControlView.alpha = 0.9;
        _rightControlView.tag = unselect;
        [self.view addSubview:_rightControlView];
        [self.view bringSubviewToFront:_rightControlView];

        float gap = (ScreenWidth - buttonHeight * 10) / 11;
        UIButton *startBake = [[UIButton alloc] initWithFrame:CGRectMake(15, gap, 60, buttonHeight)];
        [startBake setTitle:LocalString(@"开始烘焙") forState:UIControlStateNormal];
        [startBake.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [startBake setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [startBake setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [startBake setBackgroundColor:[UIColor darkGrayColor]];
        [startBake addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_rightControlView addSubview:startBake];
        
        UIButton *dehyOver = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 2 + buttonHeight * 1, 60, buttonHeight)];
        [dehyOver setTitle:LocalString(@"脱水结束") forState:UIControlStateNormal];
        [dehyOver setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dehyOver.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [dehyOver setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [dehyOver setBackgroundColor:[UIColor darkGrayColor]];
        [dehyOver addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_rightControlView addSubview:dehyOver];
        
        UIButton *firstBurst = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 3 + buttonHeight * 2, 60, buttonHeight)];
        [firstBurst setTitle:LocalString(@"一爆开始") forState:UIControlStateNormal];
        [firstBurst setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [firstBurst.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [firstBurst setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [firstBurst setBackgroundColor:[UIColor darkGrayColor]];
        [firstBurst addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_rightControlView addSubview:firstBurst];
        
        UIButton *firstBurstOver = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 4 + buttonHeight * 3, 60, buttonHeight)];
        [firstBurstOver setTitle:LocalString(@"一爆结束") forState:UIControlStateNormal];
        [firstBurstOver setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [firstBurstOver.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [firstBurstOver setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [firstBurstOver setBackgroundColor:[UIColor darkGrayColor]];
        [firstBurstOver addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_rightControlView addSubview:firstBurstOver];
        
        UIButton *secondBurst = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 5 + buttonHeight * 4, 60, buttonHeight)];
        [secondBurst setTitle:LocalString(@"二爆开始") forState:UIControlStateNormal];
        [secondBurst setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [secondBurst.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [secondBurst setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [secondBurst setBackgroundColor:[UIColor darkGrayColor]];
        [secondBurst addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_rightControlView addSubview:secondBurst];
        
        UIButton *secondBurstOver = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 6 + buttonHeight * 5, 60, buttonHeight)];
        [secondBurstOver setTitle:LocalString(@"二爆结束") forState:UIControlStateNormal];
        [secondBurstOver setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [secondBurstOver.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [secondBurstOver setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [secondBurstOver setBackgroundColor:[UIColor darkGrayColor]];
        [secondBurstOver addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_rightControlView addSubview:secondBurstOver];
        
        UIButton *bakeOver = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 7 + buttonHeight * 6, 60, buttonHeight)];
        [bakeOver setTitle:LocalString(@"烘焙结束") forState:UIControlStateNormal];
        [bakeOver setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [bakeOver.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [bakeOver setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [bakeOver setBackgroundColor:[UIColor darkGrayColor]];
        [bakeOver addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_rightControlView addSubview:bakeOver];
        
        UIButton *fireorwindPower = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 8 + buttonHeight * 7, 60, buttonHeight)];
        [fireorwindPower setTitle:LocalString(@"火力/风力") forState:UIControlStateNormal];
        [fireorwindPower setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [fireorwindPower.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [fireorwindPower setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [fireorwindPower setBackgroundColor:[UIColor darkGrayColor]];
        [fireorwindPower addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_rightControlView addSubview:fireorwindPower];
        
        UIButton *remark = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 9 + buttonHeight * 8, 60, buttonHeight)];
        [remark setTitle:LocalString(@"备注记录") forState:UIControlStateNormal];
        [remark setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [remark.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [remark setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [remark setBackgroundColor:[UIColor darkGrayColor]];
        [remark addTarget:self action:@selector(setPower) forControlEvents:UIControlEventTouchUpInside];
        [_rightControlView addSubview:remark];
        
        UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(15, gap * 10 + buttonHeight * 9, 60, buttonHeight)];
        [back setTitle:LocalString(@"返回") forState:UIControlStateNormal];
        [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [back.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [back setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.2];
        [back setBackgroundColor:[UIColor darkGrayColor]];
        [back addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        [_rightControlView addSubview:back];
    }
    return _rightControlView;
}

- (void)uiMasonry{
    [_bakeTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake((ScreenHeight - 120)/3, 30));
        make.top.mas_equalTo(self.view.mas_top);
        make.left.mas_equalTo(_chartView.mas_left);
    }];
    [_developRate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake((ScreenHeight - 120)/3, 30));
        make.top.mas_equalTo(self.view.mas_top);
        make.centerX.mas_equalTo(_chartView.mas_centerX);
    }];
    [_developTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake((ScreenHeight - 120)/3, 30));
        make.top.mas_equalTo(self.view.mas_top);
        make.right.mas_equalTo(_chartView.mas_right);
    }];
    UIView *separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:separatorView];
    
    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenHeight - 120, 10));
        make.top.mas_equalTo(_bakeTime.mas_bottom);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    [_beanTempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake((ScreenHeight - 120)/5, 30));
        make.top.mas_equalTo(separatorView.mas_bottom);
        make.left.mas_equalTo(_chartView.mas_left);
    }];
    [_inTempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake((ScreenHeight - 120)/5, 30));
        make.top.mas_equalTo(separatorView.mas_bottom);
        make.left.mas_equalTo(_beanTempLabel.mas_right);
    }];
    [_outTempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake((ScreenHeight - 120)/5, 30));
        make.top.mas_equalTo(separatorView.mas_bottom);
        make.left.mas_equalTo(_inTempLabel.mas_right);
    }];
    [_environTempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake((ScreenHeight - 120)/5, 30));
        make.top.mas_equalTo(separatorView.mas_bottom);
        make.left.mas_equalTo(_outTempLabel.mas_right);
    }];
    [_beanTempRateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake((ScreenHeight - 120)/5 + 20, 30));
        make.top.mas_equalTo(separatorView.mas_bottom);
        make.left.mas_equalTo(_environTempLabel.mas_right);
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
    if (_leftControlView.tag == unselect) {
        [UIView animateWithDuration:0.5 animations:^{
            _leftControlView.frame = CGRectMake(20, 0, 90, ScreenHeight);
            CGAffineTransform transform = CGAffineTransformMakeRotation(180 * M_PI / 180.0);
            [_leftPopBtn setTransform:transform];
        }];
        _leftControlView.tag = select;
    }else if (_leftControlView.tag == select){
        [UIView animateWithDuration:0.5 animations:^{
            _leftControlView.frame = CGRectMake(-90, 0, 90, ScreenHeight);
            CGAffineTransform transform = CGAffineTransformMakeRotation(0 * M_PI / 180.0);
            [_leftPopBtn setTransform:transform];
        }];
        _leftControlView.tag = unselect;
    }
    
}

- (void)popRightControlView{
    if (_rightControlView.tag == unselect) {
        [UIView animateWithDuration:0.5 animations:^{
            _rightControlView.frame = CGRectMake(ScreenWidth - 110, 0, 90, ScreenHeight);
            CGAffineTransform transform = CGAffineTransformMakeRotation(0 * M_PI / 180.0);
            [_rightPopBtn setTransform:transform];
        }];
        _rightControlView.tag = select;
    }else if (_rightControlView.tag == select){
        [UIView animateWithDuration:0.5 animations:^{
            _rightControlView.frame = CGRectMake(ScreenWidth, 0, 90, ScreenHeight);
            CGAffineTransform transform = CGAffineTransformMakeRotation(-180 * M_PI / 180.0);
            [_rightPopBtn setTransform:transform];
        }];
        _rightControlView.tag = unselect;
    }
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
        //set1 = [[LineChartDataSet alloc] initWithValues:— label:LocalString(@"进风温")];
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
        //set1 = [[LineChartDataSet alloc] initWithValues:— label:LocalString(@"进风温")];
        set1.axisDependency = AxisDependencyLeft;
        [set1 setColor:[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]];
        [set1 setCircleColor:UIColor.whiteColor];
        set1.lineWidth = 2.0;
        set1.circleRadius = 0.0;
        set1.fillAlpha = 65/255.0;
        set1.fillColor = [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
        set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        set1.drawCircleHoleEnabled = NO;
        set1.drawValuesEnabled = NO;//是否在拐点处显示数据
        //set1.cubicIntensity = 5;//曲线弧度
        set1.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        //set1.mode = LineChartModeCubicBezier;
        
        set2 = [[LineChartDataSet alloc] initWithValues:_myNet.yVals_In label:LocalString(@"出风温")];
        set2.axisDependency = AxisDependencyLeft;
        [set2 setColor:[UIColor colorWithRed:229/255.f green:181/255.f blue:51/255.f alpha:1.f]];
        [set2 setCircleColor:UIColor.whiteColor];
        set2.lineWidth = 2.0;
        set2.circleRadius = 0.0;
        set2.fillAlpha = 65/255.0;
        set2.fillColor = [UIColor colorWithRed:229/255.f green:181/255.f blue:51/255.f alpha:1.f];
        set2.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        set2.drawCircleHoleEnabled = NO;
        set2.drawValuesEnabled = NO;//是否在拐点处显示数据
        //set1.cubicIntensity = 1;//曲线弧度
        set2.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        
        set3 = [[LineChartDataSet alloc] initWithValues:_myNet.yVals_Bean label:LocalString(@"豆温")];
        set3.axisDependency = AxisDependencyLeft;
        [set3 setColor:[UIColor greenColor]];
        [set3 setCircleColor:UIColor.whiteColor];
        set3.lineWidth = 2.0;
        set3.circleRadius = 0.0;
        set3.fillAlpha = 65/255.0;
        set3.fillColor = [UIColor colorWithRed:229/255.f green:181/255.f blue:51/255.f alpha:1.f];
        set3.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        set3.drawCircleHoleEnabled = NO;
        set3.drawValuesEnabled = NO;//是否在拐点处显示数据
        //set1.cubicIntensity = 1;//曲线弧度
        set3.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        
        set4 = [[LineChartDataSet alloc] initWithValues:_myNet.yVals_Environment label:LocalString(@"环境温")];
        set4.axisDependency = AxisDependencyLeft;
        [set4 setColor:[UIColor yellowColor]];
        [set4 setCircleColor:UIColor.whiteColor];
        set4.lineWidth = 2.0;
        set4.circleRadius = 0.0;
        set4.fillAlpha = 65/255.0;
        set4.fillColor = [UIColor colorWithRed:229/255.f green:181/255.f blue:51/255.f alpha:1.f];
        set4.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
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
    //点击全屏
//    if (isFullScreen) {
//        [UIView animateWithDuration:0.5 animations:^{
//            _chartView.frame = CGRectMake(ScreenWidth * 0.1, ScreenHeight * 0.15, ScreenWidth * 0.8, ScreenHeight * 0.7);
//            //_chartView.center = self.view.center;
//            //NSLog(@"pinggao%f",ScreenHeight);
//            isFullScreen = NO;
//        }];
//    }else{
//        [UIView animateWithDuration:0.5 animations:^{
//            _chartView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
//            isFullScreen = YES;
//            [NSObject showHudTipStr:LocalString(@"再次点击页面退出全屏")];
//        }];
//    }
    
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
