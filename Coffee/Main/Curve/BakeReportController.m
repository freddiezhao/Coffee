//
//  BakeReportController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/29.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BakeReportController.h"
#import "BeanModel.h"
#import "ReportModel.h"
#import "EventModel.h"

@interface BakeReportController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *baseScrollView;
@property (nonatomic, strong) UIScrollView *firstReport;
@property (nonatomic, strong) UIScrollView *secondReport;
@property (nonatomic, strong) UIScrollView *thirdReport;
@property (nonatomic, strong) UIScrollView *fourthReport;

@property (nonatomic, strong) NSArray *beanArray;
@property (nonatomic, strong) ReportModel *reportModel;
@property (nonatomic, strong) NSArray *eventArray;

@property (nonatomic, strong) NSMutableArray *yVals_Out;
@property (nonatomic, strong) NSMutableArray *yVals_In;
@property (nonatomic, strong) NSMutableArray *yVals_Bean;
@property (nonatomic, strong) NSMutableArray *yVals_Environment;
@property (nonatomic, strong) NSMutableArray *yVals_Diff;
@end

@implementation BakeReportController
static int const footHeight = 30;
static int const maxContentOffSet_Y = 60;

- (void)viewDidLoad {
    [super viewDidLoad];
        
    _baseScrollView = [self baseScrollView];
    _firstReport = [self firstReport];
    _secondReport = [self secondReport];
    _thirdReport = [self thirdReport];
    _fourthReport = [self fourthReport];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

#pragma mark - Lazyload
- (UIScrollView *)baseScrollView{
    if (!_baseScrollView) {
        _baseScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _baseScrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight * 4);
        _baseScrollView.contentInset = UIEdgeInsetsMake(footHeight, 0, footHeight, 0);
        
        _baseScrollView.pagingEnabled = YES;
        _baseScrollView.showsVerticalScrollIndicator = NO;
        _baseScrollView.scrollEnabled = NO;
        
        [self.view addSubview:_baseScrollView];
    }
    return _baseScrollView;
}

- (UIScrollView *)firstReport{
    if (!_firstReport) {
        _firstReport = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64)];
        _firstReport.backgroundColor = [UIColor clearColor];
        _firstReport.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
        //_firstReport.contentInset = UIEdgeInsetsMake(footHeight, 0, footHeight, 0);
        _firstReport.showsVerticalScrollIndicator = NO;
        _firstReport.tag = 1001;
        _firstReport.delegate = self;
        
        UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -footHeight, ScreenWidth, footHeight)];
        headLabel.text = LocalString(@"这是第一页了^_^");
        headLabel.backgroundColor = [UIColor clearColor];
        headLabel.textAlignment = NSTextAlignmentCenter;
        [_firstReport addSubview:headLabel];
        
        UILabel *footLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, footHeight)];
        footLabel.text = LocalString(@"下拉查看更多");
        footLabel.backgroundColor = [UIColor clearColor];
        footLabel.textAlignment = NSTextAlignmentCenter;
        [_firstReport addSubview:footLabel];
        
        [_baseScrollView addSubview:_firstReport];
        [_baseScrollView bringSubviewToFront:_firstReport];
        
        UILabel *test = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 80, footHeight)];
        test.text = LocalString(@"1");
        test.backgroundColor = [UIColor clearColor];
        test.textAlignment = NSTextAlignmentCenter;
        [_firstReport addSubview:test];
    }
    return _firstReport;
}

- (UIScrollView *)secondReport{
    if (!_secondReport) {
        _secondReport = [[UIScrollView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - 64)];
        _secondReport.backgroundColor = [UIColor clearColor];
        _secondReport.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
        //_secondReport.contentInset = UIEdgeInsetsMake(footHeight, 0, footHeight, 0);
        _secondReport.showsVerticalScrollIndicator = NO;
        _secondReport.tag = 1002;
        _secondReport.delegate = self;
        
        UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -footHeight, ScreenWidth, footHeight)];
        headLabel.text = LocalString(@"上拉回到上一页");
        headLabel.backgroundColor = [UIColor clearColor];
        headLabel.textAlignment = NSTextAlignmentCenter;
        [_secondReport addSubview:headLabel];
        
        UILabel *footLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, footHeight)];
        footLabel.text = LocalString(@"下拉查看更多");
        footLabel.backgroundColor = [UIColor clearColor];
        footLabel.textAlignment = NSTextAlignmentCenter;
        [_secondReport addSubview:footLabel];
        
        [_baseScrollView addSubview:_secondReport];
        [_baseScrollView bringSubviewToFront:_secondReport];
        
        UILabel *test = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 80, footHeight)];
        test.text = LocalString(@"2");
        test.backgroundColor = [UIColor clearColor];
        test.textAlignment = NSTextAlignmentCenter;
        [_secondReport addSubview:test];
    }
    return _secondReport;
}

