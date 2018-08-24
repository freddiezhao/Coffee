//
//  DataBase.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DataBase.h"
#import "FMDB.h"
#import "SettingModel.h"
#import "BeanModel.h"
#import "ReportModel.h"
#import "EventModel.h"
#import "DeviceModel.h"

static DataBase *_dataBase = nil;

@implementation DataBase

+ (instancetype)shareDataBase{
    if (_dataBase == nil) {
        _dataBase = [[self alloc] init];
    }
    return _dataBase;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
        if (_dataBase == nil) {
            _dataBase = [super allocWithZone:zone];
        }
    });
    
    return _dataBase;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _userId = [NSNumber numberWithInt:11111];
        NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Coffee.sql",_userId]];
        NSLog(@"%@",filePath);
        _queueDB = [FMDatabaseQueue databaseQueueWithPath:filePath];
        [self createTable];
        [self insertBaseEvent];
        _setting = [self querySetting];
    }
    return self;
}

- (void)createTable{
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS beanInfo (beanId integer PRIMARY KEY AUTOINCREMENT,beanName text NOT NULL,nation text NOT NULL,area text NOT NULL,manor text NOT NULL,altitude integer NOT NULL,beanSpecies text NOT NULL,grade text NOT NULL,process text NOT NULL,water integer NOT NULL,supplier text NOT NULL,price integer NOT NULL,stock integer NOT NULL,time text NOT NULL)"];
        if (result) {
            NSLog(@"创建表bean成功");
        }else{
            NSLog(@"创建表bean失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS curveInfo (curveId integer PRIMARY KEY AUTOINCREMENT,curveName text NOT NULL,date text NOT NULL,deviceName text NOT NULL,rawBeanWeight integer NOT NULL,bakeBeanWeight integer NOT NULL,light integer NOT NULL,curveValue text NOT NULL,bakeTime integer NOT NULL,developTime integer NOT NULL,developRate text NOT NULL,bakerName text NOT NULL)"];
        if (result) {
            NSLog(@"创建表curve成功");
        }else{
            NSLog(@"创建表curve失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS bean_curve (id integer PRIMARY KEY AUTOINCREMENT,beanId integer NOT NULl,curveId integer NOT NULL,beanWeight integer NOT NULL)"];
        if (result) {
            NSLog(@"创建表bean_curve成功");
        }else{
            NSLog(@"创建表bean_curve失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS user_setting_events (eventId integer PRIMARY KEY AUTOINCREMENT,event text NOT NULL)"];
        if (result) {
            NSLog(@"创建表user_setting_events成功");
        }else{
            NSLog(@"创建表user_setting_events失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS curve_event (id integer PRIMARY KEY AUTOINCREMENT,curveId integer NOT NULL,eventId integer NOT NULL,eventTime integer NOT NULL,eventBeanTemp integer NOT NULL)"];
        if (result) {
            NSLog(@"创建表curve_event成功");
        }else{
            NSLog(@"创建表curve_event失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS cup (cupId integer PRIMARY KEY AUTOINCREMENT,curveId integer NOT NULL,bakeDegree text NOT NULL,dryAndWet text NOT NULL,flavor text NOT NULL,aftermath text NOT NULL,acid text NOT NULL,taste text NOT NULL,sweet text NOT NULL,balance text NOT NULL,overFeel text NOT NULL,deveUnfull text NOT NULL,overDeve text NOT NULL,bakePaste text NOT NULL,injure text NOT NULL,germInjure text NOT NULL,beanFaceInjure text NOT NULL)"];
        if (result) {
            NSLog(@"创建表cup成功");
        }else{
            NSLog(@"创建表cup失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS user_setting (id integer PRIMARY KEY AUTOINCREMENT,weightunit text NOT NULL,tempunit text NOT NULL,bakechromareferstandard text NOT NULL,timeaxis text NOT NULL,tempaxis text NOT NULL,tempcurvesmooth integer NOT NULL,tempratesmooth integer NOT NULL,language text NOT NULl)"];
        if (result) {
            NSLog(@"创建表user_setting成功");
        }else{
            NSLog(@"创建表user_setting失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS device (id integer PRIMARY KEY AUTOINCREMENT,mac text NOT NULL,deviceName text NOT NULL)"];
        if (result) {
            NSLog(@"创建表device成功");
        }else{
            NSLog(@"创建表device失败");
        }
    }];
}

#pragma mark - 查
- (SettingModel *)querySetting{
    SettingModel *model = [[SettingModel alloc] init];
    model.events = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM user_setting"];
        model.weightUnit = [set stringForColumn:@"weightUnit"];
        model.timeAxis = [set stringForColumn:@"timeAxis"];
        FMResultSet *set1 = [db executeQuery:@"SELECT * FROM user_setting_events"];
        while ([set1 next]) {
            [model.events addObject:[set1 stringForColumn:@"event"]];
        }
        [set close];
        [set1 close];
    }];
    return model;
}

- (ReportModel *)queryReport:(NSNumber *)curveId{
    ReportModel *reportModel = [[ReportModel alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM curveInfo WHERE curveId = ?",curveId];
        while ([set next]) {
            reportModel.curveName = [set stringForColumn:@"curveName"];
            reportModel.date = [NSDate UTCDateFromLocalString:[set stringForColumn:@"date"]];
            reportModel.deviceName = [set stringForColumn:@"deviceName"];
            reportModel.rawBeanWeight = [set intForColumn:@"rawBeanWeight"];
            reportModel.bakeBeanWeight = [set intForColumn:@"bakeBeanWeight"];
            reportModel.light = [set intForColumn:@"light"];
            reportModel.curveValueJson = [set stringForColumn:@"curveValue"];
            reportModel.bakeTime = [set intForColumn:@"bakeTime"];
            reportModel.developTime = [set intForColumn:@"developTime"];
            reportModel.developRate = [set stringForColumn:@"developRate"];
            reportModel.bakerName = [set stringForColumn:@"bakerName"];
//            reportModel.tempBake_event = [set stringForColumn:@"tempBake_event"];
//            reportModel.firstBoom_event = [set stringForColumn:@"firstBoom_event"];
//            reportModel.startTemp = [set stringForColumn:@"startTemp"];
//            reportModel.endTemp = [set stringForColumn:@"endTemp"];
        }
        [set close];
    }];
    return reportModel;
}

- (NSArray *)queryReportRelaBean:(NSNumber *)curveId{
    NSMutableArray *beanArray = [[NSMutableArray alloc] init];
    BeanModel *beanModel = [[BeanModel alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM bean_curve WHERE curveId = ?",curveId];
        while ([set next]) {
            beanModel.beanId = [set intForColumn:@"beanId"];
            beanModel.weight = [set intForColumn:@"beanWeight"];
            [beanArray addObject:beanModel];
        }
        [set close];
    }];
    return [beanArray copy];
}

- (NSMutableArray *)queryAllBean{
    NSMutableArray *beanArray = [NSMutableArray array];
    BeanModel *beanModel = [[BeanModel alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM beanInfo"];
        while ([set next]) {
            beanModel.name = [set stringForColumn:@"beanName"];
            beanModel.nation = [set stringForColumn:@"nation"];
            beanModel.area = [set stringForColumn:@"area"];
            beanModel.altitude = [set intForColumn:@"altitude"];
            beanModel.manor = [set stringForColumn:@"manor"];
            beanModel.beanSpecies = [set stringForColumn:@"beanSpecies"];
            beanModel.grade = [set stringForColumn:@"grade"];
            beanModel.process = [set stringForColumn:@"process"];
            beanModel.water = [set intForColumn:@"water"];
            beanModel.supplier = [set stringForColumn:@"supplier"];
            beanModel.price = [set intForColumn:@"price"];
            beanModel.stock = [set intForColumn:@"stock"];
            beanModel.time = [NSDate UTCDateFromLocalString:[set stringForColumn:@"time"]];
            [beanArray addObject:beanModel];
        }
        [set close];
    }];
    return beanArray;
}

- (BeanModel *)queryBean:(NSNumber *)beanId{
    BeanModel *beanModel = [[BeanModel alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM beanInfo WHERE beanId = ?",beanId];
        while ([set next]) {
            beanModel.name = [set stringForColumn:@"beanName"];
            beanModel.nation = [set stringForColumn:@"nation"];
            beanModel.area = [set stringForColumn:@"area"];
            beanModel.altitude = [set intForColumn:@"altitude"];
            beanModel.manor = [set stringForColumn:@"manor"];
            beanModel.beanSpecies = [set stringForColumn:@"beanSpecies"];
            beanModel.grade = [set stringForColumn:@"grade"];
            beanModel.process = [set stringForColumn:@"process"];
            beanModel.water = [set intForColumn:@"water"];
            beanModel.supplier = [set stringForColumn:@"supplier"];
            beanModel.price = [set intForColumn:@"price"];
            beanModel.stock = [set intForColumn:@"stock"];
            beanModel.time = [NSDate UTCDateFromLocalString:[set stringForColumn:@"time"]];
        }
        [set close];
    }];
    return beanModel;
}

//user_setting_events中1-8都是基本事件，快速事件id从10后面开始
- (NSArray *)queryEvent:(NSNumber *)curveId{
    NSMutableArray *eventArray = [[NSMutableArray alloc] init];
    EventModel *eventModel = [[EventModel alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT bc.*,use.event FROM curve_event bc,user_setting_events use WHERE curveId = ? AND bc.eventId = use.eventId ORDER BY bc.eventId",curveId];
        while ([set next]) {
            eventModel.eventId = [set intForColumn:@"eventId"];
            eventModel.eventTime = [set intForColumn:@"eventTime"];
            eventModel.eventBeanTemp = [set stringForColumn:@"eventBeanTemp"];
            eventModel.eventText = [set stringForColumn:@"event"];
            [eventArray addObject:eventModel];
        }
        [set close];
    }];
    return [eventArray copy];
}

- (NSMutableArray *)queryAllDevice{
    NSMutableArray *deviceArray = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM device"];
        while ([set next]) {
            DeviceModel *device = [[DeviceModel alloc] init];
            device.deviceId = [set intForColumn:@"id"];
            device.deviceMac = [set stringForColumn:@"mac"];
            device.deviceName = [set stringForColumn:@"deviceName"];
            [deviceArray addObject:device];
        }
    }];
    return deviceArray;
}

#pragma mark - 增
- (void)insertBaseEvent{
    NSArray *eventTextArray = @[@"开始烘焙",@"脱水结束",@"一爆开始",@"一爆结束",@"二爆开始",@"二爆结束",@"烘焙结束",@"火力/风力"];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        for (int i = 0; i < eventTextArray.count; i++) {
            BOOL result = [db executeUpdate:@"REPLACE INTO user_setting_events (eventId,event) VALUES (?,?)",[NSNumber numberWithInt:i],eventTextArray[i]];
            if (!result) {
                NSLog(@"插入失败");
            }
        }
    }];
}

- (void)insertNewBean:(BeanModel *)bean{
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:@"INSERT INTO beanInfo (beanName,nation,area,manor,altitude,beanSpecies,grade,process,water,supplier,price,stock,time) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",bean.name,bean.nation,bean.area,bean.manor,[NSNumber numberWithFloat:bean.altitude],bean.beanSpecies,bean.grade,bean.process,[NSNumber numberWithFloat:bean.water],bean.supplier,[NSNumber numberWithFloat:bean.price],[NSNumber numberWithFloat:bean.stock],[NSDate YMDStringFromDate:bean.time]];
        if (!result) {
            NSLog(@"添加咖啡豆失败");
        }
    }];
}

@end
