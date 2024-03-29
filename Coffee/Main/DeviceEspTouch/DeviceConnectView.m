//
//  Esptouch的源码在乐鑫官网可以找到
//
//  DeviceConnectView.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/29.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceConnectView.h"
#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"
#import "ESPAES.h"
#import "DeviceViewController.h"
#import "GCDAsyncUdpSocket.h"
#import <netdb.h>

@interface EspTouchDelegateImpl : NSObject<ESPTouchDelegate>

@end

@implementation EspTouchDelegateImpl

- (void) onEsptouchResultAddedWithResult: (ESPTouchResult *) result
{
    NSLog(@"EspTouchDelegateImpl onEsptouchResultAddedWithResult bssid: %@", result.bssid);
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//    });
}

@end

@interface DeviceConnectView () <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) NSCondition *condition;

@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) EspTouchDelegateImpl *espTouchDelegate;
@property (atomic, strong) ESPTouchTask *esptouchTask;

@property (strong, nonatomic) NSTimer *udpTimer;;
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

@end

@implementation DeviceConnectView

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!_udpSocket) {
            dispatch_queue_t queue = dispatch_queue_create("udpQueue", DISPATCH_QUEUE_SERIAL);
            _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:queue];
        }
        if (!_udpTimer) {
            _udpTimer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(broadcast) userInfo:nil repeats:YES];
            [_udpTimer setFireDate:[NSDate distantFuture]];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1]];

    self.navigationItem.title = LocalString(@"搜索并连接设备");
    
    self.condition = [[NSCondition alloc] init];
    self.espTouchDelegate = [[EspTouchDelegateImpl alloc] init];
    _spinner = [self spinner];
    _image =[self image];
    [self setImage];
    _cancelBtn = [self cancelBtn];
    [self startEsptouchConnect];
    [self sendSearchBroadcast];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(15);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.udpTimer setFireDate:[NSDate date]];
        });
    });
    //[self fail];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //去掉返回键的文字
    self.navigationController.navigationBar.topItem.title = @"";
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_udpTimer setFireDate:[NSDate distantFuture]];
    [_udpTimer invalidate];
    _udpTimer = nil;
    [_spinner stopAnimating];
    [_udpSocket close];
    _udpSocket = nil;
}

- (void)didMoveToParentViewController:(UIViewController *)parent{
    [super didMoveToParentViewController:parent];
    if (!parent) {
        [self.condition lock];
        if (self.esptouchTask != nil)
        {
            [self.esptouchTask interrupt];
        }
        [self.condition unlock];
    }
}

#pragma mark - udp
- (void)sendSearchBroadcast{
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
    
}

- (void)broadcast{
    NSString *currentIP = [NSObject getIPAddress];
    NSString *host = @"";
    if ([currentIP isEqualToString:@"error"]) {
        
    }else{
        NSArray *array = [currentIP componentsSeparatedByString:@"."];
        host = [NSString stringWithFormat:@"%@.%@.%@.255",array[0],array[1],array[2]];
    }

    NSTimeInterval timeout = 2000;
    NSString *request = @"whereareyou\r\n";
    NSData *data = [NSData dataWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    UInt16 port = 17888;
    
    NSLog(@"ip:%@",host);
    
    [_udpSocket sendData:data toHost:host port:port withTimeout:timeout tag:200];
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSLog(@"UDP接收数据……………………………………………………");
    if (1) {
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
        [NetWork shareNetWork].ipAddr = ipAddress;

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

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    NSLog(@"断开连接");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"发送的消息");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    NSLog(@"已经连接");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"断开连接");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"没有发送数据");
}

