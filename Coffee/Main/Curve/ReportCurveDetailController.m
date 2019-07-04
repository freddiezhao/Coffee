//
//  ReportCurveDetailController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2019/3/20.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "ReportCurveDetailController.h"
#import <Charts/Charts-Swift.h>

@interface ReportCurveDetailController () <ChartViewDelegate,IChartAxisValueFormatter>

@property (nonatomic, strong) LineChartView *chartView;
@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation ReportCurveDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _chartView = [self chartView];
    _backBtn = [self backBtn];
    [self setDataValue];
}

#pragma mark - setters and getters
- (LineChartView *)chartView{
    if (!_chartView) {
        _chartView = [[LineChartView alloc] init];
        if (kDevice_Is_iPhoneX) {
            _chartView.frame = CGRectMake((45+44)/HScale, 30/WScale, ScreenHeight - 87/HScale  - 44/WScale, ScreenWidth - 50/WScale);
        }else{
            _chartView.frame = CGRectMake(45/HScale, 30/WScale, ScreenHeight - 87/HScale, ScreenWidth - 50/WScale);
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
        leftAxis.axisMinimum = 0.0;
        leftAxis.spaceTop = 30.f;
        leftAxis.drawGridLinesEnabled = YES;
        leftAxis.gridLineWidth = 0.6f;
        leftAxis.gridColor = [UIColor colorWithHexString:@"EBEDF0"];
        //leftAxis.gridLineDashLengths = @[@5.f,@5.f];//虚线
        leftAxis.drawZeroLineEnabled = NO;
        leftAxis.granularityEnabled = YES;
        leftAxis.axisMinimum = 50.0;
        leftAxis.granularity = 50.f;

        ChartYAxis *rightAxis = _chartView.rightAxis;
        rightAxis.labelFont = [UIFont fontWithName:@"Avenir-Light" size:12];
        rightAxis.labelTextColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        rightAxis.axisMaximum = 20.0;
        rightAxis.axisMinimum = 0;
        rightAxis.drawGridLinesEnabled = NO;
        rightAxis.granularityEnabled = NO;
        
        [_chartView animateWithXAxisDuration:1.0];
    }
    
    return _chartView;
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
        
        _chartView.xAxis.axisRange = 15;
        [_chartView setVisibleXRangeWithMinXRange:0.5 maxXRange:UI_IS_IPHONE5?4:5];
        
        _chartView.xAxis.labelCount = 5;
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
