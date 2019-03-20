//
//  ReportCurveDetailController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2019/3/20.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReportCurveDetailController : BaseViewController

@property (nonatomic, strong) NSMutableArray *yVals_Out;
@property (nonatomic, strong) NSMutableArray *yVals_In;
@property (nonatomic, strong) NSMutableArray *yVals_Bean;
@property (nonatomic, strong) NSMutableArray *yVals_Environment;
@property (nonatomic, strong) NSMutableArray *yVals_Diff;

@end

NS_ASSUME_NONNULL_END
