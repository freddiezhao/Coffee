//
//  APProcessController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2019/3/5.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "APProcessController.h"
#import "GCDAsyncUdpSocket.h"
#import "DeviceViewController.h"
#import "DeviceModel.h"

#import <netdb.h>//解析udp获取的IP地址
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NEHotspotConfigurationManager.h>
#import "FMDB.h"


@interface APProcessController () <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSLock *lock;

@property (nonatomic) dispatch_source_t confirmWifiTimer;//确认Wi-Fi切换时钟

@end

@implementation APProcessController{
    int resendTimes;//tcp连接次数
    BOOL isFind;
    NSString *mac;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;
    
    self.navigationItem.title = LocalString(@"AP配网");

    _spinner = [self spinner];
    _image =[self image];
    [self setImage];
    _cancelBtn = [self cancelBtn];

    self.timer = [self timer];
    self.udpSocket = [self udpSocket];
    self.lock = [self lock];
    self.confirmWifiTimer = [self confirmWifiTimer];
    [self sendSearchBroadcast];
#warning 提示：ap账号密码实在network中tcp连接的target中发送
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [NetWork shareNetWork].isAp = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apSendSucc) name:@"apSendSucc" object:nil];
    
    isFind = NO;
    isApSendSucc = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [NetWork shareNetWork].isAp = NO;
    [_spinner stopAnimating];

    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    _timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"apSendSucc" object:nil];

    dispatch_source_cancel(_confirmWifiTimer);
    
    [_udpSocket close];
    _udpSocket = nil;
    isFind = NO;
}

- (void)dealloc{
    if (_timer) {
        [_timer fire];
        _timer = nil;
    }
}

#pragma mark - private methods
- (void)sendSearchBroadcast{
    _udpSocket = [self udpSocket];
    
    [_udpSocket localPort];
    
    NSError *error;
    
    //设置广播
    [_udpSocket enableBroadcast:YES error:&error];
    
    //开启接收数据
    [_udpSocket beginReceiving:&error];
    if (error) {
        NSLog(@"开启接收数据:%@",error);
        return;
    }
    
    isFind = NO;
    [_timer setFireDate:[NSDate date]];
}

- (void)broadcast{
    if (isFind) {
        [_timer setFireDate:[NSDate distantFuture]];
        NSLog(@"已经找到设备");
        return;
    }
    
    NSString *currentIP = [NSObject getIPAddress];
    NSString *host = @"";
    if ([currentIP isEqualToString:@"error"]) {

    }else{
        NSLog(@"%@",currentIP);
        NSArray *array = [currentIP componentsSeparatedByString:@"."];
        host = [NSString stringWithFormat:@"%@.%@.%@.255",array[0],array[1],array[2]];
    }
    
    NSTimeInterval timeout = 2000;
    NSString *request = @"whereareyou\r\n";
    NSData *data = [NSData dataWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    UInt16 port = 17888;
    
    [_udpSocket sendData:data toHost:host port:port withTimeout:timeout tag:200];
}

- (void)tcpActions:(NSString *)ipAddress{
    
    NetWork *net = [NetWork shareNetWork];
    NSError *error = nil;
    if (![net connectToHost:ipAddress onPort:16888 error:&error] && resendTimes > 0) {
        NSLog(@"tcp连接错误:%@",error);
        [self tcpActions:ipAddress];
        resendTimes--;
    }else{
        resendTimes = 0;
    }
}

static bool isApSendSucc = NO;
- (void)apSendSucc{
    isApSendSucc = YES;
}

static int hotspotAlertTime = 3;
- (void)confirmWifiName{
    NetWork *net = [NetWork shareNetWork];

    if (!isApSendSucc) {
        return;
    }
    NSDictionary *netInfo = [self fetchNetInfo];
    NSString *ssid = [netInfo objectForKey:@"SSID"];
    NSLog(@"%@",ssid);
    if ([ssid isEqualToString:[NetWork shareNetWork].ssid]) {
        if (isApSendSucc) {
            isFind = NO;
            [self sendSearchBroadcast];
        }
    }else if(![ssid hasPrefix:@"ESP"] && [ssid isKindOfClass:[NSString class]]){
        ///2019.5.21更新，在查到udp后记住mac，在重新连到有网络Wi-Fi后绑定设备
        [self bindDevice:mac success:^{
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[DeviceViewController class]]) {
                    [self.navigationController popToViewController:controller animated:YES];
                }
            }
            //[NSObject showHudTipStr:LocalString(@"您未连接到配网的Wi-Fi,会导致搜索不到设备，请注意切换Wi-Fi")];
        } failure:^{
            [NSObject showHudTipStr:LocalString(@"网络状况不佳")];
        }];

