//
//  CurveColorCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CurveColorCell.h"

@implementation CurveColorCell

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
        if (!_selectBtn) {
            _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_selectBtn setTitle:LocalString(@"选择") forState:UIControlStateNormal];
            [_selectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_selectBtn setButtonStyleWithColor:[UIColor blackColor] Width:1.0 cornerRadius:30 * 0.15];
            [_selectBtn setBackgroundColor:[UIColor clearColor]];
            [_selectBtn addTarget:self action:@selector(selectColor) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_selectBtn];
            [_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(55, 30));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.right.equalTo(self.contentView.mas_right).offset(-20);
            }];
        }
        if (!_colorView) {
            _colorView = [[UIView alloc] init];
            _colorView.layer.cornerRadius = 15;
            _colorView.layer.borderColor = [[UIColor blackColor] CGColor];
            _colorView.layer.borderWidth = 0.5;
            [self.contentView addSubview:_colorView];
            [_colorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(30, 30));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.right.equalTo(self.selectBtn.mas_left).offset(-20);
            }];
        }
    }
    return self;
}

- (void)selectColor{
    if (self.block) {
        self.block();
    }
}

@end
