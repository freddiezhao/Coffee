//
//  YULanguageManager.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2019/7/9.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "YULanguageManager.h"

static NSString *YUUserLanguageKey = @"YUUserLanguageKey";

@implementation YULanguageManager

+ (void)setUserLanguage:(NSString *)userLanguage {
    //跟随手机系统
    if (!userLanguage.length) {
        [self resetSystemLanguage];
        return;
    }
    //用户自定义
    [[NSUserDefaults standardUserDefaults] setValue:userLanguage forKey:YUUserLanguageKey];
    [[NSUserDefaults standardUserDefaults] setValue:@[userLanguage] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)userLanguage {
    return [[NSUserDefaults standardUserDefaults] valueForKey:YUUserLanguageKey];
}

/**
 重置系统语言
 */
+ (void)resetSystemLanguage {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:YUUserLanguageKey];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
