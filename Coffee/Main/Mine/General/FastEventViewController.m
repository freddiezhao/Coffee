//
//  FastEventViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "FastEventViewController.h"
#import "SettingModel.h"

NSString *const CellIdentifier_fastEvent = @"CellID_fastEvent";

@interface FastEventViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *fastEventTable;
@property (nonatomic, strong) NSMutableArray *eventArray;

@end

@implementation FastEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _eventArray = [[DataBase shareDataBase].setting.events copy];
    _fastEventTable = [self fastEventTable];
}

#pragma mark - Lazyload
- (UITableView *)fastEventTable{
    if (!_fastEventTable) {
        _fastEventTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier_fastEvent];
            
            [self.view addSubview:tableView];
            //tableView.estimatedRowHeight = 0;
            //tableView.estimatedSectionHeaderHeight = 0;
            //tableView.estimatedSectionFooterHeight = 0;
            
            tableView;
        });
    }
    return _fastEventTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _eventArray.count + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_fastEvent];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_fastEvent];
    }
    if (indexPath.row == _eventArray.count) {
        cell.textLabel.text = LocalString(@"自定义添加选择");
        cell.imageView.image = [UIImage imageNamed:@"ic_quick_event_add"];
        return cell;
    }
    cell.textLabel.text = _eventArray[indexPath.row];
    return cell;
}

@end