#warning TODO 自动去连接要连接的Wi-Fi
//        if (@available(iOS 11.0, *)) {
//            if (hotspotAlertTime > 0) {
//                hotspotAlertTime--;
//                return;
//            }
//            hotspotAlertTime = 3;
//            NEHotspotConfiguration *hotspotConfig = [[NEHotspotConfiguration alloc] initWithSSID:net.ssid passphrase:net.apPwd isWEP:NO];
//            [[NEHotspotConfigurationManager sharedManager] applyConfiguration:hotspotConfig completionHandler:^(NSError * _Nullable error) {
//                NSLog(@"%@",error);
//                if (error && error.code != 13 && error.code != 7) {
//                    hotspotAlertTime = 0;//马上弹出框
//                }else if(error.code ==7){//error code = 7 ：用户点击了弹框取消按钮
//                    hotspotAlertTime = 0;
//                }else{// error code = 13 ：已连接
//                    hotspotAlertTime = 100000;
//                }
//            }];
//        } else {
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"配网成功") message:LocalString(@"您未连接到配网的Wi-Fi,会导致搜索不到设备，请注意切换Wi-Fi") preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                for (UIViewController *controller in self.navigationController.viewControllers) {
//                    if ([controller isKindOfClass:[DeviceViewController class]]) {
//                        [self.navigationController popToViewController:controller animated:YES];
//                    }
//                }
//            }];
//            [alertController addAction:cancelAction];
//            [self presentViewController:alertController animated:YES completion:nil];
//        }
    }
}

- (NSDictionary *)fetchNetInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    //    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        //NSLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}


- (void)showNoWifiConnect{
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    alert.rBlock = ^{
    };
    alert.lBlock = ^{
    };
    [self presentViewController:alert animated:NO completion:^{
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
        alert.WScale_alert = WScale;
        alert.HScale_alert = HScale;
        [alert showView];
        alert.titleLabel.text = LocalString(@"提示");
        alert.messageLabel.text = LocalString(@"请连接Wi-Fi");
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
    }];
}

- (void) cancel
{
    [_spinner stopAnimating];
    [self.navigationController popViewControllerAnimated:YES];
    [NSObject showHudTipStr:LocalString(@"取消配置，你可以重新选择配置")];
}

