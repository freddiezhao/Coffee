//
//  BeanModel.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeanModel : NSObject

@property (nonatomic, strong) NSString *beanUid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) float weight;//烘焙中生豆添加重量
@property (nonatomic, strong) NSString *nation;
@property (nonatomic, strong) NSString *area;
@property (nonatomic, strong) NSString *manor;
@property (nonatomic) float altitude;
@property (nonatomic, strong) NSString *beanSpecies;
@property (nonatomic, strong) NSString *grade;
@property (nonatomic, strong) NSString *process;
@property (nonatomic) float water;
@property (nonatomic, strong) NSString *supplier;
@property (nonatomic) float price;
@property (nonatomic) float stock;
@property (nonatomic, strong) NSDate *time;

@property (nonatomic) NSRange searchRange;//用来改变搜索字体的颜色
@end
