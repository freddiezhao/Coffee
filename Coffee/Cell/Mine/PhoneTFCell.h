//
//  PhoneTFCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/19.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TFBlock)(NSString *text);

@interface PhoneTFCell : UITableViewCell

@property (nonatomic, strong) UITextField *phoneTF;
@property (nonatomic) TFBlock TFBlock;

@end

