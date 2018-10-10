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

@interface SearchCurveController () <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate>

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
    
    _myTableView = [self myTableView];
    _searchController = [self searchController];
    _dismissBtn = [self dismissBtn];
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
        self.myTableView.tableHeaderView = self.searchController.searchBar;
        
        _searchController.searchBar.showsCancelButton = YES;
        _searchController.searchBar.delegate = self;
        UITextField *searchField = [_searchController.searchBar valueForKey:@"searchField"];
        [searchField becomeFirstResponder];
        searchField.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
        [_searchController.searchBar setBackgroundImage:[self GetImageWithColor:[UIColor whiteColor] andHeight:32.f]];
    }
    return _searchController;
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = _myTableView.bounds;
        CGRect frame1 = _myTableView.tableHeaderView.bounds;
        frame.origin.y = frame.origin.y + frame1.size.height;
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
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"999999"] range:NSMakeRange(report.curveName.length + 2,report.deviceName.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.f] range:NSMakeRange(0,report.curveName.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.f] range:NSMakeRange(report.curveName.length + 2,report.deviceName.length)];
    cell.beanDeviceName.attributedText = str;
    
    
    cell.dateLabel.text = [NSDate YMDHMStringFromUTCDate:report.date];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //NSLog(@"%ld",[_currentReportArr[0] count]);
    ReportModel *report = _resultArr[indexPath.row];
    
    BakeReportController *reportVC = [[BakeReportController alloc] init];
    reportVC.curveUid = report.curveUid;
    [self.navigationController pushViewController:reportVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL/HScale;
}

#pragma mark - UISearchResultsUpdating
-  (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *inputStr = searchController.searchBar.text;
    if ([inputStr isEqualToString:@""]) {
        self.dismissBtn.hidden = NO;
    }else{
        self.dismissBtn.hidden = YES;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - actions
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
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
