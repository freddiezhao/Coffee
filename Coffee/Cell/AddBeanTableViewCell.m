//
//  AddBeanTableViewCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/16.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "AddBeanTableViewCell.h"

@implementation AddBeanTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_numLabel) {
            _numLabel = [[UILabel alloc] init];
            _numLabel.textColor = [UIColor blackColor];
            _numLabel.font = [UIFont systemFontOfSize:13.0];
            [self.contentView addSubview:_numLabel];
            [_numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(20, 30));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.contentView.mas_left).offset(20);
            }];
        }
        if (!_image) {
            _image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_bake_bean"]];
            _image.frame = CGRectMake(20, (viewHeight - 30) / 2, 30, 30);
            [self.contentView addSubview:_image];
            [_image mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(30, 30));
                make.centerX.equalTo(self.contentView.mas_centerX).offset(-ScreenWidth * 0.2);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_beanName) {
            _beanName = [[UILabel alloc] init];
            _beanName.textColor = [UIColor blackColor];
            _beanName.font = [UIFont systemFontOfSize:13.0];
            _beanName.frame = CGRectMake(0, 0, 100, viewHeight - 30);
            _beanName.center = self.center;
            [self.contentView addSubview:_beanName];
        }
        if (!_weightTF) {
            _weightTF = [[UITextField alloc] init];
            _weightTF.text = @"10g";
            _weightTF.font = [UIFont systemFontOfSize:13.f];
            [self.contentView addSubview:_weightTF];
            [_weightTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(80, viewHeight - 10));
                make.left.equalTo(_beanName.mas_right);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_deleteBtn) {
            _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_deleteBtn setImage:[UIImage imageNamed:@"ic_bake_dialog_delete"] forState:UIControlStateNormal];
            [_deleteBtn addTarget:self action:@selector(deleteCell) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_deleteBtn];
            [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(30, 30));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.right.equalTo(self.contentView.mas_right).offset(-5);
            }];
        }
    }
    return self;
}

- (void)deleteCell{
    self.delBlock();
}

@end
