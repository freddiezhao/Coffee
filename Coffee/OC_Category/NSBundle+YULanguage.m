//
//  NSBundle+YULanguage.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2019/7/9.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "NSBundle+YULanguage.h"
#import <objc/runtime.h>
#import "YULanguageManager.h"

@interface YUBundle : NSBundle

@end


@implementation YUBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    if ([YUBundle yu_mainBundle]) {
        return [[YUBundle yu_mainBundle] localizedStringForKey:key value:value table:tableName];
    } else {
        return [super localizedStringForKey:key value:value table:tableName];
    }
}

+ (NSBundle *)yu_mainBundle {
    if ([NSBundle currentLanguage].length) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSBundle currentLanguage] ofType:@"lproj"];
        if ([self isChineseLanguage]) {
            path = [[NSBundle mainBundle] pathForResource:@"zh-Hans" ofType:@"lproj"];
        }
        if (path.length) {
            return [NSBundle bundleWithPath:path];
        }
    }
    return nil;
}

@end


@implementation NSBundle (YULanguage)

+ (BOOL)isChineseLanguage {
    NSString *currentLanguage = [self currentLanguage];
    if ([currentLanguage hasPrefix:@"zh-Hans"]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)currentLanguage {
    return [YULanguageManager userLanguage] ? : [NSLocale preferredLanguages].firstObject;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //动态继承、交换，方法类似KVO，通过修改[NSBundle mainBundle]对象的isa指针，使其指向它的子类CLBundle，这样便可以调用子类的方法；其实这里也可以使用method_swizzling来交换mainBundle的实现，来动态判断，可以同样实现。
        object_setClass([NSBundle mainBundle], [YUBundle class]);
    });
}

@end
