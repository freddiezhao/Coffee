//
//  cupTestDetailController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CupTestDetailController.h"
#import "TouchTableView.h"
#import "DetailGradeCell.h"
#import "CupLightCell.h"
#import "BeanHeaderCell.h"
#import "BeanInfoCell.h"
#import "ReportCurveCell.h"
#import "ReportModel.h"
#import "BeanModel.h"
#import "CupTestEditController.h"
#import "CupModel.h"
#import "ScoreTitleCell.h"
#import "DetailScoreCell.h"


NSString *const CellIdentifier_cupDetailGrade = @"CellID_cupDetailGrade";
NSString *const CellIdentifier_cupDetailLight = @"CellID_cupDetailLight";
NSString *const CellIdentifier_cupBeanHeader = @"CellID_cupDetailBeanHeader";
NSString *const CellIdentifier_cupBeanInfo = @"CellID_cupDetailBeanInfo";
NSString *const CellIdentifier_cupCurve = @"CellID_cupDetailCurve";
NSString *const CellIdentifier_cupScoreTitle = @"CellID_cupScoreTitle";
NSString *const CellIdentifier_cupGoodScore = @"CellID_cupGoodScore";
NSString *const CellIdentifier_cupBadScore = @"CellID_cupBadScore";

@interface CupTestDetailController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISegmentedControl *mySegment;

@property (nonatomic, strong) UITableView *cupDetailTable;
@property (nonatomic, strong) UITableView *bakeDetailTable;

//report
@property (nonatomic, strong) ReportModel *reportModel;
@property (nonatomic, strong) NSArray *beanArray;
@property (nonatomic, strong) NSMutableArray *yVals_Out;
@property (nonatomic, strong) NSMutableArray *yVals_In;
@property (nonatomic, strong) NSMutableArray *yVals_Bean;
@property (nonatomic, strong) NSMutableArray *yVals_Environment;
@property (nonatomic, strong) NSMutableArray *yVals_Diff;

@end

@implementation CupTestDetailController
static float HEIGHT_HEADER = 15.f;

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    [self setNavItem];
    
    _beanArray = [[NSMutableArray alloc] init];
    _yVals_In = [[NSMutableArray alloc] init];
    _yVals_Out = [[NSMutableArray alloc] init];
    _yVals_Bean = [[NSMutableArray alloc] init];
    _yVals_Diff = [[NSMutableArray alloc] init];
    _yVals_Environment = [[NSMutableArray alloc] init];
    
    self.mySegment = [self mySegment];
    self.cupDetailTable = [self cupDetailTable];
    self.bakeDetailTable = [self bakeDetailTable];
    [self queryReportInfo];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
#pragma mark - Lazyload
- (void)setNavItem{
    if (_cup) {
        self.navigationItem.title = _cup.name;
    }else{
        self.navigationItem.title = LocalString(@"杯测名称");
    }
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"编辑") style:UIBarButtonItemStylePlain target:self action:@selector(editCup)];
    self.navigationItem.rightBarButtonItem = rightBar;
}

- (UISegmentedControl *)mySegment{
    if (!_mySegment) {
        UIView *view = [[UIView alloc] init];
        view.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor;
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 44/HScale));
            make.top.equalTo(self.view.mas_top);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        
        NSArray *titleData = @[@"杯测信息",@"烘焙详情"];
        _mySegment = [[UISegmentedControl alloc] initWithItems:titleData];
        // 设置默认选择项索引
        _mySegment.selectedSegmentIndex = 0;
        _mySegment.tintColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1];
        // 设置在点击后是否恢复原样
        //_mySegment.momentary = YES;
        [_mySegment addTarget:self action:@selector(didClickMySegmentAction:) forControlEvents:UIControlEventValueChanged];
        [view addSubview:_mySegment];
        
        [_mySegment mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(345/WScale, 28/HScale));
            make.top.equalTo(view.mas_top).offset(8/HScale);
            make.centerX.equalTo(view.mas_centerX);
        }];
    }
    return _mySegment;
}

