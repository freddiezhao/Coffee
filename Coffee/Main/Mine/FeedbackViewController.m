//
//  FeedbackViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/26.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "FeedbackViewController.h"
#import "TouchTableView.h"
#import "FeedTextViewCell.h"
#import "FeedSelectCell.h"
#import "FeedTextFieldCell.h"

#import <MessageUI/MessageUI.h>

NSString *const CellIdentifier_FeedTextView = @"CellID_FeedTextView";
NSString *const CellIdentifier_FeedSelect = @"CellID_FeedSelect";
NSString *const CellIdentifier_FeedTextField = @"CellID_FeedTextField";

@interface FeedbackViewController () <UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *feedTable;

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    [self setNavItem];
    
    _feedTable = [self feedTable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

#pragma mark - private methods
- (void)submitFeedback{
    // 判断设备能不能发送短信
    if([MFMessageComposeViewController canSendText]){
        
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        // 设置委托
        picker.messageComposeDelegate= self;
        // 默认信息内容(可以去服务器进行拉取内容)
        picker.body = @"ABCD";
        // 默认收件人(可多个)
        picker.recipients = @[@"274194059@qq.com"];
        
        [self presentViewController:picker animated:YES completion:nil];
        
    }else{
        // 提示用户不能发送短信
        YAlertViewController *alert = [[YAlertViewController alloc] init];
        alert.rBlock = ^{
        };
        alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:alert animated:NO completion:^{
            if (ScreenWidth > ScreenHeight) {
                alert.WScale_alert = 667.0 / ScreenWidth;
                alert.HScale_alert = 375.0 / ScreenHeight;
            }else{
                alert.WScale_alert = WScale;
                alert.HScale_alert = HScale;
            }
            [alert showView];
            alert.titleLabel.text = LocalString(@"提示");
            alert.messageLabel.text = LocalString(@"该设备不支持邮件功能");
            [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
            [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
        }];
    }
}

#pragma mark MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    // 不管任何状态返回之前界面
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    NSString *message;
    switch (result){
        case MessageComposeResultCancelled:
        {
            NSLog(@"取消发送");
            message = @"取消发送";
        }
            break;
        case MessageComposeResultFailed:
        {
            NSLog(@"发送失败");
            message = @"发送失败";
        }
            break;
        case MessageComposeResultSent:
        {
            NSLog(@"发送成功");
            message = @"发送成功";
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Lazyload
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"我要反馈");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 32, 23);
    [rightButton setTitle:LocalString(@"提交") forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
    rightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [rightButton addTarget:self action:@selector(submitFeedback) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;

}

- (UITableView *)feedTable{
    if (!_feedTable) {
        _feedTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 15, ScreenWidth, self.view.bounds.size.height - 15) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[FeedTextViewCell class] forCellReuseIdentifier:CellIdentifier_FeedTextView];
            [tableView registerClass:[FeedSelectCell class] forCellReuseIdentifier:CellIdentifier_FeedSelect];
            [tableView registerClass:[FeedTextFieldCell class] forCellReuseIdentifier:CellIdentifier_FeedTextField];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _feedTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 1;
    }else if (section == 1){
        return 4;
    }else{
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            FeedTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_FeedTextView];
            cell.backgroundColor = [UIColor clearColor];
            if (cell == nil) {
                cell = [[FeedTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_FeedTextView];
            }
            return cell;
        }
            break;
         
        case 1:
        {
            FeedSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_FeedSelect];
            if (cell == nil) {
                cell = [[FeedSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_FeedSelect];
            }
            cell.tag = unselect;
            if (indexPath.row == 0) {
                cell.infoLabel.text = LocalString(@"连不上路由器");
            }else if (indexPath.row == 1){
                cell.infoLabel.text = LocalString(@"升温不够快");
            }else if (indexPath.row == 2){
                cell.infoLabel.text = LocalString(@"豆子烤焦了");
            }else{
                cell.infoLabel.text = LocalString(@"机器抖的厉害");
            }
            return cell;
        }
            break;
            
        case 2:
        {
            FeedTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_FeedTextField];
            if (cell == nil) {
                cell = [[FeedTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_FeedTextField];
            }
            if (indexPath.row == 0) {
                cell.nameLabel.text = LocalString(@"联系人");
                cell.contentTF.placeholder = LocalString(@"请输入您的姓名");
            }else{
                cell.nameLabel.text = LocalString(@"手机号");
                cell.contentTF.placeholder = LocalString(@"请输入您的联系方式");
            }
            return cell;
        }
            break;
            
        default:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellindetify_feeddefaultcell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellindetify_feeddefaultcell"];
            }
            return cell;
        }
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        FeedSelectCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.tag == unselect) {
            cell.tag = select;
            [cell.checkBtn setImage:[UIImage imageNamed:@"ic_selected"] forState:UIControlStateNormal];
        }else{
            cell.tag = unselect;
            [cell.checkBtn setImage:[UIImage imageNamed:@"ic_select"] forState:UIControlStateNormal];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return 208.f;
            break;
            
        case 1:
            return 50.f;
            break;
            
        case 2:
            return 50.f;
            break;
            
        default:
            return 50.f;
            break;
    }
}

//section头部间距

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 36;
    }
    return 0;//section头部高度
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = LocalString(@"请选择您遇到的问题(可多选)");
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    label.textAlignment = NSTextAlignmentLeft;
    [view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(300/WScale, 20/HScale));
        make.left.equalTo(view.mas_left).offset(15/WScale);
        make.centerY.equalTo(view.mas_centerY);
    }];
    
    return view ;
}
//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

@end
