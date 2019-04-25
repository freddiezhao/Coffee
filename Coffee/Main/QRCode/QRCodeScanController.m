//
//  QRCodeScanController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "QRCodeScanController.h"
#import <AVFoundation/AVFoundation.h>
#import "ReportModel.h"
#import "FMDB.h"
#import "MainViewController.h"
#import "ShareReportController.h"

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
        if (object.stringValue.length >= 24){
            [self.session stopRunning];
            NSArray *resultArray = [object.stringValue componentsSeparatedByString:@":"];
            NSLog(@"%@ %@",resultArray[0],resultArray[1]);
            [self addSharedCurveWithCurveUid:resultArray[1] sharerName:resultArray[0]];
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

- (void)addSharedCurveWithCurveUid:(NSString *)curveUid sharerName:(NSString *)sharerName{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roastCurve/share?curveUid=%@&sharerName=%@",curveUid,sharerName];
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
                  [self getFullCurveInfoByApi:curveUid sharerName:sharerName];//获取曲线详细信息
              }else{
                  NSLog(@"error,%@",daetr);
                  [NSObject showHudTipStr:LocalString(@"添加分享曲线失败")];
                  [self showAlert];
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
              });
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
              if (error.code == -1001) {
                  [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
              }else{
                  [NSObject showHudTipStr:LocalString(@"添加分享曲线失败")];
              }
              [self showAlert];
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
              });
          }];
}

