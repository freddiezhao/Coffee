//
//  EditLightCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/11.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "EditLightCell.h"

@implementation EditLightCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self) {
        if (!_nameLabel) {
            _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15/WScale, 15/HScale, 180/WScale, 21/HScale)];
            _nameLabel.textColor = [UIColor colorWithHexString:@"222222"];
            _nameLabel.font = [UIFont systemFontOfSize:15.0];
            _nameLabel.textAlignment = NSTextAlignmentLeft;
            _nameLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_nameLabel];
        }
        
        if (!_circleView) {
            _circleView = [[UIView alloc] initWithFrame:CGRectMake(125/WScale, 56/HScale, 125/WScale, 125/HScale)];
            _circleView.layer.backgroundColor = [UIColor colorWithRed:99/255.0 green:84/255.0 blue:71/255.0 alpha:1].CGColor;
            _circleView.layer.cornerRadius = 125 / WScale / 2;
            [self.contentView addSubview:_circleView];
            
            UILabel *lightText = [[UILabel alloc] initWithFrame:CGRectMake(30/WScale, 22/HScale, 66/WScale, 27/HScale)];
            lightText.text = LocalString(@"Light");
            lightText.textColor = [UIColor colorWithHexString:@"FFFFFF"];
            lightText.font = [UIFont systemFontOfSize:19.0];
            lightText.textAlignment = NSTextAlignmentCenter;
            lightText.adjustsFontSizeToFitWidth = YES;
            [_circleView addSubview:lightText];
            
            _lightValue = [[UILabel alloc] initWithFrame:CGRectMake(32/WScale, 44/HScale, 61/WScale, 49/HScale)];
            _lightValue.textColor = [UIColor colorWithHexString:@"FFFFFF"];
            _lightValue.text = @"50";
            _lightValue.font = [UIFont fontWithName:@"Avenir" size:36.0];
            _lightValue.adjustsFontSizeToFitWidth = YES;
            _lightValue.textAlignment = NSTextAlignmentCenter;
            [_circleView addSubview:_lightValue];
            
            UILabel *tipText = [[UILabel alloc] initWithFrame:CGRectMake(17/WScale, 84/HScale, 91/WScale, 20/HScale)];
            tipText.text = LocalString(@"(Agtron)");
            tipText.textColor = [UIColor colorWithHexString:@"FFFFFF"];
            tipText.font = [UIFont systemFontOfSize:14.0];
            tipText.adjustsFontSizeToFitWidth = YES;
            tipText.textAlignment = NSTextAlignmentCenter;
            [_circleView addSubview:tipText];
        }
        if (!_lightSlider) {
            _lightSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 300/WScale, 15/HScale)];
            [self.contentView addSubview:_lightSlider];
            _lightSlider.minimumValue = 0;
            _lightSlider.maximumValue = 100;
            _lightSlider.value = 50;
            _lightSlider.continuous = YES;
            _lightSlider.layer.cornerRadius = 15/2.f/HScale;
            [_lightSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            [self.contentView bringSubviewToFront:_lightSlider];
            
            [_lightSlider mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(300/WScale, 15/HScale));
                make.centerX.equalTo(self.contentView.mas_centerX);
                make.top.equalTo(_circleView.mas_bottom).offset(30/HScale);
            }];
            
            //隐藏slider横条
            [_lightSlider setMinimumTrackTintColor:[UIColor clearColor]];
            [_lightSlider setMaximumTrackTintColor:[UIColor clearColor]];
            // gradient
            CAGradientLayer *gl = [CAGradientLayer layer];
            gl.frame = CGRectMake(0,0,300/WScale,15/HScale);
            [self.lightSlider.layer addSublayer:gl];
            gl.startPoint = CGPointMake(0, 0.5);
            gl.endPoint = CGPointMake(1, 0.5);
            gl.colors = @[(__bridge id)[UIColor colorWithRed:164/255.0 green:155/255.0 blue:127/255.0 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:180/255.0 green:146/255.0 blue:121/255.0 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:135/255.0 green:110/255.0 blue:88/255.0 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:123/255.0 green:101/255.0 blue:80/255.0 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:104/255.0 green:89/255.0 blue:74/255.0 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:99/255.0 green:84/255.0 blue:71/255.0 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:104/255.0 green:91/255.0 blue:76/255.0 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:63/255.0 green:64/255.0 blue:56/255.0 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:58/255.0 green:62/255.0 blue:53/255.0 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:21/255.0 green:31/255.0 blue:27/255.0 alpha:1].CGColor];
            gl.locations = @[@(0), @(0.1f), @(0.2f), @(0.3f), @(0.4f), @(0.6f), @(0.7f), @(0.8f), @(0.9f), @(1.0f)];
            gl.cornerRadius = 15.f/2/HScale;
        }
    }
    return self;
}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.lightValue.text = [NSString stringWithFormat:@"%d",(int)slider.value];
    if (self.SliderBlock) {
        self.SliderBlock(slider.value);
    }
}

- (UIImage*)imageFromColor:(UIColor*)color size:(CGSize)size
{
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width,size.height);
    UIGraphicsBeginImageContext(size);//创建图片
    CGContextRef context = UIGraphicsGetCurrentContext();//创建图片上下文
    CGContextSetFillColorWithColor(context, [color CGColor]);//设置当前填充颜色的图形上下文
    CGContextFillRect(context, rect);//填充颜色
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
