//
//  ProcessSelController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "ProcessSelController.h"
#import "SortModel.h"
#import "YTFAlertController.h"

NSString *const CellIdentifier_ProcessSel = @"CellID_ProcessSel";

@interface ProcessSelController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *processTable;
@property (nonatomic, strong) NSMutableArray *processArray;
@property (nonatomic, strong) NSMutableArray *mutableSections;//按名字排序


@end

@implementation ProcessSelController

static float HEIGHT_CELL = 50.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavItem];
    
    _processArray = [self processArray];
    [self setObjects:_processArray];
    _processTable = [self processTable];
}

#pragma mark - Lazy Load
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"处理方式选择");
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(15, 4, 22, 22);
    [searchButton setImage:[UIImage imageNamed:@"ic_nav_serch_black"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchBean) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (NSMutableArray *)processArray{
    if (!_processArray) {
        NSArray *array = @[LocalString(@"日晒"),LocalString(@"水洗"),LocalString(@"半水洗"),LocalString(@"蜜处理"),LocalString(@"动物体内发酵"),LocalString(@"#其他")];
        _processArray = [NSMutableArray array];
        for (int i = 0; i < array.count; i++) {
            SortModel *model = [[SortModel alloc] init];
            model.name = array[i];
            [_processArray addObject:model];
        }
        
    }
    return _processArray;
}

- (UITableView *)processTable{
    if (!_processTable) {
        _processTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier_ProcessSel];
            
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            
            tableView.tableFooterView = [[UIView alloc] init];
            
            tableView;
        });
    }
    return _processTable;
}

#pragma mark - UITableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _mutableSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_mutableSections[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ProcessSel];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_ProcessSel];
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
            if (self.processBlock) {
                self.processBlock(text);
            }
            [self.navigationController popViewControllerAnimated:YES];
        };
        alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:alert animated:NO completion:^{
            alert.titleLabel.text = LocalString(@"#其他");
            alert.textField.placeholder = LocalString(@"请输入豆的处理方式");
            [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
            [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
        }];
        return;
    }
    
    if (self.processBlock) {
        self.processBlock(model.name);
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
    for (SortModel *model in _processArray) {
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
