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
#import "LogOutCell.h"
#import "FastEventViewController.h"
#import "CurveColorViewController.h"
#import "SettingModel.h"
#import "YPickerAlertController.h"
#import <Charts/Charts-Swift.h>
#import "LoginViewController.h"
#import "YTFAlertController.h"

NSString *const CellIdentifier_GeneralSub = @"CellID_GeneralSub";
NSString *const CellIdentifier_GeneralLR = @"CellID_GeneralLR";
NSString *const CellIdentifier_GeneralLogout = @"CellID_GeneralLogout";

@interface GeneralViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *generalTable;
@property (nonatomic, strong) DataBase *myData;

@end

@implementation GeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    self.navigationItem.title = LocalString(@"通用设置");
    
    _myData = [DataBase shareDataBase];
    _generalTable = [self generalTable];
    
    
//    if (_myData.setting.isInit) {
//        [self getSettingByApi];
//    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
    [[NetWork shareNetWork] inquireAlertTemp];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAlertTemp) name:@"getAlertTemp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAlertTempSucc) name:@"setAlertTempSucc" object:nil];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getAlertTemp" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"setAlertTempSucc" object:nil];
}

#pragma mark - notification
- (void)getAlertTemp{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.generalTable reloadData];
    });
}

- (void)setAlertTempSucc{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject showHudTipStr:LocalString(@"设置成功")];
        [[NetWork shareNetWork] inquireAlertTemp];
    });
}

