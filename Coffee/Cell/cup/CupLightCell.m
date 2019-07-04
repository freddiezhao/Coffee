//
//  CupLightCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CupLightCell.h"

@implementation CupLightCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self) {
        if (!self.nameLabel) {
            _nameLabel = [[UILabel alloc] init];
            _nameLabel.font = [UIFont systemFontOfSize:17.f];
            _nameLabel.backgroundColor = [UIColor clearColor];
            _nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            _nameLabel.textAlignment = NSTextAlignmentCenter;
            _nameLabel.adjustsFontSizeToFitWidth = YES;
            _nameLabel.text = LocalString(@"烘焙度");
            [self.contentView addSubview:_nameLabel];
            
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(60/WScale, 24/HScale));
                make.centerX.equalTo(self.contentView.mas_centerX);
                make.top.equalTo(self.contentView.mas_top).offset(20/HScale);
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
        
        if (!_circleView) {
            _circleView = [[UIView alloc] initWithFrame:CGRectMake(125/WScale, 64/HScale, 125/WScale, 125/HScale)];
            _circleView.layer.backgroundColor = [UIColor colorWithRed:99/255.0 green:84/255.0 blue:71/255.0 alpha:1].CGColor;
            _circleView.layer.cornerRadius = 125 / WScale / 2;
            [self.contentView addSubview:_circleView];
            
            UILabel *lightText = [[UILabel alloc] initWithFrame:CGRectMake(40/WScale, 22/HScale, 46/WScale, 27/HScale)];
            lightText.text = LocalString(@"Light");
            lightText.textColor = [UIColor colorWithHexString:@"FFFFFF"];
            lightText.font = [UIFont systemFontOfSize:19.0];
            lightText.textAlignment = NSTextAlignmentCenter;
            [_circleView addSubview:lightText];
            
            _lightValue = [[UILabel alloc] initWithFrame:CGRectMake(42/WScale, 44/HScale, 41/WScale, 49/HScale)];
            _lightValue.textColor = [UIColor colorWithHexString:@"FFFFFF"];
            _lightValue.font = [UIFont fontWithName:@"Avenir" size:36.0];
            _lightValue.textAlignment = NSTextAlignmentCenter;
            [_circleView addSubview:_lightValue];
            
            UILabel *tipText = [[UILabel alloc] initWithFrame:CGRectMake(27/WScale, 84/HScale, 71/WScale, 20/HScale)];
            tipText.text = LocalString(@"(Agtron)");
            tipText.textColor = [UIColor colorWithHexString:@"FFFFFF"];
            tipText.font = [UIFont systemFontOfSize:14.0];
            tipText.textAlignment = NSTextAlignmentCenter;
            [_circleView addSubview:tipText];
        }
    }
    return self;
}

- (void)setCircleViewColor:(CGFloat)light{
    CGFloat location = light / 100;
    if (location < 0.1) {
        _circleView.layer.backgroundColor = [UIColor colorWithRed:164/255.0 green:155/255.0 blue:127/255.0 alpha:1].CGColor;
    }else if (location < 0.2){
        _circleView.layer.backgroundColor = [UIColor colorWithRed:180/255.0 green:146/255.0 blue:121/255.0 alpha:1].CGColor;
    }else if (location < 0.3){
        _circleView.layer.backgroundColor = [UIColor colorWithRed:135/255.0 green:110/255.0 blue:88/255.0 alpha:1].CGColor;
    }else if (location < 0.4){
        _circleView.layer.backgroundColor = [UIColor colorWithRed:123/255.0 green:101/255.0 blue:80/255.0 alpha:1].CGColor;
    }else if (location < 0.6){
        _circleView.layer.backgroundColor = [UIColor colorWithRed:104/255.0 green:89/255.0 blue:74/255.0 alpha:1].CGColor;
    }else if (location < 0.7){
        _circleView.layer.backgroundColor = [UIColor colorWithRed:99/255.0 green:84/255.0 blue:71/255.0 alpha:1].CGColor;
    }else if (location < 0.8){
        _circleView.layer.backgroundColor = [UIColor colorWithRed:104/255.0 green:91/255.0 blue:76/255.0 alpha:1].CGColor;
    }else if (location < 0.9){
        _circleView.layer.backgroundColor = [UIColor colorWithRed:63/255.0 green:64/255.0 blue:56/255.0 alpha:1].CGColor;
    }else if (location < 1.0){
        _circleView.layer.backgroundColor = [UIColor colorWithRed:58/255.0 green:62/255.0 blue:53/255.0 alpha:1].CGColor;
    }else{
        _circleView.layer.backgroundColor = [UIColor colorWithRed:21/255.0 green:31/255.0 blue:27/255.0 alpha:1].CGColor;
    }
}

@end
