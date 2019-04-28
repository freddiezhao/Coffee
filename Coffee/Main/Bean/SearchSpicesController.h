//
//  SearchSpicesController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2019/4/28.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^selBlock)(NSString *spices);

NS_ASSUME_NONNULL_BEGIN

@interface SearchSpicesController : UIViewController

@property (nonatomic, strong) NSMutableArray *beanSpicesArr;
@property (nonatomic) selBlock selBlock;

@end

NS_ASSUME_NONNULL_END
