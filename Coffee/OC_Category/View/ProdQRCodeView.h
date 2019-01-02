//
//  ProdQRCodeView.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProdQRCodeView : UIViewController

@property (nonatomic, strong) NSString *userName;//用于分享者名字
@property (nonatomic, strong) NSString *curveUid;

- (void)generateQRCode;
@end

NS_ASSUME_NONNULL_END
