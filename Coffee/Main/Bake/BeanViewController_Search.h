//
//  BeanViewController_Search.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2019/7/9.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^dismissBlock)(BeanModel *bean);

NS_ASSUME_NONNULL_BEGIN

@interface BeanViewController_Search : UIViewController

@property (nonatomic, strong) NSMutableArray *beanArr;
@property (nonatomic) dismissBlock dismissBlock;

@end

NS_ASSUME_NONNULL_END
