//
//  TextFieldCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/20.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TFBlock)(NSString *text);

NS_ASSUME_NONNULL_BEGIN

@interface TextFieldCell : UITableViewCell

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic) TFBlock TFBlock;

@end

NS_ASSUME_NONNULL_END
