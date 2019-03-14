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
@class CupModel;

@interface DataBase : NSObject
///@brief User Information
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *token;

///@brief Settings
@property (nonatomic, strong) SettingModel *setting;
@property (nonatomic, strong) BeanModel *bean;

@property (nonatomic, strong) FMDatabaseQueue *queueDB;


+ (instancetype)shareDataBase;
- (BOOL)initDB;
- (void)getSettingByApi;

///@brief DB action
- (NSMutableArray *)queryAllReport;
- (NSMutableArray *)queryAllReport:(DeviceModel *)device;
- (NSMutableArray *)queryAllSharedReport;
- (ReportModel *)queryReport:(NSString *)curveUid;
- (NSMutableArray *)queryBeanRelaReport:(NSString *)beanUid;
- (NSArray *)queryReportRelaBean:(NSString *)curveUid;
- (NSMutableArray *)queryAllBean;
- (BeanModel *)queryBean:(NSString *)beanUid;
- (NSArray *)queryEvent:(NSString *)curveUid;
- (NSMutableArray *)queryAllDevice;
- (BOOL)queryDevice:(NSString *)sn;
- (NSMutableArray *)queryAllCup;
- (CupModel *)queryCupWithCupUid:(NSString *)cupUid;


- (BOOL)insertNewBean:(BeanModel *)bean;
- (BOOL)insertNewReport:(ReportModel *)report;
- (BOOL)deleteqBean:(BeanModel *)bean;
- (BOOL)deleteqReport:(ReportModel *)report;
- (BOOL)updateReportWithReport:(ReportModel *)report WithBean:(NSMutableArray *)beanArr;
- (BOOL)updateBean:(BeanModel *)bean;
- (BOOL)updateBeanWeight:(BeanModel *)bean;
- (BOOL)insertNewCup:(CupModel *)cup;
- (BOOL)updateCup:(CupModel *)cup;
- (BOOL)deleteqCup:(CupModel *)cup;
- (BOOL)insertSetting;
- (BOOL)deleteSetting;

- (BOOL)createTable;
- (void)deleteAllTable;
@end
