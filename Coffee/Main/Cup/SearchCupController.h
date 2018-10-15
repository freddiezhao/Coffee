//
//  SearchCupController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/11.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^dismissBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface SearchCupController : UIViewController

@property (nonatomic, strong) NSMutableArray *cupArr;
@property (nonatomic) dismissBlock dismissBlock;

@end

NS_ASSUME_NONNULL_END
