//
//  BakeReportController.m
//  Coffee
//
//如果从后台更新的话把所有数据存到本地数据库，然后再从数据库获取信息显示，也就是所有的信息只从本地sqlite取
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
    self.navigationItem.title = LocalString(@"烘焙报告");
    
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
            return 1 + _beanArray.count;
            break;
            
        case 2:
            return 1;
            break;
            
        case 3:
            return 1;
            break;
            
        case 4:
            return _yVals_Bean.count / 30 + 1;
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
            return 36.f/HScale;
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
        if (_reportModel.light) {
            cell.lightValue.text = [NSString stringWithFormat:@"%ld",_reportModel.light];
        }else{
            cell.lightValue.text = LocalString(@"?");
        }
        if (_reportModel.date) {
            cell.bakeDate.text = [NSString stringWithFormat:@"%@%@",LocalString(@"烘焙日期:"),[NSDate localStringFromUTCDate:_reportModel.date]];
        }else{
            cell.bakeDate.text = LocalString(@"烘焙日期:1970-01-01");
        }
        if (_reportModel.deviceName) {
            cell.deviceName.text = _reportModel.deviceName;
        }else{
            cell.deviceName.text = LocalString(@"设备:未知");
        }
        return cell;
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            BeanHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_reportBeanHeader];
            if (cell == nil) {
                cell = [[BeanHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_reportBeanHeader];
            }
            if (_beanArray.count>0) {
                NSString *nameString = LocalString(@"");
                for (BeanModel *model in _beanArray) {
                    nameString = [nameString stringByAppendingString:[NSString stringWithFormat:@"%@、",model.beanName]];
                }
                cell.beanNameLabel.text = [nameString substringToIndex:[nameString length]-1];
                cell.rawBean.text = [NSString stringWithFormat:@"%@%ld",LocalString(@"生豆:"),_reportModel.rawBeanWeight];
                cell.bakedBean.text = [NSString stringWithFormat:@"%@%ld",LocalString(@"熟豆:"),_reportModel.bakeBeanWeight];
                cell.outWaterRate.text = [NSString stringWithFormat:@"%@%@",LocalString(@"脱水率:"),_reportModel.outWaterRate];
            }else{
                cell.beanNameLabel.text = LocalString(@"未添加豆种");
                cell.rawBean.text = LocalString(@"生豆:?");
                cell.bakedBean.text = LocalString(@"熟豆:?");
                cell.outWaterRate.text = LocalString(@"脱水率:?");
            }
            return cell;
        }else{
            BeanInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_reportBeanInfo];
            if (cell == nil) {
                cell = [[BeanInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_reportBeanInfo];
            }
            for (BeanModel *bean in _beanArray) {
                if (bean.beanName) {
                    cell.beanName.text = bean.beanName;
                }else{
                    cell.beanName.text = LocalString(@"未知");
                }
                if (bean.nation) {
                    cell.nation.text = bean.nation;
                }else{
                    cell.nation.text = LocalString(@"未知");
                }
                if (bean.area) {
                    cell.area.text = bean.area;
                }else{
                    cell.area.text = LocalString(@"未知");
                }
                if (bean.altitude) {
                    cell.altitude.text = bean.altitude;
                }else{
                    cell.altitude.text = LocalString(@"未知");
                }
                if (bean.manor) {
                    cell.manor.text = bean.manor;
                }else{
                    cell.manor.text = LocalString(@"未知");
                }
                if (bean.beanSpecies) {
                    cell.beanSpecies.text = bean.beanSpecies;
                }else{
                    cell.beanSpecies.text = LocalString(@"未知");
                }
                if (bean.grade) {
                    cell.grade.text = bean.grade;
                }else{
                    cell.grade.text = LocalString(@"未知");
                }
                if (bean.process) {
                    cell.process.text = bean.process;
                }else{
                    cell.process.text = LocalString(@"未知");
                }
                if (bean.water) {
                    cell.water.text = bean.water;
                }else{
                    cell.water.text = LocalString(@"未知");
                }
                if (bean.weight) {
                    cell.weight.text = [NSString stringWithFormat:@"%ld",bean.weight];
                }else{
                    cell.weight.text = LocalString(@"未知");
                }
            }
            return cell;
        }
    }else if (indexPath.section == 2){
        ReportCurveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_reportCurve];
        if (cell == nil) {
            cell = [[ReportCurveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_reportCurve];
        }
        cell.yVals_In = _yVals_In;
        cell.yVals_Out = _yVals_Out;
        cell.yVals_Bean = _yVals_Bean;
        cell.yVals_Environment = _yVals_Environment;
        cell.yVals_Diff = _yVals_Diff;
        [cell setDataValue];
        return cell;
    }else if (indexPath.section == 3){
        CollectInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_collect];
        if (cell == nil) {
            cell = [[CollectInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_collect];
        }
        cell.reportModel = _reportModel;
        cell.eventArray = [_eventArray copy];
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
            cell.Label6.text = LocalString(@"升温率\n(°C/min)");
        }else{
            if (indexPath.row * 30 < _yVals_In.count || indexPath.row * 30 < _yVals_Out.count || indexPath.row * 30 < _yVals_Bean.count || indexPath.row * 30 < _yVals_Environment.count || indexPath.row * 30 < _yVals_Diff.count) {
                cell.Label1.text = [NSString stringWithFormat:@"%ld:%ld",indexPath.row/2,indexPath.row%2*30];
                if (indexPath.row * 30 < _yVals_In.count) {
                    cell.Label2.text = _yVals_In[indexPath.row * 30];
                }else{
                    cell.Label2.text = @"?";
                }
                if (indexPath.row * 30 < _yVals_Out.count) {
                    cell.Label3.text = _yVals_Out[indexPath.row * 30];
                }else{
                    cell.Label3.text = @"?";
                }
                if (indexPath.row * 30 < _yVals_Bean.count) {
                    cell.Label4.text = _yVals_Bean[indexPath.row * 30];
                }else{
                    cell.Label4.text = @"?";
                }
                if (indexPath.row * 30 < _yVals_Environment.count) {
                    cell.Label5.text = _yVals_Environment[indexPath.row * 30];
                }else{
                    cell.Label5.text = @"?";
                }
                if (indexPath.row * 30 < _yVals_Diff.count) {
                    cell.Label6.text = _yVals_Diff[indexPath.row * 30];
                }else{
                    cell.Label6.text = @"?";
                }
            }
            
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
        case 4:
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
