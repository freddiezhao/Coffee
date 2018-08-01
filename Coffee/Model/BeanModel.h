//
//  BeanModel.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeanModel : NSObject

@property (nonatomic) NSInteger beanId;
@property (nonatomic, strong) NSString *beanName;
@property (nonatomic) NSInteger weight;//烘焙中生豆添加重量
@property (nonatomic, strong) NSString *nation;
@property (nonatomic, strong) NSString *area;
@property (nonatomic, strong) NSString *manor;
@property (nonatomic, strong) NSString *altitude;
@property (nonatomic, strong) NSString *beanSpecies;
@property (nonatomic, strong) NSString *grade;
@property (nonatomic, strong) NSString *process;
@property (nonatomic, strong) NSString *water;
@property (nonatomic, strong) NSString *supplier;
@property (nonatomic, strong) NSString *price;
@property (nonatomic) NSInteger stock;
@property (nonatomic, strong) NSDate *time;

@end
