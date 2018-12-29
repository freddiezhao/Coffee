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
        if (!_curveName) {
            _curveName = [[UILabel alloc] init];
            _curveName.textColor = [UIColor colorWithHexString:@"333333"];
            _curveName.font = [UIFont systemFontOfSize:16.0];
            _curveName.textAlignment = NSTextAlignmentLeft;
            _curveName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_curveName];
            
            [_curveName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(200/WScale, 23/HScale));
                make.left.equalTo(self.contentView.mas_left).offset(15/WScale);
                make.bottom.equalTo(self.contentView.mas_centerY).offset(-2);
            }];
        }
        if (!_deviceName) {
            _deviceName = [[UILabel alloc] init];
            _deviceName.textColor = [UIColor colorWithHexString:@"999999"];
            _deviceName.font = [UIFont systemFontOfSize:14.0];
            _deviceName.textAlignment = NSTextAlignmentLeft;
            _deviceName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_deviceName];
            
            [_deviceName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(200/WScale, 20/HScale));
                make.left.equalTo(self.contentView.mas_left).offset(15/WScale);
                make.top.equalTo(self.contentView.mas_centerY).offset(2);
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
