//
//  BeanDetailController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/12.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BeanDetailController.h"
#import "BeanModel.h"
#import "TouchTableView.h"
#import "BeanDetailCell.h"
#import "EditBeanController.h"
#import "BeanRelaCurveController.h"

NSString *const CellIdentifier_BeanDetail = @"CellID_BeanDetail";

@interface BeanDetailController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *beanDetailTable;
@property (nonatomic, strong) NSArray *cellArr;
@property (nonatomic, strong) UIButton *relaCurveBtn;

@end

@implementation BeanDetailController

static float HEIGHT_CELL = 50.f;
static float HEIGHT_HEADER = 15.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    
    _beanDetailTable = [self beanDetailTable];
    _relaCurveBtn = [self relaCurveBtn];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
    _myBean = [[DataBase shareDataBase] queryBean:_myBean.beanUid];
    [self setNavItem];
    if (_beanDetailTable) {
        [_beanDetailTable reloadData];
    }
}

#pragma mark - Lazy Load
- (void)setNavItem{
    self.navigationItem.title = _myBean.name;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 32, 23);
    [rightButton setTitle:LocalString(@"编辑") forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
    rightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [rightButton addTarget:self action:@selector(editBeanInfo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (UITableView *)beanDetailTable{
    if (!_beanDetailTable) {
        _beanDetailTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[BeanDetailCell class] forCellReuseIdentifier:CellIdentifier_BeanDetail];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            
            tableView;
        });
    }
    return _beanDetailTable;
}

- (UIButton *)relaCurveBtn{
    if (!_relaCurveBtn) {
        _relaCurveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_relaCurveBtn setTitle:LocalString(@"烘焙曲线") forState:UIControlStateNormal];
        [_relaCurveBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        [_relaCurveBtn setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
        [_relaCurveBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        [_relaCurveBtn addTarget:self action:@selector(goRelaCurveViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_relaCurveBtn];
        
        _relaCurveBtn.layer.cornerRadius = 25.f/HScale;
        
        [_relaCurveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(110/WScale, 50/HScale));
            make.right.equalTo(self.view.mas_right).offset(-15/WScale);
            make.bottom.equalTo(self.view.mas_bottom).offset(-15/HScale);
        }];
    }
    return _relaCurveBtn;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BeanDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_BeanDetail];
    if (cell == nil) {
        cell = [[BeanDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_BeanDetail];
    }
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                cell.nameLabel.text = LocalString(@"国家");
                cell.contentLabel.text = _myBean.nation;
            }else if (indexPath.row == 1){
                cell.nameLabel.text = LocalString(@"产区");
                cell.contentLabel.text = _myBean.area;
            }else if (indexPath.row == 2){
                cell.nameLabel.text = LocalString(@"庄园");
                cell.contentLabel.text = _myBean.manor;
            }else if (indexPath.row == 3){
                cell.nameLabel.text = LocalString(@"海拔");
                cell.contentLabel.text = [NSString stringWithFormat:@"%.1fm",_myBean.altitude];
            }
        }
            break;
            
        case 1:
        {
            if (indexPath.row == 0) {
                cell.nameLabel.text = LocalString(@"豆种");
                cell.contentLabel.text = _myBean.beanSpecies;
            }else if (indexPath.row == 1){
                cell.nameLabel.text = LocalString(@"等级");
                cell.contentLabel.text = _myBean.grade;
            }else if (indexPath.row == 2){
                cell.nameLabel.text = LocalString(@"处理方式");
                cell.contentLabel.text = _myBean.process;
            }else if (indexPath.row == 3){
                cell.nameLabel.text = LocalString(@"含水量");
                cell.contentLabel.text = [NSString stringWithFormat:@"%.1f%%",_myBean.water];
            }
        }
            break;
            
        case 2:
        {
            if (indexPath.row == 0) {
                cell.nameLabel.text = LocalString(@"供应商");
                cell.contentLabel.text = _myBean.supplier;
            }else if (indexPath.row == 1){
                cell.nameLabel.text = LocalString(@"价格");
                cell.contentLabel.text = [NSString stringWithFormat:@"%.1f¥/kg",_myBean.price];
            }else if (indexPath.row == 2){
                cell.nameLabel.text = LocalString(@"库存量");
                cell.contentLabel.text = [NSString stringWithFormat:@"%.1f%@",[NSString diffWeightUnitStringWithWeight:_myBean.stock],[DataBase shareDataBase].setting.weightUnit];
            }else if (indexPath.row == 3){
                cell.nameLabel.text = LocalString(@"购买日期");
                cell.contentLabel.text = [NSDate YMDStringFromDate:_myBean.time];
            }
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL/HScale;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER/HScale)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEIGHT_HEADER/HScale;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 15.f/HScale)];
    footerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0/HScale;
}


#pragma mark - Actions
- (void)editBeanInfo{
    EditBeanController *editVC = [[EditBeanController alloc] init];
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:editVC];
    editVC.myBean = _myBean;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)goRelaCurveViewController{
    BeanRelaCurveController *relaVC = [[BeanRelaCurveController alloc] init];
    relaVC.beanUid = _myBean.beanUid;
    [self.navigationController pushViewController:relaVC animated:YES];
}


@end