#pragma mark - Lazyload
-(UITableView *)generalTable{
    if (!_generalTable) {
        _generalTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            [tableView registerClass:[SubtitileCell class] forCellReuseIdentifier:CellIdentifier_GeneralSub];
            [tableView registerClass:[LlabelRlabelCell class] forCellReuseIdentifier:CellIdentifier_GeneralLR];
            [tableView registerClass:[LogOutCell class] forCellReuseIdentifier:CellIdentifier_GeneralLogout];

            [self.view addSubview:tableView];
            
            //tableView.scrollEnabled = NO;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _generalTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else if (section == 1){
        return 3;
    }else if (section == 2){
        return 2;
    }else if (section == 3){
        return 1;
        //return 3;曲线颜色好像不需要了
    }else if (section == 4){
        return 1;
    }else if (section == 5){
        return 1;
    }else if (section == 6){
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
            cell.rightLabel.text = _myData.setting.weightUnit;
            return cell;
        }else if (indexPath.row == 1){
            cell.leftLabel.text = LocalString(@"温度单位");
            cell.rightLabel.text = _myData.setting.tempUnit;
            return cell;
        }else{
            cell.leftLabel.text = LocalString(@"烘焙色度参考标准");
            cell.rightLabel.text = _myData.setting.bakeChromaReferStandard;
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
            cell.rightLabel.text = [NSString stringWithFormat:@"%ld分钟",_myData.setting.timeAxis];
            return cell;
        }else{
            cell.leftLabel.text = LocalString(@"温度轴");
            cell.rightLabel.text = [NSString stringWithFormat:@"%d%@",(int)[NSString diffTempUnitStringWithTemp:_myData.setting.tempAxis],_myData.setting.tempUnit];
            return cell;
        }
    }else if (indexPath.section == 3){
        
        LlabelRlabelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_GeneralLR];
        cell.leftLabel.font = [UIFont systemFontOfSize:15.0];
        cell.rightLabel.font = [UIFont systemFontOfSize:15.f];
        if (cell == nil) {
            cell = [[LlabelRlabelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_GeneralLR];
        }
        cell.leftLabel.text = LocalString(@"升温率平滑");
        cell.rightLabel.text = [NSString stringWithFormat:@"%ld",_myData.setting.tempRateSmooth];
        return cell;
    }else if (indexPath.section == 4){
        LlabelRlabelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_GeneralLR];
        cell.leftLabel.font = [UIFont systemFontOfSize:15.0];
        cell.rightLabel.font = [UIFont systemFontOfSize:15.f];
        if (cell == nil) {
            cell = [[LlabelRlabelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_GeneralLR];
        }
        cell.leftLabel.text = LocalString(@"语言");
        cell.rightLabel.text = _myData.setting.language;
        return cell;
    }else if (indexPath.section == 5){
        LlabelRlabelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_GeneralLR];
        cell.leftLabel.font = [UIFont systemFontOfSize:15.0];
        cell.rightLabel.font = [UIFont systemFontOfSize:15.f];
        if (cell == nil) {
            cell = [[LlabelRlabelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_GeneralLR];
        }
        cell.leftLabel.text = LocalString(@"报警温度");
        cell.rightLabel.text = [NSString stringWithFormat:@"%.1f%@",[NetWork shareNetWork].alertTemp,_myData.setting.tempUnit];
        return cell;
    }else{
        LogOutCell *cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_GeneralLogout];
        if (cell1 == nil) {
            cell1 = [[LogOutCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_GeneralLogout];
        }
        return cell1;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        FastEventViewController *eventVC = [[FastEventViewController alloc] init];
        [self.navigationController pushViewController:eventVC animated:YES];
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self showSheetWithTitle:LocalString(@"请选择重量单位") actions:@[@"g",@"kg",@"lb"] indexpath:indexPath];
        }
        if (indexPath.row == 1) {
            [self showSheetWithTitle:LocalString(@"请选择温度单位") actions:@[@"℃",@"℉"] indexpath:indexPath];
        }
        if (indexPath.row == 2) {
            [self showSheetWithTitle:LocalString(@"请选择烘焙色度参考标准") actions:@[@"agron",@"colortrack",@"lighttell",@"tonino",@"javalytics"] indexpath:indexPath];
        }
    }
    if (indexPath.section == 4) {
        [self showSheetWithTitle:LocalString(@"请选择语言") actions:@[@"中文",@"英文"] indexpath:indexPath];
    }
    if (indexPath.section == 5) {
        if ([[NetWork shareNetWork].mySocket isDisconnected]) {
            [self showNoConnectDevice];
            return;
        }
        YTFAlertController *alert = [[YTFAlertController alloc] init];
        alert.lBlock = ^{
        };
        alert.rBlock = ^(NSString * _Nullable text) {
            [[NetWork shareNetWork] setNewAlertTemp:@([text floatValue])];
        };
        alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:alert animated:NO completion:^{
            alert.textField.keyboardType = UIKeyboardTypeDecimalPad;
            alert.titleLabel.text = LocalString(@"设置报警温度");
            alert.textField.placeholder = LocalString(@"请输入报警温度");
            [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
            [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
        }];
    }
    if (indexPath.section == 6) {
        YAlertViewController *alert = [[YAlertViewController alloc] init];
        alert.lBlock = ^{
            
        };
        alert.rBlock = ^{
            //清除单例
            [NetWork destroyInstance];
            
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"passWord"];
            [userDefaults synchronize];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
        };
        alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:alert animated:NO completion:^{
            alert.WScale_alert = WScale;
            alert.HScale_alert = HScale;
            [alert showView];
            alert.titleLabel.text = LocalString(@"提示");
            alert.messageLabel.text = LocalString(@"确定退出登录吗？");
            [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
            [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
        }];
        
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < 30; i++) {
                [array addObject:[NSNumber numberWithInt:i]];
            }
            YPickerAlertController *VC = [[YPickerAlertController alloc] init];
            VC.pickerArr = [array mutableCopy];
            VC.index = _myData.setting.timeAxis;
            VC.pickerBlock = ^(NSInteger picker) {
                _myData.setting.timeAxis = picker;
                [_generalTable reloadData];
                [self updateSetting];
            };
            VC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            VC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:VC animated:YES completion:nil];
            VC.titleLabel.text = LocalString(@"选择时间轴(min)");
        }else{
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < 20; i++) {
                [array addObject:[NSNumber numberWithInt:[NSString diffTempUnitStringWithTemp:i*50]]];
            }
            YPickerAlertController *VC = [[YPickerAlertController alloc] init];
            VC.pickerArr = [array mutableCopy];
            VC.index = _myData.setting.tempAxis/50;
            VC.pickerBlock = ^(NSInteger picker) {
                _myData.setting.tempAxis = picker*50;
                [_generalTable reloadData];
                [self updateSetting];
            };
            VC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            VC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:VC animated:YES completion:nil];
            VC.titleLabel.text = [NSString stringWithFormat:@"%@(%@)",LocalString(@"选择温度轴"),_myData.setting.tempUnit];
        }
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < 30; i++) {
                [array addObject:[NSNumber numberWithInt:i]];
            }
            YPickerAlertController *VC = [[YPickerAlertController alloc] init];
            VC.pickerArr = [array mutableCopy];
            VC.index = _myData.setting.tempRateSmooth;
            VC.pickerBlock = ^(NSInteger picker) {
                _myData.setting.tempRateSmooth = picker;
                [_generalTable reloadData];
                [self updateSetting];
            };
            VC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            VC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:VC animated:YES completion:nil];
            VC.titleLabel.text = LocalString(@"升温速率平滑系数");
        }
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
    return 15;//section头部高度
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
    return 0;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - Actions
