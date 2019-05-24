//
//  AppDelegate.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/20.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "ESP_NetUtil.h"
#import "LoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSThread sleepForTimeInterval:1.0];
    [self customizeInterface];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = nav;
//    MainViewController *mainVC = [[MainViewController alloc] init];
//    self.window.rootViewController = mainVC;
    
    [self.window makeKeyAndVisible];
    
    NSSetUncaughtExceptionHandler(&getException);

    [ESP_NetUtil tryOpenNetworkPermission];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (application.backgroundTimeRemaining > 10)
    {
        NSLog(@"ESPAppDelegate: some thread goto background, remained: %f seconds", application.backgroundTimeRemaining);
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //app息屏重新打开
    if ([NetWork shareNetWork].mySocket.isDisconnected) {
        [NetWork shareNetWork].connectedDevice = nil;
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    if(self.interfaceOrientation == UIInterfaceOrientationUnknown){
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else if(self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return UIInterfaceOrientationMaskLandscapeRight;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
    
}

- (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    [navigationBarAppearance setBarTintColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    navigationBarAppearance.barStyle = UIStatusBarStyleDefault;
    [navigationBarAppearance setTintColor:[UIColor blackColor]];//返回按钮的箭头颜色
    //[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size:16],
                                     NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1],
                                     };
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
    [navigationBarAppearance setTranslucent:NO];
    
    //去掉透明后导航栏下边的黑边
    [navigationBarAppearance setShadowImage:[[UIImage alloc] init]];
}

//获得异常的C函数
void getException(NSException *exception)
{
    NSLog(@"名字：%@",exception.name);
    NSLog(@"原因：%@",exception.reason);
    NSLog(@"用户信息：%@",exception.userInfo);
    NSLog(@"栈内存地址：%@",exception.callStackReturnAddresses);
    NSLog(@"栈描述：%@",exception.callStackSymbols);
}

@end
