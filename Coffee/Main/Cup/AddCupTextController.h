//
//  AddCupTextController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^dismissBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface AddCupTextController : UIViewController

@property (nonatomic) dismissBlock disBlock;

@end

NS_ASSUME_NONNULL_END
