//
//  BeanViewController_bakeAdd.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^popBlock)(BeanModel *bean);

@interface BeanViewController_bakeAdd : UIViewController

@property (nonatomic) popBlock popBlock;
@property (nonatomic, strong) NSMutableArray *beanArray;
@end
