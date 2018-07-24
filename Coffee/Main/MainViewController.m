//
//  MainViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/21.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "MainViewController.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "BakeViewController.h"
#import "CurveViewController.h"
#import "MineViewController.h"

@interface MainViewController ()<RDVTabBarControllerDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BakeViewController *BakeVC = [[BakeViewController alloc] init];
    UINavigationController *NAV1 = [[UINavigationController alloc] initWithRootViewController:BakeVC];
    
    
    CurveViewController *curveVC = [[CurveViewController alloc] init];
    UINavigationController *NAV2 = [[UINavigationController alloc] initWithRootViewController:curveVC];
    
    UIViewController *thirdVC = [[UIViewController alloc] init];
    UINavigationController *NAV3 = [[UINavigationController alloc] initWithRootViewController:thirdVC];
    
    UIViewController *fourthVc = [[UIViewController alloc] init];
    UINavigationController *NAV4 = [[UINavigationController alloc] initWithRootViewController:fourthVc];
    
    MineViewController *mineVC = [[MineViewController alloc] init];
    UINavigationController *NAV5 = [[UINavigationController alloc] initWithRootViewController:mineVC];
    
    [self setViewControllers:@[NAV1,NAV2,NAV3,NAV4,NAV5]];
    
    [self customizeTabBarForController];
    self.selectedIndex = 0;
    self.delegate = self;
    
    //self.view = self.view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customizeTabBarForController{
    NSArray *tabBarItemImages = @[@"ic_navbar_bake",@"ic_mine_history_line",@"ic_navbar_bean",@"ic_navbar_cup",@"ic_navbar_mine"];
    NSArray *tabBarItemSelectImages = @[@"ic_navbar_bake_selected",@"ic_mine_history_line",@"ic_navbar_bean_selected",@"ic_navbar_cup_selected",@"ic_navbar_mine_selected"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in self.tabBar.items) {
        item.tag = 1000 + index;
        UIImage *selectedImage = [UIImage imageNamed:[tabBarItemSelectImages objectAtIndex:index]];
        UIImage *unselectedImage = [UIImage imageNamed:[tabBarItemImages objectAtIndex:index]];
        [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
        index++;
    }
    
    [self.tabBar setHeight:tabbarHeight + kSafeArea_Bottom];
    
    self.tabBar.translucent = YES;
    
    self.tabBar.backgroundView.backgroundColor = [UIColor colorWithRed:245/255.0
                                                                 green:245/255.0
                                                                  blue:245/255.0
                                                                 alpha:0.9];
}

-  (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    return YES;
}

- (void)tabBarController:(RDVTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
}

@end
