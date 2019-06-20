//
//  ReportEditController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/10.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ReportModel;

typedef void(^editBlock)(void);

@interface ReportEditController : BaseViewController

@property (nonatomic, strong) NSMutableArray *beanArray;
@property (nonatomic, strong) ReportModel *reportModel;
@property (nonatomic) editBlock editBlock;


@end
