//
//  UIImage+Compression.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2019/4/30.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Compression)

+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength;
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end

NS_ASSUME_NONNULL_END
