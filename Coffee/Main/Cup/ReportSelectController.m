//
//  ReportSelectController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "ReportSelectController.h"
#import "BakeReportController.h"
#import "TouchTableView.h"
#import <MJRefresh/MJRefresh.h>
#import "CurrentCurveCell.h"
#import "ReportModel.h"
#import "DeviceModel.h"
#import "QRCodeScanController.h"

NSString *const CellIdentifier_CupSelectCurve = @"CellID_CupSelectCurve";

@interface ReportSelectController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *curveSearch;

@property (nonatomic, strong) UISegmentedControl *mySegment;
@property (nonatomic, strong) NSArray *titleData;

@property (nonatomic, strong) UITableView *currentTable;
@property (nonatomic, strong) NSMutableArray *currentReportArr;

@property (nonatomic, strong) UIButton *skipButton;

@end

@implementation ReportSelectController

static float HEIGHT_CELL = 50.f;
static float HEIGHT_HEADER = 36.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    [self setNavItem];
    
    if (!_currentReportArr) {
        _currentReportArr = [[NSMutableArray alloc] init];
    }
    _currentReportArr = [self getAllReportWithCurrentDevice];
    _titleData = [self titleData];
    _mySegment = [self mySegment];
    _currentTable = [self currentTable];
    self.skipButton = [self skipButton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //self.view.frame = CGRectMake(0, 44, ScreenWidth, self.view.bounds.size.height - 44 - tabbarHeight - kSafeArea_Bottom);
}

#pragma mark - Lazyload
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"选择曲线");

}

- (UISegmentedControl *)mySegment{
    if (!_mySegment) {
        UIView *view = [[UIView alloc] init];
        view.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor;
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 44/HScale));
            make.top.equalTo(self.view.mas_top);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        
        _mySegment = [[UISegmentedControl alloc] initWithItems:_titleData];
        // 设置默认选择项索引
        _mySegment.selectedSegmentIndex = 0;
        _mySegment.tintColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1];
        // 设置在点击后是否恢复原样
        //_mySegment.momentary = YES;
        [_mySegment addTarget:self action:@selector(didClickMySegmentAction:) forControlEvents:UIControlEventValueChanged];
        [view addSubview:_mySegment];
        
        [_mySegment mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(345/WScale, 28/HScale));
            make.top.equalTo(view.mas_top).offset(8/HScale);
            make.centerX.equalTo(view.mas_centerX);
        }];
    }
    return _mySegment;
}

//- (UISearchBar *)curveSearch{
//    if (!_curveSearch) {
//        _curveSearch = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
//        _curveSearch.placeholder = LocalString(@"搜索");
//        _curveSearch.showsCancelButton = YES;
//        _curveSearch.searchBarStyle = UISearchBarStyleProminent;
//        [self.view addSubview:_curveSearch];
//    }
//    return _curveSearch;
//}

- (NSArray *)titleData {
    if (!_titleData) {
        _titleData = @[@"当前设备",@"所有设备",@"来自分享"];
    }
    return _titleData;
}

- (UITableView *)currentTable{
    if (!_currentTable) {
        _currentTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 44/HScale, ScreenWidth, ScreenHeight - 64 - (44 + 44)/HScale) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[CurrentCurveCell class] forCellReuseIdentifier:CellIdentifier_CupSelectCurve];
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

