//
//  referCurveCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/22.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^curveBlock)(BOOL isOn);

@interface referCurveCell : UITableViewCell

@property (strong, nonatomic)  UILabel *curveLabel;
@property (strong, nonatomic)  UISwitch *curveSwitch;
@property (nonatomic)  curveBlock curveBlock;

@end
