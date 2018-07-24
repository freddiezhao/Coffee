//
//  MineViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/19.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "MineViewController.h"
#import "AccountViewController.h"
#import "GeneralViewController.h"

NSString *const CellIdentifier_Mine = @"CellID_Mine";

@interface MineViewController ()

@property (nonatomic, strong) UITableView *mineTableView;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mineTableView = [self mineTableView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}

#pragma mark - Lazyload
- (UITableView *)mineTableView{
    if (!_mineTableView) {
        _mineTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier_Mine];

            [self.view addSubview:tableView];
            //tableView.estimatedRowHeight = 0;
            //tableView.estimatedSectionHeaderHeight = 0;
            //tableView.estimatedSectionFooterHeight = 0;
            
            tableView.scrollEnabled = NO;
            if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
                [tableView setSeparatorInset:UIEdgeInsetsZero];
            }
            if ([tableView respondsToSelector:@selector(setLayoutMargins:)])  {
                [tableView setLayoutMargins:UIEdgeInsetsZero];
            }
            tableView;
        });
    }
    return _mineTableView;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return 2;
    }else if (section == 2){
        return 3;
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Mine];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_Mine];
    }
    
    if (indexPath.section == 0) {
        cell.imageView.image = [UIImage imageNamed:@"ic_bake_bean"];
        cell.textLabel.text = @"My Name";
        return cell;
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.textLabel.text = LocalString(@"我的设备");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }else{
            cell.textLabel.text = LocalString(@"通用设置");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            cell.textLabel.text = LocalString(@"我要反馈");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }else if (indexPath.row == 1){
            cell.textLabel.text = LocalString(@"检查更新");
            return cell;
        }else{
            cell.textLabel.text = LocalString(@"关于我们");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }else{
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        AccountViewController *accountVC = [[AccountViewController alloc] init];
        [self.navigationController pushViewController:accountVC animated:YES];
    }else if (indexPath.section == 1){
        if (indexPath.row == 1) {
            GeneralViewController *generalVC = [[GeneralViewController alloc] init];
            [self.navigationController pushViewController:generalVC animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 90.f;
    }else{
        return cellHeight;
    }
}

//section头部间距

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;//section头部高度
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view ;
}
//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

@end
