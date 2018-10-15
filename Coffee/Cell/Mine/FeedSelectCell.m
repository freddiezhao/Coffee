//
//  FeedSelectCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/12.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "FeedSelectCell.h"

@implementation FeedSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_checkBtn) {
            _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_checkBtn setImage:[UIImage imageNamed:@"ic_select"] forState:UIControlStateNormal];
            //[_checkBtn addTarget:self action:@selector(checkDeviceType) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_checkBtn];
            [_checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(18 / WScale, 18 / HScale));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.contentView.mas_left).offset(15 / WScale);
            }];
        }
        if (!_infoLabel) {
            _infoLabel = [[UILabel alloc] init];
            _infoLabel.textColor = [UIColor colorWithHexString:@"222222"];
            _infoLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
            _infoLabel.textAlignment = NSTextAlignmentLeft;
            _infoLabel.center = self.center;
            
            [self.contentView addSubview:_infoLabel];
            [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(200 / WScale, 21 / HScale));
                make.left.equalTo(self.contentView.mas_left).offset(48 / WScale);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
