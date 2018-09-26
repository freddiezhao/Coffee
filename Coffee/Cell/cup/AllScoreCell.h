//
//  AllScoreCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SliderBlock)(float value);

NS_ASSUME_NONNULL_BEGIN

@interface AllScoreCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *integerLabel;
@property (nonatomic, strong) UILabel *decimalLabel;
@property (nonatomic, strong) UISlider *scoreSlider;
@property (nonatomic) SliderBlock SliderBlock;

-(UIImage *)getGradientImageWithColors:(NSArray*)colors imgSize:(CGSize)imgSize;
- (void)setSliderValue:(float)value;
@end

NS_ASSUME_NONNULL_END
