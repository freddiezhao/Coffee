//
//  FeedTextViewCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/12.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FeedTextViewCell : UITableViewCell <UITextViewDelegate>

@property (nonatomic, strong) UITextView *info;
@property (nonatomic, strong) UILabel *limitLabel;

@end

NS_ASSUME_NONNULL_END
