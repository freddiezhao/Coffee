//
//  BakeReportController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/29.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BakeReportController.h"
#import "BeanModel.h"
#import "ReportModel.h"
#import "EventModel.h"
#import "TouchTableView.h"
#import "ReportLightCell.h"
#import "BeanHeaderCell.h"
#import "BeanInfoCell.h"
#import "ReportCurveCell.h"
#import "CollectInfoCell.h"
#import "TempPer30sCell.h"

NSString *const CellIdentifier_reportLight = @"CellID_reportLight";
NSString *const CellIdentifier_reportBeanHeader = @"CellID_reportBeanHeader";
NSString *const CellIdentifier_reportBeanInfo = @"CellID_reportBeanInfo";
NSString *const CellIdentifier_reportCurve = @"CellID_reportCurve";
NSString *const CellIdentifier_collect = @"CellID_collect";
NSString *const CellIdentifier_TempPer30 = @"CellID_TempPer30";

@interface BakeReportController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *reportTable;

@property (nonatomic, strong) NSArray *beanArray;
@property (nonatomic, strong) ReportModel *reportModel;
@property (nonatomic, strong) NSArray *eventArray;

@property (nonatomic, strong) NSMutableArray *yVals_Out;
@property (nonatomic, strong) NSMutableArray *yVals_In;
@property (nonatomic, strong) NSMutableArray *yVals_Bean;
@property (nonatomic, strong) NSMutableArray *yVals_Environment;
@property (nonatomic, strong) NSMutableArray *yVals_Diff;

@end

@implementation BakeReportController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _reportTable = [self reportTable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

#pragma mark - lazy load
- (UITableView *)reportTable{
    if (!_reportTable) {
        _reportTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[ReportLightCell class] forCellReuseIdentifier:CellIdentifier_reportLight];
            [tableView registerClass:[BeanHeaderCell class] forCellReuseIdentifier:CellIdentifier_reportBeanHeader];
            [tableView registerClass:[BeanInfoCell class] forCellReuseIdentifier:CellIdentifier_reportBeanInfo];
            [tableView registerClass:[ReportCurveCell class] forCellReuseIdentifier:CellIdentifier_reportCurve];
            [tableView registerClass:[CollectInfoCell class] forCellReuseIdentifier:CellIdentifier_collect];
            [tableView registerClass:[TempPer30sCell class] forCellReuseIdentifier:CellIdentifier_TempPer30];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            //tableView.scrollEnabled = NO;
//            if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//                [tableView setSeparatorInset:UIEdgeInsetsZero];
//            }
//            if ([tableView respondsToSelector:@selector(setLayoutMargins:)])  {
//                [tableView setLayoutMargins:UIEdgeInsetsZero];
//            }
            tableView;
        });
    }
    return _reportTable;
}

