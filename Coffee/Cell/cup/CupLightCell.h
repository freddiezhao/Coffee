//
//  CupLightCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CupLightCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) UILabel *lightValue;

- (void)setCircleViewColor:(CGFloat)light;
@end
