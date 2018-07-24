//
//  CurveViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CurveViewController.h"

@interface CurveViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *curveSearch;
@property (nonatomic, strong) NSArray *titleData;

@end

@implementation CurveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithHexString:yColor_back]];
    
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //self.view.frame = CGRectMake(0, 44, ScreenWidth, self.view.bounds.size.height - 44 - tabbarHeight - kSafeArea_Bottom);
    _curveSearch = [self curveSearch];

}

#pragma mark 初始化代码
- (instancetype)init {
    if (self = [super init]) {
        self.titleSizeNormal = 13;
        self.titleSizeSelected = 13;
        self.menuViewStyle = WMMenuViewStyleDefault;
        self.menuItemWidth = [UIScreen mainScreen].bounds.size.width / self.titleData.count;
        //self.progressHeight = 1;//下划线的高度，需要WMMenuViewStyleLine样式
        //self.progressColor = [UIColor blueColor];//设置下划线(或者边框)颜色
        self.titleColorSelected = [UIColor redColor];//设置选中文字颜色
    }
    return self;
}

#pragma mark - Lazyload
- (UISearchBar *)curveSearch{
    if (!_curveSearch) {
        _curveSearch = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
        _curveSearch.placeholder = LocalString(@"搜索");
        _curveSearch.showsCancelButton = YES;
        _curveSearch.searchBarStyle = UISearchBarStyleProminent;
        [self.view addSubview:_curveSearch];
//        [_curveSearch mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 50));
//            make.top.equalTo(self.view.mas_top);
//            make.centerX.equalTo(self.view.mas_centerX);
//        }];
    }
    return _curveSearch;
}

- (NSArray *)titleData {
    if (!_titleData) {
        _titleData = @[@"当前设备曲线",@"所有设备曲线",@"来自分享"];
    }
    return _titleData;
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

#pragma mark - WMPageController delegate
//返回子页面的个数
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.titleData.count;
}

//返回某个index对应的页面
- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    
    
    switch (index) {
        case 0:{
            UIViewController *VC0 = [[UIViewController alloc] init];
            return VC0;
        }
            
            break;
        case 1:{
            UIViewController *VC1 = [[UIViewController alloc] init];
            return VC1;
            
        }
            break;
            
        case 2:{
            UIViewController *VC2 = [[UIViewController alloc] init];
            return VC2;
            
        }
            break;
            
        default:{
            return nil;
        }
            break;
    }
    
    
}

//返回index对应的标题
- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    
    return self.titleData[index];
}

@end
