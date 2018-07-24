//
//  SubtitileCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "SubtitileCell.h"

@implementation SubtitileCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] init];
            _titleLabel.textColor = [UIColor blackColor];
            _titleLabel.font = [UIFont systemFontOfSize:17.0];
            _titleLabel.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_titleLabel];
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(150, cellHeight));
                make.top.equalTo(self.contentView.mas_top);
                make.left.equalTo(self.contentView.mas_left).offset(20);
            }];
        }
        if (!_subtitleLabel) {
            _subtitleLabel = [[UILabel alloc] init];
            _subtitleLabel.textColor = [UIColor darkTextColor];
            _subtitleLabel.font = [UIFont systemFontOfSize:13.0];
            _subtitleLabel.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_subtitleLabel];
            [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(150, cellHeight / 2));
                make.top.equalTo(self.titleLabel.mas_bottom);
                make.left.equalTo(self.contentView.mas_left).offset(20);
            }];
        }
    }
    return self;
}


@end
