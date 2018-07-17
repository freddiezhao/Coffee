//
//  AddBeanTableViewCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/16.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddBeanTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *beanName;
@property (nonatomic, strong) UITextField *weightTF;
@property (nonatomic, strong) UIButton *deleteBtn;

@end