- (void)getFullCurveInfoByApi:(NSString *)curveUid sharerName:(NSString *)sharerName{
    [SVProgressHUD showWithStatus:LocalString(@"正在获取曲线信息")];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roastCurve/allReport?curveUid=%@&num=1",curveUid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            if ([responseDic objectForKey:@"data"]) {
                ReportModel *report = [[ReportModel alloc] init];
                //第一页信息获取
                NSDictionary *dic = [responseDic objectForKey:@"data"];
                if ([dic objectForKey:@"roastReportPageOne"]) {
                    NSDictionary *curveDic = [dic objectForKey:@"roastReportPageOne"];
                    report.curveUid = curveUid;
                    report.curveName = [curveDic objectForKey:@"name"];
                    report.deviceName = [curveDic objectForKey:@"roasterName"];
                    report.bakerName = [curveDic objectForKey:@"userName"];
                    report.date = [NSDate UTCDateFromLocalString:[curveDic objectForKey:@"createTime"]];
                    report.light = [[curveDic objectForKey:@"light"] floatValue];
                    report.rawBeanWeight = [[curveDic objectForKey:@"rawBean"] doubleValue];
                    report.bakeBeanWeight = [[curveDic objectForKey:@"cooked"] doubleValue];
                    report.sn = [curveDic objectForKey:@"sn"];
                    report.sharerName = sharerName;
                    report.isShare = 1;
                    
                    if ([curveDic objectForKey:@"beans"]) {
                        [[curveDic objectForKey:@"beans"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
                                //因为是分享曲线，所以把
                                BOOL result = [db executeUpdate:@"INSERT INTO bean_curve (beanUid,curveUid,beanWeight,beanName,nation,area,manor,altitude,beanSpecies,grade,process,water) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",[obj objectForKey:@"beanUid"],report.curveUid,[NSNumber numberWithFloat:[[obj objectForKey:@"used"] floatValue]],[obj objectForKey:@"name"],[obj objectForKey:@"country"],[obj objectForKey:@"origin"],[obj objectForKey:@"farm"],[NSNumber numberWithFloat:[[obj objectForKey:@"altitude"] floatValue]],[obj objectForKey:@"species"],[obj objectForKey:@"grade"],[obj objectForKey:@"processingMethod"],[NSNumber numberWithFloat:[[obj objectForKey:@"waterContent"] floatValue]]];
                                if (!result) {
                                    NSLog(@"插入生豆%@失败",[obj objectForKey:@"name"]);
                                }
                            }];
                        }];
                    }
                    
                }
                NSArray *eventArr = [dic objectForKey:@"eventList"];
                if (eventArr.count > 0) {
                    [eventArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
                            BOOL result = [db executeUpdate:@"INSERT INTO curve_event (curveUid,eventId,eventText,eventTime,eventBeanTemp) VALUES (?,?,?,?,?)",report.curveUid,[NSNumber numberWithInteger:[[obj objectForKey:@"type"] integerValue]],[obj objectForKey:@"content"],[NSNumber numberWithInteger:[[obj objectForKey:@"time"] integerValue]],[NSNumber numberWithDouble:[[obj objectForKey:@"name"] doubleValue]]];
                            if (!result) {
                                NSLog(@"插入事件%@失败",[obj objectForKey:@"content"]);
                            }
                        }];
                    }];
                }
                NSDictionary *curveDataDic = [dic objectForKey:@"curveData"];
                if (curveDataDic != nil) {
                    NSArray *In = [curveDataDic objectForKey:@"in"];
                    NSArray *Out = [curveDataDic objectForKey:@"out"];
                    NSArray *Bean = [curveDataDic objectForKey:@"bean"];
                    NSArray *Environment = [curveDataDic objectForKey:@"env"];
                    
                    NSLog(@"%lu",(unsigned long)Bean.count);
                    NSDictionary *curveValueDic = @{@"out":Out,@"in":In,@"bean":Bean,@"env":Environment};
                    NSData *curveData = [NSJSONSerialization dataWithJSONObject:curveValueDic options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *curveValueJson = [[NSString alloc] initWithData:curveData encoding:NSUTF8StringEncoding];
                    report.curveValueJson = curveValueJson;
                }
                [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
                    BOOL result = [db executeUpdate:@"INSERT INTO curveInfo (curveUid,curveName,date,deviceName,sn,rawBeanWeight,bakeBeanWeight,light,bakeTime,developTime,developRate,bakerName,curveValue,shareName,isShare) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",report.curveUid,report.curveName,[NSDate localStringFromUTCDate:report.date],report.deviceName,report.sn,[NSNumber numberWithFloat:report.rawBeanWeight],[NSNumber numberWithFloat:report.bakeBeanWeight],[NSNumber numberWithFloat:report.light],@0,@0,@0,report.bakerName,report.curveValueJson,report.sharerName,[NSNumber numberWithInteger:report.isShare]];//烘焙总时间、发展时间、发展率都通过事件计算,不再存储
                    if (!result) {
                        NSLog(@"插入报告失败");
                    }
                }];
                
                //跳转到曲线页面
                MainViewController *mainVC = [[MainViewController alloc] init];
                [self restoreRootViewController:mainVC];
                mainVC.selectedIndex = 1;
                
                ShareReportController *reportVC = [[ShareReportController alloc] init];
                reportVC.curveUid = curveUid;
                //因为mainVC.selectedViewController是一个自己生成的UINavigationController，所以要获得根vc
                UINavigationController *nav = (UINavigationController *)mainVC.selectedViewController;
                [[nav viewControllers][0].navigationController pushViewController:reportVC animated:YES];
            }
        }else{
            [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        if (error.code == -1001) {
            [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
        }else{
            [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

- (void)restoreRootViewController:(UIViewController *)rootViewController {
    
    typedef void (^Animation)(void);
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    
    
    rootViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    Animation animation = ^{
        
        BOOL oldState = [UIView areAnimationsEnabled];
        
        [UIView setAnimationsEnabled:NO];
        
        window.rootViewController = rootViewController;
        
        [UIView setAnimationsEnabled:oldState];
        
    };
    
    
    
    [UIView transitionWithView:window
     
                      duration:0.5f
     
                       options:UIViewAnimationOptionTransitionCrossDissolve
     
                    animations:animation
     
                    completion:nil];
    
}
@end
