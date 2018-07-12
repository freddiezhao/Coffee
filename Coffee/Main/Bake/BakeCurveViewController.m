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

@interface BakeCurveViewController () <ChartViewDelegate>

@property (nonatomic, strong) LineChartView *chartView;

@property (nonatomic, strong) NetWork *myNet;

@property (nonatomic, strong) NSTimer *myTimer;
@end

@implementation BakeCurveViewController
{
    BOOL isFullScreen;
    double leftAxisMax;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //强制亮屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    testBtn.frame = CGRectMake(0, 0, 200, 50);
    [testBtn setTitle:@"下一页" forState:UIControlStateNormal];
    [testBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
        
    _myNet = [NetWork shareNetWork];
    
    _chartView = [self chartView];
    
    [_myNet addObserver:self forKeyPath:@"tempData" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotCountTempSucc) name:@"gotCountTempSucc" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tcpDisconnect) name:@"tcpDisconnect" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"gotCountTempSucc" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tcpDisconnect" object:nil];
}

- (void)dealloc{
    [_myNet removeObserver:self forKeyPath:@"tempData"];
}

#pragma mark - lazy load
- (LineChartView *)chartView{
    if (!_chartView) {
        _chartView = [[LineChartView alloc] init];
        _chartView.frame = CGRectMake(ScreenHeight * 0.1, ScreenWidth * 0.15, ScreenHeight * 0.8, ScreenWidth * 0.7);
        isFullScreen = NO;
        [self.view addSubview:_chartView];
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

- (NSTimer *)myTimer{
    if (!_myTimer) {
        _myTimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(getTemp) userInfo:nil repeats:YES];
    }
    return _myTimer;
}

- (void)uiMasonry{
    
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
- (void)test{
    //[self dismissViewControllerAnimated:YES completion:nil];
    //[self setDataValue:nil];
    _myTimer = [self myTimer];
//    NSMutableArray *getTemp = [[NSMutableArray alloc ] init];
//    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x68]];
//    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x01]];
//    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x00]];
//    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x00]];
//    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x02]];
//    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x10]];
//    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x02]];
//    [getTemp addObject:[NSNumber numberWithUnsignedChar:[_myNet getCS:getTemp]]];
//    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x16]];
//    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x0D]];
//    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x0A]];
//    [_myNet send:getTemp withTag:102];
}

- (void)getTemp{
    NSMutableArray *getTemp = [[NSMutableArray alloc ] init];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:_myNet.frameCount]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x02]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:getTemp]]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [getTemp addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    
    _myNet.frameCount++;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_myNet send:getTemp withTag:102];
        [_myNet.mySocket readDataWithTimeout:-1 tag:2];
    });
}

- (void)setDataValue:(NSArray *)dataArray
{
    
    
//    NSDictionary *tempDic = [NSObject readLocalFileWithName:@"数据"];
//    NSArray *beanTemp = tempDic[@"temp2"];
//    NSMutableArray *yVals = [NSMutableArray array];
//    for (int i = 0, j = 0; i < [beanTemp count]; i++) {
//        [yVals addObject:[[ChartDataEntry alloc] initWithX:i y:[beanTemp[i] doubleValue]]];

//        if (i != 0) {
//            [_yVals_diff addObject:[[ChartDataEntry alloc] initWithX:i y:([beanTemp[i] doubleValue] - [beanTemp[i-1] doubleValue])]];
//        }

//        j = i * 10;
//        if (j != 0 && j < [beanTemp count]) {
//            [_yVals_diff addObject:[[ChartDataEntry alloc] initWithX:j y:([beanTemp[j] doubleValue] - [beanTemp[j-10] doubleValue])/10]];
//        }
//    }
    
    LineChartDataSet *set1 = nil, *set2 = nil, *set3 = nil, *set4 = nil;
    
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
        [dataSets addObject:set1];
        //[dataSets addObject:set2];
        [dataSets addObject:set3];
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
    if (isFullScreen) {
        [UIView animateWithDuration:0.5 animations:^{
            _chartView.frame = CGRectMake(ScreenWidth * 0.1, ScreenHeight * 0.15, ScreenWidth * 0.8, ScreenHeight * 0.7);
            //_chartView.center = self.view.center;
            //NSLog(@"pinggao%f",ScreenHeight);
            isFullScreen = NO;
        }];
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            _chartView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            isFullScreen = YES;
            [NSObject showHudTipStr:LocalString(@"再次点击页面退出全屏")];
        }];
    }
    
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
        
    }
}

- (void)gotCountTempSucc{
    [_myTimer setFireDate:[NSDate date]];
}

- (void)tcpDisconnect{
    [_myTimer setFireDate:[NSDate distantFuture]];
}
@end
