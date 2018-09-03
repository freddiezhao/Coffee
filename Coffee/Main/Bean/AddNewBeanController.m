//
//  AddNewBeanController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "AddNewBeanController.h"
#import "TouchTableView.h"
#import "AddBeanInfoCell1.h"
#import "AddBeanInfoCell2.h"
#import "GradeSelController.h"
#import "SpicesSelController.h"
#import "ProcessSelController.h"
#import "BuyDateSelController.h"
#import "BeanModel.h"

NSString *const CellIdentifier_addNewBean1 = @"CellID_addNewBean1";
NSString *const CellIdentifier_addNewBean2 = @"CellID_addNewBean2";

@interface AddNewBeanController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *beanInfoTable;

@property (nonatomic, strong) BeanModel *myBean;

@end

@implementation AddNewBeanController

static float HEIGHT_CELL = 50.f;
static float HEIGHT_HEADER = 36.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavItem];
    
    _beanInfoTable = [self beanInfoTable];
    _myBean = [[BeanModel alloc] init];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

#pragma mark - Lazy Load
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"添加咖啡豆");
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 32, 23);
    [leftButton setTitle:LocalString(@"取消") forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
    leftButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [leftButton addTarget:self action:@selector(cancelSaveInfo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 32, 23);
    [rightButton setTitle:LocalString(@"保存") forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
    leftButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [rightButton addTarget:self action:@selector(saveBeanInfo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (UITableView *)beanInfoTable{
    if (!_beanInfoTable) {
        _beanInfoTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[AddBeanInfoCell1 class] forCellReuseIdentifier:CellIdentifier_addNewBean1];
            [tableView registerClass:[AddBeanInfoCell2 class] forCellReuseIdentifier:CellIdentifier_addNewBean2];

            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            
            //tableView.scrollEnabled = NO;
            //            if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            //                [tableView setSeparatorInset:UIEdgeInsetsZero];
            //            }
            //            if ([tableView respondsToSelector:@selector(setLayoutMargins:)])  {
            //                [tableView setLayoutMargins:UIEdgeInsetsZero];
            //            }
            tableView;
        });
    }
    return _beanInfoTable;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            return 1;
        }
            break;
            
        case 1:
        {
            return 5;
        }
            break;
         
        case 2:
        {
            return 7;
        }
            break;
            
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            AddBeanInfoCell1 *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_addNewBean1];
            if (cell == nil) {
                cell = [[AddBeanInfoCell1 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_addNewBean1];
            }
            cell.nameLabel.text = LocalString(@"生豆名称");
            cell.TFBlock = ^(NSString *text) {
                _myBean.name = text;
            };
            return cell;
        }
            break;
            
        case 1:
        {
            if (indexPath.row < 4) {
                AddBeanInfoCell1 *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_addNewBean1];
                if (cell == nil) {
                    cell = [[AddBeanInfoCell1 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_addNewBean1];
                }
                switch (indexPath.row) {
                    case 0:
                    {
                        cell.nameLabel.text = LocalString(@"国家");
                        cell.TFBlock = ^(NSString *text) {
                            _myBean.nation = text;
                        };
                    }
                        break;
                        
                    case 1:
                    {
                        cell.nameLabel.text = LocalString(@"产区");
                        cell.TFBlock = ^(NSString *text) {
                            _myBean.area = text;
                        };
                    }
                        break;
                        
                    case 2:
                    {
                        cell.nameLabel.text = LocalString(@"等级");
                        cell.contentTF.enabled = NO;
                        if (_myBean.grade) {
                            cell.contentTF.text = _myBean.grade;
                        }
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                        break;
                        
                    case 3:
                    {
                        cell.nameLabel.text = LocalString(@"处理方式");
                        cell.contentTF.enabled = NO;
                        if (_myBean.process) {
                            cell.contentTF.text = _myBean.process;
                        }
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                        break;
                        
                    default:
                        break;
                }
                return cell;
            }else{
                AddBeanInfoCell2 *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_addNewBean2];
                if (cell == nil) {
                    cell = [[AddBeanInfoCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_addNewBean2];
                }
                cell.nameLabel.text = LocalString(@"库存量");
                cell.unitLabel.text = @"kg";
                cell.TFBlock = ^(NSString *text) {
                    _myBean.stock = [text floatValue];
                };
                return cell;
            }
            
        }
            break;
            
        case 2:
        {
            if (indexPath.row < 4) {
                AddBeanInfoCell1 *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_addNewBean1];
                if (cell == nil) {
                    cell = [[AddBeanInfoCell1 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_addNewBean1];
                }
                switch (indexPath.row) {
                    case 0:
                    {
                        cell.nameLabel.text = LocalString(@"庄园");
                        cell.TFBlock = ^(NSString *text) {
                            _myBean.manor = text;
                        };
                    }
                        break;
                        
                    case 1:
                    {
                        cell.nameLabel.text = LocalString(@"供应商");
                        cell.TFBlock = ^(NSString *text) {
                            _myBean.supplier = text;
                        };
                    }
                        break;
                        
                    case 2:
                    {
                        cell.nameLabel.text = LocalString(@"豆种");
                        cell.contentTF.enabled = NO;
                        if (_myBean.beanSpecies) {
                            cell.contentTF.text = _myBean.beanSpecies;
                        }
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                        break;
                        
                    case 3:
                    {
                        cell.nameLabel.text = LocalString(@"购买日期");
                        cell.contentTF.enabled = NO;
                        if (_myBean.time) {
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                            NSString *date = [dateFormatter stringFromDate:_myBean.time];
                            
                            cell.contentTF.text = date;
                        }

                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                        break;
                        
                    default:
                        break;
                }
                return cell;
            }else{
                AddBeanInfoCell2 *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_addNewBean2];
                if (cell == nil) {
                    cell = [[AddBeanInfoCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_addNewBean2];
                }
                switch (indexPath.row) {
                    case 4:
                    {
                        cell.nameLabel.text = LocalString(@"含水量");
                        cell.unitLabel.text = @"%";
                        cell.TFBlock = ^(NSString *text) {
                            _myBean.water = [text floatValue];
                        };
                    }
                        break;
                        
                    case 5:
                    {
                        cell.nameLabel.text = LocalString(@"海拔");
                        cell.unitLabel.text = @"m";
                        cell.TFBlock = ^(NSString *text) {
                            _myBean.altitude = [text floatValue];
                        };
                    }
                        break;
                        
                    case 6:
                    {
                        cell.nameLabel.text = LocalString(@"价格");
                        cell.unitLabel.text = @"¥/kg";
                        cell.TFBlock = ^(NSString *text) {
                            _myBean.price = [text floatValue];
                        };
                    }
                        break;
                        
                    default:
                        break;
                }
                return cell;
            }
        }
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 1:
        {
            switch (indexPath.row) {
                case 2:
                {
                    GradeSelController *gradeVC = [[GradeSelController alloc] init];
                    gradeVC.gradeBlock = ^(NSString *text) {
                        _myBean.grade = text;
                        [self.beanInfoTable reloadData];
                    };
                    [self.navigationController pushViewController:gradeVC animated:YES];
                }
                    break;
                    
                case 3:
                {
                    ProcessSelController *processVC = [[ProcessSelController alloc] init];
                    processVC.processBlock = ^(NSString *text) {
                        _myBean.process = text;
                        [self.beanInfoTable reloadData];
                    };
                    [self.navigationController pushViewController:processVC animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 2:
        {
            switch (indexPath.row) {
                case 2:
                {
                    SpicesSelController *spicesVC = [[SpicesSelController alloc] init];
                    spicesVC.spicesBlock = ^(NSString *text) {
                        _myBean.beanSpecies = text;
                        [self.beanInfoTable reloadData];
                    };
                    [self.navigationController pushViewController:spicesVC animated:YES];
                }
                    break;
                    
                case 3:
                {
                    BuyDateSelController *buyVC = [[BuyDateSelController alloc] init];
                    buyVC.dateBlock = ^(NSDate *date) {
                        _myBean.time = date;
                        [self.beanInfoTable reloadData];
                    };
                    buyVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                    buyVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    [self presentViewController:buyVC animated:YES completion:nil];

                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL/HScale;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER/HScale)];
    headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(11/WScale, 0, 150/WScale, HEIGHT_HEADER/HScale)];
    textLabel.textColor = [UIColor colorWithHexString:@"999999"];
    textLabel.font = [UIFont systemFontOfSize:14.f];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:textLabel];
    
    switch (section) {
        case 1:
        {
            textLabel.text = LocalString(@"基本信息");
        }
            break;
            
        case 2:
        {
            textLabel.text = LocalString(@"详细信息");
        }
            break;
            
        default:
            break;
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 15.f/HScale;
    }
    return HEIGHT_HEADER/HScale;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 15.f/HScale)];
    footerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 15.f/HScale;
}

#pragma mark - Actions
- (void)cancelSaveInfo{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveBeanInfo{
    if (!_myBean.name) {
        [NSObject showHudTipStr:LocalString(@"名字不能为空")];
        return;
    }
    if (!_myBean.nation) {
        _myBean.nation = @"";
    }
    
    if (!_myBean.area) {
        _myBean.area = @"";
    }
    
    if (!_myBean.stock) {
        _myBean.stock = 0;
    }
    
    if (!_myBean.manor) {
        _myBean.manor = @"";
    }
    
    if (!_myBean.supplier) {
        _myBean.supplier = @"";
    }
    
    if (!_myBean.water) {
        _myBean.water = 0;
    }
    
    if (!_myBean.altitude) {
        _myBean.altitude = 0;
    }
    
    if (!_myBean.price) {
        _myBean.price = 0;
    }
    
    if (!_myBean.beanSpecies) {
        _myBean.beanSpecies = @"";
    }
    if (!_myBean.grade) {
        _myBean.grade = @"";
    }
    if (!_myBean.process) {
        _myBean.process = @"";
    }
    if (!_myBean.time) {
        _myBean.time = [NSDate date];
    }
    BOOL result = [[DataBase shareDataBase] insertNewBean:_myBean];
    if (result) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [NSObject showHudTipStr:LocalString(@"添加咖啡豆成功")];
    }else{
        [NSObject showHudTipStr:LocalString(@"添加咖啡豆失败")];
    }
    
}

@end
