//
//  ReportCurveDetailController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2019/3/20.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "ReportCurveDetailController.h"
#import <Charts/Charts-Swift.h>
#import "ReportModel.h"

@interface ReportCurveDetailController () <ChartViewDelegate,IChartAxisValueFormatter>

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

@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation ReportCurveDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _chartView = [self chartView];
    _bakeTime = [self bakeTime];
    _developRate = [self developRate];
    _developTime = [self developTime];
    _beanTempLabel = [self beanTempLabel];
    _inTempLabel = [self inTempLabel];
    _outTempLabel = [self outTempLabel];
    _environTempLabel = [self environTempLabel];
    _beanTempRateLabel = [self beanTempRateLabel];
    _backBtn = [self backBtn];
    [self uiMasonry];
    [self setDataValue];
}

#pragma mark - private methods
- (void)beanCurveAction:(UIButton *)sender{
    if (_chartView.data.dataSets.count < 3) {
        return;
    }
    LineChartDataSet *set3 = (LineChartDataSet *)_chartView.data.dataSets[2];
    if (sender.tag == unselect) {
        set3.visible = NO;
        sender.tag = select;
        _view1.hidden = YES;
        _beanTempLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    }else if(sender.tag == select){
        set3.visible = YES;
        sender.tag = unselect;
        _view1.hidden = NO;
        _beanTempLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
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
        _view2.hidden = YES;
        _inTempLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    }else{
        set2.visible = YES;
        sender.tag = unselect;
        _view2.hidden = NO;
        _inTempLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
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
        _view3.hidden = YES;
        _outTempLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    }else{
        set1.visible = YES;
        sender.tag = unselect;
        _view3.hidden = NO;
        _outTempLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
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
        _view4.hidden = YES;
        _environTempLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    }else{
        set4.visible = YES;
        sender.tag = unselect;
        _view4.hidden = NO;
        _environTempLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
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
        _view5.hidden = YES;
        _beanTempRateLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    }else{
        set5.visible = YES;
        sender.tag = unselect;
        _view5.hidden = NO;
        _beanTempRateLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    }
    [self setDataValue];
}

