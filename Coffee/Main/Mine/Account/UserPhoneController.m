//
//  UserPhoneController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/19.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "UserPhoneController.h"
#import "PhoneTFCell.h"
#import "PhoneVerifyCell.h"

NSString *const CellIdentifier_userPhoneModify = @"CellID_userPhoneModify";
NSString *const CellIdentifier_userPhoneVerify = @"CellID_userPhoneVerify";

@interface UserPhoneController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *phoneTable1;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UITableView *phoneTable2;
@property (nonatomic, strong) UIButton *saveBtn;

@property (nonatomic, strong) NSString *phoneNew;
@property (nonatomic, strong) NSString *codeNew;

@end

@implementation UserPhoneController
static float HEIGHT_CELL = 50.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;

    [self setNavItem];
    
    _phoneTable1 = [self phoneTable1];
    _phoneTable2 = [self phoneTable2];
    
    _phoneNew = @"";
    _codeNew = @"";
}

#pragma mark - LazyLoad
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"修改手机号码");
}

- (UITableView *)phoneTable1{
    if (!_phoneTable1) {
        _phoneTable1 = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[PhoneVerifyCell class] forCellReuseIdentifier:CellIdentifier_userPhoneVerify];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            
            UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 110/HScale)];
            footView.backgroundColor = [UIColor clearColor];
            _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_nextBtn setTitle:LocalString(@"下一步") forState:UIControlStateNormal];
            _nextBtn.frame = CGRectMake(0, 30/HScale, 345/WScale, 50/HScale);
            [_nextBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
            [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_nextBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
            [_nextBtn addTarget:self action:@selector(nextTable) forControlEvents:UIControlEventTouchUpInside];
            _nextBtn.center = footView.center;
            _nextBtn.layer.borderWidth = 0.5;
            _nextBtn.layer.borderColor = [UIColor colorWithHexString:@"4778CC"].CGColor;
            _nextBtn.layer.cornerRadius = _nextBtn.bounds.size.height / 2.f;
            [footView addSubview:_nextBtn];
            
            tableView.tableFooterView = footView;
            
            tableView;
        });
    }
    return _phoneTable1;
}

- (UITableView *)phoneTable2{
    if (!_phoneTable2) {
        _phoneTable2 = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(ScreenWidth, 0, ScreenWidth, ScreenHeight - 64)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[PhoneVerifyCell class] forCellReuseIdentifier:CellIdentifier_userPhoneVerify];
            [tableView registerClass:[PhoneTFCell class] forCellReuseIdentifier:CellIdentifier_userPhoneModify];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            
            UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 110/HScale)];
            footView.backgroundColor = [UIColor clearColor];
            _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_saveBtn setTitle:LocalString(@"提交") forState:UIControlStateNormal];
            _saveBtn.frame = CGRectMake(0, 30/HScale, 345/WScale, 50/HScale);
            [_saveBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
            [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_saveBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
            [_saveBtn addTarget:self action:@selector(saveNewPhone) forControlEvents:UIControlEventTouchUpInside];
            _saveBtn.center = footView.center;
            _saveBtn.layer.borderWidth = 0.5;
            _saveBtn.layer.borderColor = [UIColor colorWithHexString:@"4778CC"].CGColor;
            _saveBtn.layer.cornerRadius = _saveBtn.bounds.size.height / 2.f;
            [footView addSubview:_saveBtn];
            
            tableView.tableFooterView = footView;
            
            tableView;
        });
    }
    return _phoneTable2;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _phoneTable1) {
        return 1;
    }else{
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _phoneTable1) {
        PhoneVerifyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_userPhoneVerify];;
        if (cell == nil) {
            cell = [[PhoneVerifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_userPhoneVerify];
        }
        cell.TFBlock = ^(NSString *text) {
            if ([text isEqualToString:@""]) {
                _nextBtn.backgroundColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4];
            }else{
                _nextBtn.backgroundColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1];
            }
        };
        cell.BtnBlock = ^BOOL{
            PhoneVerifyCell *cell1 = [self.phoneTable1 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            [cell1.codeTF resignFirstResponder];
            
            BOOL result = [self getVerifyCode:[DataBase shareDataBase].mobile];
            return result;
        };
        return cell;
    }else{
        if (indexPath.row == 1) {
            PhoneVerifyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_userPhoneVerify];;
            if (cell == nil) {
                cell = [[PhoneVerifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_userPhoneVerify];
            }
            cell.TFBlock = ^(NSString *text) {
                _codeNew = text;
                [self textFieldChange];
            };
            cell.BtnBlock = ^BOOL{
                PhoneVerifyCell *cell1 = [self.phoneTable2 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                [cell1.codeTF resignFirstResponder];
                PhoneTFCell *cell2 = [self.phoneTable2 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell2.phoneTF resignFirstResponder];

                BOOL result = [self getVerifyCode:_phoneNew];
                return result;
            };
            return cell;
        }else{
            PhoneTFCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_userPhoneModify];;
            if (cell == nil) {
                cell = [[PhoneTFCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_userPhoneModify];
            }
            cell.TFBlock = ^(NSString *text) {
                _phoneNew = text;
                [self textFieldChange];
            };
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL/HScale;
}

//section头部间距

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _phoneTable1) {
        return 50/HScale;
    }else{
        return 15/HScale;
    }
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    if (tableView == _phoneTable1) {
        UILabel *label = [[UILabel alloc] init];
        label.text = [[DataBase shareDataBase].mobile stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];;
        label.font = [UIFont systemFontOfSize:16.f];
        label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentLeft;
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(300/WScale, 23/HScale));
            make.left.equalTo(view.mas_left).offset(15/WScale);
            make.centerY.equalTo(view.mas_centerY);
        }];
    }
    return view ;
}

