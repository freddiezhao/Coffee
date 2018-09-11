//
//  DataBase.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabaseQueue;
@class SettingModel;
@class ReportModel;
@class BeanModel;
@class EventModel;

@interface DataBase : NSObject
///@brief User Information
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSNumber *userId;

///@brief Settings
@property (nonatomic, strong) SettingModel *setting;
@property (nonatomic, strong) BeanModel *bean;

@property (nonatomic, strong) FMDatabaseQueue *queueDB;


+ (instancetype)shareDataBase;

///@brief DB action
- (NSMutableArray *)queryAllReport:(DeviceModel *)device;
- (NSMutableArray *)queryAllSharedReport;
- (ReportModel *)queryReport:(NSNumber *)curveId;
- (NSArray *)queryReportRelaBean:(NSNumber *)curveId;
- (NSMutableArray *)queryAllBean;
- (BeanModel *)queryBean:(NSNumber *)beanId;
- (NSArray *)queryEvent:(NSNumber *)curveId;
- (NSMutableArray *)queryAllDevice;

- (BOOL)insertNewBean:(BeanModel *)bean;
- (BOOL)deleteqBean:(BeanModel *)bean;
- (BOOL)deleteqReport:(ReportModel *)report;
- (BOOL)updateReportWithReport:(ReportModel *)report WithBean:(NSMutableArray *)beanArr;
@end
