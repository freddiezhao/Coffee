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
#import "LogOutCell.h"
#import "LoginViewController.h"
#import <AliyunOSSiOS/AliyunOSSiOS.h>
#import "UIButton+WebCache.h"
#import "UIImage+Compression.h"
#import <AVFoundation/AVCaptureDevice.h>


NSString *const CellIdentifier_Accountll = @"CellID_Accountll";
NSString *const CellIdentifier_AccountLogout = @"CellID_AccountLogout";

const BOOL isCutImageEnable = YES;

@interface AccountViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *cameraPicker;
@property (nonatomic, strong) UIImagePickerController *photoLibraryPicker;

@property (nonatomic, strong) UITableView *accountTableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *headButton;
@property (nonatomic, strong) DataBase *database;
@property (nonatomic, strong) OSSClient *client;

@end

@implementation AccountViewController{
    NSString *accessKeySecret;
    NSString *accessKeyId;
    NSString *expiration;
    NSString *securityToken;
}
static float HEIGHT_CELL = 50.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavItem];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;

    _accountTableView = [self accountTableView];
    
    _database = [DataBase shareDataBase];
    _headerView = [self headerView];
    
    [self getClientInfoByApi];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    if (_accountTableView) {
        [_accountTableView reloadData];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent{
    [super didMoveToParentViewController:parent];
    if (!parent && self.popBlock) {
        self.popBlock();
    }
}

#pragma mark - private methods
- (void)saveEdit{
    
}

static NSString *endpoint = @"oss-cn-hangzhou.aliyuncs.com";
- (void)initOOSClient{
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:accessKeyId secretKeyId:accessKeySecret securityToken:securityToken];
    _client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
}

- (void)putFile:(UIImage *)image{
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd-hh:mm:ss"];
    NSString *DateTime = [formatter stringFromDate:date];
    NSString *DateTimeReverse = [DateTime reversalString];
    
    put.bucketName = @"hb-coffee-image";
    put.objectKey = [NSString stringWithFormat:@"%@%@.png",[DataBase shareDataBase].userId,DateTimeReverse];
    NSLog(@"%@",put.objectKey);
    
    put.uploadingData = UIImageJPEGRepresentation(image, 1.f); // 直接上传NSData
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    
    OSSTask *putTask = [_client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"upload object success!");
            NSString *imageUrl = [NSString stringWithFormat:@"http://%@.%@/%@",put.bucketName,endpoint,put.objectKey];
            NSLog(@"%@",imageUrl);
            [self setUserImageWithImageUrl:imageUrl];
        } else {
            NSLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
    [putTask waitUntilFinished];
}

