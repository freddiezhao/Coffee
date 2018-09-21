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
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;

    [self setNavItem];
    _userNameTF = [self userNameTF];
    
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
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"修改昵称");
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"完成") style:UIBarButtonItemStylePlain target:self action:@selector(Done)];
    [rightBar setTintColor:[UIColor colorWithHexString:@"4778CC"]];
    [rightBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16.f], NSFontAttributeName,nil] forState:(UIControlStateNormal)];
    self.navigationItem.rightBarButtonItem = rightBar;

    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"取消") style:UIBarButtonItemStylePlain target:self action:@selector(Cancel)];
    [leftBar setTintColor:[UIColor colorWithHexString:@"222222"]];
    [leftBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16.f], NSFontAttributeName,nil] forState:(UIControlStateNormal)];
    self.navigationItem.leftBarButtonItem = leftBar;
}

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
        _userNameTF.autocorrectionType = UITextAutocorrectionTypeNo;
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
    [DataBase shareDataBase].userName = _userNameTF.text;
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
