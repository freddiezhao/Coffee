//
//  ProdQRCodeView.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "ProdQRCodeView.h"
#import <CoreImage/CoreImage.h>

@interface ProdQRCodeView ()

@property (nonatomic, strong) UIView *QRcodeView;
@property (nonatomic, strong) UIImageView *QRImage;

@end

@implementation ProdQRCodeView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];

    _QRcodeView = [self QRcodeView];
}

#pragma mark - Lazy Load
- (UIView *)QRcodeView{
    if (!_QRcodeView) {
        _QRcodeView = [[UIView alloc] init];
        _QRcodeView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        [self.view addSubview:_QRcodeView];
        _QRcodeView.layer.cornerRadius = 6.f;
        [_QRcodeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(270/WScale ,361/HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.centerY.equalTo(self.view.mas_centerY);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = LocalString(@"分享给朋友");
        label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        label.textColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:61/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        [self.QRcodeView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(270/WScale ,21/HScale));
            make.centerX.equalTo(self.QRcodeView.mas_centerX);
            make.top.equalTo(self.QRcodeView.mas_top).offset(20/HScale);
        }];
        
        _QRImage = [[UIImageView alloc] init];
        [self.QRcodeView addSubview:_QRImage];
        [_QRImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200/WScale ,200/HScale));
            make.centerX.equalTo(self.QRcodeView.mas_centerX);
            make.top.equalTo(self.QRcodeView.mas_top).offset(60/HScale);
        }];
        
        UIButton *dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [dismissBtn setTitle:LocalString(@"关闭") forState:UIControlStateNormal];
        [dismissBtn setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
        [dismissBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [dismissBtn setBackgroundColor:[UIColor clearColor]];
        [dismissBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.QRcodeView addSubview:dismissBtn];
        dismissBtn.layer.borderColor = [UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1].CGColor;
        dismissBtn.layer.cornerRadius = 11.f;
        [dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(114/WScale ,44/HScale));
            make.centerX.equalTo(self.QRcodeView.mas_centerX);
            make.bottom.equalTo(self.QRcodeView.mas_bottom).offset(-30/HScale);
        }];
    }
    return _QRcodeView;
}

- (void)generateQRCode{

    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    NSString *info = [NSString stringWithFormat:@"%@:%@",_userName,_curveUid];
    
    NSData *data = [info dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    
    CIImage *image = [filter outputImage];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *qrImage = [self createNonInterpolatedUIImageFormCIImage:image withSize:200.f/WScale];
        dispatch_async(dispatch_get_main_queue(), ^{
            _QRImage.image = qrImage;
        });
    });
}

/**
 *  根据CIImage生成指定大小的UIImage
 *
 *  @param image CIImage
 *  @param size  图片宽度
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
