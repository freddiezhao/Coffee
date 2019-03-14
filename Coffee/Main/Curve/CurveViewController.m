//
//  CurveViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CurveViewController.h"
#import "BakeReportController.h"
#import "ShareReportController.h"
#import "TouchTableView.h"
#import <MJRefresh/MJRefresh.h>
#import "CurrentCurveCell.h"
#import "ReportModel.h"
#import "DeviceModel.h"
#import "FMDB.h"
#import "SearchCurveController.h"
#import "QRCodeScanController.h"


NSString *const CellIdentifier_CurrentCurve = @"CellID_CurrentCurve";

@interface CurveViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *curveSearch;

@property (nonatomic, strong) UISegmentedControl *mySegment;
@property (nonatomic, strong) NSArray *titleData;

@property (nonatomic, strong) UITableView *currentTable;
@property (nonatomic, strong) UIView *noCurveView;
@property (nonatomic, strong) UILabel *noCurveLabel;
@property (nonatomic, strong) NSMutableArray *currentReportArr;

@end

@implementation CurveViewController

static float HEIGHT_CELL = 70.f;
static float HEIGHT_HEADER = 36.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    [self setNavItem];
    
    if (!_currentReportArr) {
        _currentReportArr = [[NSMutableArray alloc] init];
    }
    _titleData = [self titleData];
    _mySegment = [self mySegment];
    _currentReportArr = [self getAllReportWithCurrentDevice];
    _currentTable = [self currentTable];
    _noCurveView = [self noCurveView];
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
    
    UIView *rightButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 89, 30)];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(52, 4, 22, 22);
    [addButton setImage:[UIImage imageNamed:@"ic_nav_scan_black"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(scanQRcode) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:addButton];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(15, 4, 22, 22);
    [searchButton setImage:[UIImage imageNamed:@"ic_nav_serch_black"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchCurve) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:searchButton];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButtonView];
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

- (NSArray *)titleData {
    if (!_titleData) {
        _titleData = @[@"当前设备",@"所有设备",@"来自分享"];
    }
    return _titleData;
}

- (UITableView *)currentTable{
    if (!_currentTable) {
        _currentTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 44/HScale, ScreenWidth, ScreenHeight - 64 - (44 + (tabbarHeight + kSafeArea_Bottom))/HScale) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.hidden = YES;
            [tableView registerClass:[CurrentCurveCell class] forCellReuseIdentifier:CellIdentifier_CurrentCurve];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            
            //不要刷新了，会对现在的后台逻辑造成混乱
//            MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshTable)];
//            // Set title
//            [header setTitle:LocalString(@"下拉刷新") forState:MJRefreshStateIdle];
//            [header setTitle:LocalString(@"松开刷新") forState:MJRefreshStatePulling];
//            [header setTitle:LocalString(@"加载中") forState:MJRefreshStateRefreshing];
//
//            // Set font
//            header.stateLabel.font = [UIFont systemFontOfSize:15];
//            header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
//
//            // Set textColor
//            header.stateLabel.textColor = [UIColor lightGrayColor];
//            header.lastUpdatedTimeLabel.textColor = [UIColor lightGrayColor];
//            tableView.mj_header = header;
            tableView;
        });
    }
    return _currentTable;
}

