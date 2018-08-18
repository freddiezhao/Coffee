//
//  BeanInfoCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/18.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeanInfoCell : UITableViewCell

@property (nonatomic, strong) UILabel *beanName;
@property (nonatomic, strong) UILabel *nation;
@property (nonatomic, strong) UILabel *area;
@property (nonatomic, strong) UILabel *altitude;//海拔
@property (nonatomic, strong) UILabel *manor;
@property (nonatomic, strong) UILabel *beanSpecies;
@property (nonatomic, strong) UILabel *grade;
@property (nonatomic, strong) UILabel *process;//处理方式
@property (nonatomic, strong) UILabel *water;//含水量
@property (nonatomic, strong) UILabel *weight;//烘焙中生豆添加重量

@end
