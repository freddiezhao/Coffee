//
//  ReportLightCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "ReportLightCell.h"

@implementation ReportLightCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self) {
        if (!_bakeDate) {
            _bakeDate = [[UILabel alloc] initWithFrame:CGRectMake(15/WScale, 10/HScale, 180/WScale, 17/HScale)];
            _bakeDate.textColor = [UIColor colorWithHexString:@"999999"];
            _bakeDate.font = [UIFont systemFontOfSize:12.0];
            _bakeDate.textAlignment = NSTextAlignmentLeft;
            _bakeDate.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_bakeDate];
        }
        
        if (!_deviceName) {
            _deviceName = [[UILabel alloc] initWithFrame:CGRectMake(219/WScale, 10/HScale, 141/WScale, 17/HScale)];
            _deviceName.textColor = [UIColor colorWithHexString:@"999999"];
            _deviceName.font = [UIFont systemFontOfSize:12.0];
            _deviceName.textAlignment = NSTextAlignmentRight;
            _deviceName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_deviceName];
        }
        
        if (!_circleView) {
            _circleView = [[UIView alloc] initWithFrame:CGRectMake(125/WScale, 51/HScale, 125/WScale, 125/HScale)];
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
            _lightValue.adjustsFontSizeToFitWidth = YES;
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

@end
