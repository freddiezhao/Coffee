//
//  beanCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "beanCell.h"

@implementation beanCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!self.beanImage) {
            _beanImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
            [self.contentView addSubview:_beanImage];
            
            [_beanImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(32/WScale, 32/WScale));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.contentView.mas_left).offset(15/WScale);
            }];
        }
        if (!self.beanLabel) {
            _beanLabel = [[UILabel alloc] init];
            _beanLabel.font = [UIFont systemFontOfSize:15.f];
            _beanLabel.backgroundColor = [UIColor clearColor];
            _beanLabel.textColor = [UIColor colorWithHexString:@"333333"];
            _beanLabel.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_beanLabel];
            
            [_beanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100/WScale, 21/HScale));
                make.centerY.equalTo(self.contentView.mas_centerY).offset(- 70 / 4/HScale);
                make.left.equalTo(_beanImage.mas_right).offset(15/WScale);
            }];
        }
        
        if (!self.infoLabel) {
            _infoLabel = [[UILabel alloc] init];
            _infoLabel.font = [UIFont systemFontOfSize:14.f];
            _infoLabel.backgroundColor = [UIColor clearColor];
            _infoLabel.textColor = [UIColor colorWithHexString:@"999999"];
            _infoLabel.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_infoLabel];
            
            [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(200/WScale, 20/HScale));
                make.centerY.equalTo(self.contentView.mas_centerY).offset(70 / 4/HScale);
                make.left.equalTo(_beanImage.mas_right).offset(15/WScale);
            }];
        }
        
        if (!self.weightLabel) {
            _weightLabel = [[UILabel alloc] init];
            _weightLabel.font = [UIFont systemFontOfSize:15.f];
            _weightLabel.backgroundColor = [UIColor clearColor];
            _weightLabel.textColor = [UIColor colorWithHexString:@"333333"];
            _weightLabel.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_weightLabel];
            
            [_weightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(80/WScale, 21/HScale));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.right.equalTo(self.contentView.mas_right).offset(-15/WScale);
            }];
        }
    }
    return self;
}

@end
