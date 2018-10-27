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

@end

@implementation AddBeanTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LocalString(@"添加咖啡豆");
    
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
    //tableView.scrollEnabled = NO;
    //            if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
    //                [tableView setSeparatorInset:UIEdgeInsetsZero];
    //            }
    //            if ([tableView respondsToSelector:@selector(setLayoutMargins:)])  {
    //                [tableView setLayoutMargins:UIEdgeInsetsZero];
    //            }

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            {
                return 1 + _myNet.beanArray.count;
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
                if (indexPath.row == _myNet.beanArray.count) {
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
                    AddBeanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_bakeBean_add forIndexPath:indexPath];
                    if (cell == nil) {
                        cell = [[AddBeanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_bakeBean_add];
                    }
                    BeanModel *bean = _myNet.beanArray[indexPath.row];
                    cell.beanName.text = bean.name;
                    cell.TFBlock = ^(NSString *text) {
                        DataBase *db = [DataBase shareDataBase];
                        if ([db.setting.weightUnit isEqualToString:@"kg"]) {
                            bean.weight = [text floatValue];
                        }else if ([db.setting.weightUnit isEqualToString:@"g"]){
                            bean.weight = [text floatValue] / 1000.f;
                        }else if ([db.setting.weightUnit isEqualToString:@"lb"]){
                            bean.weight = [text floatValue] / 2.2046f;
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
            BeanViewController_bakeAdd *bakeAdd = [[BeanViewController_bakeAdd alloc] init];
            [self.navigationController pushViewController:bakeAdd animated:YES];
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
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BeanModel *bean = _myNet.beanArray[indexPath.row];
        [_myNet.beanArray removeObject:bean];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