- (void)bindDevice:(NSString *)mac success:(void(^)(void))success failure:(void(^)(void))failure{
    //判断本地是否已经存储过，如果有则将_deviceArray中的该设备删除，如果没有则存储该设备
    NSNumber *deviceType = [NetWork shareNetWork].deviceType;
    
    NSString *name;
    switch ([deviceType intValue]) {
        case 0:
        {
            name = LocalString(@"HB-M6G咖啡烘焙机");
        }
            break;
            
        case 1:
        {
            name = LocalString(@"HB-M6E咖啡烘焙机");
        }
            break;
            
        case 2:
        {
            name = LocalString(@"HB-L2咖啡烘焙机");
        }
            break;
            
        case 3:
        {
            name = LocalString(@"PEAK-Edmund咖啡烘焙机");
        }
            break;
            
        case 4:{
            name = LocalString(@"其他机型咖啡烘焙机");
        }
            break;
            
        default:
            name = LocalString(@"其他机型咖啡烘焙机");
            break;
    }

    BOOL isStored = [[DataBase shareDataBase] queryDevice:mac];
    if (!isStored) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable:
                    NSLog(@"没有网络");
                    return;
                    break;
                    
                default:
                    break;
            }
        }];
        
        //设置超时时间
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 6.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
        [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
        
        NSDictionary *parameters = @{@"sn":mac,@"name":name,@"userId":[DataBase shareDataBase].userId,@"deviceType":deviceType};
        [manager POST:@"http://139.196.90.97:8080/coffee/roaster" parameters:parameters progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
                  if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                      [NSObject showHudTipStr:LocalString(@"添加新设备到服务器成功")];
                      
                      [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
                          BOOL result = [db executeUpdate:@"INSERT INTO device (sn,deviceName,deviceType) VALUES (?,?,?)",mac,name,deviceType];
                          if (result) {
                              NSLog(@"插入新设备到device成功");
                              [NetWork shareNetWork].ipAddr = @"";
                          }else{
                              NSLog(@"插入新设备到device失败");
                          }
                      }];
                      
                      if (success) {
                          success();
                      }
                  }else{
                      //[NSObject showHudTipStr:LocalString(@"添加新设备到服务器失败")];
                      if (failure) {
                          failure();
                      }
                  }
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"Error:%@",error);
                  if (error.code == -1001) {
                      //[NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
                  }
                  if (failure) {
                      failure();
                  }
              }];
    }else{
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        //设置超时时间
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 6.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
        [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];

        NSDictionary *parameters = @{@"sn":mac,@"name":name,@"userId":[DataBase shareDataBase].userId,@"deviceType":deviceType};
        NSLog(@"%@",name);
        [manager PUT:@"http://139.196.90.97:8080/coffee/roaster" parameters:parameters
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
                 if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                     [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
                         BOOL result = [db executeUpdate:@"UPDATE device SET deviceType = ?,deviceName = ? WHERE sn = ?",deviceType,name,mac];
                         if (result) {
                             NSLog(@"更新咖啡机到device表成功");
                         }else{
                             NSLog(@"更新咖啡机到device表失败");
                         }
                     }];
                     
                     if (success) {
                         success();
                     }
                 }else{
                     //[NSObject showHudTipStr:LocalString(@"更新咖啡机到服务器失败")];
                     if (failure) {
                         failure();
                     }
                 }
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSLog(@"Error:%@",error);
                 if (error.code == -1001) {
                     //[NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
                 }
                 if (failure) {
                     failure();
                 }
             }];
    }
}

#pragma mark - udp delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    [_lock lock];
    NSLog(@"UDP接收数据……………………………………………………");
    isFind = YES;//停止发送udp
    if (!isApSendSucc) {
        /**
         *获取IP地址
         **/
        // Copy data to a "sockaddr_storage" structure.
        struct sockaddr_storage sa;
        socklen_t salen = sizeof(sa);
        [address getBytes:&sa length:salen];
        // Get host from socket address as C string:
        char host[NI_MAXHOST];
        getnameinfo((struct sockaddr *)&sa, salen, host, sizeof(host), NULL, 0, NI_NUMERICHOST);
        // Convert C string to NSString:
        NSString *ipAddress = [[NSString alloc] initWithBytes:host length:strlen(host) encoding:NSUTF8StringEncoding];
        NSLog(@"%@",ipAddress);
        
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",msg);
        mac = [msg substringWithRange:NSMakeRange(0, 8)];
        
        resendTimes = 3;
        [self tcpActions:ipAddress];
    }else{
        /**
         *发送完账号密码后在Wi-Fi里查询udp
         **/
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",msg);
        NSString *newMac = [msg substringWithRange:NSMakeRange(0, 8)];
        if ([newMac isEqualToString:mac]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (UIViewController *controller in self.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[DeviceViewController class]]) {
                        [self.navigationController popToViewController:controller animated:YES];
                    }
                }
                [NSObject showHudTipStr:LocalString(@"连接成功，请进行设备的选择")];
            });
        }
    }
    [_lock unlock];
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    NSLog(@"失去连接");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"发送的消息");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    NSLog(@"已经连接");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"断开连接");
    if (isApSendSucc) {
        isFind = NO;
    }
    [self sendSearchBroadcast];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"没有发送数据");
}


