//
//  ForgetPasswordController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2019/3/15.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "ForgetPasswordController.h"
#import "PhoneTFCell.h"
#import "PhoneVerifyCell.h"
#import "TextFieldCell.h"

NSString *const CellIdentifier_ForgetUserPhone = @"CellID_ForgetPhone";
NSString *const CellIdentifier_ForgetUserPhoneVerify = @"CellID_ForgetPhoneVerify";
NSString *const CellIdentifier_ForgetTextField = @"CellID_ForgetTextField";

@interface ForgetPasswordController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImageView *headerImage;
@property (nonatomic, strong) UITableView *registerTable;
@property (nonatomic, strong) UIButton *registerBtn;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *pwText;
@property (nonatomic, strong) NSString *pwConText;

@end

@implementation ForgetPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;
    [self setNavItem];
    
    _headerImage = [self headerImage];
    _registerTable = [self registerTable];
    _phone = @"";
    _code = @"";
    _pwText = @"";
    _pwConText = @"";
}

#pragma mark - LazyLoad
static float HEIGHT_CELL = 50.f;

- (void)setNavItem{
    self.navigationItem.title = LocalString(@"忘记密码");
}

- (UIImageView *)headerImage{
    if (!_headerImage) {
        _headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_logo"]];
        [self.view addSubview:_headerImage];
        [_headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(140/WScale, 112/HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(20/HScale);
        }];
    }
    return _headerImage;
}

- (UITableView *)registerTable{
    if (!_registerTable) {
        _registerTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 150, ScreenWidth, ScreenHeight - 64)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[PhoneVerifyCell class] forCellReuseIdentifier:CellIdentifier_ForgetUserPhoneVerify];
            [tableView registerClass:[PhoneTFCell class] forCellReuseIdentifier:CellIdentifier_ForgetUserPhone];
            [tableView registerClass:[TextFieldCell class] forCellReuseIdentifier:CellIdentifier_ForgetTextField];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            
            UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 110/HScale)];
            footView.backgroundColor = [UIColor clearColor];
            _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_registerBtn setTitle:LocalString(@"修改密码") forState:UIControlStateNormal];
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
            PhoneVerifyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ForgetUserPhoneVerify];;
            if (cell == nil) {
                cell = [[PhoneVerifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_ForgetUserPhoneVerify];
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
                          }else{
                              [NSObject showHudTipStr:LocalString(@"操作失败")];
                          }
                          
                      }
                 ];
                return YES;
            };
            return cell;
        }else{
            PhoneTFCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ForgetUserPhone];;
            if (cell == nil) {
                cell = [[PhoneTFCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_ForgetUserPhone];
            }
            cell.TFBlock = ^(NSString *text) {
                _phone = text;
                [self textFieldChange];
            };
            return cell;
        }
    }else{
        TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ForgetTextField];
        if (cell == nil) {
            cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_ForgetTextField];
        }
        cell.textField.secureTextEntry = YES;
        if (indexPath.row == 0) {
            cell.textField.placeholder = LocalString(@"请输入新的密码");
            cell.TFBlock = ^(NSString *text) {
                _pwText = text;
                [self textFieldChange];
            };
        }else{
            cell.textField.placeholder = LocalString(@"请再次输入新的密码");
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
    if ([NSString validateMobile:_phone] && _code.length == 6 && _pwText.length >= 6 && _pwText.length <= 16 && [_pwText isEqualToString:_pwConText]){
        parameters = @{@"mobile":_phone,@"password":_pwText,@"code":_code};
    }else if(![NSString validateMobile:_phone]){
        [NSObject showHudTipStr:LocalString(@"无效的手机号码")];
        return;
    }else if(_code.length != 6){
        [NSObject showHudTipStr:LocalString(@"无效的验证码")];
        return;
    }else if(_pwText.length < 6 || _pwText.length > 16){
        [NSObject showHudTipStr:LocalString(@"请输入6-16位字符的密码")];
        return;
    }else if(![_pwText isEqualToString:_pwConText]){
        [NSObject showHudTipStr:LocalString(@"两次输入的密码不一致")];
        return;
    }else{
        [NSObject showHudTipStr:LocalString(@"修改密码失败，请检查您填写的信息")];
        return;
    }
    
    [manager PUT:@"http://139.196.90.97:8080/coffee/user/password/code" parameters:parameters
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
              NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
              NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"success:%@",daetr);
              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                  [NSObject showHudTipStr:LocalString(@"修改密码成功")];
                  [self.navigationController popViewControllerAnimated:YES];
              }else{
                  [NSObject showHudTipStr:LocalString(@"修改密码失败，请检查验证码和密码是否填写错误")];
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

- (void)textFieldChange{
    if (![_code isEqualToString:@""] && ![_phone isEqualToString:@""] && ![_pwText isEqualToString:@""] && ![_pwConText isEqualToString:@""]) {
        [_registerBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
    }else{
        [_registerBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
    }
}

@end