#pragma mark - setters and getters
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
        //[_chartView setScaleYEnabled:NO];
        
        
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
        xAxis.labelPosition = XAxisLabelPositionBottom;
        xAxis.valueFormatter = self;
        xAxis.axisRange = self.yVals_Bean.count;
        xAxis.granularity = 60;
        if (self.yVals_Bean.count > (60 * 3)) {
            xAxis.axisMaximum = self.yVals_Bean.count;
        }else{
            xAxis.axisMaximum = 60 * 3;
        }
        
        ChartYAxis *leftAxis = _chartView.leftAxis;
        leftAxis.labelTextColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        leftAxis.labelFont = [UIFont fontWithName:@"Avenir-Light" size:12];
        leftAxis.axisMaximum = [NSString diffTempUnitStringWithTemp:[DataBase shareDataBase].setting.tempAxis - 0.5];
        leftAxis.spaceTop = 30.f;
        leftAxis.drawGridLinesEnabled = YES;
        leftAxis.gridLineWidth = 0.6f;
        leftAxis.gridColor = [UIColor colorWithHexString:@"EBEDF0"];
        //leftAxis.gridLineDashLengths = @[@5.f,@5.f];//虚线
        leftAxis.drawZeroLineEnabled = NO;
        leftAxis.granularityEnabled = YES;
        leftAxis.axisMinimum = [NSString diffTempUnitStringWithTemp:50.f];
        leftAxis.granularity = 50.f;

        ChartYAxis *rightAxis = _chartView.rightAxis;
        rightAxis.labelFont = [UIFont fontWithName:@"Avenir-Light" size:12];
        rightAxis.labelTextColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        rightAxis.axisMaximum = [NSString diffTempUnitStringWithTemp:30.f];
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
        _bakeTime.font = [UIFont fontWithName:@"Helvetica" size:15];
        _bakeTime.text = [NSString stringWithFormat:@"%02ld:%02ld",_report.bakeTime/60,_report.bakeTime%60];
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
        _developRate.font = [UIFont fontWithName:@"Helvetica" size:15];
        _developRate.text = [NSString stringWithFormat:@"%.1lf%%",_report.developRate];
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
        _developTime.font = [UIFont fontWithName:@"Helvetica" size:15];
        _developTime.text = [NSString stringWithFormat:@"%02ld:%02ld",_report.developTime/60,_report.developTime%60];
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
        _beanTempLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        _beanTempLabel.text = @"";
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
        _inTempLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
        _inTempLabel.text = @"";
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
        _outTempLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
        _outTempLabel.text = @"";
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
        _environTempLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
        _environTempLabel.text = @"";
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
        _beanTempRateLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
        _beanTempRateLabel.text = @"";
        _beanTempRateLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _beanTempRateLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_beanTempRateLabel];
    }
    return _beanTempRateLabel;
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
    bakeTimeL.text = LocalString(@"烘焙时间");
    bakeTimeL.adjustsFontSizeToFitWidth = YES;
    bakeTimeL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:bakeTimeL];
    
    UILabel *developRateL = [[UILabel alloc] init];
    developRateL.textAlignment = NSTextAlignmentLeft;
    developRateL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    developRateL.text = LocalString(@"发展率");
    developRateL.adjustsFontSizeToFitWidth = YES;
    developRateL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:developRateL];
    
    UILabel *developTimeL = [[UILabel alloc] init];
    developTimeL.textAlignment = NSTextAlignmentLeft;
    developTimeL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    developTimeL.text = LocalString(@"发展时间");
    developTimeL.adjustsFontSizeToFitWidth = YES;
    developTimeL.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self.view addSubview:developTimeL];
    
    UILabel *beanTempLabelL = [[UILabel alloc] init];
    beanTempLabelL.textAlignment = NSTextAlignmentLeft;
    beanTempLabelL.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    beanTempLabelL.text = LocalString(@"豆温");
    beanTempLabelL.adjustsFontSizeToFitWidth = YES;
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
    inTempLabelL.text = LocalString(@"热风温");
    inTempLabelL.adjustsFontSizeToFitWidth = YES;
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
    outTempLabelL.text = LocalString(@"排气温");
    outTempLabelL.adjustsFontSizeToFitWidth = YES;
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
    environTempLabelL.text = LocalString(@"环境温");
    environTempLabelL.adjustsFontSizeToFitWidth = YES;
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
    beanTempRateLabelL.text = LocalString(@"升温率");
    beanTempRateLabelL.adjustsFontSizeToFitWidth = YES;
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
        make.size.mas_equalTo(CGSizeMake(60/HScale, 13/WScale));
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
        make.size.mas_equalTo(CGSizeMake(60/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(bakeTimeL.mas_right).offset(15/HScale);
    }];
    [_developTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(37/HScale, 13/WScale));
        make.top.mas_equalTo(developTimeL.mas_bottom).offset(8/WScale);
        make.left.mas_equalTo(_bakeTime.mas_right).offset(39/HScale);
    }];
    
    [developRateL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(developTimeL.mas_right).offset(15/HScale);
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
        make.size.mas_equalTo(CGSizeMake(50/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(developRateL.mas_right).offset(32/HScale);
    }];
    [_beanTempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(52/HScale, 13/WScale));
        make.top.mas_equalTo(beanTempLabelL.mas_bottom).offset(8/WScale);
        make.left.mas_equalTo(_developRate.mas_right).offset(47/HScale);
    }];
    
    [inTempLabelL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(beanTempLabelL.mas_right).offset(25/HScale);
    }];
    [_inTempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(43/HScale, 13/WScale));
        make.top.mas_equalTo(inTempLabelL.mas_bottom).offset(8/WScale);
        make.left.mas_equalTo(_beanTempLabel.mas_right).offset(24/HScale);
    }];
    
    [outTempLabelL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(inTempLabelL.mas_right).offset(15/HScale);
    }];
    [_outTempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(49/HScale, 13/WScale));
        make.top.mas_equalTo(outTempLabelL.mas_bottom).offset(8/WScale);
        make.left.mas_equalTo(_inTempLabel.mas_right).offset(32/HScale);
    }];
    
    [environTempLabelL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(outTempLabelL.mas_right).offset(15/HScale);
    }];
    [_environTempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(49/HScale, 13/WScale));
        make.top.mas_equalTo(environTempLabelL.mas_bottom).offset(8/WScale);
        make.left.mas_equalTo(_outTempLabel.mas_right).offset(26/HScale);
    }];
    
    [beanTempRateLabelL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60/HScale, 13/WScale));
        make.top.mas_equalTo(self.view.mas_top).offset(13/WScale);
        make.left.mas_equalTo(environTempLabelL.mas_right).offset(15/HScale);
    }];
    [_beanTempRateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(69/HScale, 13/WScale));
        make.top.mas_equalTo(beanTempRateLabelL.mas_bottom).offset(8/WScale);
        make.left.mas_equalTo(_environTempLabel.mas_right).offset(26/HScale);
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


