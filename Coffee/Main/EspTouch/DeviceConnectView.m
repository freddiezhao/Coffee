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

@interface EspTouchDelegateImpl : NSObject<ESPTouchDelegate>

@end

@implementation EspTouchDelegateImpl

-(void) dismissAlert:(UIAlertView *)alertView
{
    [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
}

-(void) showAlertWithResult: (ESPTouchResult *) result
{
    NSString *title = nil;
    NSString *message = [NSString stringWithFormat:@"%@ is connected to the wifi" , result.bssid];
    NSTimeInterval dismissSeconds = 3.5;
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    //UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertView show];
    [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:dismissSeconds];
}

-(void) onEsptouchResultAddedWithResult: (ESPTouchResult *) result
{
    NSLog(@"EspTouchDelegateImpl onEsptouchResultAddedWithResult bssid: %@", result.bssid);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithResult:result];
    });
}

@end

@interface DeviceConnectView ()

@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (nonatomic, strong) EspTouchDelegateImpl *espTouchDelegate;
@property (atomic, strong) ESPTouchTask *esptouchTask;

@end

@implementation DeviceConnectView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.condition = [[NSCondition alloc] init];
    self.espTouchDelegate = [[EspTouchDelegateImpl alloc] init];
    _spinner = [self spinner];
    [self startEsptouchConnect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - lazy load
- (UIActivityIndicatorView *)spinner{
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _spinner.center = CGPointMake(100.0, 100.0);
        [_spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [_spinner setHidesWhenStopped:YES];
        [_spinner setColor:[UIColor blueColor]];
        [self.view addSubview:_spinner];
    }
    return _spinner;
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
                    /**多个设备同时esptouch连接
                     for (int i = 0; i < [esptouchResultArray count]; ++i)
                     {
                     ESPTouchResult *resultInArray = [esptouchResultArray objectAtIndex:i];
                     [mutableStr appendString:[resultInArray description]];
                     [mutableStr appendString:@"\n"];
                     count++;
                     if (count >= maxDisplayCount)
                     {
                     break;
                     }
                     }
                     
                     if (count < [esptouchResultArray count])
                     {
                     [mutableStr appendString:[NSString stringWithFormat:@"\nthere's %lu more result(s) without showing\n",(unsigned long)([esptouchResultArray count] - count)]];
                     }
                     **/
                    //[[[UIAlertView alloc]initWithTitle:@"Execute Result" message:mutableStr delegate:nil cancelButtonTitle:@"I know" otherButtonTitles:nil]show];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalString(@"Execute Result") message:LocalString(@"Esptouch success") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LocalString(@"I know") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
                        NSLog(@"action = %@",action);
                    }];
                    [alert addAction:cancelAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
                else
                {
                    //[[[UIAlertView alloc]initWithTitle:@"Execute Result" message:@"Esptouch fail" delegate:nil cancelButtonTitle:@"I know" otherButtonTitles:nil]show];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalString(@"Execute Result") message:LocalString(@"Esptouch fail") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LocalString(@"I know") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        NSLog(@"action = %@",action);
                    }];
                    [alert addAction:cancelAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
            
        });
    });
    
    
//    else
//    {
//        [self.spinner stopAnimating];
//        NSLog(@"ESPViewController do cancel action...");
//        [self cancel];
//    }
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
}


@end
