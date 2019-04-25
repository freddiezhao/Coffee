//
//  CompleteInfoController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/20.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CompleteInfoController.h"
#import "MainViewController.h"
#import "BeanModel.h"

@interface CompleteInfoController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *headButton;
@property (nonatomic, strong) UITextField *nickTF;
@property (nonatomic, strong) UIButton *doneBtn;

@end

@implementation CompleteInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;
    [self setNavItem];
    
    _headerView = [self headerView];
    _nickTF = [self nickTF];
    _doneBtn = [self doneBtn];
}

#pragma mark - Lazyload
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"完善资料");
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"跳过") style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    [rightBar setTintColor:[UIColor colorWithHexString:@"333333"]];
    [rightBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16.f], NSFontAttributeName,nil] forState:(UIControlStateNormal)];
    
    self.navigationItem.rightBarButtonItem = rightBar;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 130/HScale)];
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
        _headButton.imageView.layer.cornerRadius = 35.f/HScale;
        
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

- (UITextField *)nickTF{
    if (!_nickTF) {
        _nickTF = [[UITextField alloc] init];
        _nickTF.backgroundColor = [UIColor clearColor];
        _nickTF.font = [UIFont systemFontOfSize:15.f];
        _nickTF.placeholder = LocalString(@"请输入昵称(2-16个字符)");
        _nickTF.tintColor = [UIColor colorWithHexString:@"333333"];
        _nickTF.clearButtonMode = UITextFieldViewModeNever;
        _nickTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _nickTF.delegate = self;
        _nickTF.textAlignment = NSTextAlignmentRight;
        _nickTF.autocorrectionType = UITextAutocorrectionTypeNo;
        [_nickTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_nickTF];
        [_nickTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(300/WScale, 50/HScale));
            make.right.equalTo(self.view.mas_right).offset(-15/WScale);
            make.top.equalTo(self.headerView.mas_bottom);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = LocalString(@"昵称");
        label.font = [UIFont systemFontOfSize:16.f];
        label.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentLeft;
        label.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(35/WScale, 50/HScale));
            make.left.equalTo(self.view.mas_left).offset(15/WScale);
            make.top.equalTo(self.headerView.mas_bottom);
        }];
    }
    return _nickTF;
}

- (UIButton *)doneBtn{
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneBtn setTitle:LocalString(@"完成") forState:UIControlStateNormal];
        [_doneBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        [_doneBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn.layer.borderWidth = 0.5;
        _doneBtn.layer.borderColor = [UIColor colorWithHexString:@"4778CC"].CGColor;
        _doneBtn.layer.cornerRadius = 25.f/HScale;
        [self.view addSubview:_doneBtn];
        [_doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(345/WScale, 50/HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.nickTF.mas_bottom).offset(30/HScale);
        }];
    }
    return _doneBtn;
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
- (void)next{
    [self login:NO];
}

- (void)done{
    [self login:YES];
}

- (void)textFieldTextChange:(UITextField *)textField{
    if (textField.text.length > 1) {
        [_doneBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
    }else{
        [_doneBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
    }
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

- (void)login:(BOOL)isSetUserName{
    NSLog(@"%@",[[UIDevice currentDevice] identifierForVendor]);
    [SVProgressHUD show];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *parameters = @{@"mobile":_mobile,@"password":_password,@"nowMobile":[[[UIDevice currentDevice] identifierForVendor] UUIDString]};
    
    [manager POST:@"http://139.196.90.97:8080/coffee/user/login" parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              //保存账号密码
              NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
              [userDefaults setObject:_mobile forKey:@"mobile"];
              [userDefaults setObject:_password forKey:@"passWord"];
              [userDefaults synchronize];
              
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
              NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
              NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"success:%@",daetr);
              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                  DataBase *db = [DataBase shareDataBase];
                  NSDictionary *dic = [responseDic objectForKey:@"data"];
                  db.userId = [[dic objectForKey:@"userId"] copy];
                  db.userName = [dic objectForKey:@"userName"];
                  NSLog(@"%@",db.userName);
                  db.token = [[dic objectForKey:@"token"] copy];
                  
                  //初始化数据库
                  [db initDB];
                  [db deleteAllTable];
                  [db createTable];
                  [self addSettingByApi];
                  [self generateSampleBeanInfo];
                  if (isSetUserName) {
                      [self setUserName];
                  }

                  MainViewController *mainVC = [[MainViewController alloc] init];
                  [self presentViewController:mainVC animated:NO completion:nil];
              }else{
                  [NSObject showHudTipStr:LocalString(@"登录失败，请检查您的密码")];
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
              });
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
              if (error.code == -1001) {
                  [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
              });
          }];
    
}