- (UITableView *)cupDetailTable{
    if (!_cupDetailTable) {
        _cupDetailTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 44/HScale, ScreenWidth, ScreenHeight - 64 - 44/HScale) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            [tableView registerClass:[DetailGradeCell class] forCellReuseIdentifier:CellIdentifier_cupDetailGrade];
            [tableView registerClass:[CupLightCell class] forCellReuseIdentifier:CellIdentifier_cupDetailLight];
            [tableView registerClass:[ScoreTitleCell class] forCellReuseIdentifier:CellIdentifier_cupScoreTitle];
            [tableView registerClass:[DetailScoreCell class] forCellReuseIdentifier:CellIdentifier_cupGoodScore];
            [tableView registerClass:[DetailScoreCell class] forCellReuseIdentifier:CellIdentifier_cupBadScore];
            tableView;
        });
    }
    return _cupDetailTable;
}

- (UITableView *)bakeDetailTable{
    if (!_bakeDetailTable) {
        _bakeDetailTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 44.f/HScale, ScreenWidth, ScreenHeight - 64 - 44.f/HScale) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.hidden = YES;
            [tableView registerClass:[BeanHeaderCell class] forCellReuseIdentifier:CellIdentifier_cupBeanHeader];
            [tableView registerClass:[BeanInfoCell class] forCellReuseIdentifier:CellIdentifier_cupBeanInfo];
            [tableView registerClass:[ReportCurveCell class] forCellReuseIdentifier:CellIdentifier_cupCurve];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            
            tableView;
        });
    }
    return _bakeDetailTable;
}
#pragma mark - UISegment delegate
-(void)didClickMySegmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", Index);
    switch (Index) {
        case 0:
        {
            _cupDetailTable.hidden = NO;
            _bakeDetailTable.hidden = YES;
        }
            break;
        case 1:
        {
            _cupDetailTable.hidden = YES;
            if (_reportModel == nil) {
                _bakeDetailTable.hidden = YES;
            }else{
                _bakeDetailTable.hidden = NO;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == _cupDetailTable) {
        return 4;
    }else{
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _cupDetailTable) {
        switch (section) {
            case 0:
                return 1;
                break;
                
            case 1:
                return 1;
                break;
                
            case 2:
                return 9;
                break;
                
            case 3:
                return 7;
                break;
                
            default:
                return 0;
                break;
        }
    }else{
        switch (section) {
            case 0:
                return 1 + _beanArray.count;
                break;
                
            case 1:
                return 1;
                break;
                
            default:
                return 0;
                break;
        }
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _cupDetailTable) {
        switch (indexPath.section) {
            case 0:
                return 160.f/HScale;
                break;
                
            case 1:
                return 214.f/HScale;
                break;
                
            case 2:
            case 3:
            {
                if (indexPath.row == 0) {
                    return 50.f/HScale;
                }else{
                    return 98/HScale;
                }
            }
                
            default:
                return 0;
                break;
        }
    }else{
        switch (indexPath.section) {
            case 0:
            {
                if (indexPath.row == 0) {
                    return 70.f/HScale;
                }else{
                    return 159.f/HScale;
                }
                
            }
                break;
                
            case 1:
                return 202.f/HScale;
                break;
                
            default:
                return 0;
                break;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _cupDetailTable) {
        if (indexPath.section == 0) {
            DetailGradeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupDetailGrade];
            if (cell == nil) {
                cell = [[DetailGradeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupDetailGrade];
            }
            
            if (_cup.bakeGrade) {
                cell.gradeProgress = _cup.bakeGrade;
            }else{
                cell.gradeProgress = 0.0;
            }
            if (_cup.defectGrade) {
                cell.defectProgress = _cup.defectGrade;
            }else{
                cell.defectProgress = 0.0;
            }
            if (_cup.grade) {
                cell.resultProgress = _cup.grade;
            }else{
                cell.resultProgress = cell.gradeProgress - cell.defectProgress;
            }
            [cell setProgress];
            return cell;
        }else if (indexPath.section == 1){
            CupLightCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupDetailLight];
            if (cell == nil) {
                cell = [[CupLightCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupDetailLight];
            }
            if (_cup.light) {
                cell.lightValue.text = [NSString stringWithFormat:@"%d",(int)_cup.light];
            }else{
                cell.lightValue.text = @"0";
            }
            return cell;
        }else if (indexPath.section == 2){
            if (indexPath.row == 0) {
                ScoreTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupScoreTitle];
                if (cell == nil) {
                    cell = [[ScoreTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupScoreTitle];
                }
                cell.nameLabel.text = LocalString(@"咖啡杯测");
                return cell;
            }else{
                DetailScoreCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[DetailScoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupGoodScore];
                }
                NSArray *colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:232/255.0 blue:159/255.0 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:255/255.0 green:204/255.0 blue:102/255.0 alpha:1].CGColor];
                switch (indexPath.row) {
                    case 1:
                    {
                        cell.nameLabel.text = LocalString(@"干湿香");
                        [cell addGradientLayerWithValue:_cup.dryAndWet colors:colors];
                    }
                        break;
                    case 2:
                    {
                        cell.nameLabel.text = LocalString(@"风味");
                        [cell addGradientLayerWithValue:_cup.flavor colors:colors];
                    }
                        break;
                    case 3:
                    {
                        cell.nameLabel.text = LocalString(@"余韵");
                        [cell addGradientLayerWithValue:_cup.aftermath colors:colors];
                    }
                        break;
                    case 4:
                    {
                        cell.nameLabel.text = LocalString(@"酸质");
                        [cell addGradientLayerWithValue:_cup.acid colors:colors];
                    }
                        break;
                    case 5:
                    {
                        cell.nameLabel.text = LocalString(@"口感");
                        [cell addGradientLayerWithValue:_cup.taste colors:colors];
                    }
                        break;
                    case 6:
                    {
                        cell.nameLabel.text = LocalString(@"甜度");
                        [cell addGradientLayerWithValue:_cup.sweet colors:colors];
                    }
                        break;
                    case 7:
                    {
                        cell.nameLabel.text = LocalString(@"均匀度");
                        [cell addGradientLayerWithValue:_cup.balance colors:colors];
                    }
                        break;
                    case 8:
                    {
                        cell.nameLabel.text = LocalString(@"整体感受");
                        [cell addGradientLayerWithValue:_cup.overFeel colors:colors];
                    }
                        break;
                    default:
                        break;
                }
                return cell;
            }
        }else if (indexPath.section == 3){
            if (indexPath.row == 0) {
                ScoreTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupScoreTitle];
                if (cell == nil) {
                    cell = [[ScoreTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupScoreTitle];
                }
                cell.nameLabel.text = LocalString(@"烘焙瑕疵");
                return cell;
            }else{
                DetailScoreCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[DetailScoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupBadScore];
                }
                NSArray *colors = @[(__bridge id)[UIColor colorWithRed:236/255.0 green:224/255.0 blue:203/255.0 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:214/255.0 green:181/255.0 blue:128/255.0 alpha:1].CGColor];
                switch (indexPath.row) {
                    case 1:
                    {
                        cell.nameLabel.text = LocalString(@"发展不充分");
                        [cell addGradientLayerWithValue:_cup.deveUnfull colors:colors];
                    }
                        break;
                    case 2:
                    {
                        cell.nameLabel.text = LocalString(@"过度发展");
                        [cell addGradientLayerWithValue:_cup.overDeve colors:colors];
                    }
                        break;
                    case 3:
                    {
                        cell.nameLabel.text = LocalString(@"烤焙味");
                        [cell addGradientLayerWithValue:_cup.bakePaste colors:colors];
                    }
                        break;
                    case 4:
                    {
                        cell.nameLabel.text = LocalString(@"自焙烫伤");
                        [cell addGradientLayerWithValue:_cup.injure colors:colors];
                    }
                        break;
                    case 5:
                    {
                        cell.nameLabel.text = LocalString(@"胚芽烫伤");
                        [cell addGradientLayerWithValue:_cup.germInjure colors:colors];
                    }
                        break;
                    case 6:
                    {
                        cell.nameLabel.text = LocalString(@"豆表烫伤");
                        [cell addGradientLayerWithValue:_cup.beanFaceInjure colors:colors];
                    }
                        break;
                    default:
                        break;
                }
                return cell;
            }
        }else{
            DetailGradeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupDetailGrade];
            if (cell == nil) {
                cell = [[DetailGradeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupDetailGrade];
            }
            return cell;
        }
    }else{
        if (indexPath.section == 0){
            if (indexPath.row == 0) {
                BeanHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupBeanHeader];
                if (cell == nil) {
                    cell = [[BeanHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupBeanHeader];
                }
                if (_beanArray.count>0) {
                    NSString *nameString = LocalString(@"");
                    for (BeanModel *model in _beanArray) {
                        nameString = [nameString stringByAppendingString:[NSString stringWithFormat:@"%@、",model.name]];
                    }
                    cell.beanNameLabel.text = [nameString substringToIndex:[nameString length]-1];
                    cell.rawBean.text = [NSString stringWithFormat:@"%@%.1lf",LocalString(@"生豆:"),_reportModel.rawBeanWeight];
                    cell.bakedBean.text = [NSString stringWithFormat:@"%@%.1lf",LocalString(@"熟豆:"),_reportModel.bakeBeanWeight];
                    cell.outWaterRate.text = [NSString stringWithFormat:@"%@%@",LocalString(@"脱水率:"),_reportModel.outWaterRate];
                }else{
                    cell.beanNameLabel.text = LocalString(@"未添加豆种");
                    cell.rawBean.text = LocalString(@"生豆:?");
                    cell.bakedBean.text = LocalString(@"熟豆:?");
                    cell.outWaterRate.text = LocalString(@"脱水率:?");
                }
                return cell;
            }else{
                BeanInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupBeanInfo];
                if (cell == nil) {
                    cell = [[BeanInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupBeanInfo];
                }
                BeanModel *bean = _beanArray[indexPath.row - 1];
                if (bean.name) {
                    cell.beanName.text = bean.name;
                }else{
                    cell.beanName.text = LocalString(@"未知");
                }
                if (bean.nation) {
                    cell.nation.text = bean.nation;
                }else{
                    cell.nation.text = LocalString(@"未知");
                }
                if (bean.area) {
                    cell.area.text = bean.area;
                }else{
                    cell.area.text = LocalString(@"未知");
                }
                if (bean.altitude) {
                    cell.altitude.text = [NSString stringWithFormat:@"%.1f",bean.altitude];
                }else{
                    cell.altitude.text = LocalString(@"未知");
                }
                if (bean.manor) {
                    cell.manor.text = bean.manor;
                }else{
                    cell.manor.text = LocalString(@"未知");
                }
                if (bean.beanSpecies) {
                    cell.beanSpecies.text = bean.beanSpecies;
                }else{
                    cell.beanSpecies.text = LocalString(@"未知");
                }
                if (bean.grade) {
                    cell.grade.text = bean.grade;
                }else{
                    cell.grade.text = LocalString(@"未知");
                }
                if (bean.process) {
                    cell.process.text = bean.process;
                }else{
                    cell.process.text = LocalString(@"未知");
                }
                if (bean.water) {
                    cell.water.text = [NSString stringWithFormat:@"%.1f",bean.water];
                }else{
                    cell.water.text = LocalString(@"未知");
                }
                if (bean.weight) {
                    cell.weight.text = [NSString stringWithFormat:@"%.1f",bean.weight];
                }else{
                    cell.weight.text = LocalString(@"未知");
                }
                return cell;
            }
        }else{
            ReportCurveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupCurve];
            if (cell == nil) {
                cell = [[ReportCurveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupCurve];
            }
            if (_yVals_In.count > 0 && _yVals_Out.count > 0 && _yVals_Bean.count > 0 && _yVals_Environment.count > 0) {
                cell.yVals_In = _yVals_In;
                cell.yVals_Out = _yVals_Out;
                cell.yVals_Bean = _yVals_Bean;
                cell.yVals_Environment = _yVals_Environment;
                //cell.yVals_Diff = _yVals_Diff;
                [cell setDataValue];
            }
            return cell;
        }
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == _cupDetailTable) {
        switch (section) {
            case 0:
            case 1:
            case 2:
            case 3:
            {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5/HScale)];
                headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:0.1].CGColor;
                return headerView;
            }
                break;
                                
            default:
                return nil;
                break;
        }
    }else{
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 15.f/HScale)];
        headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
        return headerView;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == _cupDetailTable) {
        switch (section) {
            case 0:
                return 0.5/HScale;
                break;
                
            case 1:
            case 2:
            case 3:
                return HEIGHT_HEADER/HScale;
                break;
                
            default:
                return 0.f;
                break;
        }
    }else{
        return 15.f;
    }
    
}

