//
//  CollectEventCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/20.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CollectEventCell.h"

@implementation CollectEventCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
        
        _leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewWidth / 3, viewHeight)];
        _leftLabel.textAlignment = NSTextAlignmentCenter;
        _leftLabel.textColor = [UIColor colorWithHexString:@"999999"];
        _leftLabel.font = [UIFont systemFontOfSize:13];
        _leftLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_leftLabel];
        
        _centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth / 3, 0, viewWidth / 3, viewHeight)];
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.textColor = [UIColor colorWithHexString:@"999999"];
        _centerLabel.font = [UIFont systemFontOfSize:13];
        _centerLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_centerLabel];
        
        _rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth / 3 * 2, 0, viewWidth / 3, viewHeight)];
        _rightLabel.textAlignment = NSTextAlignmentCenter;
        _rightLabel.textColor = [UIColor colorWithHexString:@"999999"];
        _rightLabel.font = [UIFont systemFontOfSize:13];
        _rightLabel.backgroundColor = [UIColor clearColor];
        _rightLabel.adjustsFontSizeToFitWidth = YES;
        _rightLabel.numberOfLines = 0;
        [self.contentView addSubview:_rightLabel];
    }
    
    return self;
}

@end
