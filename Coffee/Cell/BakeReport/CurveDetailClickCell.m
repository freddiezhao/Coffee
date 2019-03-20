//
//  CurveDetailClickCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2019/3/20.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "CurveDetailClickCell.h"

@implementation CurveDetailClickCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_detailLabel) {
            _detailLabel = [[UILabel alloc] init];
            _detailLabel.numberOfLines = 0;
            _detailLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
            _detailLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            _detailLabel.textAlignment = NSTextAlignmentCenter;
            _detailLabel.text = LocalString(@"查看详情");
            _detailLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_detailLabel];
            [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(60.f, 20.f));
                make.centerX.equalTo(self.contentView.mas_centerX);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_image) {
            _image = [[UIImageView alloc] init];
            _image.image = [UIImage imageNamed:@"ic_arrow"];
            [self.contentView addSubview:_image];
            [_image mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(18.f, 18.f));
                make.left.equalTo(self.detailLabel.mas_right);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
