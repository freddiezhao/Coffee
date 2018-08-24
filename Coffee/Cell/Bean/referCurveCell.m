//
//在烘焙中添加参考曲线
//
//  referCurveCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/22.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "referCurveCell.h"

@implementation referCurveCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!self.curveLabel) {
            _curveLabel = [[UILabel alloc] init];
            _curveLabel.font = [UIFont systemFontOfSize:16.f];
            _curveLabel.backgroundColor = [UIColor clearColor];
            _curveLabel.textColor = [UIColor colorWithHexString:@"222222"];
            _curveLabel.textAlignment = NSTextAlignmentLeft;
            _curveLabel.text = LocalString(@"参考曲线");
            [self.contentView addSubview:_curveLabel];
            
            [_curveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100/WScale, 23/HScale));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.contentView.mas_left).offset(15/WScale);
            }];
        }
        if (!_curveSwitch) {
            _curveSwitch = [[UISwitch alloc] init];
            _curveSwitch.transform = CGAffineTransformMakeScale(1, 1);
            [_curveSwitch setOn:NO animated:true];
            [_curveSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [self.contentView addSubview:_curveSwitch];
            
            [_curveSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(51/WScale, 31/HScale));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.right.equalTo(self.contentView.mas_right).offset(-15/WScale);
            }];
        }
    }
    return self;
}

- (void)switchAction:(UISwitch *)sender{
    if (self.curveBlock) {
        self.curveBlock(sender.isOn);
    }
}


@end
