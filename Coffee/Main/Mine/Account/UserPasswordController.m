//
//  UserPasswordController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/19.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "UserPasswordController.h"
#import "UserPWCell.h"

NSString *const CellIdentifier_userPW = @"CellID_userPW";

@interface UserPasswordController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *pwTableView;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) NSString *PWold;
@property (nonatomic, strong) NSString *PWnew;
@property (nonatomic, strong) NSString *PWConnew;

@end

@implementation UserPasswordController
static float HEIGHT_CELL = 50.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    
    [self setNavItem];
    _pwTableView = [self pwTableView];
    _PWold = @"";
    _PWnew = @"";
    _PWConnew = @"";
}

#pragma mark - Lazy load
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"修改登录密码");
}

- (UITableView *)pwTableView{
    if (!_pwTableView) {
        _pwTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[UserPWCell class] forCellReuseIdentifier:CellIdentifier_userPW];
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
            [_saveBtn addTarget:self action:@selector(savePassword) forControlEvents:UIControlEventTouchUpInside];
            _saveBtn.center = footView.center;
            _saveBtn.layer.borderWidth = 0.5;
            _saveBtn.layer.borderColor = [UIColor colorWithHexString:@"4778CC"].CGColor;
            _saveBtn.layer.cornerRadius = _saveBtn.bounds.size.height / 2.f;
            [footView addSubview:_saveBtn];
            
            tableView.tableFooterView = footView;

            tableView;
        });
    }
    return _pwTableView;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserPWCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_userPW];;
    if (cell == nil) {
        cell = [[UserPWCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_userPW];
    }
    switch (indexPath.row) {
        case 0:
        {
            cell.nameLabel.text = LocalString(@"验证旧密码");
            cell.TFBlock = ^(NSString *text) {
                _PWold = text;
                [self textFieldChange];
            };
        }
            break;
        case 1:
        {
            cell.nameLabel.text = LocalString(@"设置新密码");
            cell.TFBlock = ^(NSString *text) {
                _PWnew = text;
                [self textFieldChange];
            };
        }
            break;
        case 2:
        {
            cell.nameLabel.text = LocalString(@"确认新密码");
            cell.TFBlock = ^(NSString *text) {
                _PWConnew = text;
                [self textFieldChange];
            };
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

#pragma mark - Actions
- (void)savePassword{
    
}

- (void)textFieldChange{
    if (![_PWold isEqualToString:@""] && ![_PWnew isEqualToString:@""] && ![_PWConnew isEqualToString:@""]) {
        [_saveBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
    }else{
        [_saveBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
    }
}

@end
