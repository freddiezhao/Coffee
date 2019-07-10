//
//  SpicesSelController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "SpicesSelController.h"
#import "SortModel.h"
#import "SearchSpicesController.h"

NSString *const CellIdentifier_SpicesSel = @"CellID_SpicesSel";

@interface SpicesSelController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *spicesTable;
@property (nonatomic, strong) NSMutableArray *spicesArray;
@property (nonatomic, strong) NSMutableArray *mutableSections;//按名字排序


@end

@implementation SpicesSelController

static float HEIGHT_CELL = 50.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavItem];
    
    _spicesArray = [self spicesArray];
    [self setObjects:_spicesArray];
    _spicesTable = [self spicesTable];
}

#pragma mark - Lazy Load
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"豆种选择");
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(15, 4, 22, 22);
    [searchButton setImage:[UIImage imageNamed:@"ic_nav_serch_black"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchBean) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (NSMutableArray *)spicesArray{
    if (!_spicesArray) {
        NSArray *array = @[LocalString(@"铁皮卡"),LocalString(@"波旁"),LocalString(@"卡图拉"),LocalString(@"象豆"),LocalString(@"新世界"),LocalString(@"卡图埃"),LocalString(@"卡蒂莫"),LocalString(@"卡斯蒂洛"),LocalString(@"帕卡马拉"),LocalString(@"埃塞俄比亚原生种"),LocalString(@"提莫混种"),LocalString(@"瑰夏"),LocalString(@"SL28"),LocalString(@"SL34"),LocalString(@"F1混种"),LocalString(@"卡杜拉"),LocalString(@"卡杜艾"),LocalString(@"阿拉比卡"),LocalString(@"罗布斯塔"),LocalString(@"利比卡")];
        _spicesArray = [NSMutableArray array];
        for (int i = 0; i < array.count; i++) {
            SortModel *model = [[SortModel alloc] init];
            model.name = array[i];
            [_spicesArray addObject:model];
        }
        
    }
    return _spicesArray;
}

- (UITableView *)spicesTable{
    if (!_spicesTable) {
        _spicesTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier_SpicesSel];
            
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            
            tableView.tableFooterView = [[UIView alloc] init];
            
            tableView;
        });
    }
    return _spicesTable;
}

#pragma mark - UITableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _mutableSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_mutableSections[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_SpicesSel];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_SpicesSel];
    }
    SortModel *model = [_mutableSections[indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = model.name;
    cell.textLabel.font = [UIFont systemFontOfSize:16.f];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"333333"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SortModel *model = [_mutableSections[indexPath.section] objectAtIndex:indexPath.row];
    if (self.spicesBlock) {
        self.spicesBlock(model.name);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL/HScale;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - sort
- (void)setObjects:(NSArray *)objects {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    //1.获取section数量
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    
    //2.构建每个section数组
    _mutableSections = [NSMutableArray arrayWithCapacity:sectionTitlesCount];
    for (int i = 0; i < sectionTitlesCount; i++) {
        NSMutableArray *subArr = [NSMutableArray array];
        [_mutableSections addObject:subArr];
    }
    
    //3.排序
    //3.1 按照将需要排序的对象放入到对应分区数组
    for (SortModel *model in _spicesArray) {
        NSInteger section = [collation sectionForObject:model collationStringSelector:@selector(name)];
        NSMutableArray *subArr = _mutableSections[section];
        
        [subArr addObject:model];
    }
    
    //3.2 分别对分区进行排序
    for (NSMutableArray *subArr in _mutableSections) {
        NSArray *sortArr = [collation sortedArrayFromArray:subArr collationStringSelector:@selector(name)];
        [subArr removeAllObjects];
        [subArr addObjectsFromArray:sortArr];
    }
}

#pragma mark - Actions
- (void)searchBean{
    SearchSpicesController *searchVC = [[SearchSpicesController alloc] init];
    searchVC.beanSpicesArr = self.spicesArray;
    searchVC.selBlock = ^(NSString *spices) {
        if (self.spicesBlock) {
            self.spicesBlock(spices);
        }
        [self.navigationController popViewControllerAnimated:YES];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController setDefinesPresentationContext:YES];
    [self presentViewController:nav animated:YES completion:nil];

}
@end
