//
//  NSObject+Common.m
//  MOWOX
//
//  Created by Mac on 2017/11/18.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "NSObject+Common.h"
#import <Charts/Charts-Swift.h>

@implementation NSObject (Common)

+ (void)showHudTipStr:(NSString *)tipStr{
    if (tipStr && tipStr.length > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        hud.label.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        hud.label.text = tipStr;
        hud.margin = 10.f;
        hud.minSize = CGSizeMake(225 / WScale, 41 / HScale);
        hud.bezelView.layer.cornerRadius = 20.5f;
        [hud setOffset:CGPointMake(0, (ScreenHeight / 2 - 141) / HScale)];
        hud.removeFromSuperViewOnHide = YES;
        hud.bezelView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.8];
        [hud hideAnimated:YES afterDelay:1.5];
    }
}

+ (void)showHudTipStr2:(NSString *)tipStr{
    if (tipStr && tipStr.length > 0) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.square = YES;
        hud.label.text = tipStr;
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:2.0];

    }
}

+ (void)showHudTipStr:(NSString *)tipStr withTime:(float)time{
    if (tipStr && tipStr.length > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.font = [UIFont boldSystemFontOfSize:15.0];
        hud.label.text = tipStr;
        hud.margin = 15.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:time];
    }
}

+ (NSDictionary *)readLocalFileWithName:(NSString *)name{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (UInt8)getCS:(NSArray *)data{
    UInt8 csTemp = 0x00;
    for (int i = 0; i < [data count]; i++)
    {
        csTemp += [data[i] unsignedCharValue];
    }
    return csTemp;
}


/**
 **逐差法求加速度
 **/
+ (NSMutableArray *)evaluateAcceleration:(NSMutableArray *)valueArr{
    NSMutableArray *displacementArr = [[NSMutableArray alloc] init];//位移数组
    for (int i = 1; i < valueArr.count; i++) {
        float displacement = [valueArr[i] floatValue] - [valueArr[i-1] floatValue];
        [displacementArr addObject:[NSNumber numberWithFloat:displacement]];
    }
    NSMutableArray *acceleratioArr = [[NSMutableArray alloc] init];
    for (int i = 10; i < displacementArr.count-9; i++) {
        [acceleratioArr addObject:[[ChartDataEntry alloc] initWithX:i y:([displacementArr[i+9] doubleValue]+[displacementArr[i+8] doubleValue]+[displacementArr[i+7] doubleValue]+[displacementArr[i+6] doubleValue]+[displacementArr[i+5] doubleValue]+[displacementArr[i+4] doubleValue]+[displacementArr[i+3] doubleValue]+[displacementArr[i+2] doubleValue]+[displacementArr[i+1] doubleValue]+[displacementArr[i] doubleValue] - [displacementArr[i-1] doubleValue] - [displacementArr[i-2] doubleValue] - [displacementArr[i-3] doubleValue] - [displacementArr[i-4] doubleValue] - [displacementArr[i-5] doubleValue] - [displacementArr[i-6] doubleValue] - [displacementArr[i-7] doubleValue] - [displacementArr[i-8] doubleValue] - [displacementArr[i-9] doubleValue] - [displacementArr[i-10] doubleValue])/(10*10)]];
    }
    return acceleratioArr;
}
@end
