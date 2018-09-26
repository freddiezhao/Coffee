//
//  DetailScoreCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailScoreCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *integerLabel;
@property (nonatomic, strong) UILabel *decimalLabel;
@property (nonatomic, strong) UIView *valueView;

- (void)addGradientLayerWithValue:(float)value colors:(NSArray *)colors;
@end

NS_ASSUME_NONNULL_END
