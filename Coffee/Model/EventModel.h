//
//  EventModel.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/30.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EventType) {
    StartBake = 0,
    OutWater = 1,
    First_Burst_Start = 2,
    First_Burst_End = 3,
    Second_Burst_Start = 4,
    Second_Burst_End = 5,
    EndBake = 6,
    Wind_Fire_Power = 7,
    BakeBackTemp = 8,
};

@interface EventModel : NSObject

@property (nonatomic) EventType eventId;
@property (nonatomic) NSInteger eventTime;
@property (nonatomic, assign) double eventBeanTemp;
@property (nonatomic, strong) NSString *eventText;

@end
