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
#import "BeanViewController.h"

@interface MainViewController ()<RDVTabBarControllerDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BakeViewController *BakeVC = [[BakeViewController alloc] init];
    UINavigationController *NAV1 = [[UINavigationController alloc] initWithRootViewController:BakeVC];
    
    
    CurveViewController *curveVC = [[CurveViewController alloc] init];
    UINavigationController *NAV2 = [[UINavigationController alloc] initWithRootViewController:curveVC];
    
    BeanViewController *beanVC = [[BeanViewController alloc] init];
    UINavigationController *NAV3 = [[UINavigationController alloc] initWithRootViewController:beanVC];
    
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
    NSArray *tabBarItemTitle = @[@"烘焙", @"曲线",@"生豆",@"杯测",@"我的"];
    NSArray *tabBarItemImages = @[@"ic_tabbar_baking_nor",@"ic_tabbar_curve_nor",@"ic_tabbar_bean_nor",@"ic_tabbar_test_nor",@"ic_tabbar_mine_nor"];
    NSArray *tabBarItemSelectImages = @[@"ic_tabbar_baking_sel",@"ic_tabbar_curve_sel",@"ic_tabbar_bean_sel",@"ic_tabbar_test_sel",@"ic_tabbar_mine_sel"];
    NSDictionary *tabBarTitleUnselectedDic = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"999999"],NSFontAttributeName:[UIFont systemFontOfSize:11]};
    NSDictionary *tabBarTitleSelectedDic = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"4778CC"],NSFontAttributeName:[UIFont systemFontOfSize:11]};
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in self.tabBar.items) {
        item.tag = 1000 + index;
        UIImage *selectedImage = [UIImage imageNamed:[tabBarItemSelectImages objectAtIndex:index]];
        UIImage *unselectedImage = [UIImage imageNamed:[tabBarItemImages objectAtIndex:index]];
        [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
        
        item.selectedTitleAttributes = tabBarTitleSelectedDic;
        item.unselectedTitleAttributes = tabBarTitleUnselectedDic;
        [item setTitle:[tabBarItemTitle objectAtIndex:index]];
        index++;
    }
    
    [self.tabBar setHeight:tabbarHeight + kSafeArea_Bottom];
    
    self.tabBar.translucent = YES;
    
    self.tabBar.backgroundView.backgroundColor = [UIColor colorWithRed:252/255.0
                                                                 green:252/255.0
                                                                  blue:252/255.0
                                                                 alpha:1];
}

-  (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    return YES;
}

- (void)tabBarController:(RDVTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
}

@end
