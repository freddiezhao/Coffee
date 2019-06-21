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

@end

@implementation AddNewBeanController

static float HEIGHT_CELL = 50.f;
static float HEIGHT_HEADER = 36.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavItem];
    
    _beanInfoTable = [self beanInfoTable];
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
    rightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
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
            
            tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30.f)];
            
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
    if (!_myBean) {
        _myBean = [[BeanModel alloc] init];
    }
    switch (indexPath.section) {
        case 0:
        {
            AddBeanInfoCell1 *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_addNewBean1];
            if (cell == nil) {
                cell = [[AddBeanInfoCell1 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_addNewBean1];
            }
            cell.nameLabel.text = LocalString(@"生豆名称");
            cell.contentTF.enabled = YES;
            if (_myBean.name) {
                cell.contentTF.text = _myBean.name;
            }else{
                cell.contentTF.text = @"";
            }
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
                        cell.contentTF.enabled = YES;
                        if (_myBean.nation) {
                            cell.contentTF.text = _myBean.nation;
                        }else{
                            cell.contentTF.text = @"";
                        }
                        cell.TFBlock = ^(NSString *text) {
                            _myBean.nation = text;
                        };
                    }
                        break;
                        
                    case 1:
                    {
                        cell.nameLabel.text = LocalString(@"产区");
                        cell.contentTF.enabled = YES;
                        if (_myBean.area) {
                            cell.contentTF.text = _myBean.area;
                        }else{
                            cell.contentTF.text = @"";
                        }
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
                        }else{
                            cell.contentTF.text = @"";
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
                        }else{
                            cell.contentTF.text = @"";
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
                cell.unitLabel.text = [DataBase shareDataBase].setting.weightUnit;
                if (_myBean.stock) {
                    cell.contentTF.text = [NSString stringWithFormat:@"%.1f",[NSString diffWeightUnitStringWithWeight:_myBean.stock]];
                }
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
                        cell.contentTF.enabled = YES;
                        if (_myBean.manor) {
                            cell.contentTF.text = _myBean.manor;
                        }else{
                            cell.contentTF.text = @"";
                        }
                        cell.TFBlock = ^(NSString *text) {
                            _myBean.manor = text;
                        };
                    }
                        break;
                        
                    case 2:
                    {
                        cell.nameLabel.text = LocalString(@"供应商");
                        cell.contentTF.enabled = YES;
                        if (_myBean.supplier) {
                            cell.contentTF.text = _myBean.supplier;
                        }else{
                            cell.contentTF.text = @"";
                        }
                        cell.TFBlock = ^(NSString *text) {
                            _myBean.supplier = text;
                        };
                    }
                        break;
                        
                    case 1:
                    {
                        cell.nameLabel.text = LocalString(@"豆种");
                        cell.contentTF.enabled = NO;
                        if (_myBean.beanSpecies) {
                            cell.contentTF.text = _myBean.beanSpecies;
                        }else{
                            cell.contentTF.text = @"";
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
                        }else{
                            cell.contentTF.text = @"";
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
                        cell.contentTF.tag = 2222;
                        if (_myBean.water) {
                            cell.contentTF.text = [NSString stringWithFormat:@"%.1f",_myBean.water];
                        }
                        cell.TFBlock = ^(NSString *text) {
                            _myBean.water = [text floatValue];
                        };
                    }
                        break;
                        
                    case 5:
                    {
                        cell.nameLabel.text = LocalString(@"海拔");
                        cell.unitLabel.text = @"m";
                        if (_myBean.altitude) {
                            cell.contentTF.text = [NSString stringWithFormat:@"%.1f",_myBean.altitude];
                        }
                        cell.TFBlock = ^(NSString *text) {
                            _myBean.altitude = [text floatValue];
                        };
                    }
                        break;
                        
                    case 6:
                    {
                        cell.nameLabel.text = LocalString(@"价格");
                        cell.unitLabel.text = @"¥/kg";
                        if (_myBean.price) {
                            cell.contentTF.text = [NSString stringWithFormat:@"%.1f",_myBean.price];
                        }
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
                case 1:
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
    return 0.f;
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
    [self checkBeanInfo];

    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/bean"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"name":_myBean.name,@"country":_myBean.nation,@"origin":_myBean.area,@"grade":_myBean.grade,@"processingMethod":_myBean.process,@"stock":[NSNumber numberWithFloat:_myBean.stock],@"farm":_myBean.manor,@"altitude":[NSNumber numberWithFloat:_myBean.altitude],@"species":_myBean.beanSpecies,@"waterContent":[NSNumber numberWithFloat:_myBean.water],@"supplier":_myBean.supplier,@"price":[NSNumber numberWithFloat:_myBean.price],@"purchaseTime":[NSDate localStringFromUTCDate:_myBean.time]};

    [manager POST:url parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData *data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSLog(@"success:%@",daetr);
            if ([responseDic objectForKey:@"data"]) {
                NSDictionary *beansDic = [responseDic objectForKey:@"data"];
                _myBean.beanUid = [beansDic objectForKey:@"beanUid"];
                BOOL result = [[DataBase shareDataBase] insertNewBean:_myBean];
                if (result) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [NSObject showHudTipStr:LocalString(@"添加本地咖啡豆成功")];
                }else{
                    [NSObject showHudTipStr:LocalString(@"添加本地咖啡豆失败")];
                }

            }
        }else{
            [NSObject showHudTipStr:LocalString(@"生豆信息添加服务器失败")];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        if (error.code == -1001) {
            [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
        }else{
            [NSObject showHudTipStr:LocalString(@"生豆信息添加服务器失败")];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
    
}

- (void)checkBeanInfo{
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
}


@end
