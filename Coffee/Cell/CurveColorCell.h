//
//  CurveColorCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^actionBlock)(void);

@interface CurveColorCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) UIButton *selectBtn;
@property (assign, nonatomic) actionBlock block;

@end
