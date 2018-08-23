//
//  BeanViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BeanViewController.h"
#import "TouchTableView.h"
#import "MJRefresh.h"
#import "FMDB.h"
#import "beanCell.h"
#import "BeanModel.h"


NSString *const CellIdentifier_bean = @"CellID_bean";


@interface BeanViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) UIButton *sort_generalBtn;
@property (nonatomic, strong) UIButton *sort_nameBtn;
@property (nonatomic, strong) UIButton *sort_weightBtn;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITableView *beanTable;
@property (nonatomic, strong) UIView *noBeanView;

@property (nonatomic, strong) NSMutableArray *beanArr;//综合
@property (nonatomic, strong) NSMutableArray *mutableSections;//名称
@property (nonatomic, strong) NSMutableArray *weightArr;//重量
@end

@implementation BeanViewController
{
    BOOL isConnect;
    int resendTime;
}
static int resendTimes = 3;
static float HEIGHT_CELL = 70.f;
static float HEIGHT_HEADER = 36.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1]];
    
    self.navigationItem.title = LocalString(@"生豆");
    
    UIView *rightButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 89, 30)];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(52, 4, 22, 22);
    [addButton setImage:[UIImage imageNamed:@"ic_nav_add_black"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addBean) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:addButton];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(15, 4, 22, 22);
    [searchButton setImage:[UIImage imageNamed:@"ic_nav_serch_black"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchBean) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:searchButton];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButtonView];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    _noBeanView = [self noBeanView];
    _beanTable = [self beanTable];
    _sort_nameBtn = [self sort_nameBtn];
    _sort_weightBtn = [self sort_weightBtn];
    _sort_generalBtn = [self sort_generalBtn];
    _headerView = [self headerView];
    _timer = [self timer];
    
    NSArray *array = @[@"李娜", @"林丹", @"张学友", @"孙燕姿", @"Sammi", @"Tanya", @"东野圭吾", @"周树人", @"张大千", @"阿新"];
    NSArray *weightArray = @[@20, @40, @10, @20, @30, @15, @11, @31, @41, @51];
    _beanArr = [NSMutableArray array];
    for (int i = 0; i<array.count; i++) {
        BeanModel *bean = [[BeanModel alloc] init];
        bean.name = array[i];
        bean.weight = [weightArray[i] floatValue];
        [_beanArr addObject:bean];
    }
    
    if (0) {
        _sort_nameBtn.hidden = YES;
        _sort_generalBtn.hidden = YES;
        _sort_weightBtn.hidden = YES;
        _headerView.hidden = YES;
        _beanTable.hidden = YES;
        _noBeanView.hidden = NO;
    }else{
        _sort_nameBtn.hidden = NO;
        _sort_generalBtn.hidden = NO;
        _sort_weightBtn.hidden = NO;
        _headerView.hidden = NO;
        _beanTable.hidden = NO;
        _noBeanView.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    _timer = nil;
}

- (void)dealloc{
    if (_timer) {
        [_timer fire];
        _timer = nil;
    }
}

#pragma mark - lazy load
- (UITableView *)beanTable{
    if (!_beanTable) {
        _beanTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, (44 + HEIGHT_HEADER)/HScale, ScreenWidth, ScreenHeight - 64 - (44 + 44 + HEIGHT_HEADER)/HScale) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.hidden = YES;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[beanCell class] forCellReuseIdentifier:CellIdentifier_bean];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            
            //修改索引颜色
            tableView.sectionIndexBackgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];//修改右边索引的背景色
            tableView.sectionIndexColor = [UIColor colorWithHexString:@"4778CC"];//修改右边索引字体的颜色
            //tableView.sectionIndexTrackingBackgroundColor = [UIColor orangeColor];//修改右边索引点击时候的背景色
            

            //tableView.scrollEnabled = NO;
//            if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//                [tableView setSeparatorInset:UIEdgeInsetsZero];
//            }
//            if ([tableView respondsToSelector:@selector(setLayoutMargins:)])  {
//                [tableView setLayoutMargins:UIEdgeInsetsZero];
//            }

            MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshBeanInfo)];
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
    return _beanTable;
}

