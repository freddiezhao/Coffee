//
//  RightFuncController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/16.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^relaSwitch)(BOOL isOn);
@interface RightFuncController : UIViewController

@property (nonatomic) BOOL isRelaOn;
@property (nonatomic) relaSwitch relaSwitch;

@end