#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
            
        case 1:
            return 2;
            break;
            
        case 2:
            return 1;
            break;
            
        case 3:
            return 1;
            break;
            
        case 4:
            return 2;
            break;
            
        default:
            return 0;
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return 201.f/HScale;
            break;
            
        case 1:
            {
                if (indexPath.row == 0) {
                    return 70.f/HScale;
                }else{
                    return 159.f/HScale;
                }
                
            }
            
            break;
            
        case 2:
            return 202.f/HScale;
            break;
            
        case 3:
            return 1072.f/HScale;
            break;
            
        case 4:
            return 2 * 36;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        ReportLightCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_reportLight];
        if (cell == nil) {
            cell = [[ReportLightCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_reportLight];
        }
        cell.lightValue.text = LocalString(@"60");
        cell.bakeDate.text = LocalString(@"烘焙日期:2018-08-04");
        cell.deviceName.text = LocalString(@"设备:HB-M6G咖啡烘焙机");
        return cell;
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            BeanHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_reportBeanHeader];
            if (cell == nil) {
                cell = [[BeanHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_reportBeanHeader];
            }
            cell.beanNameLabel.text = LocalString(@"样品豆、蓝山豆、拿铁豆、越南豆");
            cell.rawBean.text = LocalString(@"生豆:100.0g");
            cell.bakedBean.text = LocalString(@"熟豆:22.0g");
            cell.outWaterRate.text = LocalString(@"脱水率:78.0%");
            
            return cell;
        }else{
            BeanInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_reportBeanInfo];
            if (cell == nil) {
                cell = [[BeanInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_reportBeanInfo];
            }
            return cell;
        }
    }else if (indexPath.section == 2){
        ReportCurveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_reportCurve];
        if (cell == nil) {
            cell = [[ReportCurveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_reportCurve];
        }
        [cell setDataValue];
        return cell;
    }else if (indexPath.section == 3){
        CollectInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_collect];
        if (cell == nil) {
            cell = [[CollectInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_collect];
        }
        
        return cell;
    }else if (indexPath.section == 4){
        TempPer30sCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_TempPer30];
        if (cell == nil) {
            cell = [[TempPer30sCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_TempPer30];
        }
        if (indexPath.row == 0) {
            cell.Label1.text = LocalString(@"时间");
            cell.Label2.text = LocalString(@"豆温(°C)");
            cell.Label3.text = LocalString(@"进风温(°C)");
            cell.Label4.text = LocalString(@"出风温(°C)");
            cell.Label5.text = LocalString(@"环境温(°C)");
            cell.Label6.text = LocalString(@"升温率(°C/min)");
        }else{
            cell.Label1.text = LocalString(@"00:00");
            cell.Label2.text = LocalString(@"1");
            cell.Label3.text = LocalString(@"1");
            cell.Label4.text = LocalString(@"1");
            cell.Label5.text = LocalString(@"1");
            cell.Label6.text = LocalString(@"1");
        }
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"asdf"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"asdf"];
        }
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5/HScale)];
                headerView.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
                return headerView;
            }
            break;
            
        case 1:
        case 2:
        case 3:
        case 4:
            {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 10/HScale)];
                headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
                return headerView;
            }
            break;
            
            
        default:
            return nil;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 0.5/HScale;
            break;
            
        case 1:
        case 2:
        case 3:
            return 10/HScale;
            break;
            
        default:
            return 0.f;
            break;
    }
}

#pragma mark - DataSource
- (void)queryReportInfo{
    _reportModel = [[DataBase shareDataBase] queryReport:[NSNumber numberWithInteger:_curveId]];
    NSLog(@"%@",_reportModel.date);
    NSData *curveData = [_reportModel.curveValueJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *curveDic = [NSJSONSerialization JSONObjectWithData:curveData options:NSJSONReadingMutableLeaves error:nil];

    _yVals_Bean = [curveDic objectForKey:@"bean"];
    _yVals_Out = [curveDic objectForKey:@"out"];
    _yVals_In = [curveDic objectForKey:@"in"];
    _yVals_Environment = [curveDic objectForKey:@"environment"];
    _yVals_Diff = [curveDic objectForKey:@"diff"];
}

- (void)queryEventInfo{
    _eventArray = [[DataBase shareDataBase] queryEvent:[NSNumber numberWithInteger:_curveId]];
    for (EventModel *event in _eventArray) {
        NSLog(@"%@",event.eventText);
    }
}

- (void)queryBeanInfo{
    DataBase *db = [DataBase shareDataBase];
    NSMutableArray *beanMutaArray = [[db queryReportRelaBean:[NSNumber numberWithInteger:_curveId]] mutableCopy];
    for (int i = 0; i < [beanMutaArray count]; i++) {
        BeanModel *beanModelOld = beanMutaArray[i];
        BeanModel *beanModelNew = [db queryBean:[NSNumber numberWithInteger:beanModelOld.beanId]];
        beanModelNew.weight = beanModelOld.weight;
        beanModelNew.beanId = beanModelOld.beanId;
        [beanMutaArray replaceObjectAtIndex:i withObject:beanModelNew];
    }
    //可能没有添加生豆数据
    _beanArray = [beanMutaArray copy];
}

@end
