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
#import "Coffee-Swift.h"
#import "FMDB.h"
#import "BeanModel.h"
#import "EventModel.h"
#import "LeftFuncController.h"
#import "RightFuncController.h"
#import "ReportModel.h"


#define buttonHeight 30

@interface BakeCurveViewController () <ChartViewDelegate,IChartAxisValueFormatter>

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

//温度颜色圆圈
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UIView *view2;
@property (nonatomic, strong) UIView *view3;
@property (nonatomic, strong) UIView *view4;
@property (nonatomic, strong) UIView *view5;

@property (nonatomic, strong) UIButton *leftPopBtn;
@property (nonatomic, strong) UIButton *rightPopBtn;
@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) NetWork *myNet;

@property (nonatomic, strong) NSMutableArray *rela_Bean;
@property (nonatomic, strong) NSMutableArray *rela_In;
@property (nonatomic, strong) NSMutableArray *rela_Out;
@property (nonatomic, strong) NSMutableArray *rela_Diff;
@property (nonatomic, strong) NSMutableArray *rela_Environment;

@end

@implementation BakeCurveViewController
{
    double leftAxisMax;
    NSInteger xAxisMax;
    
}
static BOOL isRelaOn = NO;

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
    [self setRelaCurve];
    [self setDataValue];
    
    [_myNet addObserver:self forKeyPath:@"tempData" options:NSKeyValueObservingOptionNew context:nil];
    [_myNet addObserver:self forKeyPath:@"timerValue" options:NSKeyValueObservingOptionNew context:nil];
    [_myNet addObserver:self forKeyPath:@"developTime" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCurve) name:@"clearCurve" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"clearCurve" object:nil];
}

- (void)dealloc{
    [_myNet removeObserver:self forKeyPath:@"tempData"];
    [_myNet removeObserver:self forKeyPath:@"timerValue"];
    [_myNet removeObserver:self forKeyPath:@"developTime"];
}

#pragma mark - lazy load
- (LineChartView *)chartView{
    if (!_chartView) {
        _chartView = [[LineChartView alloc] init];
        if (kDevice_Is_iPhoneX) {
            _chartView.frame = CGRectMake((45+44)/HScale, 87/WScale, ScreenHeight - 87/HScale  - 44/WScale, ScreenWidth - 100/WScale);
        }else{
            _chartView.frame = CGRectMake(45/HScale, 87/WScale, ScreenHeight - 87/HScale, ScreenWidth - 100/WScale);
        }
        [self.view addSubview:_chartView];
        
        UILabel *leftLabel = [[UILabel alloc] init];
        leftLabel.text = [DataBase shareDataBase].setting.tempUnit;
        leftLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        leftLabel.textColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        leftLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:leftLabel];

        UILabel *rightLabel = [[UILabel alloc] init];
        rightLabel.text = [NSString stringWithFormat:@"%@/min",[DataBase shareDataBase].setting.tempUnit];
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
        
        
        _chartView.legend.enabled = NO;//不显示图例说明
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
        xAxis.granularityEnabled = YES;
        xAxis.labelPosition = XAxisLabelPositionBottom;
        xAxis.valueFormatter = self;
        xAxis.axisMinimum = 0;
        xAxis.axisMaximum = 60 * [DataBase shareDataBase].setting.timeAxis;
        [xAxis setLabelCount:[DataBase shareDataBase].setting.timeAxis + 1];
        xAxisMax = [DataBase shareDataBase].setting.timeAxis;
        xAxis.axisRange = 60 * [DataBase shareDataBase].setting.timeAxis;
        xAxis.granularity = 60;
        [_chartView setVisibleXRangeWithMinXRange:60 maxXRange:UI_IS_IPHONE5?500:600];//修改缩小放大最多显示数量
        
        
        ChartYAxis *leftAxis = _chartView.leftAxis;
        leftAxis.labelTextColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        leftAxis.labelFont = [UIFont fontWithName:@"Avenir-Light" size:12];
        leftAxis.axisMaximum = [DataBase shareDataBase].setting.tempAxis - 0.5;
        leftAxisMax = [DataBase shareDataBase].setting.tempAxis - 0.5;
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
        rightAxis.axisMaximum = 30;
        rightAxis.axisMinimum = 0;
        rightAxis.drawGridLinesEnabled = NO;
        rightAxis.granularityEnabled = NO;
        
        // 显示气泡效果
        BalloonMarker *marker = [[BalloonMarker alloc]
                                 initWithColor: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.75]
                                 font: [UIFont systemFontOfSize:15.0]
                                 textColor: [UIColor colorWithHexString:@"333333"]
                                 insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)
                                 borderColor:[UIColor colorWithRed:213/255.0 green:218/255.0 blue:224/255.0 alpha:0.5]];
        marker.minimumSize = CGSizeMake(0, 0);
        marker.chartView = self.chartView;
        self.chartView.marker = marker;
        [self.chartView setDrawMarkers:YES];
        [_chartView animateWithXAxisDuration:1.0];
    }
    
    return _chartView;
}

