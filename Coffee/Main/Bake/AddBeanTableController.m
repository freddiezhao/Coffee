//
//  AddBeanTableController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/22.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "AddBeanTableController.h"
#import "referCurveCell.h"

NSString *const CellIdentifier_selectBean = @"CellID_selectBean";
NSString *const CellIdentifier_referCurve = @"CellID_referCurve";

@interface AddBeanTableController ()

@end

@implementation AddBeanTableController
{
    BOOL curveOn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LocalString(@"添加咖啡豆");
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier_selectBean];
    [self.tableView registerClass:[referCurveCell class] forCellReuseIdentifier:CellIdentifier_referCurve];
    self.tableView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
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
                return curveOn?2:1;
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
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_selectBean forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_selectBean];
                }
                cell.textLabel.text = LocalString(@"选择咖啡豆");
                cell.textLabel.textColor = [UIColor colorWithHexString:@"222222"];
                cell.textLabel.font = [UIFont systemFontOfSize:16.f];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
            break;
            
        case 1:
            {
                referCurveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_referCurve forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[referCurveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_referCurve];
                }
                return cell;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
