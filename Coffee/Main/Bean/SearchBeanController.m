//
//  SearchBeanController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/11.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "SearchBeanController.h"
#import "TouchTableView.h"
#import "beanCell.h"
#import "BeanModel.h"
#import "BeanDetailController.h"

NSString *const CellIdentifier_searchBean = @"CellID_searchBean";

@interface SearchBeanController () <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate>

@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *resultArr;
@property (nonatomic, strong) UIButton *dismissBtn;

@end

@implementation SearchBeanController
static float HEIGHT_CELL = 70.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myTableView = [self myTableView];
    _searchController = [self searchController];
    _dismissBtn = [self dismissBtn];
    _resultArr = [[NSMutableArray alloc] init];
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
            [tableView registerClass:[beanCell class] forCellReuseIdentifier:CellIdentifier_searchBean];
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
        _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
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
    beanCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_searchBean];
    if (cell == nil) {
        cell = [[beanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_searchBean];
    }
    BeanModel *bean = _resultArr[indexPath.row];
    cell.beanImage.image = [UIImage imageNamed:@"img_coffee_beans"];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:bean.name];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"4778CC"] range:bean.searchRange];
    cell.beanLabel.attributedText = str;
    
    cell.infoLabel.text = [NSString stringWithFormat:@"%@等级 · 处理方式%@",bean.grade,bean.process];
    cell.weightLabel.text = [NSString stringWithFormat:@"%.1fkg",bean.stock];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BeanDetailController *detailVC = [[BeanDetailController alloc] init];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BeanModel *bean = _resultArr[indexPath.row];
    detailVC.myBean = [[DataBase shareDataBase] queryBean:bean.beanUid];
    if (_searchController.active) {
        [_searchController dismissViewControllerAnimated:YES completion:nil];
    }
    [self.navigationController pushViewController:detailVC animated:YES];
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
    }else{
        self.dismissBtn.hidden = YES;
        _myTableView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    }
    if (self.resultArr.count > 0) {
        [_resultArr removeAllObjects];
    }
    for (BeanModel *bean in self.beanArr) {
        NSRange result = [bean.name rangeOfString:inputStr options:NSCaseInsensitiveSearch];
        if (result.length > 0)
        {
            bean.searchRange = result;

            [self.resultArr addObject:bean];
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
