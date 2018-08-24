
//在烘焙中添加参考曲线
//
//  CurveInfoCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CurveInfoCell_add.h"

@implementation CurveInfoCell_add

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!self.titleLabel) {
            _titleLabel = [[UILabel alloc] init];
            _titleLabel.font = [UIFont systemFontOfSize:16.f];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.textColor = [UIColor colorWithHexString:@"222222"];
            _titleLabel.textAlignment = NSTextAlignmentLeft;
            _titleLabel.text = LocalString(@"选择参考曲线");
            [self.contentView addSubview:_titleLabel];
            
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100/WScale, 23/HScale));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.contentView.mas_left).offset(15/WScale);
            }];
        }

        if (!self.curveLabel) {
            _curveLabel = [[UILabel alloc] init];
            _curveLabel.font = [UIFont systemFontOfSize:16.f];
            _curveLabel.backgroundColor = [UIColor clearColor];
            _curveLabel.textColor = [UIColor colorWithHexString:@"222222"];
            _curveLabel.textAlignment = NSTextAlignmentRight;
            _curveLabel.text = LocalString(@"参考曲线");
            [self.contentView addSubview:_curveLabel];
            
            [_curveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(150/WScale, 23/HScale));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.right.equalTo(self.contentView.mas_right).offset(-37/WScale);
            }];
        }
    }
    return self;
}

@end
