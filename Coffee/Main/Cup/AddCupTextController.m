//
//  AddCupTextController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "AddCupTextController.h"
#import "TouchTableView.h"
#import "BeanHeaderCell.h"
#import "BeanInfoCell.h"
#import "ReportCurveCell.h"
#import "ReportModel.h"
#import "BeanModel.h"
#import "EditCupNameCell.h"
#import "EditLightCell.h"
#import "ReportSelectController.h"
#import "CupModel.h"
#import "ScoreTitleCell.h"
#import "AllScoreCell.h"

NSString *const CellIdentifier_cupAddCupName = @"CellID_cupAddCupName";
NSString *const CellIdentifier_cupAddLight = @"CellID_cupAddLight";
NSString *const CellIdentifier_cupAddBeanHeader = @"CellID_cupAddBeanHeader";
NSString *const CellIdentifier_cupAddBeanInfo = @"CellID_cupAddBeanInfo";
NSString *const CellIdentifier_cupAddCurve = @"CellID_cupAddCurve";
NSString *const CellIdentifier_cupAddScoreTitle = @"CellID_cupAddScoreTitle";
NSString *const CellIdentifier_cupAddGoodScore = @"CellID_cupAddGoodScore";
NSString *const CellIdentifier_cupAddBadScore = @"CellID_cupAddBadScore";

@interface AddCupTextController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISegmentedControl *mySegment;

@property (nonatomic, strong) UITableView *cupAddTable;
@property (nonatomic, strong) UITableView *bakeAddTable;
@property (nonatomic, strong) UIView *noReportView;
//report
@property (nonatomic, strong) ReportModel *reportModel;
@property (nonatomic, strong) NSArray *beanArray;
@property (nonatomic, strong) NSMutableArray *yVals_Out;
@property (nonatomic, strong) NSMutableArray *yVals_In;
@property (nonatomic, strong) NSMutableArray *yVals_Bean;
@property (nonatomic, strong) NSMutableArray *yVals_Environment;
@property (nonatomic, strong) NSMutableArray *yVals_Diff;

@property (nonatomic, strong) CupModel *cup;

@end

@implementation AddCupTextController

- (void)viewDidLoad {
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
    self.cupAddTable = [self cupAddTable];
    self.bakeAddTable = [self bakeAddTable];
    self.noReportView = [self noReportView];
    
    _cup = [[CupModel alloc] init];
    [self queryReportInfo];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

#pragma mark - Lazyload
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"添加杯测");
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"保存") style:UIBarButtonItemStylePlain target:self action:@selector(saveCupInfo)];
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

- (UITableView *)cupAddTable{
    if (!_cupAddTable) {
        _cupAddTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 44/HScale, ScreenWidth, ScreenHeight - 64 - 44/HScale) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            //tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.dataSource = self;
            tableView.delegate = self;
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            [tableView registerClass:[EditCupNameCell class] forCellReuseIdentifier:CellIdentifier_cupAddCupName];
            [tableView registerClass:[EditLightCell class] forCellReuseIdentifier:CellIdentifier_cupAddLight];
            [tableView registerClass:[ScoreTitleCell class] forCellReuseIdentifier:CellIdentifier_cupAddScoreTitle];
            [tableView registerClass:[AllScoreCell class] forCellReuseIdentifier:CellIdentifier_cupAddGoodScore];
            [tableView registerClass:[AllScoreCell class] forCellReuseIdentifier:CellIdentifier_cupAddBadScore];
            tableView;
        });
    }
    return _cupAddTable;
}

