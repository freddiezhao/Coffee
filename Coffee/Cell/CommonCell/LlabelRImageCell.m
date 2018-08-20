//
//  LlabelRImageCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/19.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "LlabelRImageCell.h"

@implementation LlabelRImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_leftLabel) {
            _leftLabel = [[UILabel alloc] init];
            _leftLabel.textColor = [UIColor blackColor];
            _leftLabel.font = [UIFont systemFontOfSize:17.0];
            _leftLabel.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_leftLabel];
            [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100, 30));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.contentView.mas_left).offset(20);
            }];
        }
        if (!_rightImage) {
            _rightImage = [[UIImageView alloc] init];
            [self.contentView addSubview:_rightImage];
            [_rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(36, 36));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.right.equalTo(self.contentView.mas_right).offset(-20);
            }];
        }
    }
    return self;
}


@end
