//
//  FeedTextFieldCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/12.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TFBlock)(NSString *text);

NS_ASSUME_NONNULL_BEGIN

@interface FeedTextFieldCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *contentTF;
@property (nonatomic) TFBlock TFBlock;

@end

NS_ASSUME_NONNULL_END
