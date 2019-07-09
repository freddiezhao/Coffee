//
//  NSBundle+YULanguage.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2019/7/9.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (YULanguage)

/**
 是否是中文
 */
+ (BOOL)isChineseLanguage;

/**
 查询当前语言
 
 @return 当前语言
 */
+ (NSString *)currentLanguage;

@end

NS_ASSUME_NONNULL_END
