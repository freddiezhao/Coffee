//
//  CollectInfoCellCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/20.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CollectInfoCellCell.h"

@implementation CollectInfoCellCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 9/HScale, viewWidth, 19/HScale)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"999999"];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabel];
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45/HScale, viewWidth, 19/HScale)];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.textColor = [UIColor colorWithHexString:@"333333"];
        _valueLabel.font = [UIFont systemFontOfSize:13];
        _valueLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_valueLabel];
    }
    
    return self;
}

@end
