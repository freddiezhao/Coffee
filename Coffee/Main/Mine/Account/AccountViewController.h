//
//  AccountViewController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/19.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^popBlock)(void);

@interface AccountViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) popBlock popBlock;

@end