#pragma mark - setters and getters
- (UIActivityIndicatorView *)spinner{
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] init];
        [_spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [_spinner setHidesWhenStopped:NO];
        [_spinner startAnimating];
        //[_spinner setColor:[UIColor blueColor]];
        [self.view addSubview:_spinner];
        [_spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(15 / WScale, 15 / HScale));
            make.top.equalTo(self.view.mas_top).offset(337 / HScale);
            make.left.equalTo(self.view.mas_left).offset(128.5 / WScale);
        }];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.text = LocalString(@"正在搜索设备...");
        tipLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        tipLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.view addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100 / WScale, 20 / HScale));
            make.centerY.equalTo(self.spinner.mas_centerY);
            make.left.equalTo(_spinner.mas_right).offset(8 / WScale);
        }];
    }
    return _spinner;
}

- (UIImageView *)image{
    if (!_image) {
        _image = [[UIImageView alloc] init];
        _image.image = [UIImage imageNamed:@"img_peak_edmund"];
        [self.view addSubview:_image];
        
        [_image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(225 / WScale, 150 / HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(82 / HScale);
        }];
        
        UILabel *tipLabel1 = [[UILabel alloc] init];
        tipLabel1.text = LocalString(@"请将手机和烘焙机的距离保持在5米以内");
        tipLabel1.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        tipLabel1.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        tipLabel1.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:tipLabel1];
        
        UILabel *tipLabel2 = [[UILabel alloc] init];
        tipLabel2.text = LocalString(@"连接过程中请不要操作咖啡烘焙机");
        tipLabel2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        tipLabel2.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        tipLabel2.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:tipLabel2];
        
        [tipLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 20 / HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.image.mas_bottom).offset(18 / HScale);
        }];
        [tipLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 20 / HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(tipLabel1.mas_bottom).offset(8 / HScale);
        }];
    }
    return _image;
}

- (void)setImage{
    switch ([[NetWork shareNetWork].deviceType integerValue]) {
        case 0:
        {
            _image.image = [UIImage imageNamed:@"img_hb_m6g_small"];
        }
            break;
            
        case 1:
        {
            _image.image = [UIImage imageNamed:@"img_hb_m6g_small"];
        }
            break;
            
        case 2:
        {
            _image.image = [UIImage imageNamed:@"img_hb_l2_small"];
        }
            break;
            
        case 3:
        {
            _image.image = [UIImage imageNamed:@"img_peak_edmund_small"];
        }
            break;
            
        case 4:{
            _image.image = [UIImage imageNamed:@"img_logo_gray"];
        }
            break;
            
        default:
            break;
    }
}

- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitleColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1] forState:UIControlStateNormal];
        [_cancelBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [_cancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [_cancelBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8]];
        [_cancelBtn setButtonStyleWithColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1] Width:1.5 cornerRadius:18.f / HScale];
        [_cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_cancelBtn];
        
        [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(92.f / WScale, 36.f / HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view.mas_bottom).offset(-40 / HScale);
        }];
    }
    return _cancelBtn;
}


- (GCDAsyncUdpSocket *)udpSocket{
    if (!_udpSocket) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _udpSocket;
}

- (NSTimer *)timer{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(broadcast) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

-(NSLock *)lock{
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

- (dispatch_source_t)confirmWifiTimer{
    if (!_confirmWifiTimer) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _confirmWifiTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_confirmWifiTimer, dispatch_walltime(NULL, 0), 1.f * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_confirmWifiTimer, ^{
            [self confirmWifiName];
        });
        dispatch_resume(_confirmWifiTimer);
    }
    return _confirmWifiTimer;
}

@end
