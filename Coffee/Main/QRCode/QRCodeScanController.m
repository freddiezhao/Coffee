//
//  QRCodeScanController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "QRCodeScanController.h"
#import <AVFoundation/AVFoundation.h>

@interface QRCodeScanController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *scanLayer;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) UIView *borderView;

@end

@implementation QRCodeScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self codeScan];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

#pragma mark - Actions
- (void)codeScan
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied)
    {
        [NSObject showHudTipStr:LocalString(@"请到隐私设置中开启相机使用权限")];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device) {
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            [self.session addInput:input];
            
            [self.session addOutput:self.output];
            [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
        }
        [self.view.layer addSublayer:self.scanLayer];
        self.output.rectOfInterest = CGRectMake(150/ScreenHeight, 0.1, 150/ScreenHeight+0.8*ScreenWidth/ScreenHeight, 0.9);
        [self.view addSubview:self.borderView];
        [self.session startRunning];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
        if (object.stringValue.length == 24){
            [self addSharedCurveWithCurveUid:object.stringValue];
        }else{
            [NSObject showHudTipStr:LocalString(@"曲线的二维码信息错误")];
            [self.session stopRunning];
            [self.scanLayer removeFromSuperlayer];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self.session stopRunning];
        [self showAlert];
    }
}

- (void)showAlert{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"未扫描正确的设备数据,是否继续" preferredStyle:UIAlertControllerStyleAlert];
    alertController.view.tintColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.session startRunning];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)addSharedCurveWithCurveUid:(NSString *)curveUid{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roastCurve/share?curveUid=%@",curveUid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    
    
    [manager POST:url parameters:nil progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
              NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
              NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                  NSLog(@"success:%@",daetr);
                  [NSObject showHudTipStr:LocalString(@"添加分享曲线成功")];
                  [self.session stopRunning];
                  [self.scanLayer removeFromSuperlayer];
                  [self.navigationController popViewControllerAnimated:YES];
              }else{
                  [NSObject showHudTipStr:LocalString(@"添加分享曲线失败")];
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
              });
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
              [NSObject showHudTipStr:LocalString(@"添加分享曲线失败")];
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
              });
          }];
}

#pragma mark - Lazyload
- (AVCaptureSession *)session
{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)scanLayer
{
    if (!_scanLayer) {
        _scanLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _scanLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _scanLayer.frame = self.view.bounds;
    }
    return _scanLayer;
}

- (AVCaptureMetadataOutput *)output
{
    if (!_output) {
        _output = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    return _output;
}

- (UIView *)borderView
{
    if (!_borderView) {
        _borderView = [[UIView alloc] initWithFrame:CGRectMake(0.1 * ScreenWidth, 150, 0.8 *ScreenWidth, 0.8*ScreenWidth)];
        _borderView.layer.borderColor = [UIColor whiteColor].CGColor;
        _borderView.layer.borderWidth = 2.0f;
    }
    return _borderView;
}



@end
