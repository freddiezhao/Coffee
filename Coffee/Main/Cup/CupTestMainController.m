//
//  CupTestMainController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/14.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CupTestMainController.h"
#import "TouchTableView.h"
#import <MJRefresh/MJRefresh.h>
#import "CupModel.h"
#import "CupNormalCell.h"
#import "CupTestDetailController.h"

NSString *const CellIdentifier_cup = @"CellID_cup";

@interface CupTestMainController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *sort_generalBtn;
@property (nonatomic, strong) UIButton *sort_nameBtn;
@property (nonatomic, strong) UIButton *sort_gradeBtn;

@property (nonatomic, strong) UITableView *cupTable;

@property (nonatomic, strong) NSMutableArray *cupArr;//综合
@property (nonatomic, strong) NSMutableArray *mutableSections;//名称
@property (nonatomic, strong) NSMutableArray *gradeArr;//重量

@end

@implementation CupTestMainController
static float HEIGHT_CELL = 60.f;
static float HEIGHT_HEADER = 36.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavItem];
    
    _cupTable = [self cupTable];
    _sort_gradeBtn = [self sort_gradeBtn];
    _sort_nameBtn = [self sort_nameBtn];
    _sort_generalBtn = [self sort_generalBtn];
    
    [self getAllCup];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];    
}

#pragma mark - lazy load
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"杯测");
    
    UIView *rightButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 74, 30)];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(52, 4, 22, 22);
    [addButton setImage:[UIImage imageNamed:@"ic_nav_add_black"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addCupTest) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:addButton];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(15, 4, 22, 22);
    [searchButton setImage:[UIImage imageNamed:@"ic_nav_serch_black"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchCup) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:searchButton];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButtonView];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}


- (UIButton *)sort_generalBtn{
    if (!_sort_generalBtn) {
        _sort_generalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sort_generalBtn.tag = sortSelect;
        [_sort_generalBtn setTitle:LocalString(@"综合") forState:UIControlStateNormal];
        [_sort_generalBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_sort_generalBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
        [_sort_generalBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        [_sort_generalBtn addTarget:self action:@selector(generalSort:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_sort_generalBtn];
        
        [_sort_generalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(125.f / WScale, 44.f / HScale));
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.view.mas_top);
        }];
    }
    return _sort_generalBtn;
}

- (UIButton *)sort_nameBtn{
    if (!_sort_nameBtn) {
        _sort_nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sort_nameBtn.tag = sortUnselect;
        [_sort_nameBtn setImage:[UIImage imageNamed:@"ic_rank1"] forState:UIControlStateNormal];
        [_sort_nameBtn setTitle:LocalString(@"名称") forState:UIControlStateNormal];
        [_sort_nameBtn setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
        [_sort_nameBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
        [_sort_nameBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        [_sort_nameBtn addTarget:self action:@selector(nameSort:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_sort_nameBtn];
        
        [_sort_nameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(125.f / WScale, 44.f / HScale));
            make.left.equalTo(self.sort_generalBtn.mas_right);
            make.top.equalTo(self.view.mas_top);
        }];
        [_sort_nameBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -_sort_nameBtn.imageView.bounds.size.width, 0, _sort_nameBtn.imageView.bounds.size.width)];
        [_sort_nameBtn setImageEdgeInsets:UIEdgeInsetsMake(0,_sort_nameBtn.titleLabel.bounds.size.width, 0, -_sort_nameBtn.titleLabel.bounds.size.width)];
        
    }
    return _sort_nameBtn;
}

- (UIButton *)sort_gradeBtn{
    if (!_sort_gradeBtn) {
        if (!_sort_gradeBtn) {
            _sort_gradeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _sort_gradeBtn.tag = sortUnselect;
            [_sort_gradeBtn setImage:[UIImage imageNamed:@"ic_rank1"] forState:UIControlStateNormal];
            [_sort_gradeBtn setTitle:LocalString(@"重量") forState:UIControlStateNormal];
            [_sort_gradeBtn setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
            [_sort_gradeBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
            [_sort_gradeBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
            [_sort_gradeBtn addTarget:self action:@selector(gradeSort:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_sort_gradeBtn];
            
            [_sort_gradeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(125.f / WScale, 44.f / HScale));
                make.left.equalTo(self.sort_nameBtn.mas_right);
                make.top.equalTo(self.view.mas_top);
            }];
            [_sort_gradeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -_sort_gradeBtn.imageView.bounds.size.width, 0, _sort_gradeBtn.imageView.bounds.size.width)];
            [_sort_gradeBtn setImageEdgeInsets:UIEdgeInsetsMake(0,_sort_gradeBtn.titleLabel.bounds.size.width, 0, -_sort_gradeBtn.titleLabel.bounds.size.width)];
            
        }
        return _sort_gradeBtn;
    }
    return _sort_gradeBtn;
}

- (UITableView *)cupTable{
    if (!_cupTable) {
        _cupTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 44/HScale, ScreenWidth, ScreenHeight - 64 - (44 + 44)/HScale) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[CupNormalCell class] forCellReuseIdentifier:CellIdentifier_cup];
            [self.view addSubview:tableView];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            
            //修改索引颜色
            tableView.sectionIndexBackgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];//修改右边索引的背景色
            tableView.sectionIndexColor = [UIColor colorWithHexString:@"4778CC"];//修改右边索引字体的颜色
            //tableView.sectionIndexTrackingBackgroundColor = [UIColor orangeColor];//修改右边索引点击时候的背景色
            
            tableView.tableFooterView = [[UIView alloc] init];
            
            MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(getAllCup)];
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
    return _cupTable;
}

