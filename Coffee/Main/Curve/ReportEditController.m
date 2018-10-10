//
//  ReportEditController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/10.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "ReportEditController.h"
#import "TouchTableView.h"
#import "EditNameCell.h"
#import "ReportModel.h"
#import "EditLightCell.h"
#import "AddBeanTableViewCell.h"
#import "BeanModel.h"
#import "EditBakeBeanCell.h"
#import "EditBeanController_bakeAdd.h"

NSString *const CellIdentifier_EditName = @"CellID_EditName";
NSString *const CellIdentifier_EditLight = @"CellID_EditLight";
NSString *const CellIdentifier_EditBean = @"CellID_EditBean";
NSString *const CellIdentifier_EditAddBean = @"CellID_EditAddBean";
NSString *const CellIdentifier_EditBakeBean = @"CellID_EditBakeBean";

@interface ReportEditController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *reportEditTable;

@end

@implementation ReportEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavItem];
    _reportEditTable = [self reportEditTable];
}

#pragma mark - lazy load
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"编辑报告");
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"保存") style:UIBarButtonItemStylePlain target:self action:@selector(saveEdit)];
    self.navigationItem.rightBarButtonItem = rightBar;
}

- (UITableView *)reportEditTable{
    if (!_reportEditTable) {
        _reportEditTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[EditNameCell class] forCellReuseIdentifier:CellIdentifier_EditName];
            [tableView registerClass:[EditLightCell class] forCellReuseIdentifier:CellIdentifier_EditLight];
            [tableView registerClass:[AddBeanTableViewCell class] forCellReuseIdentifier:CellIdentifier_EditBean];
            [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier_EditAddBean];
            [tableView registerClass:[EditBakeBeanCell class] forCellReuseIdentifier:CellIdentifier_EditBakeBean];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView;
        });
    }
    return _reportEditTable;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
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
            return 1;
        }
            break;
            
        case 2:
        {
            return 1 + _beanArray.count;
        }
            break;
            
        case 3:
        {
            return 1;
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
            EditNameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_EditName forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[EditNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_EditName];
            }
            cell.nameLabel.text = LocalString(@"曲线名称");
            if (![_reportModel.curveName isEqualToString:@""]) {
                cell.nameTF.text = _reportModel.curveName;
            }
            cell.TFBlock = ^(NSString *text) {
                _reportModel.curveName = text;
            };
            return cell;
        }
            break;
            
        case 1:
        {
            EditLightCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_EditLight forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[EditLightCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_EditLight];
            }
            cell.nameLabel.text = LocalString(@"烘焙度编辑");
            cell.lightValue.text = [NSString stringWithFormat:@"%d",(int)_reportModel.light];
            cell.lightSlider.value = _reportModel.light;
            cell.SliderBlock = ^(float value) {
                _reportModel.light = value;
            };
            return cell;
        }
            break;
            
        case 2:
        {
            if (indexPath.row == _beanArray.count) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_EditAddBean forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_EditAddBean];
                }
                cell.textLabel.text = LocalString(@"选择咖啡豆");
                cell.textLabel.textColor = [UIColor colorWithHexString:@"222222"];
                cell.textLabel.font = [UIFont systemFontOfSize:16.f];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }else{
                AddBeanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_EditBean forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[AddBeanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_EditBean];
                }
                BeanModel *bean = _beanArray[indexPath.row];
                cell.beanName.text = bean.name;
                cell.weightTF.text = [NSString stringWithFormat:@"%.1f",bean.weight];
                cell.TFBlock = ^(NSString *text) {
                    bean.weight = [text floatValue];
                };
                return cell;
            }
        }
            break;
            
        case 3:
        {
            EditBakeBeanCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_EditBakeBean forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[EditBakeBeanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_EditBakeBean];
            }
            cell.nameLabel.text = LocalString(@"熟豆重量");
            cell.weightTF.text = [NSString stringWithFormat:@"%.1f",_reportModel.bakeBeanWeight];
            cell.TFBlock = ^(NSString *text) {
                _reportModel.bakeBeanWeight = [text doubleValue];
            };
            return cell;
        }
            break;
            
        default:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid_edit_default" forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellid_edit_default"];
            }
            return cell;
        }
            break;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2 && indexPath.row == _beanArray.count) {
        EditBeanController_bakeAdd *VC = [[EditBeanController_bakeAdd alloc] init];
        VC.VCBlock = ^(BeanModel *bean) {
            for (BeanModel *model in _beanArray) {
                if (model.beanUid == bean.beanUid) {
                    [NSObject showHudTipStr:@"你已经添加该生豆了"];
                    return;
                }
            }
            [_beanArray addObject:bean];
            [self.reportEditTable reloadData];
        };
        [self.navigationController pushViewController:VC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            return 50/HScale;
        }
            break;
            
        case 1:
        {
            return 256/HScale;
        }
            break;
            
        case 2:
        {
            if (indexPath.row == _beanArray.count) {
                return 50/HScale;
            }else{
                return 70/HScale;
            }
        }
            break;
            
        case 3:
        {
            return 50/HScale;
        }
            break;
        
        default:
            break;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 22)];
    headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 22;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return NO;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        BeanModel *bean = _myNet.beanArray[indexPath.row];
//        [_myNet.beanArray removeObject:bean];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Actions
- (void)saveEdit{
    BOOL result = [[DataBase shareDataBase] updateReportWithReport:_reportModel WithBean:_beanArray];
    if (result) {
        [NSObject showHudTipStr:LocalString(@"修改成功")];
    }
}

@end