- (UITableView *)bakeAddTable{
    if (!_bakeAddTable) {
        _bakeAddTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 44.f/HScale, ScreenWidth, ScreenHeight - 64 - 44.f/HScale) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.hidden = YES;
            [tableView registerClass:[BeanHeaderCell class] forCellReuseIdentifier:CellIdentifier_cupAddBeanHeader];
            [tableView registerClass:[BeanInfoCell class] forCellReuseIdentifier:CellIdentifier_cupAddBeanInfo];
            [tableView registerClass:[ReportCurveCell class] forCellReuseIdentifier:CellIdentifier_cupAddCurve];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            
            UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 86/HScale)];
            footView.backgroundColor = [UIColor clearColor];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:LocalString(@"重新选择曲线") forState:UIControlStateNormal];
            button.frame = CGRectMake(0, 0, 156/WScale, 36/HScale);
            [button.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
            [button setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(selectCurve) forControlEvents:UIControlEventTouchUpInside];
            button.center = footView.center;
            button.layer.borderWidth = 0.5;
            button.layer.borderColor = [UIColor colorWithHexString:@"4778CC"].CGColor;
            button.layer.cornerRadius = 18.f;
            [footView addSubview:button];
            
            tableView.tableFooterView = footView;
            
            tableView;
        });
    }
    return _bakeAddTable;
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
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:LocalString(@"选择烘焙曲线") forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        [button setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectCurve) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundColor:[UIColor colorWithHexString:@"4778CC"]];
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = [UIColor colorWithHexString:@"4778CC"].CGColor;
        button.layer.cornerRadius = 25.f/HScale;
        [_noReportView addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(345/WScale, 50/HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(imageView.mas_bottom).offset(20/HScale);
            
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
            _cupAddTable.hidden = NO;
            _bakeAddTable.hidden = YES;
            _noReportView.hidden = YES;
        }
            break;
        case 1:
        {
            _cupAddTable.hidden = YES;
            if (!_cup.curveUid) {
                _bakeAddTable.hidden = YES;
                _noReportView.hidden = NO;
            }else{
                _bakeAddTable.hidden = NO;
                _noReportView.hidden = YES;
                [self queryReportInfo];
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == _cupAddTable) {
        return 4;
    }else{
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _cupAddTable) {
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
    if (tableView == _cupAddTable) {
        switch (indexPath.section) {
            case 0:
                return 50.f/HScale;
                break;
                
            case 1:
                return 256.f/HScale;
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
    if (tableView == _cupAddTable) {
        if (indexPath.section == 0) {
            EditCupNameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupAddCupName];
            if (cell == nil) {
                cell = [[EditCupNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupAddCupName];
            }
            cell.nameLabel.text = LocalString(@"杯测名称");
            if (_cup.name) {
                cell.contentTF.text = _cup.name;
            }else{
                cell.contentTF.text = @"";
            }
            cell.TFBlock = ^(NSString *text) {
                _cup.name = text;
            };
            return cell;
        }else if (indexPath.section == 1){
            EditLightCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupAddLight];
            if (cell == nil) {
                cell = [[EditLightCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupAddLight];
            }
            if (_cup.light) {
                cell.lightValue.text = [NSString stringWithFormat:@"%d",(int)_cup.light];
            }else{
                cell.lightValue.text = @"0";
            }
            cell.lightSlider.value = _cup.light;
            cell.SliderBlock = ^(float value) {
                _cup.light = value;
            };
            return cell;
        }else if (indexPath.section == 2){
            if (indexPath.row == 0) {
                ScoreTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupAddScoreTitle];
                if (cell == nil) {
                    cell = [[ScoreTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupAddScoreTitle];
                }
                cell.nameLabel.text = LocalString(@"咖啡杯测");
                return cell;
            }else{
                AllScoreCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[AllScoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupAddGoodScore];
                }
                switch (indexPath.row) {
                    case 1:
                    {
                        cell.nameLabel.text = LocalString(@"干湿香");
                        [cell setSliderValue:_cup.dryAndWet];
                        cell.SliderBlock = ^(float value) {
                            _cup.dryAndWet = value/10.f;
                        };
                    }
                        break;
                    case 2:
                    {
                        cell.nameLabel.text = LocalString(@"风味");
                        [cell setSliderValue:_cup.flavor];
                        cell.SliderBlock = ^(float value) {
                            _cup.flavor = value/10.f;
                        };
                    }
                        break;
                    case 3:
                    {
                        cell.nameLabel.text = LocalString(@"余韵");
                        [cell setSliderValue:_cup.aftermath];
                        cell.SliderBlock = ^(float value) {
                            _cup.aftermath = value/10.f;
                        };
                    }
                        break;
                    case 4:
                    {
                        cell.nameLabel.text = LocalString(@"酸质");
                        [cell setSliderValue:_cup.acid];
                        cell.SliderBlock = ^(float value) {
                            _cup.acid = value/10.f;
                        };
                    }
                        break;
                    case 5:
                    {
                        cell.nameLabel.text = LocalString(@"口感");
                        [cell setSliderValue:_cup.taste];
                        cell.SliderBlock = ^(float value) {
                            _cup.taste = value/10.f;
                        };
                        
                    }
                        break;
                    case 6:
                    {
                        cell.nameLabel.text = LocalString(@"甜度");
                        [cell setSliderValue:_cup.sweet];
                        cell.SliderBlock = ^(float value) {
                            _cup.sweet = value/10.f;
                        };
                    }
                        break;
                    case 7:
                    {
                        cell.nameLabel.text = LocalString(@"均匀度");
                        [cell setSliderValue:_cup.balance];
                        cell.SliderBlock = ^(float value) {
                            _cup.balance = value/10.f;
                        };
                    }
                        break;
                    case 8:
                    {
                        cell.nameLabel.text = LocalString(@"整体感受");
                        [cell setSliderValue:_cup.overFeel];
                        cell.SliderBlock = ^(float value) {
                            _cup.overFeel = value/10.f;
                        };
                    }
                        break;
                    default:
                        break;
                }
                NSArray *colors = @[[UIColor colorWithRed:255/255.0 green:232/255.0 blue:159/255.0 alpha:1], [UIColor colorWithRed:255/255.0 green:204/255.0 blue:102/255.0 alpha:1]];
                UIImage *image = [cell getGradientImageWithColors:colors imgSize:cell.scoreSlider.bounds.size];
                [cell.scoreSlider setMinimumTrackImage:image forState:UIControlStateNormal];
                
                return cell;
            }
        }else if (indexPath.section == 3){
            if (indexPath.row == 0) {
                ScoreTitleCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[ScoreTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupAddScoreTitle];
                }
                cell.nameLabel.text = LocalString(@"烘焙瑕疵");
                return cell;
            }else{
                AllScoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupAddBadScore];
                if (cell == nil) {
                    cell = [[AllScoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupAddBadScore];
                }
                switch (indexPath.row) {
                    case 1:
                    {
                        cell.nameLabel.text = LocalString(@"发展不充分");
                        [cell setSliderValue:_cup.deveUnfull];
                        cell.SliderBlock = ^(float value) {
                            _cup.deveUnfull = value/10.f;
                        };
                    }
                        break;
                    case 2:
                    {
                        cell.nameLabel.text = LocalString(@"过度发展");
                        [cell setSliderValue:_cup.overDeve];
                        cell.SliderBlock = ^(float value) {
                            _cup.overDeve = value/10.f;
                        };
                    }
                        break;
                    case 3:
                    {
                        cell.nameLabel.text = LocalString(@"烤焙味");
                        [cell setSliderValue:_cup.bakePaste];
                        cell.SliderBlock = ^(float value) {
                            _cup.bakePaste = value/10.f;
                        };
                    }
                        break;
                    case 4:
                    {
                        cell.nameLabel.text = LocalString(@"自焙烫伤");
                        [cell setSliderValue:_cup.injure];
                        cell.SliderBlock = ^(float value) {
                            _cup.injure = value/10.f;
                        };
                    }
                        break;
                    case 5:
                    {
                        cell.nameLabel.text = LocalString(@"胚芽烫伤");
                        [cell setSliderValue:_cup.germInjure];
                        cell.SliderBlock = ^(float value) {
                            _cup.germInjure = value/10.f;
                        };
                    }
                        break;
                    case 6:
                    {
                        cell.nameLabel.text = LocalString(@"豆表烫伤");
                        [cell setSliderValue:_cup.beanFaceInjure];
                        cell.SliderBlock = ^(float value) {
                            _cup.beanFaceInjure = value/10.f;
                        };
                    }
                        break;
                    default:
                        break;
                }
                NSArray *colors = @[[UIColor colorWithRed:236/255.0 green:224/255.0 blue:203/255.0 alpha:1], [UIColor colorWithRed:214/255.0 green:181/255.0 blue:128/255.0 alpha:1]];;
                UIImage *image = [cell getGradientImageWithColors:colors imgSize:cell.scoreSlider.bounds.size];
                [cell.scoreSlider setMinimumTrackImage:image forState:UIControlStateNormal];
                return cell;
            }
        }else{
            EditCupNameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupAddCupName];
            if (cell == nil) {
                cell = [[EditCupNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupAddCupName];
            }
            return cell;
        }
    }else{
        if (indexPath.section == 0){
            if (indexPath.row == 0) {
                BeanHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupAddBeanHeader];
                if (cell == nil) {
                    cell = [[BeanHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupAddBeanHeader];
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
                BeanInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupAddBeanInfo];
                if (cell == nil) {
                    cell = [[BeanInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupAddBeanInfo];
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
            ReportCurveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupAddCurve];
            if (cell == nil) {
                cell = [[ReportCurveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupAddCurve];
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
    if (tableView == _cupAddTable) {
        switch (section) {
            case 0:
            case 1:
            case 2:
            case 3:
            {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 15.f/HScale)];
                headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
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
    if (tableView == _cupAddTable) {
        switch (section) {
            case 0:
            case 1:
            case 2:
            case 3:
                return 15.f/HScale;
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
    NSMutableArray *beanMutaArray = [[db queryReportRelaBean:_cup.curveUid] mutableCopy];
    for (int i = 0; i < [beanMutaArray count]; i++) {
        BeanModel *beanModelOld = beanMutaArray[i];
        BeanModel *beanModelNew = [db queryBean:beanModelOld.beanUid];
        beanModelNew.weight = beanModelOld.weight;
        beanModelNew.beanId = beanModelOld.beanId;
        [beanMutaArray replaceObjectAtIndex:i withObject:beanModelNew];
    }
    //可能没有添加生豆数据
    _beanArray = [beanMutaArray copy];
    [self.bakeAddTable reloadData];
}

#pragma mark - Action
- (void)saveCupInfo{
    if (!_cup.name) {
        [NSObject showHudTipStr:LocalString(@"名字不能为空")];
        return;
    }
    if (_cup.curveUid == nil) {
        _cup.curveUid = @"";
    }
    [_cup caculateGrade];
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/cupping"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"name":_cup.name,@"curveUid":_cup.curveUid,@"roastDegree":[NSNumber numberWithFloat:_cup.light],@"aroma":[NSNumber numberWithFloat:_cup.dryAndWet],@"flavor":[NSNumber numberWithFloat:_cup.flavor],@"aftertaste":[NSNumber numberWithFloat:_cup.aftermath],@"acidity":[NSNumber numberWithFloat:_cup.acid],@"taste":[NSNumber numberWithFloat:_cup.taste],@"sweetness":[NSNumber numberWithFloat:_cup.sweet],@"balance":[NSNumber numberWithFloat:_cup.balance],@"overall":[NSNumber numberWithFloat:_cup.overFeel],@"undevelopment":[NSNumber numberWithFloat:_cup.deveUnfull],@"overdevelopment":[NSNumber numberWithFloat:_cup.overDeve],@"baked":[NSNumber numberWithFloat:_cup.bakePaste],@"scorched":[NSNumber numberWithFloat:_cup.injure],@"tipped":[NSNumber numberWithFloat:_cup.germInjure],@"faced":[NSNumber numberWithFloat:_cup.beanFaceInjure],@"score":[NSNumber numberWithFloat:_cup.bakeGrade],@"defects":[NSNumber numberWithFloat:_cup.defectGrade],@"total":[NSNumber numberWithFloat:_cup.grade]};
    
    [manager POST:url parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
              NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
              NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                  NSLog(@"success:%@",daetr);
                  if ([responseDic objectForKey:@"data"]) {
                      NSDictionary *beansDic = [responseDic objectForKey:@"data"];
                      _cup.cupUid = [beansDic objectForKey:@"cupUid"];
                      BOOL result = [[DataBase shareDataBase] insertNewCup:_cup];
                      if (result) {
                          if (self.disBlock) {
                              self.disBlock();
                          }
                          [self dismissViewControllerAnimated:YES completion:nil];
                          [NSObject showHudTipStr:LocalString(@"添加本地杯测成功")];
                      }else{
                          [NSObject showHudTipStr:LocalString(@"添加本地杯测失败")];
                      }
                  }
              }else{
                  [NSObject showHudTipStr:LocalString(@"杯测信息插入服务器失败")];
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
              });
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
              [NSObject showHudTipStr:LocalString(@"杯测信息插入服务器失败")];
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
              });
          }];
    
}

- (void)selectCurve{
    ReportSelectController *selectVC =[[ReportSelectController alloc] init];
    selectVC.selBlock = ^(NSString *curveUid) {
        if (_mySegment.selectedSegmentIndex == 1) {
            self.bakeAddTable.hidden = NO;
            self.noReportView.hidden = YES;
        }
        _cup.curveUid = curveUid;
        [self queryReportInfo];
    };
    [self.navigationController pushViewController:selectVC animated:YES];
}
@end