#pragma mark - Actions
- (void)saveNewPhone{
    PhoneVerifyCell *cell1 = [self.phoneTable2 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell1.codeTF resignFirstResponder];
    PhoneTFCell *cell2 = [self.phoneTable2 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell2.phoneTF resignFirstResponder];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];

    NSDictionary *parameters = [[NSDictionary alloc] init];
    if ([NSString validateMobile:_phoneNew] && _codeNew.length == 6){
        parameters = @{@"mobile":_phoneNew,@"code":_codeNew};
    }else{
        [NSObject showHudTipStr:LocalString(@"更改手机号失败，请检查您填写的信息")];
        return;
    }
    
    [manager PUT:@"http://139.196.90.97:8080/coffee/user/mobile" parameters:parameters
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
             NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
             NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"success:%@",daetr);
             if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                 [NSObject showHudTipStr:LocalString(@"更改手机号成功")];
                 [self getUserInfoByApi];
             }else{
                 [NSObject showHudTipStr:LocalString(@"更改手机号失败，请检查验证码是否填写错误")];
             }
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error:%@",error);
             if (error.code == -1001) {
                 [NSObject showHudTipStr:LocalString(@"当前网络状况不佳") withTime:1.5];
             }else{
                 [NSObject showHudTipStr:LocalString(@"未知错误") withTime:1.5];
             }
         }
     ];
}

- (void)nextTable{
    [UIView animateWithDuration:0.5 animations:^{
        _phoneTable1.frame = CGRectMake(-ScreenWidth, 0, ScreenWidth, ScreenHeight - 64);
        _phoneTable2.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64);
    }];
    _phoneTable1.hidden = YES;
}

- (void)textFieldChange{
    if (![_codeNew isEqualToString:@""] && ![_phoneNew isEqualToString:@""]) {
        [_saveBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        _saveBtn.enabled = YES;
    }else{
        [_saveBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        _saveBtn.enabled = NO;
    }
}

- (BOOL)getVerifyCode:(NSString *)phone{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url;
    if ([NSString validateMobile:phone]){
        url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/util/smsCode?mobile=%@",phone];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    }else {
        [NSObject showHudTipStr:LocalString(@"手机号码不正确")];
        return NO;
    }
    
    [manager POST:url parameters:nil progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
              NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
              NSString * daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"success:%@",daetr);
              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                  [NSObject showHudTipStr:LocalString(@"已向您的手机发送验证码")];
              }else{
                  [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
              [NSObject showHudTipStr:LocalString(@"操作失败")];
              
          }
    ];
    return YES;
}

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
            }
        }else{
            [NSObject showHudTipStr:LocalString(@"更新用户信息失败")];
            NSLog(@"获取用户信息失败");
        }
        [self.navigationController popViewControllerAnimated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        [NSObject showHudTipStr:LocalString(@"更新用户信息失败")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
