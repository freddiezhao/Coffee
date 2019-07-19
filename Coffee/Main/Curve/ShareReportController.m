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
#import "CurveDetailClickCell.h"
#import "ReportCurveDetailController.h"

NSString *const CellIdentifier_reportLightShare = @"CellID_reportLightShare";
NSString *const CellIdentifier_reportBeanHeaderShare = @"CellID_reportBeanHeaderShare";
NSString *const CellIdentifier_reportBeanInfoShare = @"CellID_reportBeanInfoShare";
NSString *const CellIdentifier_reportCurveShare = @"CellID_reportCurveShare";
NSString *const CellIdentifier_reportCurveShareDetail = @"CellID_reportCurveShareDetail";
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
    self.navigationItem.title = self.name;
    
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
            [tableView registerClass:[CurveDetailClickCell class] forCellReuseIdentifier:CellIdentifier_reportCurveShareDetail];
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
            return 2;
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
        {
            if (indexPath.row == 0) {
                return 202.f/HScale;
            }else{
                return 40.f/HScale;
            }
        }
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
        cell.lightValue.text = [NSString stringWithFormat:@"%d",(int)_reportModel.light];
        [cell setCircleViewColor:_reportModel.light];
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
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            BeanModel *bean = _beanArray[indexPath.row - 1];
            if (bean.name && ![bean.name isEqualToString:@""]) {
                cell.beanName.attributedText = [self getAttributedString:LocalString(@"名称") appendString:bean.name];
            }else{
                cell.beanName.attributedText = [self getAttributedString:LocalString(@"名称") appendString:LocalString(@"未知")];
            }
            if (bean.nation && ![bean.nation isEqualToString:@""]) {
                cell.nation.attributedText = [self getAttributedString:LocalString(@"国家") appendString:bean.nation];
            }else{
                cell.nation.attributedText = [self getAttributedString:LocalString(@"国家") appendString:LocalString(@"未知")];
            }
            if (bean.area && ![bean.area isEqualToString:@""]) {
                cell.area.attributedText = [self getAttributedString:LocalString(@"产区") appendString:bean.area];
            }else{
                cell.area.attributedText = [self getAttributedString:LocalString(@"产区") appendString:LocalString(@"未知")];
            }
            if (bean.manor && ![bean.manor isEqualToString:@""]) {
                cell.manor.attributedText = [self getAttributedString:LocalString(@"庄园") appendString:bean.manor];
            }else{
                cell.manor.attributedText = [self getAttributedString:LocalString(@"庄园") appendString:LocalString(@"未知")];
            }
            if (bean.beanSpecies && ![bean.beanSpecies isEqualToString:@""]) {
                cell.beanSpecies.attributedText = [self getAttributedString:LocalString(@"豆种") appendString:bean.beanSpecies];
            }else{
                cell.beanSpecies.attributedText = [self getAttributedString:LocalString(@"豆种") appendString:LocalString(@"未知")];
            }
            if (bean.grade && ![bean.grade isEqualToString:@""]) {
                cell.grade.attributedText = [self getAttributedString:LocalString(@"等级") appendString:bean.grade];
            }else{
                cell.grade.attributedText = [self getAttributedString:LocalString(@"等级") appendString:LocalString(@"未知")];
            }
            if (bean.process && ![bean.process isEqualToString:@""]) {
                cell.process.attributedText = [self getAttributedString:LocalString(@"处理方式") appendString:bean.process];
            }else{
                cell.process.attributedText = [self getAttributedString:LocalString(@"处理方式") appendString:LocalString(@"未知")];
            }
            cell.water.attributedText = [self getAttributedString:LocalString(@"含水量") appendString:[NSString stringWithFormat:@"%.1f",bean.water]];
            cell.weight.attributedText = [self getAttributedString:LocalString(@"生豆重量") appendString:[NSString stringWithFormat:@"%.1f",bean.weight]];
            cell.altitude.attributedText = [self getAttributedString:LocalString(@"海拔") appendString:[NSString stringWithFormat:@"%.1f",bean.altitude]];
            return cell;
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
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
        }else{
            CurveDetailClickCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_reportCurveShareDetail];
            if (cell == nil) {
                cell = [[CurveDetailClickCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_reportCurveShareDetail];
            }
            return cell;
        }
    }else if (indexPath.section == 3){
        CollectInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_collectShare];
        if (cell == nil) {
            cell = [[CollectInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_collectShare];
        }
        cell.reportModel = _reportModel;
        cell.eventArray = [self upSortByTime:[_eventArray mutableCopy]];
        [cell.curveCollectView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        return cell;
    }else if (indexPath.section == 4){
        TempPer30sCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_TempPer30Share];
        if (cell == nil) {
            cell = [[TempPer30sCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_TempPer30Share];
        }
        if (indexPath.row == 0) {
            cell.Label1.text = LocalString(@"时间");
            cell.Label2.text = [NSString stringWithFormat:@"%@(%@)",LocalString(@"豆温"),[DataBase shareDataBase].setting.tempUnit];
            cell.Label3.text = [NSString stringWithFormat:@"%@(%@)",LocalString(@"热风温"),[DataBase shareDataBase].setting.tempUnit];
            cell.Label4.text = [NSString stringWithFormat:@"%@(%@)",LocalString(@"排气温"),[DataBase shareDataBase].setting.tempUnit];
            cell.Label5.text = [NSString stringWithFormat:@"%@(%@)",LocalString(@"环境温"),[DataBase shareDataBase].setting.tempUnit];
            cell.Label6.text = [NSString stringWithFormat:@"%@\n(%@/min)",LocalString(@"升温率"),[DataBase shareDataBase].setting.tempUnit];
        }else{
            //|| indexPath.row * 30 < _yVals_Diff.count
            NSInteger row = indexPath.row - 1;
            if (row * 30 < _In.count || row * 30 < _Out.count || row * 30 < _Bean.count || row * 30 < _Environment.count ) {
                cell.Label1.text = [NSString stringWithFormat:@"%ld:%02ld",row/2,row%2*30];
                if (row * 30 < _Bean.count) {
                    cell.Label2.text = [NSString stringWithFormat:@"%.1f",[NSString diffTempUnitStringWithTemp:[_Bean[row * 30] doubleValue]]];
                }else{
                    cell.Label2.text = @"?";
                }
                if (row * 30 < _In.count) {
                    cell.Label3.text = [NSString stringWithFormat:@"%.1f",[NSString diffTempUnitStringWithTemp:[_In[row * 30] doubleValue]]];
                }else{
                    cell.Label3.text = @"?";
                }
                if (row * 30 < _Out.count) {
                    cell.Label4.text = [NSString stringWithFormat:@"%.1f",[NSString diffTempUnitStringWithTemp:[_Out[row * 30] doubleValue]]];
                }else{
                    cell.Label4.text = @"?";
                }
                if (row * 30 < _Environment.count) {
                    cell.Label5.text = [NSString stringWithFormat:@"%.1f",[NSString diffTempUnitStringWithTemp:[_Environment[row * 30] doubleValue]]];
                }else{
                    cell.Label5.text = @"?";
                }
                if (row == 0) {
                    cell.Label6.text = @"0.0";
                }else{
                    if (row * 30 / beanRorDiffCount< _Diff.count) {
                        cell.Label6.text = [NSString stringWithFormat:@"%.1f",[_Diff[row * 30 / beanRorDiffCount - 1] doubleValue]];
                    }else{
                        cell.Label6.text = @"0.0";
                    }
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

- (NSMutableAttributedString *)getAttributedString:(NSString *)text appendString:(NSString *)appendStr{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@",text,appendStr]];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"999999"] range:NSMakeRange(0,text.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"333333"] range:NSMakeRange(text.length + 2,str.length - text.length - 2)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.f] range:NSMakeRange(0,text.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.f] range:NSMakeRange(text.length + 2, str.length - text.length - 2)];
    return str;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2 && indexPath.row == 1) {
        ReportCurveDetailController *vc = [[ReportCurveDetailController alloc] init];
        vc.report = self.reportModel;
        vc.yVals_In = _yVals_In;
        vc.yVals_Out = _yVals_Out;
        vc.yVals_Bean = _yVals_Bean;
        vc.yVals_Environment = _yVals_Environment;
        vc.yVals_Diff = _yVals_Diff;
        [self presentViewController:vc animated:YES completion:nil];
    }
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
        for (long i = beanRorDiffCount; i < _Bean.count; i = i + beanRorDiffCount) {
            [_Diff addObject:[NSNumber numberWithDouble:([NSString diffTempUnitStringWithTemp:[_Bean[i] doubleValue]] - [NSString diffTempUnitStringWithTemp:[_Bean[i - beanRorDiffCount] doubleValue]]) * (60.f/beanRorDiffCount)]];
        }
        
        NSLog(@"%lu",(unsigned long)_Bean.count);
        NSLog(@"%lu",_Out.count);
        NSLog(@"%lu",_In.count);
        NSLog(@"%lu",_Environment.count);
        
        for (int i = 0; i<_Bean.count; i++) {
            [_yVals_Bean addObject:[[ChartDataEntry alloc] initWithX:i y:[NSString diffTempUnitStringWithTemp:[_Bean[i] doubleValue]]]];
        }
        for (int i = 0; i<_Out.count; i++) {
            [_yVals_Out addObject:[[ChartDataEntry alloc] initWithX:i y:[NSString diffTempUnitStringWithTemp:[_Out[i] doubleValue]]]];
        }
        for (int i = 0; i<_In.count; i++) {
            [_yVals_In addObject:[[ChartDataEntry alloc] initWithX:i y:[NSString diffTempUnitStringWithTemp:[_In[i] doubleValue]]]];
        }
        for (int i = 0; i<_Environment.count; i++) {
            [_yVals_Environment addObject:[[ChartDataEntry alloc] initWithX:i y:[NSString diffTempUnitStringWithTemp:[_Environment[i] doubleValue]]]];
        }
        _yVals_Diff = [[NetWork shareNetWork] getBeanTempRorWithArr:_Bean];
    }
    
    [self queryEventInfo];
}

- (void)queryEventInfo{
    _eventArray = [[[DataBase shareDataBase] queryEvent:_curveUid] mutableCopy];
    
    NSInteger compensate = 0;//事件时间长度和当前温度数组长度的补偿
    for (EventModel *event in _eventArray) {
        if (event.eventId == EndBake) {
            NSInteger lastIndex = event.eventTime;
            NSInteger count = _yVals_Bean.count;
            compensate = lastIndex - count;
            if (compensate < 0) {
                compensate = 0;
            }
        }
    }
    
    for (EventModel *event in _eventArray) {
        NSLog(@"%@",event.eventText);
        NSInteger count = _yVals_Bean.count;
        if (event.eventTime >= (count - compensate)) {//超出时减去补偿
            ChartDataEntry *entry = _yVals_Bean[event.eventTime - compensate - 1];
            entry.tag = event.eventText;
        }else{
            ChartDataEntry *entry = _yVals_Bean[event.eventTime];
            entry.tag = event.eventText;
        }
        //NSLog(@"%ld",event.eventId);
    }

    EventModel *event1;
    EventModel *event2;
    
    //烘焙时长，发展时间，发展率，脱水率，开始温度，结束温度都由事件列表取得或计算得到，脱水率，开始温度，结束温度在cell的显示函数中直接计算，烘焙时长，发展时间，发展率在下面计算并保存在reportModel中
    //计算烘焙时长
    for (EventModel *event in _eventArray) {
        if (event.eventId == StartBake) {
            event1 = event;
        }else if (event.eventId == EndBake){
            event2 = event;
        }
    }
    _reportModel.bakeTime = event2.eventTime - event1.eventTime;
    
    //计算发展时间
    for (EventModel *event in _eventArray) {
        if (event.eventId == First_Burst_Start) {
            event1 = event;
        }else if (event.eventId == Second_Burst_Start){
            event2 = event;
        }
    }
    _reportModel.developTime = event2.eventTime - event1.eventTime;
    _reportModel.developRate = (float)_reportModel.developTime/_reportModel.bakeTime*100.f;
    [self completionBackTempture];
    [self queryBeanInfo];
}

- (void)completionBackTempture{
    for (EventModel *event in self.eventArray) {
        if (event.eventId == BakeBackTemp) {
            return;
        }
    }
    bool isRorStartNegative = NO;//y轴下方数据数量大于10个表示开始温度下降
    int rorNegativeCount = 0;//在y轴下方的数据数量
    bool isRorStartPositive = NO;//表示温度开始上升
    bool backTempPointCacSucc = NO;//是否生成了回温点

    for (ChartDataEntry *entry in _yVals_Diff) {
        if (backTempPointCacSucc) {
            break;
        }
        if (entry.y < 0) {
            if (rorNegativeCount > 30/beanRorDiffCount) {
                isRorStartNegative = YES;
            }else{
                //NSLog(@"%@",@"adasfsf");
                rorNegativeCount++;
            }
        }else{
            rorNegativeCount = 0;
        }
        if (isRorStartNegative && entry.y > 0) {
            isRorStartPositive = YES;
        }
        if (isRorStartNegative && isRorStartPositive) {
            NSLog(@"回温点出现%f",entry.x);
            backTempPointCacSucc = YES;
            EventModel *event = [[EventModel alloc] init];
            event.eventId = BakeBackTemp;//类型为8
            event.eventTime = (int)entry.x;
            event.eventText = LocalString(@"回温点");
            if (self.Bean.count > 0) {
                event.eventBeanTemp = [self.Bean[(int)entry.x] floatValue];
            }else{
                event.eventBeanTemp = 0.0;
            }
            for (EventModel *event in self.eventArray) {
                if (event.eventId == BakeBackTemp) {
                    [self.eventArray removeObject:event];
                    break;
                }
            }
            [self.eventArray addObject:event];
        }
    }
}

- (void)queryBeanInfo{
    [SVProgressHUD show];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roastCurve/bean/message?curveUid=%@&num=1",_curveUid];
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
                    __block CGFloat rawBeanWeight = 0;
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
                        rawBeanWeight += bean.weight;
                        [_beanArray addObject:bean];
                    }];
                    _reportModel.rawBeanWeight = rawBeanWeight;
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
        if (error.code == -1001) {
            [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
        }else{
            [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
        }
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
//分享曲线应该不需要这两个功能

//- (void)editReport{
//    ReportEditController *editVC = [[ReportEditController alloc] init];
//    editVC.beanArray = [_beanArray mutableCopy];
//    editVC.reportModel = _reportModel;
//    [self.navigationController pushViewController:editVC animated:YES];
//}
//
//- (void)shareReport{
//    ProdQRCodeView *QRVC = [[ProdQRCodeView alloc] init];
//    QRVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    QRVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentViewController:QRVC animated:YES completion:^{
//        QRVC.curveUid = _curveUid;
//        NSLog(@"%@",_curveUid);
//        [QRVC generateQRCode];
//    }];
//}
@end
