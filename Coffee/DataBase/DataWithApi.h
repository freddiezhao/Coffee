//
//  DataWithApi.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/10.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataWithApi : NSObject

- (void)startGetInfoWithFailBlock:(void(^)(void))failure;

@end

NS_ASSUME_NONNULL_END
