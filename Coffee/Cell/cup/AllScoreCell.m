//
//  AllScoreCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "AllScoreCell.h"
#import "HeightSlider.h"

@implementation AllScoreCell

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
        
        if (!_scoreSlider) {
            _scoreSlider = [[HeightSlider alloc] initWithFrame:CGRectMake(0, 0, 335/WScale, 30/HScale)];
            [self.contentView addSubview:_scoreSlider];
            _scoreSlider.minimumValue = 0;
            _scoreSlider.maximumValue = 100;
            _scoreSlider.value = 0;
            _scoreSlider.continuous = YES;
            _scoreSlider.layer.cornerRadius = 15/2.f/HScale;
            _scoreSlider.layer.masksToBounds = YES;
            [_scoreSlider setMaximumTrackTintColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]];
            [_scoreSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            [self.contentView bringSubviewToFront:_scoreSlider];
            [_scoreSlider setMinimumTrackTintColor:[UIColor clearColor]];
            [_scoreSlider setThumbImage:[UIImage imageNamed:@"img_slider"] forState:UIControlStateNormal];
            [_scoreSlider setThumbImage:[UIImage imageNamed:@"img_slider"] forState:UIControlStateHighlighted];

            [_scoreSlider mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(335/WScale, 15/HScale));
                make.centerX.equalTo(self.contentView.mas_centerX);
                make.top.equalTo(self.contentView.mas_top).offset(63/HScale);
            }];
            
        }
    }
    return self;
}

-(UIImage *)getGradientImageWithColors:(NSArray*)colors imgSize:(CGSize)imgSize
{
    NSMutableArray *arRef = [NSMutableArray array];
    for(UIColor *ref in colors) {
        [arRef addObject:(id)ref.CGColor];
        
    }
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)arRef, NULL);
    CGPoint start = CGPointMake(0.0, 0.0);
    CGPoint end = CGPointMake(imgSize.width, imgSize.height);
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.integerLabel.text = [NSString stringWithFormat:@"%d",(int)slider.value/10];
    self.decimalLabel.text = [NSString stringWithFormat:@"%d",(int)slider.value%10];
    if (self.SliderBlock) {
        self.SliderBlock(slider.value);
    }
}

- (void)setSliderValue:(float)value{
    value = value * 10.f;
    self.scoreSlider.value = value;
    self.integerLabel.text = [NSString stringWithFormat:@"%d",(int)value/10];
    self.decimalLabel.text = [NSString stringWithFormat:@"%d",(int)value%10];
}
@end