- (UIView *)noBeanView{
    if (!_noBeanView) {
        _noBeanView = [[UIView alloc] init];
        _noBeanView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        _noBeanView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
        [self.view addSubview:_noBeanView];
        
        UIImageView *deviceImage = [[UIImageView alloc] init];
        deviceImage.image = [UIImage imageNamed:@"img_logo_gray"];
        [_noBeanView addSubview:deviceImage];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = LocalString(@"您的生豆库中还未添加生豆");
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_noBeanView addSubview:label];
        
        [deviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(140.f / WScale, 110.f / HScale));
            make.centerX.equalTo(_noBeanView.mas_centerX);
            make.top.equalTo(_noBeanView.mas_top).offset(120.f / HScale);
        }];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(168.f / WScale, 20.f / HScale));
            make.centerX.equalTo(_noBeanView.mas_centerX);
            make.top.equalTo(_noBeanView.mas_top).offset(252.f / HScale);
        }];
        
    }
    return _noBeanView;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.hidden = YES;
        UILabel *totolCount = [[UILabel alloc] initWithFrame:CGRectMake(15/WScale, 0, 70/WScale, HEIGHT_HEADER/HScale)];
        totolCount.font = [UIFont systemFontOfSize:14.f];
        totolCount.backgroundColor = [UIColor clearColor];
        totolCount.textColor = [UIColor colorWithHexString:@"999999"];
        totolCount.textAlignment = NSTextAlignmentCenter;
        totolCount.text = @"总数：8";
        [_headerView addSubview:totolCount];
        UILabel *totolWeight = [[UILabel alloc] initWithFrame:CGRectMake(90/WScale, 0, 200/WScale, HEIGHT_HEADER/HScale)];
        totolWeight.font = [UIFont systemFontOfSize:14.f];
        totolWeight.backgroundColor = [UIColor clearColor];
        totolWeight.textColor = [UIColor colorWithHexString:@"999999"];
        totolWeight.textAlignment = NSTextAlignmentLeft;
        totolWeight.text = @"总重量：51.2 kg";
        [_headerView addSubview:totolWeight];
        [self.view addSubview:_headerView];

        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, HEIGHT_HEADER / HScale));
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.sort_generalBtn.mas_bottom);
        }];
    }
    return _headerView;
}

