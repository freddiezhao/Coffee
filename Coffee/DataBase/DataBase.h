//
//  DataBase.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingModel.h"

@class FMDatabaseQueue;

@interface DataBase : NSObject
///@brief User Information
@property (nonatomic, strong) NSString *userName;
///@brief Settings
@property (nonatomic, strong) SettingModel *settings;

@property (nonatomic, strong) FMDatabaseQueue *queueDB;


+ (instancetype)shareDataBase;

- (SettingModel *)selectSetting;
@end
