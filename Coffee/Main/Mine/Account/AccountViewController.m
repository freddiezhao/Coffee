//
//  AccountViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/19.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "AccountViewController.h"
#import "LlabelRlabelCell.h"
#import "UsernameViewController.h"
#import "UserPasswordController.h"
#import "UserPhoneController.h"

NSString *const CellIdentifier_Accountll = @"CellID_Accountll";

@interface AccountViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *accountTableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *headButton;
@property (nonatomic, strong) DataBase *database;

@end

@implementation AccountViewController
static float HEIGHT_CELL = 50.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavItem];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;

    _accountTableView = [self accountTableView];
    
    _database = [DataBase shareDataBase];
    _headerView = [self headerView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    if (_accountTableView) {
        [_accountTableView reloadData];
    }
}

#pragma mark - Lazyload
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"账户管理");
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"保存") style:UIBarButtonItemStylePlain target:self action:@selector(saveEdit)];
    [rightBar setTintColor:[UIColor colorWithHexString:@"4778CC"]];
    [rightBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16.f], NSFontAttributeName,nil] forState:(UIControlStateNormal)];
    
    //self.navigationItem.rightBarButtonItem = rightBar;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 130/HScale)];
        _headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
        [self.view addSubview:_headerView];
        
        _headButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_headButton setImage:[UIImage imageNamed:@"ic_default_headportrait"] forState:UIControlStateNormal];
        [_headButton addTarget:self action:@selector(showSheet:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:_headButton];
        [_headButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(70/WScale, 70/WScale));
            make.centerX.equalTo(self.headerView.mas_centerX);
            make.top.equalTo(self.headerView.mas_top).offset(30/HScale);
        }];
        _headButton.layer.cornerRadius = 35.f/HScale;
        _headButton.imageView.layer.cornerRadius = _headButton.bounds.size.height/2.0;
        
        UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cameraBtn setImage:[UIImage imageNamed:@"ic_account_pic"] forState:UIControlStateNormal];
        [_headerView addSubview:cameraBtn];
        [_headerView bringSubviewToFront:cameraBtn];
        [cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(24/WScale, 24/WScale));
            make.right.equalTo(self.headButton.mas_right);
            make.bottom.equalTo(self.headButton.mas_bottom);
        }];
    }
    return _headerView;
}

- (UITableView *)accountTableView{
    if (!_accountTableView) {
        _accountTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 130/HScale, ScreenWidth, ScreenHeight - 64 - 130/HScale)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            [tableView registerClass:[LlabelRlabelCell class] forCellReuseIdentifier:CellIdentifier_Accountll];
            
            [self.view addSubview:tableView];
            
            tableView.scrollEnabled = NO;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _accountTableView;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
            
        case 1:
            return 2;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LlabelRlabelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Accountll];
    if (cell == nil) {
        cell = [[LlabelRlabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_Accountll];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        cell.leftLabel.text = LocalString(@"昵称");
        cell.rightLabel.text = _database.userName;
        return cell;
    }else{
        if (indexPath.row == 0){
            cell.leftLabel.text = LocalString(@"修改登录密码");
            return cell;
        }else if (indexPath.row == 1){
            cell.leftLabel.text = LocalString(@"修改手机号码");
            cell.rightLabel.text = [[DataBase shareDataBase].mobile stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
            return cell;
        }else{
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        UsernameViewController *userNameVC = [[UsernameViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:userNameVC];
        [self presentViewController:nav animated:YES completion:nil];
    }else{
        if (indexPath.row == 0){
            UserPasswordController *pwVC = [[UserPasswordController alloc] init];
            [self.navigationController pushViewController:pwVC animated:YES];
        }else if (indexPath.row == 1){
            UserPhoneController *phoneVC = [[UserPhoneController alloc] init];
            [self.navigationController pushViewController:phoneVC animated:YES];
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
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

#pragma mark - ImagePicker
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [_headButton setImage:image forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Actions
- (void)saveEdit{
    
}


- (void)showSheet:(UIButton *)sender {
    //显示弹出框列表选择
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择您的照片"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             NSLog(@"action = %@", action);
                                                         }];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             NSLog(@"action = %@", action);
                                                         }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           //响应事件
                                                           NSLog(@"action = %@", action);
                                                           UIImagePickerController *ipcVC = [[UIImagePickerController alloc] init];
                                                           [ipcVC setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                                                           [ipcVC setDelegate:self];
                                                           [self presentViewController:ipcVC animated:YES completion:^{
                                                               
                                                           }];
                                                       }];
    [alert addAction:cameraAction];
    [alert addAction:albumAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
