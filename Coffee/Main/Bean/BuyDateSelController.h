//
//  BuyDateSelController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^dateBlock)(NSDate *date);

@interface BuyDateSelController : UIViewController

@property (nonatomic) dateBlock dateBlock;

@end
