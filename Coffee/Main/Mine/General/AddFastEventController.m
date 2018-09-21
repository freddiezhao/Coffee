//
//  AddFastEventController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/19.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "AddFastEventController.h"

@interface AddFastEventController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *fastEventTF;

@end

@implementation AddFastEventController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;

    [self setNavItem];
    _fastEventTF = [self fastEventTF];
}

#pragma mark - Lazyload
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"添加快速事件");
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"保存") style:UIBarButtonItemStylePlain target:self action:@selector(Done)];
    [rightBar setTintColor:[UIColor colorWithHexString:@"4778CC"]];
    [rightBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16.f], NSFontAttributeName,nil] forState:(UIControlStateNormal)];

    self.navigationItem.rightBarButtonItem = rightBar;
}

- (UITextField *)fastEventTF{
    if (!_fastEventTF) {
        _fastEventTF = [[UITextField alloc] init];
        _fastEventTF.backgroundColor = [UIColor whiteColor];
        _fastEventTF.font = [UIFont systemFontOfSize:15.f];
        _fastEventTF.tintColor = [UIColor blackColor];
        _fastEventTF.clearButtonMode = UITextFieldViewModeAlways;
        _fastEventTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _fastEventTF.delegate = self;
        _fastEventTF.placeholder = LocalString(@"请输入您要添加的事件");
        _fastEventTF.frame = CGRectMake(0, 20, ScreenWidth, cellHeight);
        [_fastEventTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_fastEventTF];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
        _fastEventTF.leftView = paddingView;
        _fastEventTF.leftViewMode = UITextFieldViewModeAlways;
    }
    return _fastEventTF;
}

#pragma mark - Actions
- (void)Done{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self resignFirstResponder];
}

#pragma mark - UITextField Delegate
- (void)textFieldTextChange:(UITextField *)textField{
    
}

@end
