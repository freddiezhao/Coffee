//
//  BeanInfoCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/18.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BeanInfoCell.h"

@implementation BeanInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_beanName) {
            UILabel *beanNameText = [[UILabel alloc] initWithFrame:CGRectMake(20/WScale, 12/HScale, 28/WScale, 20/HScale)];
            beanNameText.textColor = [UIColor colorWithHexString:@"999999"];
            beanNameText.font = [UIFont systemFontOfSize:13.0];
            beanNameText.textAlignment = NSTextAlignmentCenter;
            beanNameText.text = LocalString(@"名称");
            [self.contentView addSubview:beanNameText];

            
            _beanName = [[UILabel alloc] initWithFrame:CGRectMake(60/WScale, 12/HScale, 120/WScale, 20/HScale)];
            _beanName.textColor = [UIColor colorWithHexString:@"333333"];
            _beanName.font = [UIFont systemFontOfSize:13.0];
            _beanName.textAlignment = NSTextAlignmentLeft;
            _beanName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_beanName];
        }
        
        if (!_nation) {
            UILabel *nationText = [[UILabel alloc] initWithFrame:CGRectMake(20/WScale, 40/HScale, 28/WScale, 20/HScale)];
            nationText.textColor = [UIColor colorWithHexString:@"999999"];
            nationText.font = [UIFont systemFontOfSize:13.0];
            nationText.textAlignment = NSTextAlignmentCenter;
            nationText.text = LocalString(@"国家");
            [self.contentView addSubview:nationText];
            
            _nation = [[UILabel alloc] initWithFrame:CGRectMake(60/WScale, 40/HScale, 120/WScale, 20/HScale)];
            _nation.textColor = [UIColor colorWithHexString:@"333333"];
            _nation.font = [UIFont systemFontOfSize:13.0];
            _nation.textAlignment = NSTextAlignmentLeft;
            _nation.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_nation];
        }
        
        if (!_area) {
            UILabel *areaText = [[UILabel alloc] initWithFrame:CGRectMake(20/WScale, 68/HScale, 28/WScale, 20/HScale)];
            areaText.textColor = [UIColor colorWithHexString:@"999999"];
            areaText.font = [UIFont systemFontOfSize:13.0];
            areaText.textAlignment = NSTextAlignmentCenter;
            areaText.text = LocalString(@"产区");
            [self.contentView addSubview:areaText];
            
            _area = [[UILabel alloc] initWithFrame:CGRectMake(60/WScale, 68/HScale, 120/WScale, 20/HScale)];
            _area.textColor = [UIColor colorWithHexString:@"333333"];
            _area.font = [UIFont systemFontOfSize:13.0];
            _area.textAlignment = NSTextAlignmentLeft;
            _area.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_area];
        }
        
        if (!_altitude) {
            UILabel *altitudeText = [[UILabel alloc] initWithFrame:CGRectMake(20/WScale, 96/HScale, 28/WScale, 20/HScale)];
            altitudeText.textColor = [UIColor colorWithHexString:@"999999"];
            altitudeText.font = [UIFont systemFontOfSize:13.0];
            altitudeText.textAlignment = NSTextAlignmentCenter;
            altitudeText.text = LocalString(@"海拔");
            [self.contentView addSubview:altitudeText];
            
            _altitude = [[UILabel alloc] initWithFrame:CGRectMake(60/WScale, 96/HScale, 120/WScale, 20/HScale)];
            _altitude.textColor = [UIColor colorWithHexString:@"333333"];
            _altitude.font = [UIFont systemFontOfSize:13.0];
            _altitude.textAlignment = NSTextAlignmentLeft;
            _altitude.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_altitude];
        }
        
        if (!_manor) {
            UILabel *manorText = [[UILabel alloc] initWithFrame:CGRectMake(20/WScale, 124/HScale, 28/WScale, 20/HScale)];
            manorText.textColor = [UIColor colorWithHexString:@"999999"];
            manorText.font = [UIFont systemFontOfSize:13.0];
            manorText.textAlignment = NSTextAlignmentCenter;
            manorText.text = LocalString(@"庄园");
            [self.contentView addSubview:manorText];
            
            _manor = [[UILabel alloc] initWithFrame:CGRectMake(60/WScale, 124/HScale, 120/WScale, 20/HScale)];
            _manor.textColor = [UIColor colorWithHexString:@"333333"];
            _manor.font = [UIFont systemFontOfSize:13.0];
            _manor.textAlignment = NSTextAlignmentLeft;
            _manor.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_manor];
        }
        
        if (!_beanSpecies) {
            UILabel *beanSpeciesText = [[UILabel alloc] initWithFrame:CGRectMake(203/WScale, 12/HScale, 28/WScale, 20/HScale)];
            beanSpeciesText.textColor = [UIColor colorWithHexString:@"999999"];
            beanSpeciesText.font = [UIFont systemFontOfSize:13.0];
            beanSpeciesText.textAlignment = NSTextAlignmentCenter;
            beanSpeciesText.text = LocalString(@"豆种");
            [self.contentView addSubview:beanSpeciesText];
            
            _beanSpecies = [[UILabel alloc] initWithFrame:CGRectMake(243/WScale, 12/HScale, 120/WScale, 20/HScale)];
            _beanSpecies.textColor = [UIColor colorWithHexString:@"333333"];
            _beanSpecies.font = [UIFont systemFontOfSize:13.0];
            _beanSpecies.textAlignment = NSTextAlignmentLeft;
            _beanSpecies.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_beanSpecies];
        }
        
        if (!_grade) {
            UILabel *gradeText = [[UILabel alloc] initWithFrame:CGRectMake(203/WScale, 40/HScale, 28/WScale, 20/HScale)];
            gradeText.textColor = [UIColor colorWithHexString:@"999999"];
            gradeText.font = [UIFont systemFontOfSize:13.0];
            gradeText.textAlignment = NSTextAlignmentCenter;
            gradeText.text = LocalString(@"等级");
            [self.contentView addSubview:gradeText];
            
            _grade = [[UILabel alloc] initWithFrame:CGRectMake(243/WScale, 40/HScale, 120/WScale, 20/HScale)];
            _grade.textColor = [UIColor colorWithHexString:@"333333"];
            _grade.font = [UIFont systemFontOfSize:13.0];
            _grade.textAlignment = NSTextAlignmentLeft;
            _grade.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_grade];
        }
        
        if (!_process) {
            UILabel *processText = [[UILabel alloc] initWithFrame:CGRectMake(203/WScale, 68/HScale, 56/WScale, 20/HScale)];
            processText.textColor = [UIColor colorWithHexString:@"999999"];
            processText.font = [UIFont systemFontOfSize:13.0];
            processText.textAlignment = NSTextAlignmentCenter;
            processText.text = LocalString(@"处理方式");
            [self.contentView addSubview:processText];
            
            _process = [[UILabel alloc] initWithFrame:CGRectMake(271/WScale, 68/HScale, 120/WScale, 20/HScale)];
            _process.textColor = [UIColor colorWithHexString:@"333333"];
            _process.font = [UIFont systemFontOfSize:13.0];
            _process.textAlignment = NSTextAlignmentLeft;
            _process.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_process];
        }
        
        if (!_water) {
            UILabel *waterText = [[UILabel alloc] initWithFrame:CGRectMake(203/WScale, 96/HScale, 42/WScale, 20/HScale)];
            waterText.textColor = [UIColor colorWithHexString:@"999999"];
            waterText.font = [UIFont systemFontOfSize:13.0];
            waterText.textAlignment = NSTextAlignmentCenter;
            waterText.text = LocalString(@"含水量");
            [self.contentView addSubview:waterText];
            
            _water = [[UILabel alloc] initWithFrame:CGRectMake(267/WScale, 96/HScale, 120/WScale, 20/HScale)];
            _water.textColor = [UIColor colorWithHexString:@"333333"];
            _water.font = [UIFont systemFontOfSize:13.0];
            _water.textAlignment = NSTextAlignmentLeft;
            _water.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_water];
        }
        
        if (!_weight) {
            UILabel *weightText = [[UILabel alloc] initWithFrame:CGRectMake(203/WScale, 124/HScale, 56/WScale, 20/HScale)];
            weightText.textColor = [UIColor colorWithHexString:@"999999"];
            weightText.font = [UIFont systemFontOfSize:13.0];
            weightText.textAlignment = NSTextAlignmentCenter;
            weightText.text = LocalString(@"生豆重量");
            [self.contentView addSubview:weightText];
            
            _weight = [[UILabel alloc] initWithFrame:CGRectMake(271/WScale, 124/HScale, 120/WScale, 20/HScale)];
            _weight.textColor = [UIColor colorWithHexString:@"333333"];
            _weight.font = [UIFont systemFontOfSize:13.0];
            _weight.textAlignment = NSTextAlignmentLeft;
            _weight.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_weight];
        }
    }
    return self;
}
@end
