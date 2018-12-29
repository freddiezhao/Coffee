//
//  GradeSelController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "GradeSelController.h"
#import "SortModel.h"
#import "YTFAlertController.h"

NSString *const CellIdentifier_GradeSel = @"CellID_GradeSel";

@interface GradeSelController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *gradeTable;
@property (nonatomic, strong) NSMutableArray *gradeArray;
@property (nonatomic, strong) NSMutableArray *mutableSections;//按名字排序

@end

@implementation GradeSelController

static float HEIGHT_CELL = 50.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavItem];
    
    _gradeArray = [self gradeArray];
    [self setObjects:_gradeArray];
    _gradeTable = [self gradeTable];
}

#pragma mark - Lazy Load
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"等级选择");
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(15, 4, 22, 22);
    [searchButton setImage:[UIImage imageNamed:@"ic_nav_serch_black"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchBean) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (NSMutableArray *)gradeArray{
    if (!_gradeArray) {
        NSArray *array = @[@"AA",@"A",@"B",@"C",@"PB",@"Grade1",@"SHB",@"#其他"];
        _gradeArray = [NSMutableArray array];
        for (int i = 0; i < array.count; i++) {
            SortModel *model = [[SortModel alloc] init];
            model.name = array[i];
            [_gradeArray addObject:model];
        }

    }
    return _gradeArray;
}

- (UITableView *)gradeTable{
    if (!_gradeTable) {
        _gradeTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier_GradeSel];
            
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            
            tableView.tableFooterView = [[UIView alloc] init];
            
            tableView;
        });
    }
    return _gradeTable;
}

#pragma mark - UITableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _mutableSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_mutableSections[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_GradeSel];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_GradeSel];
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
    
    //其他选项时手动输入
    if ([model.name isEqualToString:@"#其他"]) {
        YTFAlertController *alert = [[YTFAlertController alloc] init];
        alert.lBlock = ^{
        };
        alert.rBlock = ^(NSString * _Nullable text) {
            if (self.gradeBlock) {
                self.gradeBlock(text);
            }
            [self.navigationController popViewControllerAnimated:YES];
        };
        alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:alert animated:NO completion:^{
            alert.titleLabel.text = LocalString(@"#其他");
            alert.textField.placeholder = LocalString(@"请输入豆的等级");
            [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
            [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
        }];
        return;
    }
    
    if (self.gradeBlock) {
        self.gradeBlock(model.name);
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
    for (SortModel *model in _gradeArray) {
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
    
}

@end
