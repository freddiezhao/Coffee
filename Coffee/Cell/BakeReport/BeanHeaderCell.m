//
//  BeanHeaderCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/18.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BeanHeaderCell.h"

@implementation BeanHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_beanImage) {
            _beanImage = [[UIImageView alloc] initWithFrame:CGRectMake(15/WScale, 19/HScale, 32/WScale, 32/HScale)];
            [self.contentView addSubview:_beanImage];
        }
        if (!_beanNameLabel) {
            _beanNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62/WScale, 12/HScale, 210/WScale, 20/HScale)];
            _beanNameLabel.textColor = [UIColor colorWithHexString:@"333333"];
            _beanNameLabel.font = [UIFont systemFontOfSize:13.0];
            _beanNameLabel.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_beanNameLabel];
        }
        
        if (!_rawBean) {
            _rawBean = [[UILabel alloc] initWithFrame:CGRectMake(62/WScale, 40/HScale, 80/WScale, 20/HScale)];
            _rawBean.textColor = [UIColor colorWithHexString:@"999999"];
            _rawBean.font = [UIFont systemFontOfSize:13.0];
            _rawBean.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_rawBean];
        }
        
        if (!_bakedBean) {
            _bakedBean = [[UILabel alloc] initWithFrame:CGRectMake(157/WScale, 40/HScale, 80/WScale, 20/HScale)];
            _bakedBean.textColor = [UIColor colorWithHexString:@"999999"];
            _bakedBean.font = [UIFont systemFontOfSize:13.0];
            _bakedBean.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_bakedBean];
        }
        
        if (!_outWaterRate) {
            _outWaterRate = [[UILabel alloc] initWithFrame:CGRectMake(246/WScale, 40/HScale, 87/WScale, 20/HScale)];
            _outWaterRate.textColor = [UIColor colorWithHexString:@"999999"];
            _outWaterRate.font = [UIFont systemFontOfSize:13.0];
            _outWaterRate.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_outWaterRate];
        }
    }
    return self;
}

@end
