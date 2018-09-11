//
//  EditBakeBeanCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/11.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TFBlock)(NSString *text);

@interface EditBakeBeanCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *weightTF;
@property (nonatomic, strong) TFBlock TFBlock;

@end