- (UIView *)noCurveView{
    if (!_noCurveView) {
        _noCurveView = [[UIView alloc] init];
        _noCurveView.frame = CGRectMake(0, 44, ScreenWidth, ScreenHeight);
        _noCurveView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
        [self.view addSubview:_noCurveView];
        
        UIImageView *deviceImage = [[UIImageView alloc] init];
        deviceImage.image = [UIImage imageNamed:@"img_logo_gray"];
        [_noCurveView addSubview:deviceImage];
        
        _noCurveLabel = [[UILabel alloc] init];
        _noCurveLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        _noCurveLabel.textAlignment = NSTextAlignmentCenter;
        _noCurveLabel.adjustsFontSizeToFitWidth = YES;
        _noCurveLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_noCurveView addSubview:_noCurveLabel];
        
        [deviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(140.f / WScale, 110.f / HScale));
            make.centerX.equalTo(_noCurveView.mas_centerX);
            make.top.equalTo(_noCurveView.mas_top).offset(120.f / HScale);
        }];
        
        [_noCurveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 20.f / HScale));
            make.centerX.equalTo(_noCurveView.mas_centerX);
            make.top.equalTo(_noCurveView.mas_top).offset(252.f / HScale);
        }];
        
    }
    return _noCurveView;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _currentReportArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_currentReportArr[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CurrentCurveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_CurrentCurve];
    if (cell == nil) {
        cell = [[CurrentCurveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_CurrentCurve];
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
    if (report.isShare == 0) {
        BakeReportController *reportVC = [[BakeReportController alloc] init];
        reportVC.curveUid = report.curveUid;
        [self.navigationController pushViewController:reportVC animated:YES];
    }else{
        ShareReportController *shareVC = [[ShareReportController alloc] init];
        shareVC.curveUid = report.curveUid;
        [self.navigationController pushViewController:shareVC animated:YES];
    }
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
    if (report.date) {
        textLabel.text = [NSDate YMDStringFromDate:report.date];
    }else{
        textLabel.text = LocalString(@"No date");
    }
    

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
        
        //http delete
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        //设置超时时间
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 6.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roastCurve/deleteReport?curveUid=%@&num=%ld",report.curveUid,(long)report.isShare];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];

        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
        [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
        
        
        //manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
        
        [manager DELETE:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
            NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
            NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"success:%@",daetr);
            
            if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                
                //本地数据库delete
                BOOL result = NO;
                result = [db deleteqReport:report];
                if (result) {
                    if ([_currentReportArr[indexPath.section] count] == 0) {
                        [_currentReportArr removeObjectAtIndex:indexPath.section];
                        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
                    }else{
                        [_currentReportArr[indexPath.section] removeObjectAtIndex:indexPath.row];
                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        
                    }
                    [NSObject showHudTipStr:LocalString(@"删除成功")];
                }else{
                    [NSObject showHudTipStr:LocalString(@"删除失败")];
                }
                
            }else{
                [NSObject showHudTipStr:LocalString(@"删除失败")];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            
            NSLog(@"error--%@",serializedData);
            
            
            [NSObject showHudTipStr:LocalString(@"删除失败")];
            NSLog(@"Error:%@",error);
        }];
        
    }
}

#pragma mark - UISegment delegate
-(void)didClickMySegmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", Index);
    switch (Index) {
        case 0:
        {
            [_currentReportArr removeAllObjects];
            [_currentReportArr addObjectsFromArray:[self getAllReportWithCurrentDevice]];
            [_currentTable reloadData];
        }
            break;
        case 1:
        {
            [_currentReportArr removeAllObjects];
            [_currentReportArr addObjectsFromArray:[self getAllReport]];
            [_currentTable reloadData];
        }
            break;
        case 2:
        {
            [self getAllSharedReport];
            [_currentTable reloadData];
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
    SearchCurveController *searchVC = [[SearchCurveController alloc] init];
    searchVC.curveArr = [[DataBase shareDataBase] queryAllReport];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;//可以保持本VC的UI显示
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    searchVC.dismissBlock = ^{
        [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    };
    searchVC.isRela = NO;
    [self presentViewController:nav animated:YES completion:nil];
}

- (NSMutableArray *)getAllReport{
    NSMutableArray *arr = [[DataBase shareDataBase] queryAllReport];
    if (arr.count > 0) {
        self.currentTable.hidden = NO;
        self.noCurveView.hidden = YES;
    }else{
        self.currentTable.hidden = YES;
        self.noCurveView.hidden = NO;
        _noCurveLabel.text = LocalString(@"您还未生成过曲线");
    }
    for (ReportModel *report in arr) {
        NSLog(@"%ld",(long)report.isShare);
    }
    arr = [self sortByDate:arr];
    NSMutableArray *classArr = [self classArray:arr];
    return classArr;
}

- (NSMutableArray *)getAllReportWithCurrentDevice{
    NSMutableArray *arr = [[DataBase shareDataBase] queryAllReport:[NetWork shareNetWork].connectedDevice];
    if (arr.count > 0) {
        self.currentTable.hidden = NO;
        self.noCurveView.hidden = YES;
    }else{
        self.currentTable.hidden = YES;
        self.noCurveView.hidden = NO;
        _noCurveLabel.text = LocalString(@"该设备还未生成过曲线");
    }
    arr = [self sortByDate:arr];
    NSMutableArray *classArr = [self classArray:arr];
    return classArr;
}

- (void)getAllSharedReport{
    NSMutableArray *arr = [[DataBase shareDataBase] queryAllSharedReport];
    if (arr.count > 0) {
        self.currentTable.hidden = NO;
        self.noCurveView.hidden = YES;
    }else{
        self.currentTable.hidden = YES;
        self.noCurveView.hidden = NO;
        _noCurveLabel.text = LocalString(@"您还没有添加过被分享的曲线");
    }
    arr = [self sortByDate:arr];
    NSMutableArray *classArr = [self classArray:arr];
    if (_currentReportArr.count > 0) {
        [_currentReportArr removeAllObjects];
    }
    [_currentReportArr addObjectsFromArray:classArr];
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
