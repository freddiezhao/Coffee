//
//  UsernameViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "UsernameViewController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>

@interface UsernameViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *userNameTF;
@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation UsernameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userNameTF = [self userNameTF];
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.frame = CGRectMake(0, 0, 30, 30);
    [_rightButton setTitle:LocalString(@"完成") forState:UIControlStateNormal];
    [_rightButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(Done) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
    _rightButton.enabled = NO;
    _rightButton.alpha = 0.4;
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 30, 30);
    [leftButton setTitle:LocalString(@"取消") forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(Cancel) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

#pragma mark - Lazyload
- (UITextField *)userNameTF{
    if (!_userNameTF) {
        _userNameTF = [[UITextField alloc] init];
        _userNameTF.backgroundColor = [UIColor whiteColor];
        _userNameTF.font = [UIFont systemFontOfSize:15.f];
        _userNameTF.tintColor = [UIColor blackColor];
        _userNameTF.text = [DataBase shareDataBase].userName;
        _userNameTF.clearButtonMode = UITextFieldViewModeAlways;
        _userNameTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _userNameTF.delegate = self;
        [_userNameTF becomeFirstResponder];
        _userNameTF.frame = CGRectMake(0, 20, ScreenWidth, cellHeight);
        [_userNameTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_userNameTF];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
        _userNameTF.leftView = paddingView;
        _userNameTF.leftViewMode = UITextFieldViewModeAlways;
    }
    return _userNameTF;
}

#pragma mark - Actions
- (void)Done{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self resignFirstResponder];
}

- (void)Cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self resignFirstResponder];
}

#pragma mark - UITextField Delegate
- (void)textFieldTextChange:(UITextField *)textField{
    if ([textField.text isEqualToString:[DataBase shareDataBase].userName]) {
        _rightButton.enabled = NO;
        _rightButton.alpha = 0.4;
    }else{
        _rightButton.enabled = YES;
        _rightButton.alpha = 1;
    }
}

@end
