//
//  DetailScoreCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DetailScoreCell.h"

@implementation DetailScoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self) {
        if (!self.nameLabel) {
            _nameLabel = [[UILabel alloc] init];
            _nameLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
            _nameLabel.backgroundColor = [UIColor clearColor];
            _nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            _nameLabel.textAlignment = NSTextAlignmentLeft;
            _nameLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_nameLabel];
            
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(80/WScale, 23/HScale));
                make.left.equalTo(self.contentView.mas_left).offset(20/WScale);
                make.top.equalTo(self.contentView.mas_top).offset(15/HScale);
            }];
        }
        
        if (!_integerLabel) {
            _integerLabel = [[UILabel alloc] init];
            _integerLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
            _integerLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
            _integerLabel.text = @"0";
            _integerLabel.textAlignment = NSTextAlignmentCenter;
            _integerLabel.adjustsFontSizeToFitWidth = YES;
            _integerLabel.layer.backgroundColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1].CGColor;
            _integerLabel.layer.cornerRadius = 2.f/WScale;
            [self.contentView addSubview:_integerLabel];
            
            [_integerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(14/WScale, 18/HScale));
                make.centerY.equalTo(self.nameLabel.mas_centerY);
                make.left.equalTo(self.nameLabel.mas_right).offset(10/HScale);
            }];
        }
        
        UILabel *dot = [[UILabel alloc] init];
        dot.text = @".";
        dot.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
        dot.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        dot.textAlignment = NSTextAlignmentJustified;
        [self.contentView addSubview:dot];
        [dot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(5/WScale, 15/HScale));
            make.centerY.equalTo(_nameLabel.mas_centerY);
            make.left.equalTo(_integerLabel.mas_right).offset(2/WScale);
        }];
        
        if (!_decimalLabel) {
            _decimalLabel = [[UILabel alloc] init];
            _decimalLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
            _decimalLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
            _decimalLabel.text = @"0";
            _decimalLabel.textAlignment = NSTextAlignmentCenter;
            _decimalLabel.adjustsFontSizeToFitWidth = YES;
            _decimalLabel.layer.backgroundColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1].CGColor;
            _decimalLabel.layer.cornerRadius = 2.f/WScale;
            [self.contentView addSubview:_decimalLabel];
            
            [_decimalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(14/WScale, 18/HScale));
                make.centerY.equalTo(self.nameLabel.mas_centerY);
                make.left.equalTo(dot.mas_right).offset(2/HScale);
            }];
        }
        
        _valueView = [[UIView alloc] init];
        _valueView.layer.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1].CGColor;
        _valueView.layer.cornerRadius = 7.5/HScale;
        [self.contentView addSubview:_valueView];
        [_valueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(335/WScale, 15/HScale));
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.top.equalTo(self.contentView.mas_top).offset(63/HScale);
        }];
    }
    return self;
}

- (void)addGradientLayerWithValue:(float)value colors:(NSArray *)colors{
    // gradient
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,value/10.f*(335.f/WScale),15/HScale);
    gl.startPoint = CGPointMake(0, 0.5);
    gl.endPoint = CGPointMake(1, 0.5);
    gl.colors = colors;
    gl.locations = @[@(0), @(1.0f)];
    gl.cornerRadius = 15.f/HScale/2;
    [_valueView.layer addSublayer:gl];
    
    value = value * 10.f;
    self.integerLabel.text = [NSString stringWithFormat:@"%d",(int)value/10];
    self.decimalLabel.text = [NSString stringWithFormat:@"%d",(int)value%10];
}
@end

