//
//  CupTestEditController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CupTestEditController.h"
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

NSString *const CellIdentifier_cupEditCupName = @"CellID_cupEditCupName";
NSString *const CellIdentifier_cupEditLight = @"CellID_cupEditLight";
NSString *const CellIdentifier_cupEditBeanHeader = @"CellID_cupEditBeanHeader";
NSString *const CellIdentifier_cupEditBeanInfo = @"CellID_cupEditBeanInfo";
NSString *const CellIdentifier_cupEditCurve = @"CellID_cupEditCurve";

@interface CupTestEditController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISegmentedControl *mySegment;

@property (nonatomic, strong) UITableView *cupEditTable;
@property (nonatomic, strong) UITableView *bakeEditTable;
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

@implementation CupTestEditController
static float HEIGHT_HEADER = 36.f;

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
    self.cupEditTable = [self cupEditTable];
    self.bakeEditTable = [self bakeEditTable];
    self.noReportView = [self noReportView];
    
    [self queryReportInfo];
}

#pragma mark - Lazyload
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"编辑杯测");
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"保存") style:UIBarButtonItemStylePlain target:self action:@selector(saveCup)];
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

- (UITableView *)cupEditTable{
    if (!_cupEditTable) {
        _cupEditTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 44/HScale, ScreenWidth, ScreenHeight - 64 - 44/HScale) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            [tableView registerClass:[EditCupNameCell class] forCellReuseIdentifier:CellIdentifier_cupEditCupName];
            [tableView registerClass:[EditLightCell class] forCellReuseIdentifier:CellIdentifier_cupEditLight];
            tableView;
        });
    }
    return _cupEditTable;
}

- (UITableView *)bakeEditTable{
    if (!_bakeEditTable) {
        _bakeEditTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 44.f/HScale, ScreenWidth, ScreenHeight - 64 - 44.f/HScale) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.hidden = YES;
            [tableView registerClass:[BeanHeaderCell class] forCellReuseIdentifier:CellIdentifier_cupEditBeanHeader];
            [tableView registerClass:[BeanInfoCell class] forCellReuseIdentifier:CellIdentifier_cupEditBeanInfo];
            [tableView registerClass:[ReportCurveCell class] forCellReuseIdentifier:CellIdentifier_cupEditCurve];
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
    return _bakeEditTable;
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
            _cupEditTable.hidden = NO;
            _bakeEditTable.hidden = YES;
            _noReportView.hidden = YES;
        }
            break;
        case 1:
        {
            _cupEditTable.hidden = YES;
            if (!_cup.curveId) {
                _bakeEditTable.hidden = YES;
                _noReportView.hidden = NO;
            }else{
                _bakeEditTable.hidden = NO;
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
    if (tableView == _cupEditTable) {
        return 2;
    }else{
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _cupEditTable) {
        switch (section) {
            case 0:
                return 1;
                break;
                
            case 1:
                return 1;
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
    if (tableView == _cupEditTable) {
        switch (indexPath.section) {
            case 0:
                return 50.f/HScale;
                break;
                
            case 1:
                return 256.f/HScale;
                break;
                
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
    if (tableView == _cupEditTable) {
        if (indexPath.section == 0) {
            EditCupNameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupEditCupName];
            if (cell == nil) {
                cell = [[EditCupNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupEditCupName];
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
            EditLightCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupEditLight];
            if (cell == nil) {
                cell = [[EditLightCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupEditLight];
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
        }else{
            EditCupNameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupEditCupName];
            if (cell == nil) {
                cell = [[EditCupNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupEditCupName];
            }
            return cell;
        }
    }else{
        if (indexPath.section == 0){
            if (indexPath.row == 0) {
                BeanHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupEditBeanHeader];
                if (cell == nil) {
                    cell = [[BeanHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupEditBeanHeader];
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
                BeanInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupEditBeanInfo];
                if (cell == nil) {
                    cell = [[BeanInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupEditBeanInfo];
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
            ReportCurveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_cupEditCurve];
            if (cell == nil) {
                cell = [[ReportCurveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_cupEditCurve];
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
    if (tableView == _cupEditTable) {
        switch (section) {
            case 0:
            case 1:
            {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 15.f/HScale)];
                headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
                return headerView;
            }
                break;
                
            case 2:
            {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER/HScale)];
                headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
                
                UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(11/WScale, 0, 200/WScale, HEIGHT_HEADER/HScale)];
                textLabel.textColor = [UIColor colorWithHexString:@"999999"];
                textLabel.font = [UIFont systemFontOfSize:14.f];
                textLabel.textAlignment = NSTextAlignmentLeft;
                textLabel.backgroundColor = [UIColor clearColor];
                [headerView addSubview:textLabel];
                textLabel.text = LocalString(@"烘焙度");
                
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
    if (tableView == _cupEditTable) {
        switch (section) {
            case 0:
            case 1:
                return 15.f/HScale;
                break;
                
            case 2:
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
    [self.bakeEditTable reloadData];
}

#pragma mark - Action
- (void)saveCup{
    BOOL result = [[DataBase shareDataBase] updateCup:_cup];
    if (result) {
        if (self.editBlock) {
            self.editBlock(_cup);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [NSObject showHudTipStr:LocalString(@"保存失败")];
    }
}

- (void)selectCurve{
    ReportSelectController *selectVC =[[ReportSelectController alloc] init];
    selectVC.selBlock = ^(NSInteger curveId) {
        if (_mySegment.selectedSegmentIndex == 1) {
            self.bakeEditTable.hidden = NO;
            self.noReportView.hidden = YES;
        }
        _cup.curveId = curveId;
        [self queryReportInfo];
    };
    [self.navigationController pushViewController:selectVC animated:YES];
}
@end