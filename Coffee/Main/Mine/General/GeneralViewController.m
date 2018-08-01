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
#import "FastEventViewController.h"
#import "CurveColorViewController.h"
#import "SettingModel.h"

NSString *const CellIdentifier_GeneralSub = @"CellID_GeneralSub";
NSString *const CellIdentifier_GeneralLR = @"CellID_GeneralLR";

@interface GeneralViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *generalTable;
@property (nonatomic, strong) DataBase *myData;

@end

@implementation GeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _generalTable = [self generalTable];
    _myData = [DataBase shareDataBase];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
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
        cell.rightLabel.font = [UIFont systemFontOfSize:15.f];
        if (cell == nil) {
            cell = [[LlabelRlabelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_GeneralLR];
        }
        
        if (indexPath.row == 0) {
            cell.leftLabel.text = LocalString(@"重量单位");
            if (!_myData.setting.weightUnit) {
                cell.rightLabel.text = @"g";
            }else{
                cell.rightLabel.text = _myData.setting.weightUnit;
            }
            return cell;
        }else if (indexPath.row == 1){
            cell.leftLabel.text = LocalString(@"温度单位");
            if (!_myData.setting.tempUnit) {
                cell.rightLabel.text = @"℃";
            }else{
                cell.rightLabel.text = _myData.setting.tempUnit;
            }
            return cell;
        }else{
            cell.leftLabel.text = LocalString(@"烘焙色度参考标准");
            if (!_myData.setting.bakeChromaReferStandard) {
                cell.rightLabel.text = @"argon";
            }else{
                cell.rightLabel.text = _myData.setting.bakeChromaReferStandard;
            }
            return cell;
        }
        
    }else if (indexPath.section == 2){
        
        LlabelRlabelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_GeneralLR];
        cell.leftLabel.font = [UIFont systemFontOfSize:15.0];
        cell.rightLabel.font = [UIFont systemFontOfSize:15.f];
        if (cell == nil) {
            cell = [[LlabelRlabelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_GeneralLR];
        }
        if (indexPath.row == 0) {
            cell.leftLabel.text = LocalString(@"时间轴");
            if (!_myData.setting.timeAxis) {
                cell.rightLabel.text = @"10分钟";
            }else{
                cell.rightLabel.text = _myData.setting.timeAxis;
            }
            return cell;
        }else{
            cell.leftLabel.text = LocalString(@"温度轴");
            if (!_myData.setting.tempAxis) {
                cell.rightLabel.text = @"300℃";
            }else{
                cell.rightLabel.text = _myData.setting.tempAxis;
            }
            return cell;
        }
    }else if (indexPath.section == 3){
        
        LlabelRlabelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_GeneralLR];
        cell.leftLabel.font = [UIFont systemFontOfSize:15.0];
        cell.rightLabel.font = [UIFont systemFontOfSize:15.f];
        if (cell == nil) {
            cell = [[LlabelRlabelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_GeneralLR];
        }
        if (indexPath.row == 0) {
            cell.leftLabel.text = LocalString(@"温度曲线平滑");
            if (!_myData.setting.tempCurveSmooth) {
                cell.rightLabel.text = @"5";
            }else{
                cell.rightLabel.text = _myData.setting.tempCurveSmooth;
            }
            return cell;
        }else if (indexPath.row == 1){
            cell.leftLabel.text = LocalString(@"升温率平滑");
            if (!_myData.setting.tempRateSmooth) {
                cell.rightLabel.text = @"6";
            }else{
                cell.rightLabel.text = _myData.setting.tempRateSmooth;
            }
            return cell;
        }else{
            cell.leftLabel.text = LocalString(@"曲线颜色");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }else{
        
        LlabelRlabelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_GeneralLR];
        cell.leftLabel.font = [UIFont systemFontOfSize:15.0];
        cell.rightLabel.font = [UIFont systemFontOfSize:15.f];
        if (cell == nil) {
            cell = [[LlabelRlabelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_GeneralLR];
        }
        cell.leftLabel.text = LocalString(@"语言");
        if (!_myData.setting.language) {
            cell.rightLabel.text = @"中文";
        }else{
            cell.rightLabel.text = _myData.setting.language;
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        FastEventViewController *eventVC = [[FastEventViewController alloc] init];
        [self.navigationController pushViewController:eventVC animated:YES];
    }else if (indexPath.section == 3 && indexPath.row == 2){
        CurveColorViewController *ccVC = [[CurveColorViewController alloc] init];
        [self.navigationController pushViewController:ccVC animated:YES];
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
