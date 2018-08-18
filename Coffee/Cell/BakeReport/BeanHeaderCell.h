//
//  BeanHeaderCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/18.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeanHeaderCell : UITableViewCell

@property (nonatomic, strong) UIImageView *beanImage;
@property (nonatomic, strong) UILabel *beanNameLabel;
@property (nonatomic, strong) UILabel *rawBean;
@property (nonatomic, strong) UILabel *bakedBean;
@property (nonatomic, strong) UILabel *outWaterRate;

@end