#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_sort_generalBtn.tag == sortSelect || _sort_gradeBtn.tag != sortUnselect) {
        return 1;
    }else if (_sort_nameBtn.tag != sortUnselect){
        return _mutableSections.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_sort_generalBtn.tag == sortSelect || _sort_gradeBtn.tag != sortUnselect) {
        return _cupArr.count;
    }else if (_sort_nameBtn.tag != sortUnselect){
        return [_mutableSections[section] count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL/HScale;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CupNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cup];
    if (cell == nil) {
        cell = [[CupNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cup];
    }
    CupModel *cup;
    if (_sort_generalBtn.tag == sortSelect) {//综合排序
        cup = _cupArr[indexPath.row];
    }else if (_sort_gradeBtn.tag != sortUnselect){//重量排序(包括正序和倒叙)
        cup = _gradeArr[indexPath.row];
    }else if (_sort_nameBtn.tag != sortUnselect){//名字排序
        cup = [_mutableSections[indexPath.section] objectAtIndex:indexPath.row];
    }else{
        cup = _cupArr[indexPath.row];
    }
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %.1f分",cup.name,cup.grade]];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"333333"] range:NSMakeRange(0,cup.name.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"999999"] range:NSMakeRange(cup.name.length + 2,str.length - cup.name.length - 2)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.f] range:NSMakeRange(0,cup.name.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.f] range:NSMakeRange(cup.name.length + 2, str.length - cup.name.length - 2)];
    cell.beanGradeName.attributedText = str;
    cell.dateLabel.text = [NSDate YMDStringFromDate:cup.date];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CupModel *cup;
    if (_sort_generalBtn.tag == sortSelect) {//综合排序
        cup = _cupArr[indexPath.row];
    }else if (_sort_gradeBtn.tag != sortUnselect){//重量排序(包括正序和倒叙)
        cup = _gradeArr[indexPath.row];
    }else if (_sort_nameBtn.tag != sortUnselect){//名字排序
        cup = [_mutableSections[indexPath.section] objectAtIndex:indexPath.row];
    }
    CupTestDetailController *detailVC = [[CupTestDetailController alloc] init];
    detailVC.cup = cup;
    [self.navigationController pushViewController:detailVC animated:YES];
    //NetWork *net = [NetWork shareNetWork];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_sort_generalBtn.tag == sortSelect || _sort_gradeBtn.tag != sortUnselect) {
        return 0;
    }else if (_sort_nameBtn.tag != sortUnselect){
        //有内容时才显示字母
        if ([_mutableSections[section] count]) {
            return 28.f/HScale;
        }else{
            return 0;
        }
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (_sort_nameBtn.tag != sortUnselect){
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }else{
        return nil;
    }
}

//修改titleForHeaderInSection title的属性
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.contentView.backgroundColor= [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    
    [header.textLabel setTextColor:[UIColor colorWithHexString:@"4778CC"]];
    
    [header.textLabel setFont:[UIFont systemFontOfSize:15.f]];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (_sort_nameBtn.tag != sortUnselect){
        return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    }else{
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
    if (_sort_nameBtn.tag != sortUnselect){
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
    }else{
        return 0;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DataBase *db = [DataBase shareDataBase];
        BOOL result = NO;
        if (_sort_generalBtn.tag == sortSelect) {
            CupModel *cup = _cupArr[indexPath.row];
            result = [db deleteqCup:cup];
            if (result) {
                [_cupArr removeObject:cup];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [NSObject showHudTipStr:LocalString(@"删除成功")];
            }else{
                [NSObject showHudTipStr:LocalString(@"删除失败")];
            }
        }else if (_sort_nameBtn.tag == sortUp){
            CupModel *cup = _gradeArr[indexPath.row];
            result = [db deleteqCup:cup];
            if (result) {
                [_gradeArr removeObject:cup];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [NSObject showHudTipStr:LocalString(@"删除成功")];
            }else{
                [NSObject showHudTipStr:LocalString(@"删除失败")];
            }
        }else if (_sort_gradeBtn.tag == sortUp || _sort_gradeBtn.tag == sortDown){
            CupModel *cup = [_mutableSections[indexPath.section] objectAtIndex:indexPath.row];
            result = [db deleteqCup:cup];
            if (result) {
                [_mutableSections[indexPath.section] removeObject:cup];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [NSObject showHudTipStr:LocalString(@"删除成功")];
            }else{
                [NSObject showHudTipStr:LocalString(@"删除失败")];
            }
        }
    }
}

#pragma mark - Actions
- (void)addCupTest{
    [[DataBase shareDataBase] insertNewCup:nil];
    [self getAllCup];
}

- (void)searchCup{
    
}

- (void)generalSort:(UIButton *)sender{
    _sort_gradeBtn.tag = sortUnselect;
    [_sort_gradeBtn setImage:[UIImage imageNamed:@"ic_rank1"] forState:UIControlStateNormal];
    _sort_nameBtn.tag = sortUnselect;
    [_sort_nameBtn setImage:[UIImage imageNamed:@"ic_rank1"] forState:UIControlStateNormal];
    
    if (sender.tag == sortUnselect) {
        sender.tag = sortSelect;
    }
    [sender setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
    [self.cupTable reloadData];
}

- (void)nameSort:(UIButton *)sender{
    _sort_gradeBtn.tag = sortUnselect;
    [_sort_gradeBtn setImage:[UIImage imageNamed:@"ic_rank1"] forState:UIControlStateNormal];
    _sort_generalBtn.tag = sortUnselect;
    [_sort_generalBtn setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
    
    if (sender.tag == sortUnselect) {
        sender.tag = sortUp;
        [sender setImage:[UIImage imageNamed:@"ic_rank3"] forState:UIControlStateNormal];
        [self setObjects:_cupArr];
    }else if (sender.tag == sortUp){
        sender.tag = sortDown;
        [sender setImage:[UIImage imageNamed:@"ic_rank3"] forState:UIControlStateNormal];
    }else{
        sender.tag = sortUp;
        [sender setImage:[UIImage imageNamed:@"ic_rank3"] forState:UIControlStateNormal];
    }
    [self.cupTable reloadData];
}

- (void)gradeSort:(UIButton *)sender{
    _sort_generalBtn.tag = sortUnselect;
    [_sort_generalBtn setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
    _sort_nameBtn.tag = sortUnselect;
    [_sort_nameBtn setImage:[UIImage imageNamed:@"ic_rank1"] forState:UIControlStateNormal];
    if (sender.tag == sortUnselect) {
        [self upSortByGrade:_cupArr];
        sender.tag = sortUp;
        [sender setImage:[UIImage imageNamed:@"ic_rank3"] forState:UIControlStateNormal];
    }else if (sender.tag == sortUp){
        [self downSortByGrade:_cupArr];
        sender.tag = sortDown;
        [sender setImage:[UIImage imageNamed:@"ic_rank3"] forState:UIControlStateNormal];
    }else{
        [self upSortByGrade:_cupArr];//正序排序
        sender.tag = sortUp;
        [sender setImage:[UIImage imageNamed:@"ic_rank3"] forState:UIControlStateNormal];
    }
    [self.cupTable reloadData];
}

#pragma mark - Sort Actions
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
    for (CupModel *cup in _cupArr) {
        NSInteger section = [collation sectionForObject:cup collationStringSelector:@selector(name)];
        NSMutableArray *subArr = _mutableSections[section];
        
        [subArr addObject:cup];
    }
    
    //3.2 分别对分区进行排序
    for (NSMutableArray *subArr in _mutableSections) {
        NSArray *sortArr = [collation sortedArrayFromArray:subArr collationStringSelector:@selector(name)];
        [subArr removeAllObjects];
        [subArr addObjectsFromArray:sortArr];
    }
}

- (void)upSortByGrade:(NSMutableArray *)arr{
    [arr sortUsingComparator:^NSComparisonResult(CupModel *obj1, CupModel *obj2) {
        if (obj1.grade > obj2.grade) {
            return NSOrderedDescending;
        }else if (obj1.grade == obj2.grade){
            return NSOrderedSame;
        }else{
            return NSOrderedAscending;
        }
    }];
    _gradeArr = [arr mutableCopy];
}

- (void)downSortByGrade:(NSMutableArray *)arr{
    [arr sortUsingComparator:^NSComparisonResult(CupModel *obj1, CupModel *obj2) {
        if (obj1.grade > obj2.grade) {
            return NSOrderedAscending;
        }else if (obj1.grade == obj2.grade){
            return NSOrderedSame;
        }else{
            return NSOrderedDescending;
        }
    }];
    _gradeArr = [arr mutableCopy];
}

#pragma mark - Data Source
- (void)getAllCup{
    _cupArr = [[DataBase shareDataBase] queryAllCup];
    
    if (_sort_nameBtn.tag == sortUp) {
        [self setObjects:_cupArr];
    }else if(_sort_gradeBtn.tag == sortUp){
        [self upSortByGrade:_cupArr];//正序排序
    }else if(_sort_gradeBtn.tag == sortDown){
        [self downSortByGrade:_cupArr];
    }
    [self.cupTable reloadData];
    if ([_cupTable.mj_header isRefreshing]) {
        [_cupTable.mj_header endRefreshing];
    }
}
@end
