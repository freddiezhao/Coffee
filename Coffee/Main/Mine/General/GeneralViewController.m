//
//  GeneralViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "GeneralViewController.h"
#import "LlabelRlabelCell.h"
#import "SubtitileCell.h"

NSString *const CellIdentifier_GeneralSub = @"CellID_GeneralSub";
NSString *const CellIdentifier_GeneralLR = @"CellID_GeneralLR";

@interface GeneralViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *generalTable;
@property (nonatomic, strong) SettingModel *settingModel;

@end

@implementation GeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _generalTable = [self generalTable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
    _settingModel = [[DataBase shareDataBase] selectSetting];
}

#pragma mark - Lazyload
-(UITableView *)generalTable{
    if (!_generalTable) {
        _generalTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[SubtitileCell class] forCellReuseIdentifier:CellIdentifier_GeneralSub];
            [tableView registerClass:[LlabelRlabelCell class] forCellReuseIdentifier:CellIdentifier_GeneralLR];
            
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
    return _generalTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return 3;
    }else if (section == 2){
        return 2;
    }else if (section == 3){
        return 3;
    }else if (section == 4){
        return 1;
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        
        SubtitileCell *subCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_GeneralSub];
        if (subCell == nil) {
            subCell = [[SubtitileCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_GeneralSub];
        }
        subCell.titleLabel.text = LocalString(@"快速事件");
        subCell.subtitleLabel.text = LocalString(@"标记时使用的标签");
        subCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return subCell;
        
    }else if (indexPath.section == 1){
        
        LlabelRlabelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_GeneralLR];
        cell.leftLabel.font = [UIFont systemFontOfSize:15.0];
        if (cell == nil) {
            cell = [[LlabelRlabelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_GeneralLR];
        }
        
        if (indexPath.row == 0) {
            cell.leftLabel.text = LocalString(@"重量单位");
            return cell;
        }else if (indexPath.row == 1){
            cell.leftLabel.text = LocalString(@"温度单位");
            return cell;
        }else{
            cell.leftLabel.text = LocalString(@"烘焙色度参考标准");
            return cell;
        }
        
    }else if (indexPath.section == 2){
        
        LlabelRlabelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_GeneralLR];
        cell.leftLabel.font = [UIFont systemFontOfSize:15.0];
        if (cell == nil) {
            cell = [[LlabelRlabelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_GeneralLR];
        }
        if (indexPath.row == 0) {
            cell.leftLabel.text = LocalString(@"时间轴");
            return cell;
        }else{
            cell.leftLabel.text = LocalString(@"温度轴");
            return cell;
        }
    }else if (indexPath.section == 3){
        
        LlabelRlabelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_GeneralLR];
        cell.leftLabel.font = [UIFont systemFontOfSize:15.0];
        if (cell == nil) {
            cell = [[LlabelRlabelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_GeneralLR];
        }
        if (indexPath.row == 0) {
            cell.leftLabel.text = LocalString(@"温度曲线平滑");
            return cell;
        }else if (indexPath.row == 1){
            cell.leftLabel.text = LocalString(@"升温率平滑");
            return cell;
        }else{
            cell.leftLabel.text = LocalString(@"曲线颜色");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }else{
        
        LlabelRlabelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_GeneralLR];
        cell.leftLabel.font = [UIFont systemFontOfSize:15.0];
        if (cell == nil) {
            cell = [[LlabelRlabelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_GeneralLR];
        }
        cell.leftLabel.text = LocalString(@"语言");
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return cellHeight * 1.5;
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
    return 20;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


@end
