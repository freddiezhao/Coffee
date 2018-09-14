//
//  BeanDetailCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/12.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "BeanDetailCell.h"

@implementation BeanDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!self.nameLabel) {
            _nameLabel = [[UILabel alloc] init];
            _nameLabel.font = [UIFont systemFontOfSize:15.f];
            _nameLabel.backgroundColor = [UIColor clearColor];
            _nameLabel.textColor = [UIColor colorWithHexString:@"222222"];
            _nameLabel.textAlignment = NSTextAlignmentLeft;
            _nameLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_nameLabel];
            
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100/WScale, 21/HScale));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.contentView.mas_left).offset(15/WScale);
            }];
        }
        if (!self.contentLabel) {
            _contentLabel = [[UILabel alloc] init];
            _contentLabel.font = [UIFont systemFontOfSize:15.f];
            _contentLabel.backgroundColor = [UIColor clearColor];
            _contentLabel.textColor = [UIColor colorWithHexString:@"666666"];
            _contentLabel.textAlignment = NSTextAlignmentLeft;
            _contentLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_contentLabel];
            
            [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(200/WScale, 21/HScale));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.nameLabel.mas_right).offset(15/WScale);
            }];
        }
    }
    return self;
}

@end