#pragma mark - DataSource
- (void)queryReportInfo{
    _reportModel = [[DataBase shareDataBase] queryReport:[NSNumber numberWithInteger:_cup.curveId]];
    _reportModel.curveId = _cup.curveId;
    NSLog(@"%@",_reportModel.date);
    if (_reportModel.curveValueJson) {
        NSData *curveData = [_reportModel.curveValueJson dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *curveDic = [NSJSONSerialization JSONObjectWithData:curveData options:NSJSONReadingMutableLeaves error:nil];
        
        NSArray *Bean = [curveDic objectForKey:@"bean"];
        NSArray *Out = [curveDic objectForKey:@"out"];
        NSArray *In = [curveDic objectForKey:@"in"];
        NSArray *Environment = [curveDic objectForKey:@"environment"];
        //NSArray *Diff = [curveDic objectForKey:@"diff"];
        NSLog(@"%lu",(unsigned long)Bean.count);
        NSLog(@"%lu",Out.count);
        NSLog(@"%lu",In.count);
        NSLog(@"%lu",Environment.count);
        
        for (int i = 0; i<Bean.count; i++) {
            [_yVals_Bean addObject:[[ChartDataEntry alloc] initWithX:i y:[Bean[i] doubleValue]]];
        }
        for (int i = 0; i<Out.count; i++) {
            [_yVals_Out addObject:[[ChartDataEntry alloc] initWithX:i y:[Out[i] doubleValue]]];
        }
        for (int i = 0; i<In.count; i++) {
            [_yVals_In addObject:[[ChartDataEntry alloc] initWithX:i y:[In[i] doubleValue]]];
        }
        for (int i = 0; i<Environment.count; i++) {
            [_yVals_Environment addObject:[[ChartDataEntry alloc] initWithX:i y:[Environment[i] doubleValue]]];
        }
        //_yVals_Diff = [curveDic objectForKey:@"diff"];
    }
    [self queryBeanInfo];
}

- (void)queryBeanInfo{
    DataBase *db = [DataBase shareDataBase];
    NSMutableArray *beanMutaArray = [[db queryReportRelaBean:[NSNumber numberWithInteger:_cup.curveId]] mutableCopy];
    for (int i = 0; i < [beanMutaArray count]; i++) {
        BeanModel *beanModelOld = beanMutaArray[i];
        BeanModel *beanModelNew = [db queryBean:[NSNumber numberWithInteger:beanModelOld.beanId]];
        beanModelNew.weight = beanModelOld.weight;
        beanModelNew.beanId = beanModelOld.beanId;
        [beanMutaArray replaceObjectAtIndex:i withObject:beanModelNew];
    }
    //可能没有添加生豆数据
    _beanArray = [beanMutaArray copy];
    [self.bakeDetailTable reloadData];
}

#pragma mark - Actions
- (void)editCup{
    CupTestEditController *editVC = [[CupTestEditController alloc] init];
    editVC.cup = _cup;
    editVC.editBlock = ^(CupModel *cup) {
        self.cup = cup;
        [self.cupDetailTable reloadData];
        [self queryReportInfo];
    };
    [self.navigationController pushViewController:editVC animated:YES];
}
@end
