//
//  RegisterController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/20.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "RegisterController.h"
#import "PhoneTFCell.h"
#import "PhoneVerifyCell.h"
#import "TextFieldCell.h"
#import "CompleteInfoController.h"

NSString *const CellIdentifier_RegisterUserPhone = @"CellID_RegisteruserPhone";
NSString *const CellIdentifier_RegisterUserPhoneVerify = @"CellID_RegisteruserPhoneVerify";
NSString *const CellIdentifier_RegisterTextField = @"CellID_RegisterTextField";

@interface RegisterController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *registerTable;
@property (nonatomic, strong) UIButton *registerBtn;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *pwText;
@property (nonatomic, strong) NSString *pwConText;

@end

@implementation RegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;
    [self setNavItem];
    
    _registerTable = [self registerTable];
    _phone = @"";
    _code = @"";
    _pwText = @"";
    _pwConText = @"";
}

#pragma mark - LazyLoad
static float HEIGHT_CELL = 50.f;

- (void)setNavItem{
    self.navigationItem.title = LocalString(@"注册新用户");
}

- (UITableView *)registerTable{
    if (!_registerTable) {
        _registerTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[PhoneVerifyCell class] forCellReuseIdentifier:CellIdentifier_RegisterUserPhoneVerify];
            [tableView registerClass:[PhoneTFCell class] forCellReuseIdentifier:CellIdentifier_RegisterUserPhone];
            [tableView registerClass:[TextFieldCell class] forCellReuseIdentifier:CellIdentifier_RegisterTextField];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            
            UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 110/HScale)];
            footView.backgroundColor = [UIColor clearColor];
            _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_registerBtn setTitle:LocalString(@"注册") forState:UIControlStateNormal];
            _registerBtn.frame = CGRectMake(0, 30/HScale, 345/WScale, 50/HScale);
            [_registerBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
            [_registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_registerBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
            [_registerBtn addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
            _registerBtn.center = footView.center;
            _registerBtn.layer.borderWidth = 0.5;
            _registerBtn.layer.borderColor = [UIColor colorWithHexString:@"4778CC"].CGColor;
            _registerBtn.layer.cornerRadius = _registerBtn.bounds.size.height / 2.f;
            [footView addSubview:_registerBtn];
            
            tableView.tableFooterView = footView;
            
            tableView;
        });
    }
    return _registerTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            PhoneVerifyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_RegisterUserPhoneVerify];;
            if (cell == nil) {
                cell = [[PhoneVerifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_RegisterUserPhoneVerify];
            }
            cell.TFBlock = ^(NSString *text) {
                _code = text;
                [self textFieldChange];
            };
            cell.BtnBlock = ^BOOL{
                PhoneVerifyCell *cell1 = [self.registerTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                [cell1.codeTF resignFirstResponder];
                PhoneTFCell *cell2 = [self.registerTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
                [cell2.phoneTF resignFirstResponder];
                TextFieldCell *cell3 = [self.registerTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                [cell3.textField resignFirstResponder];
                TextFieldCell *cell4 = [self.registerTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
                [cell4.textField resignFirstResponder];

                AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                
                //设置超时时间
                [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
                manager.requestSerializer.timeoutInterval = 6.f;
                [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

                NSString *url;
                if ([NSString validateMobile:_phone]){
                    url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/util/smsCode?mobile=%@",_phone];
                    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
                }else {
                    [NSObject showHudTipStr:LocalString(@"手机号码不正确")];
                    return NO;
                }
                
                [manager POST:url parameters:nil progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                          NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
                          NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
                          NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                          NSLog(@"success:%@",daetr);
                          if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                              [NSObject showHudTipStr:LocalString(@"已向您的手机发送验证码")];
                          }else{
                              [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
                          }
                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          NSLog(@"Error:%@",error);
                          if (error.code == -1001) {
                              [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
                          }else
                          {
                              [NSObject showHudTipStr:LocalString(@"操作失败")];
                          }
                          
                      }
                ];
                return YES;
            };
            return cell;
        }else{
            PhoneTFCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_RegisterUserPhone];;
            if (cell == nil) {
                cell = [[PhoneTFCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_RegisterUserPhone];
            }
            cell.TFBlock = ^(NSString *text) {
                _phone = text;
                [self textFieldChange];
            };
            return cell;
        }
    }else{
        TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_RegisterTextField];
        if (cell == nil) {
            cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_RegisterTextField];
        }
        cell.textField.secureTextEntry = YES;
        if (indexPath.row == 0) {
            cell.textField.placeholder = LocalString(@"请输入密码（6位以上字符）");
            cell.TFBlock = ^(NSString *text) {
                _pwText = text;
                [self textFieldChange];
            };
        }else{
            cell.textField.placeholder = LocalString(@"请再次输入密码");
            cell.TFBlock = ^(NSString *text) {
                _pwConText = text;
                [self textFieldChange];
            };
        }
        return cell;
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
    return 15/HScale;
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view ;
}

#pragma mark - Actions
- (void)registerUser{
    PhoneVerifyCell *cell1 = [self.registerTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell1.codeTF resignFirstResponder];
    PhoneTFCell *cell2 = [self.registerTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
    [cell2.phoneTF resignFirstResponder];
    TextFieldCell *cell3 = [self.registerTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [cell3.textField resignFirstResponder];
    TextFieldCell *cell4 = [self.registerTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    [cell4.textField resignFirstResponder];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *parameters = [[NSDictionary alloc] init];
    if ([NSString validateMobile:_phone] && _code.length == 6 && _pwText.length >= 6 && [_pwText isEqualToString:_pwConText]){
        parameters = @{@"mobile":_phone,@"password":_pwText,@"code":_code};
    }else{
        [NSObject showHudTipStr:LocalString(@"注册用户失败，请检查您填写的信息")];
        return;
    }
    
    [manager POST:@"http://139.196.90.97:8080/coffee/user/register" parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
              NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
              NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"success:%@",daetr);
              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                  CompleteInfoController *infoVC = [[CompleteInfoController alloc] init];
                  infoVC.mobile = _phone;
                  infoVC.password = _pwText;
                  [self.navigationController pushViewController:infoVC animated:YES];
              }else{
                  [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
              if (error.code == -1001) {
                  [NSObject showHudTipStr:LocalString(@"当前网络状况不佳") withTime:1.5];
              }
          }];
}

- (void)textFieldChange{
    if (![_code isEqualToString:@""] && ![_phone isEqualToString:@""] && ![_pwText isEqualToString:@""] && ![_pwConText isEqualToString:@""]) {
        [_registerBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
    }else{
        [_registerBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
    }
}

@end
