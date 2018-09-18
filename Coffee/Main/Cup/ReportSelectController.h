//
//  ReportSelectController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^selBlock)(NSInteger curveId);

@interface ReportSelectController : UIViewController

@property (nonatomic) selBlock selBlock;

@end
