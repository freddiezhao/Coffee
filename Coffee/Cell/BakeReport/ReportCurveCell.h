//
//  ReportCurveCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/18.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts-Swift.h>

@interface ReportCurveCell : UITableViewCell <ChartViewDelegate>

@property (nonatomic, strong) LineChartView *chartView;

@property (nonatomic, strong) NSMutableArray *yVals_Out;
@property (nonatomic, strong) NSMutableArray *yVals_In;
@property (nonatomic, strong) NSMutableArray *yVals_Bean;
@property (nonatomic, strong) NSMutableArray *yVals_Environment;
@property (nonatomic, strong) NSMutableArray *yVals_Diff;

- (void)setDataValue;
@end