- (UILabel *)bakeTime{
    if (!_bakeTime) {
        _bakeTime = [[UILabel alloc] init];
        _bakeTime.textAlignment = NSTextAlignmentLeft;
        _bakeTime.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _bakeTime.text = @"00:00";
        _bakeTime.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _bakeTime.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_bakeTime];
    }
    return _bakeTime;
}

- (UILabel *)developRate{
    if (!_developRate) {
        _developRate = [[UILabel alloc] init];
        _developRate.textAlignment = NSTextAlignmentLeft;
        _developRate.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _developRate.text = @"0.0%";
        _developRate.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _developRate.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_developRate];
    }
    return _developRate;
}

- (UILabel *)developTime{
    if (!_developTime) {
        _developTime = [[UILabel alloc] init];
        _developTime.textAlignment = NSTextAlignmentLeft;
        _developTime.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _developTime.text = @"00:00";
        _developTime.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _developTime.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_developTime];
    }
    return _developTime;
}

- (UILabel *)beanTempLabel{
    if (!_beanTempLabel) {
        _beanTempLabel = [[UILabel alloc] init];
        _beanTempLabel.textAlignment = NSTextAlignmentLeft;
        _beanTempLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _beanTempLabel.text = [NSString stringWithFormat:@"0.0%@",[DataBase shareDataBase].setting.tempUnit];
        _beanTempLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _beanTempLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_beanTempLabel];
    }
    return _beanTempLabel;
}

- (UILabel *)inTempLabel{
    if (!_inTempLabel) {
        _inTempLabel = [[UILabel alloc] init];
        _inTempLabel.textAlignment = NSTextAlignmentLeft;
        _inTempLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _inTempLabel.text = [NSString stringWithFormat:@"0.0%@",[DataBase shareDataBase].setting.tempUnit];
        _inTempLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _inTempLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_inTempLabel];
    }
    return _inTempLabel;
}

- (UILabel *)outTempLabel{
    if (!_outTempLabel) {
        _outTempLabel = [[UILabel alloc] init];
        _outTempLabel.textAlignment = NSTextAlignmentLeft;
        _outTempLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _outTempLabel.text = [NSString stringWithFormat:@"0.0%@",[DataBase shareDataBase].setting.tempUnit];
        _outTempLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _outTempLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_outTempLabel];
    }
    return _outTempLabel;
}

- (UILabel *)environTempLabel{
    if (!_environTempLabel) {
        _environTempLabel = [[UILabel alloc] init];
        _environTempLabel.textAlignment = NSTextAlignmentLeft;
        _environTempLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _environTempLabel.text = [NSString stringWithFormat:@"0.0%@",[DataBase shareDataBase].setting.tempUnit];
        _environTempLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _environTempLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_environTempLabel];
    }
    return _environTempLabel;
}

- (UILabel *)beanTempRateLabel{
    if (!_beanTempRateLabel) {
        _beanTempRateLabel = [[UILabel alloc] init];
        _beanTempRateLabel.textAlignment = NSTextAlignmentLeft;
        _beanTempRateLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
        _beanTempRateLabel.text = [NSString stringWithFormat:@"0.0%@/min",[DataBase shareDataBase].setting.tempUnit];
        _beanTempRateLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _beanTempRateLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_beanTempRateLabel];
    }
    return _beanTempRateLabel;
}

- (UIButton *)leftPopBtn{
    if (!_leftPopBtn) {
        _leftPopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftPopBtn setImage:[UIImage imageNamed:@"btn_expand2"] forState:UIControlStateNormal];
        _leftPopBtn.alpha = 0.6;
        [_leftPopBtn addTarget:self action:@selector(popLeftControlView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_leftPopBtn];
    }
    return _leftPopBtn;
}

- (UIButton *)rightPopBtn{
    if (!_rightPopBtn) {
        _rightPopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightPopBtn setImage:[UIImage imageNamed:@"btn_expand3"] forState:UIControlStateNormal];
        [_rightPopBtn addTarget:self action:@selector(popRightControlView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_rightPopBtn];
    }
    return _rightPopBtn;
}

- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(15/WScale,19/HScale,22/WScale,22/HScale);
        [_backBtn setImage:[UIImage imageNamed:@"ic_nav_back"] forState:UIControlStateNormal];
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
    
    _view1 = [[UIView alloc] init];
    if (kDevice_Is_iPhoneX) {
        _view1.frame = CGRectMake((282+44)/HScale,17/WScale,5/HScale,5/WScale);
    }else{
        _view1.frame = CGRectMake(282/HScale,17/WScale,5/HScale,5/WScale);
    }
    _view1.backgroundColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1];
    _view1.layer.cornerRadius = 2.5f/WScale;
    [self.view addSubview:_view1];
    
    UILabel *inTempLabelL = [[UILabel alloc] init];
    inTempLabelL.textAlignment = NSTextAlignmentLeft;
    inTempLabelL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    inTempLabelL.text = @"进风温";
    inTempLabelL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:inTempLabelL];
    
    _view2 = [[UIView alloc] init];
    if (kDevice_Is_iPhoneX) {
        _view2.frame = CGRectMake((357+44)/HScale,17/WScale,5/HScale,5/WScale);
    }else{
        _view2.frame = CGRectMake(357/HScale,17/WScale,5/HScale,5/WScale);
    }
    _view2.backgroundColor = [UIColor colorWithRed:123/255.0 green:179/255.0 blue:64/255.0 alpha:1];
    _view2.layer.cornerRadius = 2.5f/WScale;
    [self.view addSubview:_view2];
    
    UILabel *outTempLabelL = [[UILabel alloc] init];
    outTempLabelL.textAlignment = NSTextAlignmentLeft;
    outTempLabelL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    outTempLabelL.text = @"出风温";
    outTempLabelL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:outTempLabelL];
    
    _view3 = [[UIView alloc] init];
    if (kDevice_Is_iPhoneX) {
        _view3.frame = CGRectMake((432+44)/HScale,17/WScale,5/HScale,5/WScale);
    }else{
        _view3.frame = CGRectMake(432/HScale,17/WScale,5/HScale,5/WScale);
    }
    _view3.backgroundColor = [UIColor colorWithRed:80/255.0 green:227/255.0 blue:194/255.0 alpha:1];
    _view3.layer.cornerRadius = 2.5f/WScale;
    [self.view addSubview:_view3];
    
    UILabel *environTempLabelL = [[UILabel alloc] init];
    environTempLabelL.textAlignment = NSTextAlignmentLeft;
    environTempLabelL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    environTempLabelL.text = @"环境温";
    environTempLabelL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:environTempLabelL];
    
    _view4 = [[UIView alloc] init];
    if (kDevice_Is_iPhoneX) {
        _view4.frame = CGRectMake((507+44)/HScale,17/WScale,5/HScale,5/WScale);
    }else{
        _view4.frame = CGRectMake(507/HScale,17/WScale,5/HScale,5/WScale);
    }
    _view4.backgroundColor = [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1];
    _view4.layer.cornerRadius = 2.5f/WScale;
    [self.view addSubview:_view4];
    
    UILabel *beanTempRateLabelL = [[UILabel alloc] init];
    beanTempRateLabelL.textAlignment = NSTextAlignmentLeft;
    beanTempRateLabelL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    beanTempRateLabelL.text = @"升温率";
    beanTempRateLabelL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:beanTempRateLabelL];
    
    _view5 = [[UIView alloc] init];
    if (kDevice_Is_iPhoneX) {
        _view5.frame = CGRectMake((582+44)/HScale,17/WScale,5/HScale,5/WScale);
    }else{
        _view5.frame = CGRectMake(582/HScale,17/WScale,5/HScale,5/WScale);
    }
    _view5.backgroundColor = [UIColor colorWithRed:255/255.0 green:71/255.0 blue:51/255.0 alpha:1];
    _view5.layer.cornerRadius = 2.5f/WScale;
    [self.view addSubview:_view5];
    
    
    [bakeTimeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(48/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        if (kDevice_Is_iPhoneX) {
            make.left.mas_equalTo(self.view.mas_left).offset((47+44)/HScale);
        }else{
            make.left.mas_equalTo(self.view.mas_left).offset(47/HScale);
        }
    }];
    [_bakeTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36/HScale, 13/WScale));
        make.top.mas_equalTo(bakeTimeL.mas_bottom).offset(8/WScale);
        if (kDevice_Is_iPhoneX) {
            make.left.mas_equalTo(self.view.mas_left).offset((47+44)/HScale);
        }else{
            make.left.mas_equalTo(self.view.mas_left).offset(47/HScale);
        }
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
        make.size.mas_equalTo(CGSizeMake(32/WScale, 32/WScale));
        if (@available(iOS 11.0,*)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
        }else{
            make.left.equalTo(self.view.mas_left);
        }
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    [_rightPopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32/WScale, 32/WScale));
        make.right.equalTo(self.view.mas_right);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    
    //用来点击隐藏曲线，覆盖在温度文字上面
    UIButton *beanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (kDevice_Is_iPhoneX) {
        beanBtn.frame = CGRectMake((272+44)/HScale,0,75/HScale,60/WScale);
    }else{
        beanBtn.frame = CGRectMake(272/HScale,0,75/HScale,60/WScale);
    }
    [beanBtn setBackgroundColor:[UIColor clearColor]];
    [beanBtn addTarget:self action:@selector(beanCurveAction:) forControlEvents:UIControlEventTouchUpInside];
    beanBtn.tag = unselect;
    [self.view addSubview:beanBtn];
    
    UIButton *inBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (kDevice_Is_iPhoneX) {
        inBtn.frame = CGRectMake((347+44)/HScale,0,75/HScale,60/WScale);
    }else{
        inBtn.frame = CGRectMake(347/HScale,0,75/HScale,60/WScale);
    }
    [inBtn setBackgroundColor:[UIColor clearColor]];
    [inBtn addTarget:self action:@selector(inCurveAction:) forControlEvents:UIControlEventTouchUpInside];
    inBtn.tag = unselect;
    [self.view addSubview:inBtn];
    
    UIButton *outBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (kDevice_Is_iPhoneX) {
        outBtn.frame = CGRectMake((422+44)/HScale,0,75/HScale,60/WScale);
    }else{
        outBtn.frame = CGRectMake(422/HScale,0,75/HScale,60/WScale);
    }
    [outBtn setBackgroundColor:[UIColor clearColor]];
    [outBtn addTarget:self action:@selector(outCurveAction:) forControlEvents:UIControlEventTouchUpInside];
    outBtn.tag = unselect;
    [self.view addSubview:outBtn];
    
    UIButton *environBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (kDevice_Is_iPhoneX) {
        environBtn.frame = CGRectMake((497+44)/HScale,0,75/HScale,60/WScale);
    }else{
        environBtn.frame = CGRectMake(497/HScale,0,75/HScale,60/WScale);
    }
    [environBtn setBackgroundColor:[UIColor clearColor]];
    [environBtn addTarget:self action:@selector(environCurveAction:) forControlEvents:UIControlEventTouchUpInside];
    environBtn.tag = unselect;
    [self.view addSubview:environBtn];
    
    UIButton *upTempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (kDevice_Is_iPhoneX) {
        upTempBtn.frame = CGRectMake((572+44)/HScale,0,75/HScale,60/WScale);
    }else{
        upTempBtn.frame = CGRectMake(572/HScale,0,75/HScale,60/WScale);
    }
    [upTempBtn setBackgroundColor:[UIColor clearColor]];
    [upTempBtn addTarget:self action:@selector(upTempCurveAction:) forControlEvents:UIControlEventTouchUpInside];
    upTempBtn.tag = unselect;
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
- (void)clearCurve{
    if (_chartView) {
        [_chartView clear];
        [_chartView clearValues];
    }
}

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
    rfVC.isRelaOn = isRelaOn;
    rfVC.relaSwitch = ^(BOOL isOn) {
        LineChartDataSet *rela1 = (LineChartDataSet *)_chartView.data.dataSets[5];
        LineChartDataSet *rela2 = (LineChartDataSet *)_chartView.data.dataSets[6];
        LineChartDataSet *rela3 = (LineChartDataSet *)_chartView.data.dataSets[7];
        LineChartDataSet *rela4 = (LineChartDataSet *)_chartView.data.dataSets[8];
        LineChartDataSet *rela5 = (LineChartDataSet *)_chartView.data.dataSets[9];
        isRelaOn = isOn;
        if (isOn) {
            NSLog(@"sdf");
            rela1.visible = YES;
            rela2.visible = YES;
            rela3.visible = YES;
            rela4.visible = YES;
            rela5.visible = YES;
        }else{
            rela1.visible = NO;
            rela2.visible = NO;
            rela3.visible = NO;
            rela4.visible = NO;
            rela5.visible = NO;
        }
    };
    rfVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    rfVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:rfVC animated:YES completion:nil];
}

