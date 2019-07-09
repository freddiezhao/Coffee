//
//  YULanguageManager.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2019/7/9.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YULanguageManager : NSObject

/**
 用户自定义使用的语言，当传nil时，等同于resetSystemLanguage
 */
@property (class, nonatomic, strong, nullable) NSString *userLanguage;
/**
 重置系统语言
 */
+ (void)resetSystemLanguage;

@end

NS_ASSUME_NONNULL_END