- (UIButton *)skipButton{
    if (!_skipButton) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_skipButton setTitle:LocalString(@"跳过") forState:UIControlStateNormal];
        [_skipButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        [_skipButton setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
        _skipButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_skipButton setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        [_skipButton addTarget:self action:@selector(skipCurveCheck) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_skipButton];
        
        _skipButton.layer.cornerRadius = 25.f/HScale;
        
        [_skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(110/WScale, 44/HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view.mas_bottom).offset(-16/HScale);
        }];
    }
    return _skipButton;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _currentReportArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_currentReportArr[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CurrentCurveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_CupSelectCurve];
    if (cell == nil) {
        cell = [[CurrentCurveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_CupSelectCurve];
    }
    ReportModel *report = _currentReportArr[indexPath.section][indexPath.row];
    if (_mySegment.selectedSegmentIndex == 0 || _mySegment.selectedSegmentIndex == 1) {
        cell.curveName.text = report.curveName;
        cell.deviceName.text = report.deviceName;
    }else if (_mySegment.selectedSegmentIndex == 2){
        cell.curveName.text = report.curveName;
        cell.deviceName.text = [NSString stringWithFormat:@"%@%@%@",LocalString(@"来自"),report.sharerName,LocalString(@"的分享")];;
    }
    
    cell.dateLabel.text = [NSDate YMDHMStringFromUTCDate:report.date];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //NSLog(@"%ld",[_currentReportArr[0] count]);
    ReportModel *report = _currentReportArr[indexPath.section][indexPath.row];
    if (self.selBlock) {
        self.selBlock(report.curveUid);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
    return NO;
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

#pragma mark - uisearchbar delegate
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
//    _searchTableView.hidden = NO;
//    [searchBar setShowsCancelButton:YES animated:YES];
//}
//
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
//    _searchTableView.hidden = YES;
//    [searchBar resignFirstResponder];
//    searchBar.text = @"";
//    [searchBar setShowsCancelButton:NO animated:YES];
//    [_searchData removeAllObjects];
//    [_searchTableView reloadData];
//}
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
//    for (SectionModel *section in _sectionData) {
//        for (CellModel *cell in section.cellArray) {
//            if ([cell.title containsString:searchText]) {
//                cell.groupName = section.groupName;
//                [_searchData addObject:cell];
//                [_searchTableView reloadData];
//                NSLog(@"%@",cell.title);
//            }
//        }
//    }
//}

#pragma mark - UISegment delegate
-(void)didClickMySegmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", Index);
    switch (Index) {
        case 0:
        {
            [_currentTable.mj_header beginRefreshing];
            [_currentReportArr removeAllObjects];
            [_currentReportArr addObjectsFromArray:[self getAllReportWithCurrentDevice]];
            [_currentTable reloadData];
            [_currentTable.mj_header endRefreshing];
        }
            break;
        case 1:
        {
            [_currentTable.mj_header beginRefreshing];
            [_currentReportArr removeAllObjects];
            [_currentReportArr addObjectsFromArray:[self getAllReport]];
            [_currentTable reloadData];
            [_currentTable.mj_header endRefreshing];
        }
            break;
        case 2:
        {
            [_currentTable.mj_header beginRefreshing];
            [self getAllSharedReport];
            [_currentTable reloadData];
            [_currentTable.mj_header endRefreshing];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - Actions
- (void)next{
    BakeReportController *reportVC = [[BakeReportController alloc] init];
    [self.navigationController pushViewController:reportVC animated:YES];
}

- (void)scanQRcode{
    QRCodeScanController *scanVC = [[QRCodeScanController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (void)searchCurve{
    
}

- (NSMutableArray *)getAllReport{
    NSMutableArray *arr = [[DataBase shareDataBase] queryAllReport];
    arr = [self sortByDate:arr];
    NSMutableArray *classArr = [self classArray:arr];
    return classArr;
}

- (NSMutableArray *)getAllReportWithCurrentDevice{
    NSMutableArray *arr = [[DataBase shareDataBase] queryAllReport:[NetWork shareNetWork].connectedDevice];
    arr = [self sortByDate:arr];
    NSMutableArray *classArr = [self classArray:arr];
    return classArr;
}

- (void)getAllSharedReport{
    NSMutableArray *arr = [[DataBase shareDataBase] queryAllSharedReport];
    arr = [self sortByDate:arr];
    NSMutableArray *classArr = [self classArray:arr];
    if (_currentReportArr.count > 0) {
        [_currentReportArr removeAllObjects];
    }
    [_currentReportArr addObjectsFromArray:classArr];
}

- (void)refreshTable{
    //_currentReportArr = [self getAllReport:nil];
}

- (void)skipCurveCheck{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 排序
- (NSMutableArray *)sortByDate:(NSMutableArray *)arr{
    [arr sortUsingComparator:^NSComparisonResult(ReportModel *obj1, ReportModel *obj2) {
        return [obj2.date compare:obj1.date];
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
