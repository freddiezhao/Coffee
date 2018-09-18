//
//  MineNormalCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/18.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "MineNormalCell.h"

@implementation MineNormalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_normalImage) {
            _normalImage = [[UIImageView alloc] init];
            [self.contentView addSubview:_normalImage];
            [_normalImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(20/WScale, 20/HScale));
                make.left.equalTo(self.contentView.mas_left).offset(15/WScale);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_normalLabel) {
            _normalLabel = [[UILabel alloc] init];
            _normalLabel.textColor = [UIColor colorWithHexString:@"222222"];
            _normalLabel.font = [UIFont systemFontOfSize:16.0];
            _normalLabel.textAlignment = NSTextAlignmentLeft;
            _normalLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_normalLabel];
            
            [_normalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(200/WScale, 23/HScale));
                make.left.equalTo(self.normalImage.mas_right).offset(15/WScale);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
