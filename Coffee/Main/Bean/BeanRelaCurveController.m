//
//  CurveViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BeanRelaCurveController.h"
#import "BakeReportController.h"
#import "TouchTableView.h"
#import <MJRefresh/MJRefresh.h>
#import "CurrentCurveCell.h"
#import "ReportModel.h"
#import "DeviceModel.h"

NSString *const CellIdentifier_BeanRelaCurve = @"CellID_BeanRelaCurve";

@interface BeanRelaCurveController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *curveSearch;

@property (nonatomic, strong) NSArray *titleData;

@property (nonatomic, strong) UITableView *currentTable;
@property (nonatomic, strong) NSMutableArray *currentReportArr;

@end

@implementation BeanRelaCurveController

static float HEIGHT_CELL = 50.f;
static float HEIGHT_HEADER = 36.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    [self setNavItem];
    
    _currentReportArr = [self getRelaReport];
    _titleData = [self titleData];
    _currentTable = [self currentTable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

#pragma mark - Lazyload
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"烘焙曲线");
}

- (NSArray *)titleData {
    if (!_titleData) {
        _titleData = @[@"当前设备",@"所有设备",@"来自分享"];
    }
    return _titleData;
}

- (UITableView *)currentTable{
    if (!_currentTable) {
        _currentTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[CurrentCurveCell class] forCellReuseIdentifier:CellIdentifier_BeanRelaCurve];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            
            MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshTable)];
            // Set title
            [header setTitle:LocalString(@"下拉刷新") forState:MJRefreshStateIdle];
            [header setTitle:LocalString(@"松开刷新") forState:MJRefreshStatePulling];
            [header setTitle:LocalString(@"加载中") forState:MJRefreshStateRefreshing];
            
            // Set font
            header.stateLabel.font = [UIFont systemFontOfSize:15];
            header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
            
            // Set textColor
            header.stateLabel.textColor = [UIColor lightGrayColor];
            header.lastUpdatedTimeLabel.textColor = [UIColor lightGrayColor];
            tableView.mj_header = header;
            tableView;
        });
    }
    return _currentTable;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _currentReportArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_currentReportArr[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CurrentCurveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_BeanRelaCurve];
    if (cell == nil) {
        cell = [[CurrentCurveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_BeanRelaCurve];
    }
    ReportModel *report = _currentReportArr[indexPath.section][indexPath.row];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@",report.curveName,report.deviceName]];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"333333"] range:NSMakeRange(0,report.curveName.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"999999"] range:NSMakeRange(report.curveName.length + 2,report.deviceName.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.f] range:NSMakeRange(0,report.curveName.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.f] range:NSMakeRange(report.curveName.length + 2,report.deviceName.length)];
    cell.beanDeviceName.attributedText = str;
    
    cell.dateLabel.text = [NSDate YMDHMStringFromUTCDate:report.date];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ReportModel *report = _currentReportArr[indexPath.section][indexPath.row];
    
    BakeReportController *reportVC = [[BakeReportController alloc] init];
    reportVC.curveUid = report.curveUid;
    [self.navigationController pushViewController:reportVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL/HScale;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER/HScale)];
    headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER/HScale)];
    textLabel.textColor = [UIColor colorWithHexString:@"999999"];
    textLabel.font = [UIFont systemFontOfSize:14.f];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:textLabel];
    
    ReportModel *report = _currentReportArr[section][0];
    textLabel.text = [NSDate YMDStringFromDate:report.date];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEIGHT_HEADER/HScale;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DataBase *db = [DataBase shareDataBase];
        ReportModel *report = _currentReportArr[indexPath.section][indexPath.row];
        BOOL result = NO;
        result = [db deleteqReport:report];
        if (result) {
            [_currentReportArr[indexPath.section] removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [NSObject showHudTipStr:LocalString(@"删除成功")];
        }else{
            [NSObject showHudTipStr:LocalString(@"删除失败")];
        }
    }
}

#pragma mark - Actions

- (NSMutableArray *)getRelaReport{
    NSMutableArray *arr = [[DataBase shareDataBase] queryBeanRelaReport:_beanId];
    arr = [self sortByDate:arr];
    NSMutableArray *classArr = [self classArray:arr];
    return classArr;
}

- (void)refreshTable{
    _currentReportArr = [self getRelaReport];
    [_currentTable reloadData];
    [_currentTable.mj_header endRefreshing];
}
#pragma mark - 排序
- (NSMutableArray *)sortByDate:(NSMutableArray *)arr{
    [arr sortUsingComparator:^NSComparisonResult(ReportModel *obj1, ReportModel *obj2) {
        return [obj1.date compare:obj2.date];
    }];
    return arr;
}

//将相同时间的object重新生成数组
- (NSMutableArray *)classArray:(NSMutableArray *)arr{
    //将相同date重新生成一个数组，作为一个section
    NSMutableArray *classArr = [[NSMutableArray alloc] init];
    
    if (arr.count == 1) {
        ReportModel *obj1 = arr[0];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:obj1];
        [classArr addObject:array];
    }else if (arr.count > 1) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i < arr.count - 1; i++) {
            ReportModel *obj1 = arr[i];
            ReportModel *obj2 = arr[i+1];
            
            if ([[NSDate YMDStringFromDate:obj1.date] isEqualToString:[NSDate YMDStringFromDate:obj2.date]]){
                [array addObject:obj1];
            }else{
                [array addObject:obj1];
                //[classArr addObject:array];//这样写会让每一个添加的array都指向同一个指针，所以值都是一样的
                [classArr addObject:[array mutableCopy]];
                [array removeAllObjects];
            }
            if (i == arr.count - 2) {//如果是最后一个值，无法进行到下个循环，所以将未插入的直接插入
                [array addObject:obj2];
                [classArr addObject:[array mutableCopy]];
            }
            
        }
    }
    
    //    for (int i = 0; i < arr.count; i++) {
    //        ReportModel *obj1 = arr[i];
    //        NSMutableArray *array = [[NSMutableArray alloc] init];
    //        [array addObject:obj1];
    //        if (i+1 > array.count) {//只有一个值时
    //            [classArr addObject:array];
    //        }
    //        for (int j = i+1; j < arr.count; j++) {
    //            ReportModel *obj2 = arr[j];
    //            if ([[NSDate YMDStringFromDate:obj1.date] isEqualToString:[NSDate YMDStringFromDate:obj2.date]]) {
    //                [array addObject:obj2];
    //                if (j+1 >= arr.count) {//最后一个与前一个相同时，则添加完后结束比较
    //                    [classArr addObject:array];
    //                    i = j;
    //                    break;
    //                }
    //            }else{
    //                //这个与比较的不同，则下一个比较以这个为基准开始比较
    //                [classArr addObject:array];
    //                i = j - 1;
    //                break;
    //            }
    //        }
    //    }
    
    return classArr;
}

@end