#pragma mark - private methods
- (void)setDataValue
{
    LineChartDataSet *set1 = nil, *set2 = nil, *set3 = nil, *set4 = nil, *set5 = nil;
    
    if (_chartView.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
        set1.values = _yVals_Out;
        
        set2 = (LineChartDataSet *)_chartView.data.dataSets[1];
        set2.values = _yVals_In;
        
        set3 = (LineChartDataSet *)_chartView.data.dataSets[2];
        set3.values = _yVals_Bean;
        
        set4 = (LineChartDataSet *)_chartView.data.dataSets[3];
        set4.values = _yVals_Environment;
        
        set5 = (LineChartDataSet *)_chartView.data.dataSets[4];
        set5.values = _yVals_Diff;
                
        [_chartView.data notifyDataChanged];
        [_chartView notifyDataSetChanged];
    }
    else
    {
        set1 = [[LineChartDataSet alloc] initWithValues:_yVals_In label:LocalString(@"热风温")];
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
        
        set2 = [[LineChartDataSet alloc] initWithValues:_yVals_Out label:LocalString(@"排气温")];
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
        
        set3 = [[LineChartDataSet alloc] initWithValues:_yVals_Bean label:LocalString(@"豆温")];
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
        
        set4 = [[LineChartDataSet alloc] initWithValues:_yVals_Environment label:LocalString(@"环境温")];
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
        
        set5 = [[LineChartDataSet alloc] initWithValues:_yVals_Diff label:LocalString(@"升温率")];
        set5.axisDependency = AxisDependencyRight;
        [set5 setColor:[UIColor colorWithRed:255/255.0 green:71/255.0 blue:51/255.0 alpha:1]];
        [set5 setCircleColor:UIColor.whiteColor];
        set5.lineWidth = 2.0;
        set5.circleRadius = 0.0;
        set5.fillAlpha = 65/255.0;
        set5.fillColor = [UIColor colorWithRed:255/255.0 green:71/255.0 blue:51/255.0 alpha:1];
        set5.drawCircleHoleEnabled = NO;
        set5.drawValuesEnabled = NO;//是否在拐点处显示数据
        set5.highlightEnabled = NO;//选中拐点,是否开启高亮效果(显示十字线)
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        [dataSets addObject:set2];
        [dataSets addObject:set3];
        [dataSets addObject:set4];
        [dataSets addObject:set5];
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        [data setValueTextColor:UIColor.whiteColor];
        [data setValueFont:[UIFont systemFontOfSize:9.f]];
        
//        _chartView.xAxis.axisRange = 15;
//        [_chartView setVisibleXRangeWithMinXRange:0.5 maxXRange:UI_IS_IPHONE5?4:5];
//        
//        _chartView.xAxis.labelCount = 5;
        _chartView.data = data;
    }
}

- (void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
