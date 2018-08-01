//
//  DeviceViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceViewController.h"
#import "EspViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"
#import "TouchTableView.h"
#import "DeviceTableViewCell.h"
#import "MJRefresh.h"
#import "DeviceModel.h"
#import "FMDB.h"

#import <SystemConfiguration/CaptiveNetwork.h>

#import <sys/socket.h>
#import <netdb.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

#define HEIGHT_CELL 44.f
#define HEIGHT_HEADER 44.f
#define resendTimes 3

NSString *const CellIdentifier_device = @"CellID_device";
NSString *const CellNibName_device = @"DeviceTableViewCell";

@interface DeviceViewController () <GCDAsyncUdpSocketDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UITableView *devieceTable;

///@brief mac地址数组
@property (nonatomic, strong) NSMutableArray *macIpArray;

///@brief ip数组
@property (nonatomic, strong) NSMutableArray *ipArray;

///@brief 本地所有设备数组
@property (nonatomic, strong) NSMutableArray *deviceArray;

@end

@implementation DeviceViewController
{
    BOOL isConnect;
    int resendTime;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self queryDevices];
    
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setImage:[UIImage imageNamed:@"ic_details"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(goEsp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    _macIpArray = [NSMutableArray array];
    _ipArray = [NSMutableArray array];
    _devieceTable = [self devieceTable];
    _timer = [self timer];
    
    if (!_deviceArray && !_ipArray && !_macIpArray) {
        _devieceTable.hidden = YES;
    }else{
        _devieceTable.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self sendSearchBroadcast];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    _timer = nil;
}

- (void)dealloc{
    if (_timer) {
        [_timer fire];
        _timer = nil;
    }
}

#pragma mark - lazy load
- (UITableView *)devieceTable{
    if (!_devieceTable) {
        _devieceTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.hidden = YES;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[DeviceTableViewCell class] forCellReuseIdentifier:CellIdentifier_device];
            [tableView registerNib:[UINib nibWithNibName:CellNibName_device bundle:nil] forCellReuseIdentifier:CellIdentifier_device];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            //tableView.scrollEnabled = NO;
            if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
                [tableView setSeparatorInset:UIEdgeInsetsZero];
            }
            if ([tableView respondsToSelector:@selector(setLayoutMargins:)])  {
                [tableView setLayoutMargins:UIEdgeInsetsZero];
            }
            
            MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(sendSearchBroadcast)];
            // Set title
            [header setTitle:LocalString(@"下拉刷新") forState:MJRefreshStateIdle];
            [header setTitle:LocalString(@"松开刷新") forState:MJRefreshStatePulling];
            [header setTitle:LocalString(@"加载中") forState:MJRefreshStateRefreshing];
            
            // Set font
            header.stateLabel.font = [UIFont systemFontOfSize:15];
            header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
            
            // Set textColor
            header.stateLabel.textColor = [UIColor yellowColor];
            header.lastUpdatedTimeLabel.textColor = [UIColor yellowColor];
            tableView.mj_header = header;
            tableView;
        });
    }
    return _devieceTable;
}

- (NSTimer *)timer{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(broadcast) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

#pragma mark - udp
- (GCDAsyncUdpSocket *)udpSocket{
    if (!_udpSocket) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _udpSocket;
}

- (void)sendSearchBroadcast{
    resendTime = resendTimes;
    
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
    
    isConnect = NO;
    [_timer setFireDate:[NSDate date]];
}

- (void)broadcast{
    if (isConnect || resendTime == 0) {
        [_timer setFireDate:[NSDate distantFuture]];
        NSLog(@"发送三次udp请求或已经接收到数据");
        [self.devieceTable.mj_header endRefreshing];
        return;
    }else{
        resendTime--;
    }
    
    NSString *host = @"255.255.255.255";
    NSTimeInterval timeout = 2000;
    NSString *request = @"whereareyou\r\n";
    NSData *data = [NSData dataWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    UInt16 port = 17888;
    
    [_udpSocket sendData:data toHost:host port:port withTimeout:timeout tag:200];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSLog(@"UDP接收数据……………………………………………………");
    [self.devieceTable.mj_header endRefreshing];
    isConnect = YES;//停止发送udp
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
        
        NSString *msgg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",msgg);
        //避免重复显示同一个设备
        int isContain = 0;
        for (NSString *address in _ipArray) {
            if ([ipAddress isEqualToString:address]) {
                isContain = 1;
                break;
            }
        }
        if (!isContain) {
            [_ipArray addObject:ipAddress];
            
            NSLog(@"strAddr = %@", ipAddress);
            
            NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",msg);
            [_macIpArray addObject:[msg substringWithRange:NSMakeRange(0, 8)]];
            
            //判断本地是否已经存储过，如果有则将_deviceArray中的该设备删除，如果没有则存储该设备
            int isNewDevice = 1;
            for (int i = 0; i < _deviceArray.count; i++) {
                DeviceModel *device = _deviceArray[i];
                if ([[msg substringWithRange:NSMakeRange(0, 8)] isEqualToString:device.deviceMac]) {
                    [_deviceArray removeObjectAtIndex:i];
                    isNewDevice = 0;
                }
            }
            if (isNewDevice) {
                [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
                    BOOL result = [db executeUpdate:@"INSERT INTO device (mac,deviceName) VALUES (?,?)",[msg substringWithRange:NSMakeRange(0, 8)],[msg substringWithRange:NSMakeRange(0, 8)]];
                    if (result) {
                        NSLog(@"插入新设备到device成功");
                    }else{
                        NSLog(@"插入新设备到device失败");
                    }
                }];
            }
            
//            NSArray *msgArray = [msg componentsSeparatedByString:@"|"];
//            NSData *msgData = [msgArray.lastObject dataUsingEncoding:NSUTF8StringEncoding];
//            NSError *error;
//            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:msgData options:NSJSONReadingMutableContainers error:&error];
//            NSLog(@"%@",dataDict);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_devieceTable reloadData];
            });
        }
        
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

