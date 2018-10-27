//
//  SearchCurveController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/10.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "SearchCurveController.h"
#import "TouchTableView.h"
#import "CurrentCurveCell.h"
#import "ReportModel.h"
#import "BakeReportController.h"

NSString *const CellIdentifier_searchCurve = @"CellID_searchCurve";

@interface SearchCurveController () <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate>

@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *resultArr;
@property (nonatomic, strong) UIButton *dismissBtn;

@end

@implementation SearchCurveController
static float HEIGHT_CELL = 50.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4]];
    
    _resultArr = [[NSMutableArray alloc] init];
    _myTableView = [self myTableView];
    _searchController = [self searchController];
    _dismissBtn = [self dismissBtn];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _searchController.active = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        
    }else{
        [self.navigationController setNavigationBarHidden:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (@available(iOS 11.0, *)) {
        //[self.navigationController setNavigationBarHidden:NO];
    }else{
        [self.navigationController setNavigationBarHidden:NO];
    }
}
#pragma mark - Lazy load
- (UITableView *)myTableView{
    if (!_myTableView) {
        _myTableView = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, self.view.bounds.size.height - 20) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[CurrentCurveCell class] forCellReuseIdentifier:CellIdentifier_searchCurve];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _myTableView;
}

- (UISearchController *)searchController{
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.delegate = self;
        
        if (@available(iOS 11.0, *)) {
            self.navigationItem.searchController = _searchController;
            //[[self.searchController.searchBar.heightAnchor constraintEqualToConstant:44.0] setActive:YES];
            self.navigationItem.hidesSearchBarWhenScrolling = NO;
            _searchController.hidesNavigationBarDuringPresentation = YES;
            
        } else {
            self.myTableView.tableHeaderView = self.searchController.searchBar;
        }
        
        _searchController.searchBar.showsCancelButton = YES;
        _searchController.searchBar.delegate = self;
        UITextField *searchField = [_searchController.searchBar valueForKey:@"searchField"];
        searchField.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
        
        _searchController.dimsBackgroundDuringPresentation = NO;
        _searchController.obscuresBackgroundDuringPresentation = NO;
        [_searchController.searchBar setBackgroundImage:[self GetImageWithColor:[UIColor whiteColor] andHeight:32.f]];
        
        CGRect frame = _searchController.searchBar.frame;
        frame.size.height = 44.f;
        _searchController.searchBar.frame = frame;
    }
    return _searchController;
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = _myTableView.bounds;
        CGRect frame1 = _myTableView.tableHeaderView.bounds;
        frame.origin.y = frame.origin.y + frame1.size.height + 20;
        _dismissBtn.frame = frame;
        [_dismissBtn setBackgroundColor:[UIColor clearColor]];
        [_dismissBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_dismissBtn];
    }
    return _dismissBtn;
}
#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CurrentCurveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_searchCurve];
    if (cell == nil) {
        cell = [[CurrentCurveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_searchCurve];
    }
    ReportModel *report = _resultArr[indexPath.row];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@",report.curveName,report.deviceName]];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"333333"] range:NSMakeRange(0,report.curveName.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"4778CC"] range:report.searchRange];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"999999"] range:NSMakeRange(report.curveName.length + 2,report.deviceName.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.f] range:NSMakeRange(0,report.curveName.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.f] range:NSMakeRange(report.curveName.length + 2,report.deviceName.length)];
    cell.beanDeviceName.attributedText = str;
    
    
    cell.dateLabel.text = [NSDate YMDHMStringFromUTCDate:report.date];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ReportModel *report = _resultArr[indexPath.row];
    if (_searchController.active) {
        [_searchController dismissViewControllerAnimated:YES completion:nil];
    }
    if (_isRela) {
        [NetWork shareNetWork].relaCurve = [[DataBase shareDataBase] queryReport:report.curveUid];
        [self dismissVC];
    }else{
        
        BakeReportController *reportVC = [[BakeReportController alloc] init];
        reportVC.curveUid = report.curveUid;
        [self.navigationController pushViewController:reportVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL/HScale;
}

#pragma mark - UISearchResultsUpdating
-  (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *inputStr = searchController.searchBar.text;
    if ([inputStr isEqualToString:@""]) {
        self.dismissBtn.hidden = NO;
        _myTableView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
        return;
    }else{
        self.dismissBtn.hidden = YES;
        _myTableView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    }
    if (self.resultArr.count > 0) {
        [_resultArr removeAllObjects];
    }
    for (ReportModel *report in self.curveArr) {
        if (report.curveName) {
            NSRange result = [report.curveName rangeOfString:inputStr options:NSCaseInsensitiveSearch];
            if (result.length > 0)
            {
                report.searchRange = result;
                [self.resultArr addObject:report];
            }
        }
    }
    [self.myTableView reloadData];

}

- (void)didPresentSearchController:(UISearchController *)searchController{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_searchController.searchBar becomeFirstResponder];
    });
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self dismissVC];
}

#pragma mark - actions
//根据颜色生成图片
- (UIImage *)GetImageWithColor:(UIColor*)color andHeight:(CGFloat)height{
    
    CGRect r= CGRectMake(0.0f,
               0.0f, 1.0f, height);
    
    UIGraphicsBeginImageContext(r.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color
                                                 CGColor]);
    
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
    
}

- (void)dismissVC{
    if (self.searchController.active) {
        [self.searchController dismissViewControllerAnimated:YES completion:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}
@end
