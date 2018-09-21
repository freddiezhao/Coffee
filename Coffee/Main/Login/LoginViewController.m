//
//  LoginViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/20.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "LoginViewController.h"
#import "TextFieldCell.h"
#import "VerifyCodeLoginController.h"
#import "RegisterController.h"
#import "MainViewController.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *headerImage;
@property (nonatomic, strong) UITextField *phoneTF;
@property (nonatomic, strong) UITextField *passwordTF;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *verifyLoginBtn;
@property (nonatomic, strong) UIButton *registeBtn;
@property (nonatomic, strong) UIButton *forgetPWBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;
    
    _headerImage = [self headerImage];
    _phoneTF = [self phoneTF];
    _passwordTF = [self passwordTF];
    _loginBtn = [self loginBtn];
    _verifyLoginBtn = [self verifyLoginBtn];
    _registeBtn = [self registeBtn];
    _forgetPWBtn = [self forgetPWBtn];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationBar setShadowImage:nil];
}
#pragma mark - Lazyload
- (UIImageView *)headerImage{
    if (!_headerImage) {
        _headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_logo"]];
        [self.view addSubview:_headerImage];
        [_headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(140/WScale, 112/HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(70/HScale);
        }];
    }
    return _headerImage;
}

- (UITextField *)phoneTF{
    if (!_phoneTF) {
        _phoneTF = [[UITextField alloc] init];
        _phoneTF.backgroundColor = [UIColor clearColor];
        _phoneTF.font = [UIFont systemFontOfSize:15.f];
        _phoneTF.placeholder = LocalString(@"请输入手机号");
        _phoneTF.tintColor = [UIColor colorWithHexString:@"333333"];
        _phoneTF.clearButtonMode = UITextFieldViewModeAlways;
        _phoneTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _phoneTF.delegate = self;
        _phoneTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _phoneTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        [_phoneTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_phoneTF];
        [_phoneTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(350/WScale, 50/HScale));
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.headerImage.mas_bottom).offset(30/HScale);
        }];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18/WScale, 0)];
        _phoneTF.leftView = paddingView;
        _phoneTF.leftViewMode = UITextFieldViewModeAlways;

    }
    return _phoneTF;
}

- (UITextField *)passwordTF{
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc] init];
        _passwordTF.backgroundColor = [UIColor whiteColor];
        _passwordTF.font = [UIFont systemFontOfSize:15.f];
        _passwordTF.tintColor = [UIColor blackColor];
        _passwordTF.clearButtonMode = UITextFieldViewModeAlways;
        _passwordTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _passwordTF.delegate = self;
        _passwordTF.secureTextEntry = YES;
        _passwordTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _passwordTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _passwordTF.placeholder = LocalString(@"请输入登录密码");
        [_passwordTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_passwordTF];
        [_passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(350/WScale, 50/HScale));
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.phoneTF.mas_bottom);
        }];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18/WScale, 0)];
        _passwordTF.leftView = paddingView;
        _passwordTF.leftViewMode = UITextFieldViewModeAlways;

    }
    return _passwordTF;
}

- (UIButton *)loginBtn{
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:LocalString(@"登录") forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        [_loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        _loginBtn.layer.borderWidth = 0.5;
        _loginBtn.layer.borderColor = [UIColor colorWithHexString:@"4778CC"].CGColor;
        _loginBtn.layer.cornerRadius = 25.f/HScale;
        _loginBtn.enabled = NO;
        [self.view addSubview:_loginBtn];
        [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(345/WScale, 50/HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.passwordTF.mas_bottom).offset(40/HScale);
        }];
    }
    return _loginBtn;
}