- (void)showSheetWithTitle:(NSString *)title actions:(NSArray *)actions indexpath:(NSIndexPath *)indexpath{
    //显示弹出框列表选择
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (int i = 0; i < actions.count; i++) {
        NSString *actionTitle = actions[i];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            //响应事件
            NSLog(@"action = %@", action);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (indexpath.section == 1) {
                    if (indexpath.row == 0) {
                        _myData.setting.weightUnit = actionTitle;
                    }else if (indexpath.row == 1){
                        if (![_myData.setting.tempUnit isEqualToString:actionTitle]) {
                            _myData.setting.tempUnit = actionTitle;
                            //将曲线数据转化单位
                            [self transformValuesWithDifferentTempUnit];
                        }
                        
                    }else if (indexpath.row == 2){
                        _myData.setting.bakeChromaReferStandard = actionTitle;
                    }
                }else if (indexpath.section == 4){
                    _myData.setting.language = actionTitle;
                }
                [_generalTable reloadData];
                [self updateSetting];
            });
        }];
        [alertAction setValue:[UIColor colorWithHexString:@"333333"] forKey:@"_titleTextColor"];
        if ([title isEqualToString:LocalString(@"请选择烘焙色度参考标准")]) {
            if ([actionTitle isEqualToString:[DataBase shareDataBase].setting.bakeChromaReferStandard]) {
                [alertAction setValue:[UIColor colorWithHexString:@"333333"] forKey:@"_titleTextColor"];
            }else{
                [alertAction setValue:[UIColor colorWithHexString:@"999999"] forKey:@"_titleTextColor"];
            }
        }
        [alert addAction:alertAction];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        //响应事件
        NSLog(@"action = %@", action);

    }];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)transformValuesWithDifferentTempUnit{
    NetWork *net = [NetWork shareNetWork];
    for (int i = 0; i < net.yVals_Out.count; i++) {
        ChartDataEntry *entry = net.yVals_Out[i];
        entry.y = [self transformTempUnitStringWithTemp:entry.y];
    }
    for (int i = 0; i < net.yVals_In.count; i++) {
        ChartDataEntry *entry = net.yVals_In[i];
        entry.y = [self transformTempUnitStringWithTemp:entry.y];
    }
    for (int i = 0; i < net.yVals_Bean.count; i++) {
        ChartDataEntry *entry = net.yVals_Bean[i];
        entry.y = [self transformTempUnitStringWithTemp:entry.y];
    }
    for (int i = 0; i < net.yVals_Environment.count; i++) {
        ChartDataEntry *entry = net.yVals_Environment[i];
        entry.y = [self transformTempUnitStringWithTemp:entry.y];
    }
    for (int i = 0; i < net.yVals_Diff.count; i++) {
        ChartDataEntry *entry = net.yVals_Diff[i];
        entry.y = [self transformTempUnitStringWithTemp:entry.y];
    }
}

//在更改温度单位时数据要根据单位转换为准确的值
- (double)transformTempUnitStringWithTemp:(double)temp{
    DataBase *db = [DataBase shareDataBase];
    double caltemp = temp;
    if ([db.setting.tempUnit isEqualToString:@"℃"]) {
        caltemp = (temp - 32)*5/9;
    }else if ([db.setting.tempUnit isEqualToString:@"℉"]){
        caltemp = temp*9/5 + 32;
    }
    return caltemp;
}

- (void)showNoConnectDevice{
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    alert.rBlock = ^{
        [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    };
    alert.lBlock = ^{
        [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    };
    [self presentViewController:alert animated:NO completion:^{
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
        alert.WScale_alert = WScale;
        alert.HScale_alert = HScale;
        [alert showView];
        alert.titleLabel.text = LocalString(@"提示");
        alert.messageLabel.text = LocalString(@"请先连接咖啡机设备");
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
    }];
}

#pragma mark - DataSource
- (void)updateSetting{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 4.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/setting"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"weightUnit":_myData.setting.weightUnit,@"tempUnit":_myData.setting.tempUnit,@"roasterChroma":_myData.setting.bakeChromaReferStandard,@"timer":[NSNumber numberWithInteger:_myData.setting.timeAxis],@"temp":[NSNumber numberWithInteger:_myData.setting.tempAxis],@"tempCurveSmooth":[NSNumber numberWithInteger:_myData.setting.tempCurveSmooth],@"tempRateSmooth":[NSNumber numberWithInteger:_myData.setting.tempRateSmooth],@"language":_myData.setting.language};
    
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [_myData deleteSetting];//删除之前可能存在的设置
            if (![_myData insertSetting]) {
                [NSObject showHudTipStr:@"本地更新设置失败"];
            }
        }else{
            [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == -1001) {
            [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
        }else{
            [NSObject showHudTipStr:LocalString(@"更新设置失败")];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}
@end
