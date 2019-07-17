//
//  AddBeanTableController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/22.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "AddBeanTableController.h"
#import "referCurveCell.h"
#import "CurveInfoCell_add.h"
#import "AddBeanTableViewCell.h"
#import "BeanModel.h"
#import "BeanViewController_bakeAdd.h"
#import "ReportModel.h"
#import "CurveController_bakeRela.h"

NSString *const CellIdentifier_bakeBean_add = @"CellID_bakeBean_add";
NSString *const CellIdentifier_selectBean = @"CellID_selectBean";
NSString *const CellIdentifier_referCurve = @"CellID_referCurve";
NSString *const CellIdentifier_curveInfo = @"CellID_curveInfo_add";

@interface AddBeanTableController ()

@property (nonatomic, strong) NetWork *myNet;
@property (nonatomic, strong) NSMutableArray *beanArray;

@end

@implementation AddBeanTableController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.beanArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNavItem];
    
    [self.tableView registerClass:[AddBeanTableViewCell class] forCellReuseIdentifier:CellIdentifier_bakeBean_add];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier_selectBean];
    [self.tableView registerClass:[referCurveCell class] forCellReuseIdentifier:CellIdentifier_referCurve];
    [self.tableView registerClass:[CurveInfoCell_add class] forCellReuseIdentifier:CellIdentifier_curveInfo];
    self.tableView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1];
    self.tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];

    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.tableFooterView = [[UIView alloc] init];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
    _myNet = [NetWork shareNetWork];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

#pragma mark - private methods
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"添加咖啡豆");
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 32, 23);
    [leftButton setTitle:LocalString(@"取消") forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
    leftButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [leftButton addTarget:self action:@selector(cancelAddBean) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 32, 23);
    [rightButton setTitle:LocalString(@"确定") forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
    rightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [rightButton addTarget:self action:@selector(saveAddBean) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)cancelAddBean{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveAddBean{
    NSRange range = NSMakeRange(0, self.beanArray.count);
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
    [_myNet.beanArray insertObjects:self.beanArray atIndexes:set];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            {
                return 1 + _myNet.beanArray.count + self.beanArray.count;
            }
            break;
            
        case 1:
            {
                return _myNet.isCurveOn?2:1;
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
                if (indexPath.row == (_myNet.beanArray.count+_beanArray.count)) {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_selectBean forIndexPath:indexPath];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_selectBean];
                    }
                    cell.textLabel.text = LocalString(@"选择咖啡豆");
                    cell.textLabel.textColor = [UIColor colorWithHexString:@"222222"];
                    cell.textLabel.font = [UIFont systemFontOfSize:16.f];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }else{
//                    AddBeanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_bakeBean_add forIndexPath:indexPath];
//                    if (cell == nil) {
//                        cell = [[AddBeanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_bakeBean_add];
//                    }
                    AddBeanTableViewCell *cell = [[AddBeanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_bakeBean_add];

                    BeanModel *bean;
                    if (indexPath.row >= self.beanArray.count) {
                        bean = _myNet.beanArray[indexPath.row-self.beanArray.count];
                    }else{
                        bean = self.beanArray[indexPath.row];
                    }
                    cell.beanName.text = bean.name;
                    if (bean.weight > 0) {
                        cell.weightTF.text = [NSString stringWithFormat:@"%.1f",[NSString diffWeightUnitStringWithWeight:bean.weight]];
                    }
                    if (indexPath.row == 0) {
                        [cell.weightTF becomeFirstResponder];
                    }
                    __block typeof(cell) blockCell = cell;
                    cell.TFBlock = ^(NSString *text) {
                        float weight = [text floatValue];
                    
                        DataBase *db = [DataBase shareDataBase];
                        //把当前单位的重量转为kg
                        if ([db.setting.weightUnit isEqualToString:@"g"]){
                            weight = weight / 1000.f;
                        }else if ([db.setting.weightUnit isEqualToString:@"lb"]){
                            weight = weight / 2.2046f;
                        }else{
                            //设置为kg
                            weight = weight;
                        }
                        
                        if (weight > bean.stock) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [NSObject showHudTipStrAtWindowMid:LocalString(@"输入值超过库存量,以库存数显示")];
                            });
                            weight = bean.stock;
                            bean.weight = weight;
                            
                            //把重量转为当前单位
                            if ([db.setting.weightUnit isEqualToString:@"g"]){
                                weight = weight * 1000.f;
                            }else if ([db.setting.weightUnit isEqualToString:@"lb"]){
                                weight = weight * 2.2046f;
                            }else{
                                //设置为kg
                                weight = weight;
                            }
                            blockCell.weightTF.text = [NSString stringWithFormat:@"%.1f",weight];
                        }else{
                            weight = [text floatValue];
                            bean.weight = weight;
                        }
                    };
                    return cell;
                }
            }
            break;
            
        case 1:
            {
                if (indexPath.row == 0) {
                    referCurveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_referCurve forIndexPath:indexPath];
                    if (cell == nil) {
                        cell = [[referCurveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_referCurve];
                    }
                    cell.curveSwitch.on = _myNet.isCurveOn;
                    cell.curveBlock = ^(BOOL isOn) {
                        if (isOn) {
                            _myNet.isCurveOn = YES;
                        }else{
                            _myNet.isCurveOn = NO;
                        }
                        [self.tableView reloadData];
                    };
                    return cell;
                }else{
                    CurveInfoCell_add *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_curveInfo forIndexPath:indexPath];
                    if (cell == nil) {
                        cell = [[CurveInfoCell_add alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_curveInfo];
                    }
                    if (_myNet.relaCurve) {
                        cell.curveLabel.text = [NSString stringWithFormat:@"%@·%@",_myNet.relaCurve.curveName,_myNet.relaCurve.deviceName];
                    }
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                
            }
            break;
            
        default:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_selectBean forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_selectBean];
            }
            return cell;
        }
            break;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == (_myNet.beanArray.count + self.beanArray.count)) {
                BeanViewController_bakeAdd *bakeAdd = [[BeanViewController_bakeAdd alloc] init];
                bakeAdd.popBlock = ^(BeanModel *bean) {
                    [self.beanArray insertObject:bean atIndex:0];
                };
                bakeAdd.beanArray = self.beanArray;
                [self.navigationController pushViewController:bakeAdd animated:YES];
            }
        }
            break;
            
        case 1:
        {
            if (indexPath.row == 1 && _myNet.isCurveOn) {
                CurveController_bakeRela *curveAdd = [[CurveController_bakeRela alloc] init];
                [self.navigationController pushViewController:curveAdd animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            {
                return 50;
            }
            break;
            
        case 1:
            {
                return 50;
            }
            break;
            
        default:
            break;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 22)];
    headerView.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 22;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row != (_myNet.beanArray.count + self.beanArray.count)) {
        return YES;
    }else{
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row >= self.beanArray.count) {
            BeanModel *bean = _myNet.beanArray[indexPath.row-self.beanArray.count];
            [_myNet.beanArray removeObject:bean];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        }else{
            BeanModel *bean = self.beanArray[indexPath.row];
            [self.beanArray removeObject:bean];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

@end
