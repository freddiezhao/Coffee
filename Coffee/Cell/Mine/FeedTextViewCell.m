//
//  FeedTextViewCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/12.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "FeedTextViewCell.h"

@implementation FeedTextViewCell 

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_info) {
            _info = [[UITextView alloc] init];
            _info.backgroundColor = [UIColor whiteColor];
            _info.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.f];
            _info.textColor = [UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1];
            _info.text = LocalString(@"请详细描述您遇到的问题");
            _info.textAlignment = NSTextAlignmentLeft;
            _info.scrollEnabled = NO;
            _info.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            _info.editable = YES;
            _info.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
            _info.delegate = self;
            _info.layer.cornerRadius = 8.f;
            [self.contentView addSubview:_info];
            [_info mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(345/WScale, 208/HScale));
                make.centerX.equalTo(self.contentView.mas_centerX);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_limitLabel) {
            _limitLabel = [[UILabel alloc] init];
            _limitLabel.text = @"0/200";
            _limitLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
            _limitLabel.textColor = [UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1];
            _limitLabel.textAlignment = NSTextAlignmentCenter;
            _limitLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_limitLabel];
            [self.contentView bringSubviewToFront:_limitLabel];
            [_limitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(44/WScale, 21/HScale));
                make.right.equalTo(self.info.mas_right).offset(-12/WScale);
                make.bottom.equalTo(self.info.mas_bottom).offset(-8/HScale);
            }];
        }
    }
    return self;
}

#pragma mark - UITextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"请详细描述您遇到的问题"]) {
        textView.text = @"";
        textView.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length == 0) {
        textView.text = LocalString(@"请详细描述您遇到的问题");
        textView.textColor = [UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1];
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    if ([textView.text length] > 200) {
        textView.text = [textView.text substringWithRange:NSMakeRange(0, 200)];
    }
    _limitLabel.text = [NSString stringWithFormat:@"%ld/200",textView.text.length];
}
@end
