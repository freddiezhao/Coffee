//
//  EditLightCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/11.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SliderBlock)(float value);

@interface EditLightCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) UILabel *lightValue;
@property (nonatomic, strong) UISlider *lightSlider;
@property (nonatomic) SliderBlock SliderBlock;

- (void)setCircleViewColor:(CGFloat)light;
@end
