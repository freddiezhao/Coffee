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
#import "MineNormalCell.h"
#import "AboutViewController.h"
#import "FeedbackViewController.h"
#import "UIButton+WebCache.h"
#import "DeviceViewController.h"
#import "QRCodeScanController.h"

NSString *const CellIdentifier_Mine = @"CellID_Mine";

@interface MineViewController ()

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *headButton;
@property (nonatomic, strong) UILabel *nickLabel;

@property (nonatomic, strong) UITableView *mineTableView;

@end

@implementation MineViewController
static float HEIGHT_CELL = 51.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    
    _headerView = [self headerView];
    _mineTableView = [self mineTableView];
    [self getUserInfoByApi];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    self.navigationController.navigationBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark - Lazyload
-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 210/HScale)];
        [self.view addSubview:_headerView];
        UIImageView *bgImg = [[UIImageView alloc] initWithFrame:_headerView.bounds];
        [bgImg setImage:[UIImage imageNamed:@"img_mine_bg"]];
        [_headerView addSubview:bgImg];
        [_headerView sendSubviewToBack:bgImg];

        UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [scanBtn setImage:[UIImage imageNamed:@"ic_nav_scan"] forState:UIControlStateNormal];
        [scanBtn addTarget:self action:@selector(scanAction) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:scanBtn];
        [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(22/WScale, 22/WScale));
            make.top.equalTo(self.headerView.mas_top).offset((15+20)/HScale);
            make.right.equalTo(self.headerView.mas_right).offset(-15/WScale);
        }];
        
        _headButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_headButton setImage:[UIImage imageNamed:@"ic_default_headportrait"] forState:UIControlStateNormal];
        [_headButton addTarget:self action:@selector(accountSetAction) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:_headButton];
        [_headButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(70/WScale, 70/WScale));
            make.centerX.equalTo(self.headerView.mas_centerX);
            make.top.equalTo(self.headerView.mas_top).offset(64/HScale);
        }];
        _headButton.layer.masksToBounds = YES;
        _headButton.layer.cornerRadius = 35.f/WScale;
        
        _nickLabel = [[UILabel alloc] init];
        _nickLabel.text = @"红鲤鱼与绿鲤鱼";
        _nickLabel.font = [UIFont systemFontOfSize:17.f];
        _nickLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        _nickLabel.textAlignment = NSTextAlignmentCenter;
        _nickLabel.adjustsFontSizeToFitWidth = YES;
        [_headerView addSubview:_nickLabel];
        [_nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(300/WScale, 24/HScale));
            make.centerX.equalTo(self.headerView.mas_centerX);
            make.top.equalTo(self.headButton.mas_bottom).offset(12/HScale);
        }];
    }
    return _headerView;
}

- (UITableView *)mineTableView{
    if (!_mineTableView) {
        _mineTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 210/HScale, ScreenWidth, ScreenHeight - (210 + 44)/HScale)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[MineNormalCell class] forCellReuseIdentifier:CellIdentifier_Mine];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];

            [self.view addSubview:tableView];
            
            tableView.scrollEnabled = NO;
            tableView;
        });
    }
    return _mineTableView;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 2;
    }else if (section == 1){
        return 3;
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MineNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Mine];
    if (cell == nil) {
        cell = [[MineNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_Mine];
    }
    
    if (indexPath.section == 0){
        if (indexPath.row == 0) {
            cell.normalLabel.text = LocalString(@"我的设备");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }else{
            cell.normalLabel.text = LocalString(@"通用设置");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.normalLabel.text = LocalString(@"我要反馈");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }else if (indexPath.row == 1){
            cell.normalLabel.text = LocalString(@"关于我们");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }else{
            cell.normalLabel.text = LocalString(@"检查更新");
            return cell;
        }
    }else{
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0){
        if (indexPath.row == 0) {
            DeviceViewController *deviceVC = [[DeviceViewController alloc] init];
            [self.navigationController pushViewController:deviceVC animated:YES];
        }else if (indexPath.row == 1) {
            GeneralViewController *generalVC = [[GeneralViewController alloc] init];
            [self.navigationController pushViewController:generalVC animated:YES];
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 1) {
            AboutViewController *aboutVC = [[AboutViewController alloc] init];
            [self.navigationController pushViewController:aboutVC animated:YES];
        }else if (indexPath.row == 0){
            FeedbackViewController *feedVC = [[FeedbackViewController alloc] init];
            [self.navigationController pushViewController:feedVC animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
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
    return 15;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - Actions
- (void)accountSetAction{
    AccountViewController *accountVC = [[AccountViewController alloc] init];
    [self.navigationController pushViewController:accountVC animated:YES];
}

- (void)scanAction{
    NSLog(@"sdsd");
    QRCodeScanController *scanVC = [[QRCodeScanController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

#pragma mark - API
- (void)getUserInfoByApi{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/user?userId=%@",[DataBase shareDataBase].userId];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSLog(@"success:%@",daetr);
            if ([responseDic objectForKey:@"data"]) {
                NSDictionary *beansDic = [responseDic objectForKey:@"data"];
                DataBase *db = [DataBase shareDataBase];
                db.userName = [beansDic objectForKey:@"userName"];
                db.mobile = [beansDic objectForKey:@"mobile"];
                db.imageUrl = [beansDic objectForKey:@"image"];
                _nickLabel.text = db.userName;
                [_headButton sd_setImageWithURL:[NSURL URLWithString:db.imageUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_default_headportrait"]];
            }
        }else{
            [NSObject showHudTipStr:LocalString(@"获取用户信息失败")];
            NSLog(@"获取用户信息失败");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        [NSObject showHudTipStr:LocalString(@"获取用户信息失败")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}

@end