- (void)showSheet:(UIButton *)sender {
    //先创建好 不然调用的时候 第一次创建很慢 有2秒的延迟
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //判断相机可用
        [self setUpCameraPickControllerIsEdit:isCutImageEnable];
    }
    [self setUpPhotoPickControllerIsEdit:isCutImageEnable];

    //显示弹出框列表选择
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalString(@"请选择您的照片") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LocalString(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        //响应事件
        NSLog(@"action = %@", action);
    }];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:LocalString(@"拍照") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        //响应事件
        NSLog(@"action = %@", action);
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {

            if (granted) {
                [self presentViewController:self.cameraPicker animated:YES completion:nil];
            }
            else {
                UIAlertController * noticeAlertController = [UIAlertController alertControllerWithTitle:@"未开启相机权限，请到设置界面开启" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"现在就去" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    //跳转到设置界面
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                        
                    }];
                }];
                
                [noticeAlertController addAction:cancelAction];
                [noticeAlertController addAction:okAction];
                [self presentViewController:noticeAlertController animated:YES completion:^{
                    
                }];
            }
        }];
        
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:LocalString(@"从相册选择") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        //响应事件
        NSLog(@"action = %@", action);
        [self presentViewController:self.photoLibraryPicker animated:YES completion:^{
            
        }];
    }];
    [alert addAction:cameraAction];
    [alert addAction:albumAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - api methods
- (void)getClientInfoByApi{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:10011/app/sts"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if ([[responseDic objectForKey:@"statusCode"] intValue] == 200) {
            NSLog(@"success:%@",daetr);
            accessKeySecret = [responseDic objectForKey:@"accessKeySecret"];
            accessKeyId = [responseDic objectForKey:@"accessKeyId"];
            expiration = [responseDic objectForKey:@"expiration"];
            securityToken = [responseDic objectForKey:@"securityToken"];
            [self initOOSClient];
        }else{
            NSLog(@"获取sts信息失败");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        if (error.code == -1001) {
            [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
        }else{
            [NSObject showHudTipStr:LocalString(@"获取sts信息失败")];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}

- (void)setUserImageWithImageUrl:(NSString *)imageUrl{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/user/image"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"image":imageUrl};
    
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSLog(@"修改头像成功");
            [NSObject showHudTipStr:LocalString(@"修改头像成功")];
        }else{
            [NSObject showHudTipStr:LocalString(@"修改头像失败")];
            NSLog(@"修改头像失败");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"修改头像失败");
        if (error.code == -1001) {
            [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
        }
    }];
}

#pragma mark - ImagePicker
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image imageByScalingAndCroppingForSize:CGSizeMake(140/WScale, 140/WScale)];
    [_headButton setImage:image forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self putFile:image];
        [SVProgressHUD dismiss];
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
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
        [_headButton sd_setImageWithURL:[NSURL URLWithString:[DataBase shareDataBase].imageUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_default_headportrait"]];

        [_headButton addTarget:self action:@selector(showSheet:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:_headButton];
        [_headButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(70/WScale, 70/WScale));
            make.centerX.equalTo(self.headerView.mas_centerX);
            make.top.equalTo(self.headerView.mas_top).offset(30/HScale);
        }];
        _headButton.layer.masksToBounds = YES;
        _headButton.layer.cornerRadius = 35.f/HScale;
        _headButton.imageView.layer.cornerRadius = _headButton.bounds.size.height/2.0;
        
        UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cameraBtn addTarget:self action:@selector(showSheet:) forControlEvents:UIControlEventTouchUpInside];
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
            [tableView registerClass:[LogOutCell class] forCellReuseIdentifier:CellIdentifier_AccountLogout];
            [self.view addSubview:tableView];
            
            tableView.scrollEnabled = NO;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _accountTableView;
}

- (void)setUpCameraPickControllerIsEdit:(BOOL)isEdit {
    self.cameraPicker = [[UIImagePickerController alloc] init];
    self.cameraPicker.allowsEditing = isEdit; //拍照选去是否可以截取，和代理中的获取截取后的方法配合使用
    self.cameraPicker.delegate = self;
    self.cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
}

- (void)setUpPhotoPickControllerIsEdit:(BOOL)isEdit {
    self.photoLibraryPicker = [[UIImagePickerController alloc] init];
    self.photoLibraryPicker.allowsEditing = isEdit; // 相册选取是否截图
    self.photoLibraryPicker.delegate = self;
    //去掉毛玻璃效果 否则在ios11 下 全局设置了UIScrollViewContentInsetAdjustmentNever 导致导航栏遮住了内容视图
    self.photoLibraryPicker.navigationBar.translucent = NO;
    self.photoLibraryPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
            
        case 1:
            return 2;
            break;
            
        case 2:
            return 1;
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
    }else if(indexPath.section == 1) {
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
    }else{
        LogOutCell *cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_AccountLogout];
        if (cell1 == nil) {
            cell1 = [[LogOutCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_AccountLogout];
        }
        return cell1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        UsernameViewController *userNameVC = [[UsernameViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:userNameVC];
        [self presentViewController:nav animated:YES completion:nil];
    }else if(indexPath.section == 1) {
        if (indexPath.row == 0){
            UserPasswordController *pwVC = [[UserPasswordController alloc] init];
            [self.navigationController pushViewController:pwVC animated:YES];
        }else if (indexPath.row == 1){
            UserPhoneController *phoneVC = [[UserPhoneController alloc] init];
            [self.navigationController pushViewController:phoneVC animated:YES];
        }
    }else{
        YAlertViewController *alert = [[YAlertViewController alloc] init];
        alert.lBlock = ^{
            
        };
        alert.rBlock = ^{
            //清除单例
            [NetWork destroyInstance];
            
            LoginViewController *loginVC = [[LoginViewController alloc] init];
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


@end