#pragma mark - 获取网络信息
- (NSDictionary *)fetchNetInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    //    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        //        NSLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

- (NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}

#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            
        case 1:
            return _macIpArray.count;
            //return 1;
            
        case 3:
            return _deviceArray.count;
            
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_device];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellNibName_device owner:self options:nil] lastObject];
        }
        
        cell.deviceLabel.text = [_macIpArray objectAtIndex:indexPath.row];
        return cell;
    }else if (indexPath.section == 0){
        DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_device];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellNibName_device owner:self options:nil] lastObject];
        }
        cell.deviceLabel.text = @"";
        return cell;
    }else{
        DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_device];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellNibName_device owner:self options:nil] lastObject];
        }
        DeviceModel *device = _deviceArray[indexPath.row];
        cell.deviceLabel.text = device.deviceName;
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        NSError *error = nil;
        [[NetWork shareNetWork] connectToHost:[_ipArray objectAtIndex:indexPath.row] onPort:16888 error:&error];
        
        if (error) {
            NSLog(@"tcp连接错误:%@",error);
        }
    }else if (indexPath.section == 0){
        NSError *error = nil;
        [[NetWork shareNetWork] connectToHost:@"192.168.1.125" onPort:16888 error:&error];
        //NSArray *array = [[NSArray alloc] initWithObjects:[NSNumber numberWithUnsignedInteger:0x68],[NSNumber numberWithUnsignedInteger:0x00],[NSNumber numberWithUnsignedInteger:0x00],[NSNumber numberWithUnsignedInteger:0x00],[NSNumber numberWithUnsignedInteger:0x01],[NSNumber numberWithUnsignedInteger:0x00],[NSNumber numberWithUnsignedInteger:0x69],[NSNumber numberWithUnsignedInteger:0x16],[NSNumber numberWithUnsignedInteger:0x0D],[NSNumber numberWithUnsignedInteger:0x0A], nil];
        
        //[[NetWork shareNetWork] send:[array mutableCopy] withTag:101];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER)];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, HEIGHT_HEADER)];
    headerTitle.font = [UIFont systemFontOfSize:14.f];
    if (section == 0) {
        headerTitle.text = LocalString(@"已连接设备");
    }else if (section == 1){
        headerTitle.text = LocalString(@"在线设备");
    }else{
        headerTitle.text = LocalString(@"离线设备");
    }
    [headerView addSubview:headerTitle];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEIGHT_HEADER;
}

#pragma mark - view action

- (void)goEsp{
    EspViewController *EspVC = [[EspViewController alloc] init];
    NSDictionary *netInfo = [self fetchNetInfo];
    EspVC.ssid = [netInfo objectForKey:@"SSID"];
    EspVC.bssid = [netInfo objectForKey:@"BSSID"];
    
    EspVC.block = ^(ESPTouchResult *result) {
        
    };
    [self.navigationController pushViewController:EspVC animated:YES];
    
}

#pragma mark - Data Source
- (void)queryDevices{
    _deviceArray = [[DataBase shareDataBase] queryAllDevice];
}

@end