- (UIButton *)verifyLoginBtn{
    if (!_verifyLoginBtn) {
        _verifyLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_verifyLoginBtn setTitle:LocalString(@"验证码登录") forState:UIControlStateNormal];
        [_verifyLoginBtn.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
        [_verifyLoginBtn setBackgroundColor:[UIColor clearColor]];
        [_verifyLoginBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_verifyLoginBtn addTarget:self action:@selector(verifyLogin) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_verifyLoginBtn];
        [_verifyLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80/WScale, 20/HScale));
            make.left.equalTo(self.loginBtn.mas_left);
            make.top.equalTo(self.loginBtn.mas_bottom).offset(10/HScale);
        }];
    }
    return _verifyLoginBtn;
}

- (UIButton *)registeBtn{
    if (!_registeBtn) {
        _registeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registeBtn setTitle:LocalString(@"注册新用户") forState:UIControlStateNormal];
        [_registeBtn.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
        [_registeBtn setBackgroundColor:[UIColor clearColor]];
        [_registeBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_registeBtn addTarget:self action:@selector(registeUser) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_registeBtn];
        [_registeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80/WScale, 20/HScale));
            make.right.equalTo(self.loginBtn.mas_right);
            make.top.equalTo(self.loginBtn.mas_bottom).offset(10/HScale);
        }];
    }
    return _registeBtn;
}

- (UIButton *)forgetPWBtn{
    if (!_forgetPWBtn) {
        _forgetPWBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgetPWBtn setTitle:LocalString(@"忘记密码") forState:UIControlStateNormal];
        [_forgetPWBtn.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
        [_forgetPWBtn setBackgroundColor:[UIColor clearColor]];
        [_forgetPWBtn setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
        [_forgetPWBtn addTarget:self action:@selector(forgetPW) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_forgetPWBtn];
        [_forgetPWBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60/WScale, 20/HScale));
            make.right.equalTo(self.loginBtn.mas_right);
            make.bottom.equalTo(self.loginBtn.mas_top).offset(-10/HScale);
        }];
    }
    return _forgetPWBtn;
}
#pragma mark - uitextfield delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
    
}

#pragma mark - Actions
- (void)login{
    NSLog(@"%@",[[UIDevice currentDevice] identifierForVendor]);

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *parameters = @{@"mobile":_phoneTF.text,@"password":_passwordTF.text,@"nowMobile":[[[UIDevice currentDevice] identifierForVendor] UUIDString]};
    
    [manager POST:@"http://139.196.90.97:8080/coffee/user/login" parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
              NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
              NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"success:%@",daetr);
              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                  DataBase *db = [DataBase shareDataBase];
                  NSDictionary *dic = [responseDic objectForKey:@"data"];
                  db.userId = [[dic objectForKey:@"userId"] copy];
                  db.token = [[dic objectForKey:@"token"] copy];
                  [db initDB];
                  if (![[dic objectForKey:@"lastMobile"] isEqualToString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]]) {
                      [db deleteAllTable];
                      [db createTable];
                  }
                  MainViewController *mainVC = [[MainViewController alloc] init];
                  [self presentViewController:mainVC animated:NO completion:nil];
              }else{
                  [NSObject showHudTipStr:LocalString(@"登录失败，请检查您的密码")];
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
              if (error.code == -1001) {
                  [NSObject showHudTipStr:LocalString(@"当前网络状况不佳") withTime:1.5];
              }
          }];
    
}

- (void)textFieldTextChange:(UITextField *)textField{
    if ([NSString validateMobile:_phoneTF.text] && _passwordTF.text.length >= 6){
        [_loginBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        _loginBtn.enabled = YES;
    }else{
        [_loginBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        _loginBtn.enabled = NO;
    }
}

- (void)verifyLogin{
    VerifyCodeLoginController *verifyVC = [[VerifyCodeLoginController alloc] init];
    [self.navigationController pushViewController:verifyVC animated:YES];
}

- (void)registeUser{
    RegisterController *registVC = [[RegisterController alloc] init];
    [self.navigationController pushViewController:registVC animated:YES];
}

- (void)forgetPW{
    
}
@end
