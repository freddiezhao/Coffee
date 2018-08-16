//
//  DeviceSelectCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/13.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceSelectCell.h"

@implementation DeviceSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_checkBtn) {
            _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_checkBtn setImage:[UIImage imageNamed:@"untick"] forState:UIControlStateNormal];
            [_checkBtn addTarget:self action:@selector(checkDevice) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_checkBtn];
            [_checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(18 / WScale, 18 / HScale));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.contentView.mas_left).offset(15 / WScale);
            }];
        }
        if (!_image) {
            _image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
            _image.frame = CGRectMake(20, (viewHeight - 30) / 2, 30, 30);
            [self.contentView addSubview:_image];
            [_image mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(90 / WScale, 60 / HScale));
                make.left.equalTo(self.contentView.mas_left).offset(45 / WScale);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_deviceName) {
            _deviceName = [[UILabel alloc] init];
            _deviceName.textColor = [UIColor blackColor];
            _deviceName.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
            _deviceName.frame = CGRectMake(0, 0, 100, viewHeight - 30);
            _deviceName.center = self.center;
            [self.contentView addSubview:_deviceName];
            [_deviceName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(140 / WScale, 21 / HScale));
                make.left.equalTo(self.contentView.mas_left).offset(145 / WScale);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
