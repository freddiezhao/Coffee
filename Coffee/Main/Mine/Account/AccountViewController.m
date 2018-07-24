//
//  AccountViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/19.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "AccountViewController.h"
#import "LlabelRlabelCell.h"
#import "LlabelRImageCell.h"
#import "UsernameViewController.h"
#import "PasswordViewController.h"

#define buttonHeight 44

NSString *const CellIdentifier_Accountll = @"CellID_Accountll";
NSString *const CellIdentifier_Accountlm = @"CellID_Accountlm";

@interface AccountViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *accountTableView;
@property (nonatomic, strong) UIImage *headImage;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) DataBase *database;

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LocalString(@"账号设置");
    
    _accountTableView = [self accountTableView];
    
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setTitle:LocalString(@"退出登录") forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logoutBtn setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.1];
    [logoutBtn setBackgroundColor:[UIColor redColor]];
    [logoutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutBtn];
    
    [logoutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(120, buttonHeight));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(_accountTableView.mas_bottom).offset(20);
    }];
    
    _database = [DataBase shareDataBase];
    _headImage = [UIImage imageNamed:@"ic_bake_bean"];
    _userName = _database.userName;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

#pragma mark - Lazyload
- (UITableView *)accountTableView{
    if (!_accountTableView) {
        _accountTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, cellHeight * 5)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[LlabelRlabelCell class] forCellReuseIdentifier:CellIdentifier_Accountll];
            [tableView registerClass:[LlabelRImageCell class] forCellReuseIdentifier:CellIdentifier_Accountlm];
            
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
    return _accountTableView;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row == 0) {
        LlabelRImageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Accountlm];
        if (cell == nil) {
            cell = [[LlabelRImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_Accountlm];
        }
        cell.leftLabel.text = LocalString(@"头像");
        cell.rightImage.image = _headImage;
        return cell;
    }else{
        LlabelRlabelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Accountll];
        if (cell == nil) {
            cell = [[LlabelRlabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_Accountll];
        }
        
        if (indexPath.row == 1){
            cell.leftLabel.text = LocalString(@"用户名");
            cell.rightLabel.text = _userName;
            return cell;
        }else if (indexPath.row == 2){
            cell.leftLabel.text = LocalString(@"手机");
            cell.rightLabel.text = LocalString(@"138****7276");
            return cell;
        }else{
            cell.leftLabel.text = LocalString(@"登陆密码");
            cell.rightLabel.text = LocalString(@"修改");
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        UIImagePickerController *ipcVC = [[UIImagePickerController alloc] init];
        [ipcVC setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [ipcVC setDelegate:self];
        [self presentViewController:ipcVC animated:YES completion:^{
            
        }];
    }else if (indexPath.row == 1){
        UsernameViewController *userNameVC = [[UsernameViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:userNameVC];
        [self presentViewController:nav animated:YES completion:nil];
    }else if (indexPath.row == 2){

    }else if (indexPath.row == 3){
        PasswordViewController *pwVc = [[UIStoryboard storyboardWithName:@"Password" bundle:nil] instantiateViewControllerWithIdentifier:@"PasswordViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pwVc];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
}

//section头部间距

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;//section头部高度
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

#pragma mark - ImagePicker
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _headImage = image;
    [_accountTableView reloadData];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Actions
- (void)logout{
    
}



@end
