//
//  ShareReportController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/11/7.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "ShareReportController.h"
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
#import "ReportEditController.h"
#import "ProdQRCodeView.h"

NSString *const CellIdentifier_reportLightShare = @"CellID_reportLightShare";
NSString *const CellIdentifier_reportBeanHeaderShare = @"CellID_reportBeanHeaderShare";
NSString *const CellIdentifier_reportBeanInfoShare = @"CellID_reportBeanInfoShare";
NSString *const CellIdentifier_reportCurveShare = @"CellID_reportCurveShare";
NSString *const CellIdentifier_collectShare = @"CellID_collectShare";
NSString *const CellIdentifier_TempPer30Share = @"CellID_TempPer30Share";

@interface ShareReportController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *reportTable;

@property (nonatomic, strong) NSMutableArray *beanArray;
@property (nonatomic, strong) ReportModel *reportModel;
@property (nonatomic, strong) NSMutableArray *eventArray;

@property (nonatomic, strong) NSMutableArray *yVals_Out;
@property (nonatomic, strong) NSMutableArray *yVals_In;
@property (nonatomic, strong) NSMutableArray *yVals_Bean;
@property (nonatomic, strong) NSMutableArray *yVals_Environment;
@property (nonatomic, strong) NSMutableArray *yVals_Diff;

@property (nonatomic, strong) NSMutableArray *Out;
@property (nonatomic, strong) NSMutableArray *In;
@property (nonatomic, strong) NSMutableArray *Bean;
@property (nonatomic, strong) NSMutableArray *Environment;
@property (nonatomic, strong) NSMutableArray *Diff;

@end

@implementation ShareReportController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavItem];
    
    _reportTable = [self reportTable];
    
    _beanArray = [[NSMutableArray alloc] init];
    _eventArray = [[NSMutableArray alloc] init];
    _yVals_In = [[NSMutableArray alloc] init];
    _yVals_Out = [[NSMutableArray alloc] init];
    _yVals_Bean = [[NSMutableArray alloc] init];
    _yVals_Diff = [[NSMutableArray alloc] init];
    _yVals_Environment = [[NSMutableArray alloc] init];
    
    [self queryReportInfo];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

#pragma mark - lazy load
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"烘焙报告");
    
}


