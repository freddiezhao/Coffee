//
//  EventModel.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/30.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "EventModel.h"

@implementation EventModel

- (NSString *)getEventText:(EventType)type{
    switch (type) {
        case StartBake:
            return LocalString(@"烘焙开始");
            break;
            
        case OutWater:
            return LocalString(@"脱水结束");
            break;
            
        case First_Burst_Start:
            return LocalString(@"一爆开始");
            break;
            
        case First_Burst_End:
            return LocalString(@"一爆结束");
            break;
            
        case Second_Burst_Start:
            return LocalString(@"二爆开始");
            break;
        case Second_Burst_End:
            return LocalString(@"二爆结束");
            break;
            
        case EndBake:
            return LocalString(@"烘焙结束");
            break;
            
        case Wind_Fire_Power:
            return LocalString(@"风力/火力");
            break;
            
        case BakeBackTemp:
            return LocalString(@"回温点");
            break;
            
        default:
            break;
    }
}

@end