- (void)beanCurveAction:(UIButton *)sender{
    if (_chartView.data.dataSets.count < 3) {
        return;
    }
    LineChartDataSet *set3 = (LineChartDataSet *)_chartView.data.dataSets[2];
    if (sender.tag == unselect) {
        set3.visible = NO;
        sender.tag = select;
        _view1.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    }else if(sender.tag == select){
        set3.visible = YES;
        sender.tag = unselect;
        _view1.backgroundColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1];
    }
    [self setDataValue];
}

- (void)inCurveAction:(UIButton *)sender{
    if (_chartView.data.dataSets.count < 1) {
        return;
    }
    LineChartDataSet *set2 = (LineChartDataSet *)_chartView.data.dataSets[0];
    if (sender.tag == unselect) {
        set2.visible = NO;
        sender.tag = select;
        _view2.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    }else{
        set2.visible = YES;
        sender.tag = unselect;
        _view2.backgroundColor = [UIColor colorWithRed:123/255.0 green:179/255.0 blue:64/255.0 alpha:1];
    }
    [self setDataValue];
}

- (void)outCurveAction:(UIButton *)sender{
    if (_chartView.data.dataSets.count < 2) {
        return;
    }
    LineChartDataSet *set1 = (LineChartDataSet *)_chartView.data.dataSets[1];
    if (sender.tag == unselect) {
        set1.visible = NO;
        sender.tag = select;
        _view3.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    }else{
        set1.visible = YES;
        sender.tag = unselect;
        _view3.backgroundColor = [UIColor colorWithRed:80/255.0 green:227/255.0 blue:194/255.0 alpha:1];
    }
    [self setDataValue];
}