- (UITableView *)reportTable{
    if (!_reportTable) {
        _reportTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[ReportLightCell class] forCellReuseIdentifier:CellIdentifier_reportLightShare];
            [tableView registerClass:[BeanHeaderCell class] forCellReuseIdentifier:CellIdentifier_reportBeanHeaderShare];
            [tableView registerClass:[BeanInfoCell class] forCellReuseIdentifier:CellIdentifier_reportBeanInfoShare];
            [tableView registerClass:[ReportCurveCell class] forCellReuseIdentifier:CellIdentifier_reportCurveShare];
            [tableView registerClass:[CollectInfoCell class] forCellReuseIdentifier:CellIdentifier_collectShare];
            [tableView registerClass:[TempPer30sCell class] forCellReuseIdentifier:CellIdentifier_TempPer30Share];
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
            return _yVals_Bean.count>0?_yVals_Bean.count / 30 + 1 + 1:1;
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
        ReportLightCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_reportLightShare];
        if (cell == nil) {
            cell = [[ReportLightCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_reportLightShare];
        }
        if (_reportModel.light) {
            cell.lightValue.text = [NSString stringWithFormat:@"%lf",_reportModel.light];
        }else{
            cell.lightValue.text = LocalString(@"?");
        }
        if (_reportModel.date) {
            cell.bakeDate.text = [NSString stringWithFormat:@"%@%@",LocalString(@"烘焙日期:"),[NSDate YMDStringFromDate:_reportModel.date]];
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
            BeanHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_reportBeanHeaderShare];
            if (cell == nil) {
                cell = [[BeanHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_reportBeanHeaderShare];
            }
            if (_beanArray.count>0) {
                NSString *nameString = LocalString(@"");
                for (BeanModel *model in _beanArray) {
                    nameString = [nameString stringByAppendingString:[NSString stringWithFormat:@"%@、",model.name]];
                }
                cell.beanNameLabel.text = [nameString substringToIndex:[nameString length]-1];
                cell.rawBean.text = [NSString stringWithFormat:@"%@%.1lf",LocalString(@"生豆:"),_reportModel.rawBeanWeight];
                cell.bakedBean.text = [NSString stringWithFormat:@"%@%.1lf",LocalString(@"熟豆:"),_reportModel.bakeBeanWeight];
                cell.outWaterRate.text = [NSString stringWithFormat:@"%@%.1lf%%",LocalString(@"脱水率:"),(_reportModel.rawBeanWeight - _reportModel.bakeBeanWeight)/_reportModel.rawBeanWeight*100.f];
            }else{
                cell.beanNameLabel.text = LocalString(@"未添加豆种");
                cell.rawBean.text = LocalString(@"生豆:?");
                cell.bakedBean.text = LocalString(@"熟豆:?");
                cell.outWaterRate.text = LocalString(@"脱水率:?");
            }
            return cell;
        }else{
            BeanInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_reportBeanInfoShare];
            if (cell == nil) {
                cell = [[BeanInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_reportBeanInfoShare];
            }
            BeanModel *bean = _beanArray[indexPath.row - 1];
            if (bean.name) {
                cell.beanName.text = bean.name;
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
                cell.altitude.text = [NSString stringWithFormat:@"%.1f",bean.altitude];
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
                cell.water.text = [NSString stringWithFormat:@"%.1f",bean.water];
            }else{
                cell.water.text = LocalString(@"未知");
            }
            if (bean.weight) {
                cell.weight.text = [NSString stringWithFormat:@"%.1f",bean.weight];
            }else{
                cell.weight.text = LocalString(@"未知");
            }
            return cell;
        }
    }else if (indexPath.section == 2){
        ReportCurveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_reportCurveShare];
        if (cell == nil) {
            cell = [[ReportCurveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_reportCurveShare];
        }
        if (_yVals_In.count > 0 && _yVals_Out.count > 0 && _yVals_Bean.count > 0 && _yVals_Environment.count > 0) {
            cell.yVals_In = _yVals_In;
            cell.yVals_Out = _yVals_Out;
            cell.yVals_Bean = _yVals_Bean;
            cell.yVals_Environment = _yVals_Environment;
            cell.yVals_Diff = _yVals_Diff;
            [cell setDataValue];
        }
        return cell;
    }else if (indexPath.section == 3){
        CollectInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_collectShare];
        if (cell == nil) {
            cell = [[CollectInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_collectShare];
        }
        cell.reportModel = _reportModel;
        cell.eventArray = [self upSortByTime:[_eventArray mutableCopy]];
        //[cell.curveCollectView reloadData];
        return cell;
    }else if (indexPath.section == 4){
        TempPer30sCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_TempPer30Share];
        if (cell == nil) {
            cell = [[TempPer30sCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_TempPer30Share];
        }
        if (indexPath.row == 0) {
            cell.Label1.text = LocalString(@"时间");
            cell.Label2.text = [NSString stringWithFormat:@"%@(%@)",LocalString(@"豆温"),[DataBase shareDataBase].setting.tempUnit];
            cell.Label3.text = [NSString stringWithFormat:@"%@(%@)",LocalString(@"进风温"),[DataBase shareDataBase].setting.tempUnit];
            cell.Label4.text = [NSString stringWithFormat:@"%@(%@)",LocalString(@"出风温"),[DataBase shareDataBase].setting.tempUnit];
            cell.Label5.text = [NSString stringWithFormat:@"%@(%@)",LocalString(@"环境温"),[DataBase shareDataBase].setting.tempUnit];
            cell.Label6.text = [NSString stringWithFormat:@"%@\n(%@/min)",LocalString(@"升温率"),[DataBase shareDataBase].setting.tempUnit];
        }else{
            //|| indexPath.row * 30 < _yVals_Diff.count
            NSInteger row = indexPath.row - 1;
            if (row * 30 < _In.count || row * 30 < _Out.count || row * 30 < _Bean.count || row * 30 < _Environment.count ) {
                cell.Label1.text = [NSString stringWithFormat:@"%ld:%ld",row/2,row%2*30];
                if (row * 30 < _In.count) {
                    cell.Label2.text = [NSString stringWithFormat:@"%.1f",[NSString diffTempUnitStringWithTemp:[_In[row * 30] doubleValue]]];
                }else{
                    cell.Label2.text = @"?";
                }
                if (row * 30 < _Out.count) {
                    cell.Label3.text = [NSString stringWithFormat:@"%.1f",[NSString diffTempUnitStringWithTemp:[_Out[row * 30] doubleValue]]];
                }else{
                    cell.Label3.text = @"?";
                }
                if (row * 30 < _Bean.count) {
                    cell.Label4.text = [NSString stringWithFormat:@"%.1f",[NSString diffTempUnitStringWithTemp:[_In[row * 30] doubleValue]]];
                }else{
                    cell.Label4.text = @"?";
                }
                if (row * 30 < _Environment.count) {
                    cell.Label5.text = [NSString stringWithFormat:@"%.1f",[NSString diffTempUnitStringWithTemp:[_In[row * 30] doubleValue]]];
                }else{
                    cell.Label5.text = @"?";
                }
                if (row * 30 / beanRorDiffCount< _Diff.count) {
                    cell.Label6.text = [NSString stringWithFormat:@"%.1f",[NSString diffTempUnitStringWithTemp:[_Diff[row * 30 / beanRorDiffCount] doubleValue]]];
                }else{
                    cell.Label6.text = @"0.0";
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
    _reportModel = [[DataBase shareDataBase] queryReport:_curveUid];
    _reportModel.curveUid = _curveUid;
    NSLog(@"%@",_reportModel.date);
    if (_reportModel.curveValueJson) {
        NSData *curveData = [_reportModel.curveValueJson dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *curveDic = [NSJSONSerialization JSONObjectWithData:curveData options:NSJSONReadingMutableLeaves error:nil];
        
        _Bean = [curveDic objectForKey:@"bean"];
        _Out = [curveDic objectForKey:@"out"];
        _In = [curveDic objectForKey:@"in"];
        _Environment = [curveDic objectForKey:@"env"];
        if (!_Diff) {
            _Diff = [[NSMutableArray alloc] init];
        }
        [_Diff removeAllObjects];
        for (int i = beanRorDiffCount; i < _Bean.count; i = i + beanRorDiffCount) {
            [_Diff addObject:[NSNumber numberWithDouble:([_Bean[i] doubleValue] - [_Bean[i - beanRorDiffCount] doubleValue]) * 12.f]];
        }
        
        NSLog(@"%lu",(unsigned long)_Bean.count);
        NSLog(@"%lu",_Out.count);
        NSLog(@"%lu",_In.count);
        NSLog(@"%lu",_Environment.count);
        
        for (int i = 0; i<_Bean.count; i++) {
            [_yVals_Bean addObject:[[ChartDataEntry alloc] initWithX:i y:[_Bean[i] doubleValue]]];
        }
        for (int i = 0; i<_Out.count; i++) {
            [_yVals_Out addObject:[[ChartDataEntry alloc] initWithX:i y:[_Out[i] doubleValue]]];
        }
        for (int i = 0; i<_In.count; i++) {
            [_yVals_In addObject:[[ChartDataEntry alloc] initWithX:i y:[_In[i] doubleValue]]];
        }
        for (int i = 0; i<_Environment.count; i++) {
            [_yVals_Environment addObject:[[ChartDataEntry alloc] initWithX:i y:[_Environment[i] doubleValue]]];
        }
        _yVals_Diff = [[NetWork shareNetWork] getBeanTempRorWithArr:_Bean];
        
    }
    
    [self queryEventInfo];
}

- (void)queryEventInfo{
    _eventArray = [[[DataBase shareDataBase] queryEvent:_curveUid] mutableCopy];
    for (EventModel *event in _eventArray) {
        NSLog(@"%@",event.eventText);
        //NSLog(@"%ld",event.eventId);
    }
    
    EventModel *event1;
    EventModel *event2;
    
    //烘焙时长，发展时间，发展率，脱水率，开始温度，结束温度都由事件列表取得或计算得到，脱水率，开始温度，结束温度在cell的显示函数中直接计算，烘焙时长，发展时间，发展率在下面计算并保存在reportModel中
    //计算烘焙时长
    for (EventModel *event in _eventArray) {
        if (event.eventId == 0) {
            event1 = event;
        }else if (event.eventId == 7){
            event2 = event;
        }
    }
    _reportModel.bakeTime = event2.eventTime - event1.eventTime;
    
    //计算发展时间
    for (EventModel *event in _eventArray) {
        if (event.eventId == 3) {
            event1 = event;
        }else if (event.eventId == 5){
            event2 = event;
        }
    }
    _reportModel.developTime = event2.eventTime - event1.eventTime;
    _reportModel.developRate = (float)_reportModel.developTime/_reportModel.bakeTime*100.f;
    
    [self queryBeanInfo];
}

- (void)queryBeanInfo{
    [SVProgressHUD show];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roastCurve/bean/message?curveUid=%@",_curveUid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            if ([responseDic objectForKey:@"data"]) {
                //第一页信息获取
                NSDictionary *dic = [responseDic objectForKey:@"data"];
                if ([dic objectForKey:@"beans"]) {
                    [[dic objectForKey:@"beans"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        BeanModel *bean = [[BeanModel alloc] init];
                        bean.name = [obj objectForKey:@"name"];
                        bean.nation = [obj objectForKey:@"country"];
                        bean.area = [obj objectForKey:@"origin"];
                        bean.grade = [obj objectForKey:@"grade"];
                        bean.process = [obj objectForKey:@"processingMethod"];
                        bean.manor = [obj objectForKey:@"farm"];
                        bean.altitude = [[obj objectForKey:@"altitude"] floatValue];
                        bean.weight = [[obj objectForKey:@"used"] floatValue];
                        [_beanArray addObject:bean];
                    }];
                    [self.reportTable reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                }
            }
        }else{
            [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
    
}

//用来排序事件列表(根据事件发生时间)
- (NSMutableArray *)upSortByTime:(NSMutableArray *)arr{
    [arr sortUsingComparator:^NSComparisonResult(EventModel *obj1, EventModel *obj2) {
        if (obj1.eventTime > obj2.eventTime) {
            return NSOrderedDescending;
        }else if (obj1.eventTime == obj2.eventTime){
            return NSOrderedSame;
        }else{
            return NSOrderedAscending;
        }
    }];
    return [arr mutableCopy];
}

#pragma mark - Actions
- (void)editReport{
    ReportEditController *editVC = [[ReportEditController alloc] init];
    editVC.beanArray = [_beanArray mutableCopy];
    editVC.reportModel = _reportModel;
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)shareReport{
    ProdQRCodeView *QRVC = [[ProdQRCodeView alloc] init];
    QRVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    QRVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:QRVC animated:YES completion:^{
        QRVC.curveUid = _curveUid;
        NSLog(@"%@",_curveUid);
        [QRVC generateQRCode];
    }];
}
@end