- (UIButton *)sort_generalBtn{
    if (!_sort_generalBtn) {
        _sort_generalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sort_generalBtn.hidden = YES;
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
        _sort_nameBtn.hidden = YES;
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

- (UIButton *)sort_weightBtn{
    if (!_sort_weightBtn) {
        if (!_sort_weightBtn) {
            _sort_weightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _sort_weightBtn.hidden = YES;
            _sort_weightBtn.tag = sortUnselect;
            [_sort_weightBtn setImage:[UIImage imageNamed:@"ic_rank1"] forState:UIControlStateNormal];
            [_sort_weightBtn setTitle:LocalString(@"重量") forState:UIControlStateNormal];
            [_sort_weightBtn setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
            [_sort_weightBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
            [_sort_weightBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
            [_sort_weightBtn addTarget:self action:@selector(weightSort:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_sort_weightBtn];
            
            [_sort_weightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(125.f / WScale, 44.f / HScale));
                make.left.equalTo(self.sort_nameBtn.mas_right);
                make.top.equalTo(self.view.mas_top);
            }];
            [_sort_weightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -_sort_weightBtn.imageView.bounds.size.width, 0, _sort_weightBtn.imageView.bounds.size.width)];
            [_sort_weightBtn setImageEdgeInsets:UIEdgeInsetsMake(0,_sort_weightBtn.titleLabel.bounds.size.width, 0, -_sort_weightBtn.titleLabel.bounds.size.width)];

        }
        return _sort_weightBtn;
    }
    return _sort_weightBtn;
}

- (NSTimer *)timer{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(broadcast) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

-(NSLock *)lock{
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}


#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_sort_generalBtn.tag == sortSelect || _sort_weightBtn.tag != sortUnselect) {
        return 1;
    }else if (_sort_nameBtn.tag != sortUnselect){
        return _mutableSections.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_sort_generalBtn.tag == sortSelect || _sort_weightBtn.tag != sortUnselect) {
        return _beanArr.count;
    }else if (_sort_nameBtn.tag != sortUnselect){
        return [_mutableSections[section] count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL/HScale;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    beanCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_bean];
    if (cell == nil) {
        cell = [[beanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_bean];
    }
    if (_sort_generalBtn.tag == sortSelect) {//综合排序
        BeanModel *bean = _beanArr[indexPath.row];
        cell.beanImage.image = [UIImage imageNamed:@"img_coffee_beans"];
        cell.beanLabel.text = bean.name;
        cell.infoLabel.text = @"Q1等级 · 处理方式日晒";
        cell.weightLabel.text = [NSString stringWithFormat:@"%.1fkg",bean.weight];
        return cell;
    }else if (_sort_weightBtn.tag != sortUnselect){//重量排序(包括正序和倒叙)
        BeanModel *bean = _weightArr[indexPath.row];
        cell.beanImage.image = [UIImage imageNamed:@"img_coffee_beans"];
        cell.beanLabel.text = bean.name;
        cell.infoLabel.text = @"Q1等级 · 处理方式日晒";
        cell.weightLabel.text = [NSString stringWithFormat:@"%.1fkg",bean.weight];
        return cell;
    }else if (_sort_nameBtn.tag != sortUnselect){//名字排序
        BeanModel *bean = [_mutableSections[indexPath.section] objectAtIndex:indexPath.row];
        cell.beanImage.image = [UIImage imageNamed:@"img_coffee_beans"];
        cell.beanLabel.text = bean.name;
        cell.infoLabel.text = @"Q1等级 · 处理方式日晒";
        cell.weightLabel.text = [NSString stringWithFormat:@"%.1fkg",bean.weight];
        return cell;
    }else{
        cell.beanImage.image = [UIImage imageNamed:@"img_coffee_beans"];
        cell.beanLabel.text = @"样品豆";
        cell.infoLabel.text = @"Q1等级 · 处理方式日晒";
        cell.weightLabel.text = [NSString stringWithFormat:@"%.1fkg",5.2];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //NetWork *net = [NetWork shareNetWork];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_sort_generalBtn.tag == sortSelect || _sort_weightBtn.tag != sortUnselect) {
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

#pragma mark - actions
- (void)addBean{
    
}

- (void)searchBean{
    
}

- (void)refreshBeanInfo{
    [_beanTable.mj_header endRefreshing];
}

- (void)generalSort:(UIButton *)sender{
    _sort_weightBtn.tag = sortUnselect;
    [_sort_weightBtn setImage:[UIImage imageNamed:@"ic_rank1"] forState:UIControlStateNormal];
    _sort_nameBtn.tag = sortUnselect;
    [_sort_nameBtn setImage:[UIImage imageNamed:@"ic_rank1"] forState:UIControlStateNormal];
    
    if (sender.tag == sortUnselect) {
        sender.tag = sortSelect;
    }
    [sender setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
    [self.beanTable reloadData];
}

- (void)nameSort:(UIButton *)sender{
    _sort_weightBtn.tag = sortUnselect;
    [_sort_weightBtn setImage:[UIImage imageNamed:@"ic_rank1"] forState:UIControlStateNormal];
    _sort_generalBtn.tag = sortUnselect;
    [_sort_generalBtn setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
    
    if (sender.tag == sortUnselect) {
        sender.tag = sortUp;
        [sender setImage:[UIImage imageNamed:@"ic_rank3"] forState:UIControlStateNormal];
        [self setObjects:_beanArr];
    }else if (sender.tag == sortUp){
        sender.tag = sortDown;
        [sender setImage:[UIImage imageNamed:@"ic_rank3"] forState:UIControlStateNormal];
    }else{
        sender.tag = sortUp;
        [sender setImage:[UIImage imageNamed:@"ic_rank3"] forState:UIControlStateNormal];
    }
    [self.beanTable reloadData];
}

- (void)weightSort:(UIButton *)sender{
    _sort_generalBtn.tag = sortUnselect;
    [_sort_generalBtn setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
    _sort_nameBtn.tag = sortUnselect;
    [_sort_nameBtn setImage:[UIImage imageNamed:@"ic_rank1"] forState:UIControlStateNormal];
    if (sender.tag == sortUnselect) {
        if (!_weightArr) {
            [self sortByWeight:_beanArr];
        }
        sender.tag = sortUp;
        [sender setImage:[UIImage imageNamed:@"ic_rank3"] forState:UIControlStateNormal];
    }else if (sender.tag == sortUp){
        if (!_weightArr) {
            [self sortByWeight:_beanArr];//正序排序
        }else{
            _weightArr = (NSMutableArray *)[[_weightArr reverseObjectEnumerator] allObjects];//倒序排序
        }
        sender.tag = sortDown;
        [sender setImage:[UIImage imageNamed:@"ic_rank3"] forState:UIControlStateNormal];
    }else{
        if (!_weightArr) {
            [self sortByWeight:_beanArr];//正序排序
        }
        sender.tag = sortUp;
        [sender setImage:[UIImage imageNamed:@"ic_rank3"] forState:UIControlStateNormal];
    }
    [self.beanTable reloadData];
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
    for (BeanModel *bean in _beanArr) {
        NSInteger section = [collation sectionForObject:bean collationStringSelector:@selector(name)];
        NSMutableArray *subArr = _mutableSections[section];
        
        [subArr addObject:bean];
    }
    
    //3.2 分别对分区进行排序
    for (NSMutableArray *subArr in _mutableSections) {
        NSArray *sortArr = [collation sortedArrayFromArray:subArr collationStringSelector:@selector(name)];
        [subArr removeAllObjects];
        [subArr addObjectsFromArray:sortArr];
    }
}

- (void)sortByWeight:(NSMutableArray *)arr{
    [arr sortUsingComparator:^NSComparisonResult(BeanModel *obj1, BeanModel *obj2) {
        return [@(obj1.weight) compare:@(obj2.weight)];
    }];
    _weightArr = [arr mutableCopy];
}

#pragma mark - Data Source

@end

