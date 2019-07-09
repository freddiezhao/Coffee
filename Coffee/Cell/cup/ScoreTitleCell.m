//
//  ScoreTitleCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "ScoreTitleCell.h"

@implementation ScoreTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!self.nameLabel) {
            _nameLabel = [[UILabel alloc] init];
            _nameLabel.font = [UIFont systemFontOfSize:17.f];
            _nameLabel.backgroundColor = [UIColor clearColor];
            _nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            _nameLabel.textAlignment = NSTextAlignmentCenter;
            _nameLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_nameLabel];
            
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(120/WScale, 24/HScale));
                make.centerX.equalTo(self.contentView.mas_centerX);
                make.top.equalTo(self.contentView.mas_top).offset(25/HScale);
            }];
        }

        UIView *line1 = [[UIView alloc] init];
        line1.layer.backgroundColor = [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1].CGColor;
        [self.contentView addSubview:line1];
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100/WScale, 1/HScale));
            make.centerY.equalTo(_nameLabel.mas_centerY);
            make.right.equalTo(_nameLabel.mas_left).offset(-15/WScale);
        }];
        
        UIView *line2 = [[UIView alloc] init];
        line2.layer.backgroundColor = [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1].CGColor;
        [self.contentView addSubview:line2];
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100/WScale, 1/HScale));
            make.centerY.equalTo(_nameLabel.mas_centerY);
            make.left.equalTo(_nameLabel.mas_right).offset(15/WScale);
        }];
    }
    return self;
}

@end
