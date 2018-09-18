//
//  CupTestEditController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CupModel;

typedef void(^editBlock)(CupModel *cup);

@interface CupTestEditController : UIViewController

@property (nonatomic, strong) CupModel *cup;
@property (nonatomic) editBlock editBlock;

@end
