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
#import "CurveDetailClickCell.h"
#import "ReportCurveDetailController.h"


NSString *const CellIdentifier_cupDetailGrade = @"CellID_cupDetailGrade";
NSString *const CellIdentifier_cupDetailLight = @"CellID_cupDetailLight";
NSString *const CellIdentifier_cupBeanHeader = @"CellID_cupDetailBeanHeader";
NSString *const CellIdentifier_cupBeanInfo = @"CellID_cupDetailBeanInfo";
NSString *const CellIdentifier_cupCurve = @"CellID_cupDetailCurve";
NSString *const CellIdentifier_cupCurveDetail = @"CellID_cupCurveDetail";
NSString *const CellIdentifier_cupScoreTitle = @"CellID_cupScoreTitle";
NSString *const CellIdentifier_cupGoodScore = @"CellID_cupGoodScore";
NSString *const CellIdentifier_cupBadScore = @"CellID_cupBadScore";

@interface CupTestDetailController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISegmentedControl *mySegment;

@property (nonatomic, strong) UITableView *cupDetailTable;
@property (nonatomic, strong) UITableView *bakeDetailTable;
@property (nonatomic, strong) UIView *noReportView;

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
    self.noReportView = [self noReportView];
    _cup = [[DataBase shareDataBase] queryCupWithCupUid:_cup.cupUid];
    [_cup caculateGrade];
    [self.cupDetailTable reloadData];
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
        
        NSArray *titleData = @[LocalString(@"杯测信息"),LocalString(@"烘焙详情")];
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
            [tableView registerClass:[CurveDetailClickCell class] forCellReuseIdentifier:CellIdentifier_cupCurveDetail];
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
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _bakeDetailTable;
}

