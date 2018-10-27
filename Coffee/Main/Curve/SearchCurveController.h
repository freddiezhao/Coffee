//
//  SearchCurveController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/10.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^dismissBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface SearchCurveController : UIViewController

@property (nonatomic, strong) NSMutableArray *curveArr;
@property (nonatomic) dismissBlock dismissBlock;
@property (nonatomic) BOOL isRela;//是参考曲线的搜索还是曲线页面的搜索

@end

NS_ASSUME_NONNULL_END
