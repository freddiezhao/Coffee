//
//  CurveController_bakeRela.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/28.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CurveController_bakeRela.h"
#import "BakeReportController.h"
#import "TouchTableView.h"
#import <MJRefresh/MJRefresh.h>
#import "CurrentCurveCell.h"
#import "ReportModel.h"
#import "DeviceModel.h"

NSString *const CellIdentifier_CurrentCurve_bakeadd = @"CellID_CurrentCurve_bakeadd";

@interface CurveController_bakeRela () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *curveSearch;

@property (nonatomic, strong) UISegmentedControl *mySegment;
@property (nonatomic, strong) NSArray *titleData;

@property (nonatomic, strong) UITableView *currentTable;
@property (nonatomic, strong) NSMutableArray *currentReportArr;

@end

@implementation CurveController_bakeRela

static float HEIGHT_CELL = 50.f;
static float HEIGHT_HEADER = 36.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavItem];
    
    _currentReportArr = [self getAllReport];
    _titleData = [self titleData];
    _mySegment = [self mySegment];
    _currentTable = [self currentTable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //self.view.frame = CGRectMake(0, 44, ScreenWidth, self.view.bounds.size.height - 44 - tabbarHeight - kSafeArea_Bottom);
}

#pragma mark - Lazyload
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"曲线");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setImage:[UIImage imageNamed:@"ic_nav_serch_black"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
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
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[CurrentCurveCell class] forCellReuseIdentifier:CellIdentifier_CurrentCurve_bakeadd];
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
    CurrentCurveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_CurrentCurve_bakeadd];
    if (cell == nil) {
        cell = [[CurrentCurveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_CurrentCurve_bakeadd];
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
    ReportModel *relaCurve = _currentReportArr[indexPath.section][indexPath.row];
    [NetWork shareNetWork].relaCurve = relaCurve;
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
            _currentTable.hidden = NO;
        }
            break;
        case 1:
        {
            _currentTable.hidden = YES;
        }
            break;
        case 2:
        {
            _currentTable.hidden = YES;
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

- (NSMutableArray *)getAllReport{
    DeviceModel *device = [[DeviceModel alloc] init];
    device.sn = @"fbb";
    NSMutableArray *arr = [[DataBase shareDataBase] queryAllReport:device];
    //NSMutableArray *arr = [[DataBase shareDataBase] queryAllReport:[NetWork shareNetWork].connectedDevice];
    arr = [self sortByDate:arr];
    //将相同date重新生成一个数组，作为一个section
    NSMutableArray *classArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < arr.count; i++) {
        ReportModel *obj1 = arr[i];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:obj1];
        NSLog(@"%@",[NSDate YMDHMStringFromUTCDate:obj1.date]);
        for (int j = i+1; j < arr.count; j++) {
            ReportModel *obj2 = arr[j];
            if ([[NSDate YMDStringFromDate:obj1.date] isEqualToString:[NSDate YMDStringFromDate:obj2.date]]) {
                [array addObject:obj2];
                if (j+1 >= arr.count) {//最后一个与前一个相同时，则添加完后结束比较
                    [classArr addObject:array];
                    i = j;
                    break;
                }
            }else{
                //这个与比较的不同，则下一个比较以这个为基准开始比较
                [classArr addObject:array];
                i = j - 1;
                break;
            }
        }
    }
    return classArr;
}

- (void)refreshTable{
    _currentReportArr = [self getAllReport];
}
#pragma mark - 排序
- (NSMutableArray *)sortByDate:(NSMutableArray *)arr{
    [arr sortUsingComparator:^NSComparisonResult(ReportModel *obj1, ReportModel *obj2) {
        return [obj1.date compare:obj2.date];
    }];
    return arr;
}

@end