- (UIView *)noReportView{
    if (!_noReportView) {
        _noReportView = [[UIView alloc] initWithFrame:CGRectMake(0, 44.f/HScale, ScreenWidth, ScreenHeight - 64 - 44.f/HScale)];
        _noReportView.backgroundColor = [UIColor clearColor];
        _noReportView.hidden = YES;
        [self.view addSubview:_noReportView];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.noReportView addSubview:imageView];
        imageView.image = [UIImage imageNamed:@"img_logo_gray"];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(140/WScale, 112/HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(_noReportView.mas_top).offset(85/HScale);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = LocalString(@"没有关联曲线");
        label.font = [UIFont systemFontOfSize:14.f];
        label.textColor = [UIColor colorWithHexString:@"999999"];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        [_noReportView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(345/WScale, 50/HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(imageView.mas_bottom);
        }];

    }
    return _noReportView;
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
            _noReportView.hidden = YES;
        }
            break;
        case 1:
        {
            _cupDetailTable.hidden = YES;
            if (!_cup.curveUid || [_cup.curveUid isEqualToString:@""]) {
                _bakeDetailTable.hidden = YES;
                _noReportView.hidden = NO;
            }else{
                _bakeDetailTable.hidden = NO;
                _noReportView.hidden = YES;
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
                return 2;
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
                if (indexPath.row == 0) {
                    return 202.f/HScale;
                }else{
                    return 40.f;
                }
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
            
            cell.gradeProgress = _cup.bakeGrade/100;
            cell.defectProgress = _cup.defectGrade/30;
            cell.resultProgress = _cup.grade/100;
            cell.bakeGrade.text = [NSString stringWithFormat:@"%.1f",_cup.bakeGrade];
            cell.bakeDefect.text = [NSString stringWithFormat:@"%.1f",_cup.defectGrade];
            cell.result.text = [NSString stringWithFormat:@"%.1f",_cup.grade];
            NSLog(@"%f",_cup.bakeGrade);
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
            [cell setCircleViewColor:_cup.light];
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
                    if (_reportModel.rawBeanWeight == 0) {
                        cell.outWaterRate.text = [NSString stringWithFormat:@"%@%.1f%%",LocalString(@"脱水率:"),0.0f];
                    }else{
                        cell.outWaterRate.text = [NSString stringWithFormat:@"%@%.1lf%%",LocalString(@"脱水率:"),(_reportModel.rawBeanWeight - _reportModel.bakeBeanWeight)/_reportModel.rawBeanWeight*100.f];
                    }
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
                if (bean.name && ![bean.name isEqualToString:@""]) {
                    cell.beanName.attributedText = [self getAttributedString:LocalString(@"名称") appendString:bean.name];
                }else{
                    cell.beanName.attributedText = [self getAttributedString:LocalString(@"名称") appendString:LocalString(@"未知")];
                }
                if (bean.nation && ![bean.nation isEqualToString:@""]) {
                    cell.nation.attributedText = [self getAttributedString:LocalString(@"国家") appendString:bean.nation];
                }else{
                    cell.nation.attributedText = [self getAttributedString:LocalString(@"国家") appendString:LocalString(@"未知")];
                }
                if (bean.area && ![bean.area isEqualToString:@""]) {
                    cell.area.attributedText = [self getAttributedString:LocalString(@"产区") appendString:bean.area];
                }else{
                    cell.area.attributedText = [self getAttributedString:LocalString(@"产区") appendString:LocalString(@"未知")];
                }
                if (bean.manor && ![bean.manor isEqualToString:@""]) {
                    cell.manor.attributedText = [self getAttributedString:LocalString(@"庄园") appendString:bean.manor];
                }else{
                    cell.manor.attributedText = [self getAttributedString:LocalString(@"庄园") appendString:LocalString(@"未知")];
                }
                if (bean.beanSpecies && ![bean.beanSpecies isEqualToString:@""]) {
                    cell.beanSpecies.attributedText = [self getAttributedString:LocalString(@"豆种") appendString:bean.beanSpecies];
                }else{
                    cell.beanSpecies.attributedText = [self getAttributedString:LocalString(@"豆种") appendString:LocalString(@"未知")];
                }
                if (bean.grade && ![bean.grade isEqualToString:@""]) {
                    cell.grade.attributedText = [self getAttributedString:LocalString(@"等级") appendString:bean.grade];
                }else{
                    cell.grade.attributedText = [self getAttributedString:LocalString(@"等级") appendString:LocalString(@"未知")];
                }
                if (bean.process && ![bean.process isEqualToString:@""]) {
                    cell.process.attributedText = [self getAttributedString:LocalString(@"处理方式") appendString:bean.process];
                }else{
                    cell.process.attributedText = [self getAttributedString:LocalString(@"处理方式") appendString:LocalString(@"未知")];
                }
                cell.water.attributedText = [self getAttributedString:LocalString(@"含水量") appendString:[NSString stringWithFormat:@"%.1f",bean.water]];
                cell.weight.attributedText = [self getAttributedString:LocalString(@"生豆重量") appendString:[NSString stringWithFormat:@"%.1f",bean.weight]];
                cell.altitude.attributedText = [self getAttributedString:LocalString(@"海拔") appendString:[NSString stringWithFormat:@"%.1f",bean.altitude]];
                return cell;
            }
        }else{
            if (indexPath.row == 0) {
                ReportCurveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupCurve];
                if (cell == nil) {
                    cell = [[ReportCurveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupCurve];
                }
                if (_yVals_In.count > 0 && _yVals_Out.count > 0 && _yVals_Bean.count > 0 && _yVals_Environment.count > 0) {
                    cell.yVals_In = _yVals_In;
                    cell.yVals_Out = _yVals_Out;
                    cell.yVals_Bean = _yVals_Bean;
                    cell.yVals_Environment = _yVals_Environment;
                    cell.yVals_Diff = _yVals_Diff;
                    [cell setDataValue];
                }
                return cell;
            }else{
                CurveDetailClickCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupCurveDetail];
                if (cell == nil) {
                    cell = [[CurveDetailClickCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupCurveDetail];
                }
                return cell;
            }
        }
    }

}