- (UIView *)thirdReport{
    if (!_thirdReport) {
        _thirdReport = [[UIScrollView alloc] initWithFrame:CGRectMake(0, ScreenHeight * 2, ScreenWidth, ScreenHeight - 64)];
        _thirdReport.backgroundColor = [UIColor clearColor];
        _thirdReport.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
        //_thirdReport.contentInset = UIEdgeInsetsMake(footHeight, 0, footHeight, 0);
        _thirdReport.showsVerticalScrollIndicator = NO;
        _thirdReport.tag = 1003;
        _thirdReport.delegate = self;
        
        UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -footHeight, ScreenWidth, footHeight)];
        headLabel.text = LocalString(@"上拉回到上一页");
        headLabel.backgroundColor = [UIColor clearColor];
        headLabel.textAlignment = NSTextAlignmentCenter;
        [_thirdReport addSubview:headLabel];
        
        UILabel *footLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, footHeight)];
        footLabel.text = LocalString(@"下拉查看更多");
        footLabel.backgroundColor = [UIColor clearColor];
        footLabel.textAlignment = NSTextAlignmentCenter;
        [_thirdReport addSubview:footLabel];
        
        [_baseScrollView addSubview:_thirdReport];
        [_baseScrollView bringSubviewToFront:_thirdReport];
        
        UILabel *test = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 80, footHeight)];
        test.text = LocalString(@"3");
        test.backgroundColor = [UIColor clearColor];
        test.textAlignment = NSTextAlignmentCenter;
        [_thirdReport addSubview:test];
    }
    return _thirdReport;
}

-(UIScrollView *)fourthReport{
    if (!_fourthReport) {
        _fourthReport = [[UIScrollView alloc] initWithFrame:CGRectMake(0, ScreenHeight * 3, ScreenWidth, ScreenHeight - 64)];
        _fourthReport.backgroundColor = [UIColor clearColor];
        _fourthReport.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
        //_fourthReport.contentInset = UIEdgeInsetsMake(footHeight, 0, footHeight, 0);
        _fourthReport.showsVerticalScrollIndicator = NO;
        _fourthReport.tag = 1004;
        _fourthReport.delegate = self;
        
        UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -footHeight, ScreenWidth, footHeight)];
        headLabel.text = LocalString(@"上拉回到上一页");
        headLabel.backgroundColor = [UIColor clearColor];
        headLabel.textAlignment = NSTextAlignmentCenter;
        [_fourthReport addSubview:headLabel];
        
        UILabel *footLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight * 4, ScreenWidth, footHeight)];
        footLabel.text = LocalString(@"已经最后一页了");
        footLabel.backgroundColor = [UIColor clearColor];
        footLabel.textAlignment = NSTextAlignmentCenter;
        [_fourthReport addSubview:footLabel];
        
        [_baseScrollView addSubview:_fourthReport];
        [_baseScrollView bringSubviewToFront:_fourthReport];
    }
    return _fourthReport;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //当前显示区域顶点相对于frame顶点的偏移量
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat value = scrollView.contentSize.height - ScreenHeight;
    NSLog(@"%f",value);
    NSLog(@"%f",offsetY);
    
    if (offsetY > 0) {
        if ((offsetY - value - 64) > maxContentOffSet_Y && scrollView.tag != 1004) {
            [self gotoNextView];
        }
    }else{
        if ((-offsetY - value) > maxContentOffSet_Y && scrollView.tag != 1001) {
            [self gotoFrontView];
        }
    }
    
}

#pragma mark - Actions
- (void)gotoNextView{
    CGPoint contentOffSet = _baseScrollView.contentOffset;
    
    contentOffSet.y += ScreenHeight;
    
    [_baseScrollView setContentOffset:contentOffSet];
}

- (void)gotoFrontView{
    CGPoint contentOffSet = _baseScrollView.contentOffset;
    
    contentOffSet.y -= ScreenHeight;
    
    [_baseScrollView setContentOffset:contentOffSet];
}

#pragma mark - DataSource
- (void)queryReportInfo{
    _reportModel = [[DataBase shareDataBase] queryReport:[NSNumber numberWithInteger:_curveId]];
    NSLog(@"%@",_reportModel.date);
    NSData *curveData = [_reportModel.curveValueJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *curveDic = [NSJSONSerialization JSONObjectWithData:curveData options:NSJSONReadingMutableLeaves error:nil];

    _yVals_Bean = [curveDic objectForKey:@"bean"];
    _yVals_Out = [curveDic objectForKey:@"out"];
    _yVals_In = [curveDic objectForKey:@"in"];
    _yVals_Environment = [curveDic objectForKey:@"environment"];
    _yVals_Diff = [curveDic objectForKey:@"diff"];
}

- (void)queryEventInfo{
    _eventArray = [[DataBase shareDataBase] queryEvent:[NSNumber numberWithInteger:_curveId]];
    for (EventModel *event in _eventArray) {
        NSLog(@"%@",event.eventText);
    }
}

- (void)queryBeanInfo{
    DataBase *db = [DataBase shareDataBase];
    NSMutableArray *beanMutaArray = [[db queryReportRelaBean:[NSNumber numberWithInteger:_curveId]] mutableCopy];
    for (int i = 0; i < [beanMutaArray count]; i++) {
        BeanModel *beanModelOld = beanMutaArray[i];
        BeanModel *beanModelNew = [db queryBean:[NSNumber numberWithInteger:beanModelOld.beanId]];
        beanModelNew.weight = beanModelOld.weight;
        beanModelNew.beanId = beanModelOld.beanId;
        [beanMutaArray replaceObjectAtIndex:i withObject:beanModelNew];
    }
    //可能没有添加生豆数据
    _beanArray = [beanMutaArray copy];
}

@end