- (void)environCurveAction:(UIButton *)sender{
    if (_chartView.data.dataSets.count < 4) {
        return;
    }
    LineChartDataSet *set4 = (LineChartDataSet *)_chartView.data.dataSets[3];
    if (sender.tag == unselect) {
        set4.visible = NO;
        sender.tag = select;
        _view4.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    }else{
        set4.visible = YES;
        sender.tag = unselect;
        _view4.backgroundColor = [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1];
    }
    [self setDataValue];
}

- (void)upTempCurveAction:(UIButton *)sender{
    if (_chartView.data.dataSets.count < 5) {
        return;
    }
    LineChartDataSet *set5 = (LineChartDataSet *)_chartView.data.dataSets[4];
    if (sender.tag == unselect) {
        set5.visible = NO;
        sender.tag = select;
        _view5.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    }else{
        set5.visible = YES;
        sender.tag = unselect;
        _view5.backgroundColor = [UIColor colorWithRed:255/255.0 green:71/255.0 blue:51/255.0 alpha:1];
    }
    [self setDataValue];
}

- (void)setPower{
    
}

- (void)setRelaCurve{
    NetWork *net = [NetWork shareNetWork];
    if (net.relaCurve.curveValueJson) {
        NSData *curveData = [net.relaCurve.curveValueJson dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *curveDic = [NSJSONSerialization JSONObjectWithData:curveData options:NSJSONReadingMutableLeaves error:nil];
        
        NSArray *Bean = [curveDic objectForKey:@"bean"];
        NSArray *Out = [curveDic objectForKey:@"out"];
        NSArray *In = [curveDic objectForKey:@"in"];
        NSArray *Environment = [curveDic objectForKey:@"environment"];
        NSMutableArray *Diff = [[NSMutableArray alloc] init];
        for (int i = beanRorDiffCount; i < Bean.count; i = i + beanRorDiffCount) {
            [Diff addObject:[NSNumber numberWithDouble:([Bean[i] doubleValue] - [Bean[i - beanRorDiffCount] doubleValue]) * 12.f]];
        }
        
        NSLog(@"%lu",(unsigned long)Bean.count);
        NSLog(@"%lu",Out.count);
        NSLog(@"%lu",In.count);
        NSLog(@"%lu",Environment.count);
        _rela_Diff = [[NSMutableArray alloc] init];
        _rela_In = [[NSMutableArray alloc] init];
        _rela_Out = [[NSMutableArray alloc] init];
        _rela_Bean = [[NSMutableArray alloc] init];
        _rela_Environment = [[NSMutableArray alloc] init];
        
        for (int i = 0; i<Bean.count; i++) {
            [_rela_Bean addObject:[[ChartDataEntry alloc] initWithX:i y:[Bean[i] doubleValue]]];
        }
        for (int i = 0; i<Out.count; i++) {
            [_rela_Out addObject:[[ChartDataEntry alloc] initWithX:i y:[Out[i] doubleValue]]];
        }
        for (int i = 0; i<In.count; i++) {
            [_rela_In addObject:[[ChartDataEntry alloc] initWithX:i y:[In[i] doubleValue]]];
        }
        for (int i = 0; i<Environment.count; i++) {
            [_rela_Environment addObject:[[ChartDataEntry alloc] initWithX:i y:[Environment[i] doubleValue]]];
        }
        _rela_Diff = [[NetWork shareNetWork] getBeanTempRorWithArr:[Bean mutableCopy]];
        
    }
}

- (void)setDataValue
{
    NSDictionary *tempDic = [NSObject readLocalFileWithName:@"数据"];
    NSArray *beanTemp = tempDic[@"temp2"];
    NSMutableArray *yVals = [NSMutableArray array];
    yVals = [NSObject evaluateAcceleration:[beanTemp mutableCopy]];
//    for (int i = 0, j = 0; i < [beanTemp count]; i++) {
//        [yVals addObject:[[ChartDataEntry alloc] initWithX:i y:[beanTemp[i] doubleValue]]];
//
////        if (i != 0) {
////            [_yVals_diff addObject:[[ChartDataEntry alloc] initWithX:i y:([beanTemp[i] doubleValue] - [beanTemp[i-1] doubleValue])]];
////        }
////
////        j = i * 10;
////        if (j != 0 && j < [beanTemp count]) {
////            [_yVals_diff addObject:[[ChartDataEntry alloc] initWithX:j y:([beanTemp[j] doubleValue] - [beanTemp[j-10] doubleValue])/10]];
////        }
//    }
    
    LineChartDataSet *set1 = nil, *set2 = nil, *set3 = nil, *set4 = nil,*set5, *rela1 = nil, *rela2 = nil, *rela3 = nil, *rela4 = nil, *rela5 = nil;
    
    if (_chartView.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
        set1.values = _myNet.yVals_In;
        
        set2 = (LineChartDataSet *)_chartView.data.dataSets[1];
        set2.values = _myNet.yVals_Out;
        
        set3 = (LineChartDataSet *)_chartView.data.dataSets[2];
        set3.values = _myNet.yVals_Bean;
        
        set4 = (LineChartDataSet *)_chartView.data.dataSets[3];
        set4.values = _myNet.yVals_Environment;
        
        set5 = (LineChartDataSet *)_chartView.data.dataSets[4];
        set5.values = _myNet.yVals_Diff;
        
        rela1 = (LineChartDataSet *)_chartView.data.dataSets[5];
        rela1.values = _rela_In;

        rela2 = (LineChartDataSet *)_chartView.data.dataSets[6];
        rela2.values = _rela_Out;

        rela3 = (LineChartDataSet *)_chartView.data.dataSets[7];
        rela3.values = _rela_Bean;

        rela4 = (LineChartDataSet *)_chartView.data.dataSets[8];
        rela4.values = _rela_Environment;

        rela5 = (LineChartDataSet *)_chartView.data.dataSets[9];
        rela5.values = _rela_Diff;


        //实时调整y轴最大值
        if ([_myNet.BeanArr[_myNet.BeanArr.count-1] floatValue] > leftAxisMax) {
            _chartView.leftAxis.axisMaximum = leftAxisMax + 50;
            leftAxisMax = leftAxisMax + 50;
        }
        if ([_myNet.InArr[_myNet.InArr.count-1] floatValue] > leftAxisMax) {
            _chartView.leftAxis.axisMaximum = leftAxisMax + 50;
            leftAxisMax = leftAxisMax + 50;
        }
        if ([_myNet.OutArr[_myNet.OutArr.count-1] floatValue] > leftAxisMax) {
            _chartView.leftAxis.axisMaximum = leftAxisMax + 50;
            leftAxisMax = leftAxisMax + 50;
        }
        if ([_myNet.EnvironmentArr[_myNet.EnvironmentArr.count-1] floatValue] > leftAxisMax) {
            _chartView.leftAxis.axisMaximum = leftAxisMax + 50;
            leftAxisMax = leftAxisMax + 50;
        }
        if (_myNet.BeanArr.count > xAxisMax * 60) {
            NSLog(@"%ld",xAxisMax);
            xAxisMax = xAxisMax + 2;
            _chartView.xAxis.axisMaximum = xAxisMax * 60;
            _chartView.xAxis.labelCount = xAxisMax + 1;
        }
        
        [_chartView.data notifyDataChanged];
        [_chartView notifyDataSetChanged];
    }
    else
    {
        
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
        [set3 setCircleColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        [set3 setCircleHoleColor:[UIColor whiteColor]];
        set3.lineWidth = 2.0;
        set3.circleRadius = 6.0;
        set3.circleHoleRadius = 5.5;
        set3.fillAlpha = 65/255.0;
        set3.fillColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1];
        //set3.drawCircleHoleEnabled = YES;
        set3.drawValuesEnabled = YES;//是否在拐点处显示数据
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
        
        set5 = [[LineChartDataSet alloc] initWithValues:_myNet.yVals_Diff label:LocalString(@"升温率")];
        set5.axisDependency = AxisDependencyRight;
        set5.mode = LineChartModeHorizontalBezier;
        [set5 setColor:[UIColor colorWithRed:255/255.0 green:71/255.0 blue:51/255.0 alpha:1]];
        [set5 setCircleColor:UIColor.whiteColor];
        set5.lineWidth = 2.0;
        set5.circleRadius = 0.0;
        set5.fillAlpha = 65/255.0;
        set5.fillColor = [UIColor colorWithRed:255/255.0 green:71/255.0 blue:51/255.0 alpha:1];
        set5.drawCircleHoleEnabled = NO;
        set5.drawValuesEnabled = NO;//是否在拐点处显示数据
        set5.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        
        rela1 = [[LineChartDataSet alloc] initWithValues:_rela_In label:LocalString(@"进风温(rela)")];
        rela1.axisDependency = AxisDependencyRight;
        [rela1 setColor:[UIColor colorWithRed:123/255.0 green:179/255.0 blue:64/255.0 alpha:1]];
        [rela1 setCircleColor:UIColor.whiteColor];
        rela1.lineWidth = 1.0;
        rela1.circleRadius = 0.0;
        rela1.fillAlpha = 65/255.0;
        rela1.fillColor = [UIColor colorWithRed:123/255.0 green:179/255.0 blue:64/255.0 alpha:1];
        rela1.drawCircleHoleEnabled = NO;
        rela1.drawValuesEnabled = NO;//是否在拐点处显示数据
        rela1.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        rela1.lineDashLengths = @[@5.f,@5.f];
        rela1.visible = NO;
        
        rela2 = [[LineChartDataSet alloc] initWithValues:_rela_Out label:LocalString(@"出风温(rela)")];
        rela2.axisDependency = AxisDependencyRight;
        [rela2 setColor:[UIColor colorWithRed:80/255.0 green:227/255.0 blue:194/255.0 alpha:1]];
        [rela2 setCircleColor:UIColor.whiteColor];
        rela2.lineWidth = 1.0;
        rela2.circleRadius = 0.0;
        rela2.fillAlpha = 65/255.0;
        rela2.fillColor = [UIColor colorWithRed:80/255.0 green:227/255.0 blue:194/255.0 alpha:1];
        rela2.drawCircleHoleEnabled = NO;
        rela2.drawValuesEnabled = NO;//是否在拐点处显示数据
        rela2.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        rela2.lineDashLengths = @[@5.f,@5.f];
        rela2.visible = NO;
        
        rela3 = [[LineChartDataSet alloc] initWithValues:_rela_Bean label:LocalString(@"豆温(rela)")];
        rela3.axisDependency = AxisDependencyRight;
        [rela3 setColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        [rela3 setCircleColor:UIColor.whiteColor];
        rela3.lineWidth = 1.0;
        rela3.circleRadius = 0.0;
        rela3.fillAlpha = 65/255.0;
        rela3.fillColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1];
        rela3.drawCircleHoleEnabled = NO;
        rela3.drawValuesEnabled = NO;//是否在拐点处显示数据
        rela3.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        rela3.lineDashLengths = @[@5.f,@5.f];
        rela3.visible = NO;
        
        rela4 = [[LineChartDataSet alloc] initWithValues:_rela_Environment label:LocalString(@"环境温(rela)")];
        rela4.axisDependency = AxisDependencyRight;
        [rela4 setColor:[UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1]];
        [rela4 setCircleColor:UIColor.whiteColor];
        rela4.lineWidth = 1.0;
        rela4.circleRadius = 0.0;
        rela4.fillAlpha = 65/255.0;
        rela4.fillColor = [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1];
        rela4.drawCircleHoleEnabled = NO;
        rela4.drawValuesEnabled = NO;//是否在拐点处显示数据
        rela4.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        rela4.lineDashLengths = @[@5.f,@5.f];
        rela4.visible = NO;
        
        rela5 = [[LineChartDataSet alloc] initWithValues:_rela_Diff label:LocalString(@"升温率(rela)")];
        rela5.axisDependency = AxisDependencyRight;
        [rela5 setColor:[UIColor colorWithRed:255/255.0 green:71/255.0 blue:51/255.0 alpha:1]];
        [rela5 setCircleColor:UIColor.whiteColor];
        rela5.lineWidth = 1.0;
        rela5.circleRadius = 0.0;
        rela5.fillAlpha = 65/255.0;
        rela5.fillColor = [UIColor colorWithRed:255/255.0 green:71/255.0 blue:51/255.0 alpha:1];
        rela5.drawCircleHoleEnabled = NO;
        rela5.drawValuesEnabled = NO;//是否在拐点处显示数据
        rela5.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        rela5.lineDashLengths = @[@5.f,@5.f];
        rela5.visible = NO;
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        [dataSets addObject:set2];
        [dataSets addObject:set3];
        [dataSets addObject:set4];
        [dataSets addObject:set5];
        [dataSets addObject:rela1];
        [dataSets addObject:rela2];
        [dataSets addObject:rela3];
        [dataSets addObject:rela4];
        [dataSets addObject:rela5];
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        [data setValueTextColor:UIColor.whiteColor];
        [data setValueFont:[UIFont systemFontOfSize:9.f]];
        
//        //_chartView.xAxis.labelCount = 10;
//        _chartView.xAxis.valueFormatter = self;
//
//        _chartView.xAxis.axisMinimum = 0;
//        _chartView.xAxis.axisMaximum = 600;
//        _chartView.xAxis.axisRange = 600;
//        _chartView.xAxis.granularity = 60;
//        _chartView.xAxis.labelCount = 10;
        NSLog(@"%ld",_chartView.xAxis.labelCount);
        
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
    //NSLog(@"图表移动");
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis{
    return [NSString stringWithFormat:@"%d",(int)value/60];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"tempData"]) {
        NetWork *net = [NetWork shareNetWork];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setDataValue];
            
            NSMutableArray *data = [_myNet.recivedData68 copy];
            double tempOut = ([data[6] intValue] * 256 + [data[7] intValue]) / 10.0;
            double tempIn = ([data[8] intValue] * 256 + [data[9] intValue]) / 10.0;
            double tempBean = ([data[10] intValue] * 256 + [data[11] intValue]) / 10.0;
            double tempEnvironment = ([data[12] intValue] * 256 + [data[13] intValue]) / 10.0;
            
            _beanTempLabel.text = [NSString stringWithFormat:@"%.1f%@",[NSString diffTempUnitStringWithTemp:tempBean],[DataBase shareDataBase].setting.tempUnit];
            _inTempLabel.text = [NSString stringWithFormat:@"%.1f%@",[NSString diffTempUnitStringWithTemp:tempIn],[DataBase shareDataBase].setting.tempUnit];
            _outTempLabel.text = [NSString stringWithFormat:@"%.1f%@",[NSString diffTempUnitStringWithTemp:tempOut],[DataBase shareDataBase].setting.tempUnit];
            _environTempLabel.text = [NSString stringWithFormat:@"%.1f%@",[NSString diffTempUnitStringWithTemp:tempEnvironment],[DataBase shareDataBase].setting.tempUnit];
            if (net.BeanArr.count > 5) {
                _beanTempRateLabel.text = [NSString stringWithFormat:@"%.1f%@/min",([NSString diffTempUnitStringWithTemp:[net.BeanArr[net.BeanArr.count-1] doubleValue]] - [NSString diffTempUnitStringWithTemp:[net.BeanArr[net.BeanArr.count-6] doubleValue]])/5*60,[DataBase shareDataBase].setting.tempUnit];
            }
        });

    }else if ([keyPath isEqualToString:@"timerValue"]){
        long minute = _myNet.timerValue / 60;
        long second = _myNet.timerValue % 60;
        if (_myNet.deviceTimerStatus == 0) {
            _bakeTime.text = [NSString stringWithFormat:@"%02ld:%02ld",minute,second];
            _developRate.text = [NSString stringWithFormat:@"%.1f%%",(float)_myNet.developTime/_myNet.timerValue*100.f];
        }
    }else if ([keyPath isEqualToString:@"developTime"]){
        long minute = _myNet.developTime / 60;
        long second = _myNet.developTime % 60;
        if (_myNet.isDevelop) {
            _developTime.text = [NSString stringWithFormat:@"%02ld:%02ld",minute,second];
        }
    }
}

@end