- (void)addSettingByApi{
    DataBase *mydb = [DataBase shareDataBase];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 4.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/setting"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"weightUnit":mydb.setting.weightUnit,@"tempUnit":mydb.setting.tempUnit,@"roasterChroma":mydb.setting.bakeChromaReferStandard,@"timer":[NSNumber numberWithInteger:mydb.setting.timeAxis],@"temp":[NSNumber numberWithInteger:mydb.setting.tempAxis],@"tempCurveSmooth":[NSNumber numberWithInteger:mydb.setting.tempCurveSmooth],@"tempRateSmooth":[NSNumber numberWithInteger:mydb.setting.tempRateSmooth],@"language":mydb.setting.language};
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [mydb insertSetting];
        }else{
            [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == -1001) {
            [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
        }
    }];
}

//保存一个样品豆用来生成烘焙报告（未添加豆时烘焙的状况）
- (void)generateSampleBeanInfo{
    BeanModel *myBean = [[BeanModel alloc] init];
    myBean.name = LocalString(@"样品豆");
    myBean = [self checkBeanInfo:myBean];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/bean"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"name":myBean.name,@"country":myBean.nation,@"origin":myBean.area,@"grade":myBean.grade,@"processingMethod":myBean.process,@"stock":[NSNumber numberWithFloat:myBean.stock],@"farm":myBean.manor,@"altitude":[NSNumber numberWithFloat:myBean.altitude],@"species":myBean.beanSpecies,@"waterContent":[NSNumber numberWithFloat:myBean.water],@"supplier":myBean.supplier,@"price":[NSNumber numberWithFloat:myBean.price],@"purchaseTime":[NSDate localStringFromUTCDate:myBean.time]};
    
    [manager POST:url parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
              NSData *data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
              NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                  NSLog(@"success:%@",daetr);
                  if ([responseDic objectForKey:@"data"]) {
                      NSDictionary *beansDic = [responseDic objectForKey:@"data"];
                      myBean.beanUid = [beansDic objectForKey:@"beanUid"];
                      BOOL result = [[DataBase shareDataBase] insertNewBean:myBean];
                      if (result) {
                          NSLog(@"添加本地咖啡豆成功");
                      }else{
                          NSLog(@"添加本地咖啡豆失败");
                      }
                      
                  }
              }else{
                  NSLog(@"Error:%@",daetr);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
              if (error.code == -1001) {
                  [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
              }
          }];
    
}

- (BeanModel *)checkBeanInfo:(BeanModel *)myBean{
    if (!myBean.nation) {
        myBean.nation = @"";
    }
    if (!myBean.area) {
        myBean.area = @"";
    }
    if (!myBean.stock) {
        myBean.stock = 500.f;
    }
    if (!myBean.manor) {
        myBean.manor = @"";
    }
    if (!myBean.supplier) {
        myBean.supplier = @"";
    }
    if (!myBean.water) {
        myBean.water = 0;
    }
    if (!myBean.altitude) {
        myBean.altitude = 0;
    }
    if (!myBean.price) {
        myBean.price = 0;
    }
    if (!myBean.beanSpecies) {
        myBean.beanSpecies = @"";
    }
    if (!myBean.grade) {
        myBean.grade = @"";
    }
    if (!myBean.process) {
        myBean.process = @"";
    }
    if (!myBean.time) {
        myBean.time = [NSDate date];
    }
    return myBean;
}

- (void)setUserName{
    [DataBase shareDataBase].userName = _nickTF.text;

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/user"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"userName":_nickTF.text};
    
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSLog(@"修改昵称成功");
        }else{
            NSLog(@"修改昵称失败");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"修改昵称失败");
        if (error.code == -1001) {
            [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
        }
    }];
}
@end
