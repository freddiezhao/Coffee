//
//  EventModel.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/30.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventModel : NSObject

@property (nonatomic) NSInteger eventId;
@property (nonatomic) NSInteger eventTime;
@property (nonatomic, strong) NSString *eventBeanTemp;
@property (nonatomic, strong) NSString *eventText;

@end