- (NSMutableAttributedString *)getAttributedString:(NSString *)text appendString:(NSString *)appendStr{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@",text,appendStr]];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"999999"] range:NSMakeRange(0,text.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"333333"] range:NSMakeRange(text.length + 2,str.length - text.length - 2)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.f] range:NSMakeRange(0,text.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.f] range:NSMakeRange(text.length + 2, str.length - text.length - 2)];
    return str;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.bakeDetailTable && indexPath.section == 1 && indexPath.row == 1) {
        ReportCurveDetailController *vc = [[ReportCurveDetailController alloc] init];
        vc.yVals_In = _yVals_In;
        vc.yVals_Out = _yVals_Out;
        vc.yVals_Bean = _yVals_Bean;
        vc.yVals_Environment = _yVals_Environment;
        vc.yVals_Diff = _yVals_Diff;
        [self presentViewController:vc animated:YES completion:nil];
    }
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
    _reportModel = [[DataBase shareDataBase] queryReport:_cup.curveUid];
    _reportModel.curveUid = _cup.curveUid;
    NSLog(@"%@",_reportModel.date);
    if (_reportModel.curveValueJson) {
        NSData *curveData = [_reportModel.curveValueJson dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *curveDic = [NSJSONSerialization JSONObjectWithData:curveData options:NSJSONReadingMutableLeaves error:nil];
        
        NSArray *Bean = [curveDic objectForKey:@"bean"];
        NSArray *Out = [curveDic objectForKey:@"out"];
        NSArray *In = [curveDic objectForKey:@"in"];
        NSArray *Environment = [curveDic objectForKey:@"env"];
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
        _yVals_Diff = [[NetWork shareNetWork] getBeanTempRorWithArr:[Bean mutableCopy]];
    }
    [self queryBeanInfo];
}

- (void)queryBeanInfo{
    if (_reportModel.isShare) {
        [SVProgressHUD show];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 6.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roastCurve/bean/message?curveUid=%@&num=1",_cup.curveUid];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
        
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
        [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
            NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
            NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"success:%@",daetr);
            if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                if ([responseDic objectForKey:@"data"]) {
                    //第一页信息获取
                    NSDictionary *dic = [responseDic objectForKey:@"data"];
                    if ([dic objectForKey:@"beans"]) {
                        NSMutableArray *beanArr = [[NSMutableArray alloc] init];
                        [[dic objectForKey:@"beans"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            BeanModel *bean = [[BeanModel alloc] init];
                            bean.name = [obj objectForKey:@"name"];
                            bean.nation = [obj objectForKey:@"country"];
                            bean.area = [obj objectForKey:@"origin"];
                            bean.grade = [obj objectForKey:@"grade"];
                            bean.process = [obj objectForKey:@"processingMethod"];
                            bean.manor = [obj objectForKey:@"farm"];
                            bean.altitude = [[obj objectForKey:@"altitude"] floatValue];
                            bean.weight = [[obj objectForKey:@"used"] floatValue];
                            [beanArr addObject:bean];
                        }];
                        _beanArray = [beanArr copy];
                        [self.bakeDetailTable reloadData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                        });
                    }
                }
            }else{
                [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error:%@",error);
            if (error.code == -1001) {
                [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
            }else{
                [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }];
    }else{
        DataBase *db = [DataBase shareDataBase];
        NSMutableArray *beanMutaArray = [[db queryReportRelaBean:_cup.curveUid] mutableCopy];
        for (int i = 0; i < [beanMutaArray count]; i++) {
            BeanModel *beanModelOld = beanMutaArray[i];
            BeanModel *beanModelNew = [db queryBean:beanModelOld.beanUid];
            beanModelNew.weight = beanModelOld.weight;
            beanModelNew.beanUid = beanModelOld.beanUid;
            [beanMutaArray replaceObjectAtIndex:i withObject:beanModelNew];
        }
        //可能没有添加生豆数据
        _beanArray = [beanMutaArray copy];
        
        if (_beanArray.count == 0) {
            //没有生豆或者没有曲线的情况下
            BeanModel *bean = [[[DataBase shareDataBase] queryAllBean] objectAtIndex:0];
            _beanArray = @[bean];
        }
        [self.bakeDetailTable reloadData];

    }
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
