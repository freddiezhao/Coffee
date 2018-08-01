//
//  CurveColorViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CurveColorViewController.h"
#import "CurveColorCell.h"

NSString *const CellIdentifier_curveColor = @"CellID_curveColor";

@interface CurveColorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *curveColorTable;
@property (nonatomic, strong) NSArray *type;

@end

@implementation CurveColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _curveColorTable = [self curveColorTable];
    _type = @[@"豆温",@"进风温",@"出风温",@"环境温",@"豆温升温率"];
}

#pragma mark - Lazyload
- (UITableView *)curveColorTable{
    if (!_curveColorTable) {
        _curveColorTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[CurveColorCell class] forCellReuseIdentifier:CellIdentifier_curveColor];
            
            [self.view addSubview:tableView];
            //tableView.estimatedRowHeight = 0;
            //tableView.estimatedSectionHeaderHeight = 0;
            //tableView.estimatedSectionFooterHeight = 0;
            
            tableView;
        });
    }
    return _curveColorTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CurveColorCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_curveColor];
    if (cell == nil) {
        cell = [[CurveColorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_curveColor];
    }
    cell.titleLabel.text = _type[indexPath.row];
    cell.colorView.backgroundColor = [UIColor redColor];
    cell.block = ^{
        
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
