//
//  CurrentCurveCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CurrentCurveCell.h"

@implementation CurrentCurveCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_beanDeviceName) {
            _beanDeviceName = [[UILabel alloc] init];
            _beanDeviceName.textColor = [UIColor colorWithHexString:@"333333"];
            _beanDeviceName.font = [UIFont systemFontOfSize:16.0];
            _beanDeviceName.textAlignment = NSTextAlignmentLeft;
            _beanDeviceName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_beanDeviceName];
            
            [_beanDeviceName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(200/WScale, 23/HScale));
                make.left.equalTo(self.contentView.mas_left).offset(15/WScale);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_dateLabel) {
            _dateLabel = [[UILabel alloc] init];
            _dateLabel.textColor = [UIColor colorWithHexString:@"999999"];
            _dateLabel.font = [UIFont systemFontOfSize:14.0];
            _dateLabel.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_dateLabel];
            
            [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(150/WScale, 20/HScale));
                make.right.equalTo(self.contentView.mas_right).offset(-15/WScale);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
