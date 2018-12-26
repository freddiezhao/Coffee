//
//  NSData+Common.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/12/22.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Common)

- (NSString *)utf8String;
- (NSString *)IpAddress;

@end

NS_ASSUME_NONNULL_END