#pragma mark - start Esptouch
- (void)startEsptouchConnect
{
    [self.spinner startAnimating];
    
    NSLog(@"ESPViewController do confirm action...");
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSLog(@"ESPViewController do the execute work...");
        // execute the task
        NSArray *esptouchResultArray = [self executeForResults];
        // show the result to the user in UI Main Thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            
            ESPTouchResult *firstResult = [esptouchResultArray objectAtIndex:0];
            
            // check whether the task is cancelled and no results received
            if (!firstResult.isCancelled)
            {
                NSMutableString *mutableStr = [[NSMutableString alloc]init];
                NSUInteger count = 0;
                // max results to be displayed, if it is more than maxDisplayCount,
                // just show the count of redundant ones
                const int maxDisplayCount = 5;
                if ([firstResult isSuc])
                {
                    NSLog(@"%@",firstResult.ipAddrData);
                    NSString *ipAddrDataStr = [ESP_NetUtil descriptionInetAddr4ByData:firstResult.ipAddrData];
                    if (ipAddrDataStr==nil) {
                        ipAddrDataStr = [ESP_NetUtil descriptionInetAddr6ByData:firstResult.ipAddrData];
                    }
                    [NetWork shareNetWork].ipAddr = ipAddrDataStr;
                    NSLog(@"%@",[NetWork shareNetWork].ipAddr);

                    for (int i = 0; i < [esptouchResultArray count]; ++i)
                    {
                        ESPTouchResult *resultInArray = [esptouchResultArray objectAtIndex:i];
                        [mutableStr appendString:[resultInArray description]];
                        [mutableStr appendString:@"\n"];
                        count++;
                        if (count >= maxDisplayCount){
                            break;
                        }
                    }
                    
                    if (count < [esptouchResultArray count]){
                        [mutableStr appendString:[NSString stringWithFormat:@"\nthere's %lu more result(s) without showing\n",(unsigned long)([esptouchResultArray count] - count)]];
                    }
                    NSLog(@"esp信息%@",mutableStr);
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[DeviceViewController class]]) {
                            [self.navigationController popToViewController:controller animated:YES];
                        }
                    }
                    [NSObject showHudTipStr:LocalString(@"连接成功，请进行设备的选择")];
                }
                else
                {
                    [self fail];
                }
            }
            
        });
    });
}

#pragma mark - the example of how to use executeForResults
- (NSArray *) executeForResults
{
    [self.condition lock];
    int taskCount = 1;//具体用途待测试
    BOOL useAES = NO;
    if (useAES) {
        NSString *secretKey = @"1234567890123456"; // TODO modify your own key
        ESPAES *aes = [[ESPAES alloc] initWithKey:secretKey];
        self.esptouchTask = [[ESPTouchTask alloc]initWithApSsid:[NetWork shareNetWork].ssid andApBssid:[NetWork shareNetWork].bssid andApPwd:[NetWork shareNetWork].apPwd andAES:aes];
    } else {
        self.esptouchTask = [[ESPTouchTask alloc]initWithApSsid:[NetWork shareNetWork].ssid andApBssid:[NetWork shareNetWork].bssid andApPwd:[NetWork shareNetWork].apPwd];
        NSLog(@"%@",[NetWork shareNetWork].ssid);
        NSLog(@"%@",[NetWork shareNetWork].bssid);
        NSLog(@"%@",[NetWork shareNetWork].apPwd);
    }
    
    // set delegate
    [self.esptouchTask setEsptouchDelegate:self.espTouchDelegate];
    [self.condition unlock];
    NSArray * esptouchResults = [self.esptouchTask executeForResults:taskCount];
    NSLog(@"ESPViewController executeForResult() result is: %@",esptouchResults);
    return esptouchResults;
}

#pragma mark - the example of how to cancel the executing task

- (void) cancel
{
    [self.condition lock];
    if (self.esptouchTask != nil)
    {
        [self.esptouchTask interrupt];
    }
    [self.condition unlock];
    [_spinner stopAnimating];
    [self.navigationController popViewControllerAnimated:YES];
    [NSObject showHudTipStr:LocalString(@"取消配置，你可以重新选择配置")];
}

- (void)fail{
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.lBlock = ^{
        [self.condition lock];
        if (self.esptouchTask != nil)
        {
            [self.esptouchTask interrupt];
        }
        [self.condition unlock];
        [self.navigationController popViewControllerAnimated:YES];
        [NSObject showHudTipStr:LocalString(@"配置失败，你可以重新选择配置")];
    };
    alert.rBlock = ^{
        [self.condition lock];
        if (self.esptouchTask != nil)
        {
            [self.esptouchTask interrupt];
        }
        [self.condition unlock];
        [self.navigationController popViewControllerAnimated:YES];
        [NSObject showHudTipStr:LocalString(@"配置失败，你可以重新选择配置")];
    };
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:alert animated:NO completion:^{
        alert.WScale_alert = WScale;
        alert.HScale_alert = HScale;
        [alert showView];
        alert.titleLabel.text = LocalString(@"添加过程中出现了小问题");
        alert.messageLabel.text = LocalString(@"配置失败，请检测当前网络。请选择同一个Wi-Fi环境，再试一次吧~");
        [alert.leftBtn setTitle:LocalString(@"以后再说") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"重新添加") forState:UIControlStateNormal];
    }];
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
        tipLabel1.numberOfLines = 2;
        [self.view addSubview:tipLabel1];
        
        UILabel *tipLabel2 = [[UILabel alloc] init];
        tipLabel2.text = LocalString(@"连接过程中请不要操作咖啡烘焙机");
        tipLabel2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        tipLabel2.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        tipLabel2.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:tipLabel2];
        
        [tipLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 40 / HScale));
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
@end
