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
#import "DeviceModel.h"
#import "CupModel.h"

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
        
    }
    return self;
}

- (void)initDB{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Coffee.sql",_userId]];
    NSLog(@"%@",filePath);
    _queueDB = [FMDatabaseQueue databaseQueueWithPath:filePath];
    [self createTable];
    //[self insertBaseEvent];
    _setting = [self setting];
    [self querySetting];
    //[self deleteTable];
    //[self insertNewReport:nil];
}

#pragma mark - Lazy load
- (SettingModel *)setting{
    if (!_setting) {
        _setting = [[SettingModel alloc] init];
        _setting.weightUnit = @"kg";
        _setting.tempUnit = @"℃";
        _setting.bakeChromaReferStandard = @"argon";
        _setting.timeAxis = 10;
        _setting.tempAxis = 300;
        _setting.tempCurveSmooth = 5;
        _setting.tempRateSmooth = 5;
        _setting.language = LocalString(@"中文");
    }
    return _setting;
}

#pragma mark - Data 增删改查
- (void)createTable{
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS beanInfo (beanUid text PRIMARY KEY,beanName text NOT NULL,nation text,area text,manor text,altitude REAL,beanSpecies text,grade text,process text,water REAL,supplier text,price REAL,stock REAL,time text，isShared integer)"];
        if (result) {
            NSLog(@"创建表bean成功");
        }else{
            NSLog(@"创建表bean失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS curveInfo (curveUid text PRIMARY KEY,curveName text NOT NULL,date text,deviceName text,sn text,rawBeanWeight REAL,bakeBeanWeight REAL,light REAL,curveValue text,bakeTime integer,developTime integer,developRate REAL,bakerName text,shareName text,isShare integer NOT NULL)"];
        if (result) {
            NSLog(@"创建表curve成功");
        }else{
            NSLog(@"创建表curve失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS bean_curve (beanUid text NOT NULL,curveUid text NOT NULL,beanWeight REAL NOT NULL,beanName text,nation text,area text,manor text,altitude REAL,beanSpecies text,grade text,process text,water REAL)"];
        if (result) {
            NSLog(@"创建表bean_curve成功");
        }else{
            NSLog(@"创建表bean_curve失败");
        }
        result = [db executeUpdate:@"create unique index if not exists message_key on bean_curve (beanUid,curveUid)"];
        if (result) {
            NSLog(@"创建表bean_curve联合主键成功");
        }else{
            NSLog(@"创建表bean_curve联合主键失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS user_setting_events (eventId integer PRIMARY KEY AUTOINCREMENT,event text NOT NULL)"];
        if (result) {
            NSLog(@"创建表user_setting_events成功");
        }else{
            NSLog(@"创建表user_setting_events失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS curve_event (id integer PRIMARY KEY AUTOINCREMENT,curveUid text NOT NULL,eventId integer NOT NULL,eventText text NOT NULL,eventTime integer NOT NULL,eventBeanTemp REAL NOT NULL)"];
        if (result) {
            NSLog(@"创建表curve_event成功");
        }else{
            NSLog(@"创建表curve_event失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS cup (cupUid text PRIMARY KEY,cupName text NOT NULL,curveUid text,dryAndWet REAL,flavor REAL,aftermath REAL,acid REAL,taste REAL,sweet REAL,balance REAL,overFeel REAL,deveUnfull REAL,overDeve REAL,bakePaste REAL,injure REAL,germInjure REAL,beanFaceInjure REAL,date text,light REAL,total REAL)"];
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
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS device (id integer PRIMARY KEY AUTOINCREMENT,sn text NOT NULL,deviceName text NOT NULL,deviceType integer NOT NULL)"];
        if (result) {
            NSLog(@"创建表device成功");
        }else{
            NSLog(@"创建表device失败");
        }
    }];
}

#pragma mark - 查
- (void)querySetting{
    SettingModel *model = [[SettingModel alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM user_setting"];
        while ([set next]) {
            model.weightUnit = [set stringForColumn:@"weightunit"];
            model.timeAxis = [set intForColumn:@"timeaxis"];
            model.tempUnit = [set stringForColumn:@"tempunit"];
            model.bakeChromaReferStandard = [set stringForColumn:@"bakechromareferstandard"];
            model.tempAxis = [set intForColumn:@"tempaxis"];
            model.tempCurveSmooth = [set intForColumn:@"tempcurvesmooth"];
            model.tempRateSmooth = [set intForColumn:@"tempratesmooth"];
            model.language = [set stringForColumn:@"language"];
            self.setting = model;
        }
        [set close];
    }];
}

- (NSMutableArray *)queryAllReport{//device为nil就查全部
    NSMutableArray *reportArr = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM curveInfo WHERE isShare = 0"];
        while ([set next]) {
            ReportModel *reportModel = [[ReportModel alloc] init];
            reportModel.curveUid = [set stringForColumn:@"curveUid"];
            reportModel.curveName = [set stringForColumn:@"curveName"];
            reportModel.date = [NSDate UTCDateFromLocalString:[set stringForColumn:@"date"]];
            reportModel.deviceName = [set stringForColumn:@"deviceName"];
            [reportArr addObject:reportModel];
        }
        [set close];
    }];
    return reportArr;
}


- (NSMutableArray *)queryAllReport:(DeviceModel *)device{
    NSMutableArray *reportArr = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set;
        if (device == nil) {
            return ;
        }else{
            set = [db executeQuery:@"SELECT * FROM curveInfo WHERE sn = ? AND isShare = 0",device.sn];
        }
        while ([set next]) {
            ReportModel *reportModel = [[ReportModel alloc] init];
            reportModel.curveUid = [set stringForColumn:@"curveUid"];
            reportModel.curveName = [set stringForColumn:@"curveName"];
            reportModel.date = [NSDate UTCDateFromLocalString:[set stringForColumn:@"date"]];
            reportModel.deviceName = [set stringForColumn:@"deviceName"];
            [reportArr addObject:reportModel];
        }
        [set close];
    }];
    return reportArr;
}

- (NSMutableArray *)queryAllSharedReport{//查询来自分享的曲线
    NSMutableArray *reportArr = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM curveInfo WHERE isShare = 1"];
        while ([set next]) {
            ReportModel *reportModel = [[ReportModel alloc] init];
            reportModel.curveUid = [set stringForColumn:@"curveUid"];
            reportModel.curveName = [set stringForColumn:@"curveName"];
            reportModel.date = [NSDate UTCDateFromLocalString:[set stringForColumn:@"date"]];
            reportModel.deviceName = [set stringForColumn:@"deviceName"];
            reportModel.isShare = [set intForColumn:@"isShare"];
            reportModel.sharerName = [set stringForColumn:@"shareName"];;
            [reportArr addObject:reportModel];
        }
        [set close];
    }];
    return reportArr;
}

- (ReportModel *)queryReport:(NSString *)curveUid{
    ReportModel *reportModel = [[ReportModel alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM curveInfo WHERE curveUid = ?",curveUid];
        while ([set next]) {
            reportModel.curveUid = [set stringForColumn:@"curveUid"];
            reportModel.curveName = [set stringForColumn:@"curveName"];
            reportModel.date = [NSDate UTCDateFromLocalString:[set stringForColumn:@"date"]];
            reportModel.deviceName = [set stringForColumn:@"deviceName"];
            reportModel.rawBeanWeight = [set doubleForColumn:@"rawBeanWeight"];
            reportModel.bakeBeanWeight = [set doubleForColumn:@"bakeBeanWeight"];
            reportModel.light = [set doubleForColumn:@"light"];
            reportModel.curveValueJson = [set stringForColumn:@"curveValue"];
            reportModel.bakeTime = [set intForColumn:@"bakeTime"];
            reportModel.developTime = [set intForColumn:@"developTime"];
            reportModel.developRate = [set doubleForColumn:@"developRate"];
            reportModel.bakerName = [set stringForColumn:@"bakerName"];
        }
        [set close];
    }];
    return reportModel;
}

- (NSMutableArray *)queryBeanRelaReport:(NSString *)beanUid{//device为nil就查全部
    NSMutableArray *reportArr = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT curve.curveUid,curve.curveName,curve.date,curve.deviceName FROM bean_curve AS bc,curveInfo AS curve WHERE beanUid = ? AND bc.curveUid = curve.curveUid",beanUid];
        while ([set next]) {
            ReportModel *reportModel = [[ReportModel alloc] init];
            reportModel.curveUid = [set stringForColumn:@"curveUid"];
            reportModel.curveName = [set stringForColumn:@"curveName"];
            reportModel.date = [NSDate UTCDateFromLocalString:[set stringForColumn:@"date"]];
            reportModel.deviceName = [set stringForColumn:@"deviceName"];
            [reportArr addObject:reportModel];
        }
        [set close];
    }];
    return reportArr;
}

- (NSArray *)queryReportRelaBean:(NSString *)curveUid{
    NSMutableArray *beanArray = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM bean_curve WHERE curveUid = ?",curveUid];
        while ([set next]) {
            BeanModel *beanModel = [[BeanModel alloc] init];
            beanModel.beanUid = [set stringForColumn:@"beanUid"];
            beanModel.weight = [set intForColumn:@"beanWeight"];
            [beanArray addObject:beanModel];
        }
        [set close];
    }];
    return [beanArray copy];
}

- (NSMutableArray *)queryAllBean{
    NSMutableArray *beanArray = [NSMutableArray array];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM beanInfo"];
        while ([set next]) {
            BeanModel *beanModel = [[BeanModel alloc] init];
            beanModel.beanUid = [set stringForColumn:@"beanUid"];
            beanModel.name = [set stringForColumn:@"beanName"];
            beanModel.nation = [set stringForColumn:@"nation"];
            beanModel.area = [set stringForColumn:@"area"];
            beanModel.altitude = [set doubleForColumn:@"altitude"];
            beanModel.manor = [set stringForColumn:@"manor"];
            beanModel.beanSpecies = [set stringForColumn:@"beanSpecies"];
            beanModel.grade = [set stringForColumn:@"grade"];
            beanModel.process = [set stringForColumn:@"process"];
            beanModel.water = [set doubleForColumn:@"water"];
            beanModel.supplier = [set stringForColumn:@"supplier"];
            beanModel.price = [set doubleForColumn:@"price"];
            beanModel.stock = [set doubleForColumn:@"stock"];
            beanModel.time = [NSDate YMDDateFromLocalString:[set stringForColumn:@"time"]];
            [beanArray addObject:beanModel];
        }
        [set close];
    }];
    return beanArray;
}

- (BeanModel *)queryBean:(NSString *)beanUid{
    BeanModel *beanModel = [[BeanModel alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM beanInfo WHERE beanUid = ?",beanUid];
        while ([set next]) {
            beanModel.beanUid = beanUid;
            beanModel.name = [set stringForColumn:@"beanName"];
            beanModel.nation = [set stringForColumn:@"nation"];
            beanModel.area = [set stringForColumn:@"area"];
            beanModel.altitude = [set doubleForColumn:@"altitude"];
            beanModel.manor = [set stringForColumn:@"manor"];
            beanModel.beanSpecies = [set stringForColumn:@"beanSpecies"];
            beanModel.grade = [set stringForColumn:@"grade"];
            beanModel.process = [set stringForColumn:@"process"];
            beanModel.water = [set doubleForColumn:@"water"];
            beanModel.supplier = [set stringForColumn:@"supplier"];
            beanModel.price = [set doubleForColumn:@"price"];
            beanModel.stock = [set doubleForColumn:@"stock"];
            beanModel.time = [NSDate YMDDateFromLocalString:[set stringForColumn:@"time"]];
        }
        [set close];
    }];
    return beanModel;
}

//user_setting_events中1-8都是基本事件，快速事件id从10后面开始
- (NSArray *)queryEvent:(NSString *)curveUid{
    NSMutableArray *eventArray = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM curve_event WHERE curveUid = ? ORDER BY eventId",curveUid];
        while ([set next]) {
            EventModel *eventModel = [[EventModel alloc] init];//每次循环都必须新建对象，不然都是在同一个对象（内存地址）操作
            eventModel.eventId = [set intForColumn:@"eventId"];
            eventModel.eventTime = [set intForColumn:@"eventTime"];
            eventModel.eventBeanTemp = [set doubleForColumn:@"eventBeanTemp"];
            eventModel.eventText = [set stringForColumn:@"eventText"];
            [eventArray addObject:eventModel];
            NSLog(@"%@",eventModel.eventText);
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
            device.sn = [set stringForColumn:@"sn"];
            device.deviceName = [set stringForColumn:@"deviceName"];
            device.deviceType = [NSNumber numberWithInteger:[set intForColumn:@"deviceType"]];
            [deviceArray addObject:device];
        }
    }];
    return deviceArray;
}

- (BOOL)queryDevice:(NSString *)sn{
    static BOOL isContain = NO;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM device WHERE sn = ?",sn];
        while ([set next]) {
            isContain = YES;
        }
    }];
    return isContain;
}

- (NSMutableArray *)queryAllCup{
    NSMutableArray *cupArray = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM cup"];
        while ([set next]) {
            CupModel *cup = [[CupModel alloc] init];
            cup.cupUid = [set stringForColumn:@"cupUid"];
            cup.name = [set stringForColumn:@"cupName"];
            cup.curveUid = [set stringForColumn:@"curveUid"];
            cup.dryAndWet = [set doubleForColumn:@"dryAndWet"];
            cup.flavor = [set doubleForColumn:@"flavor"];
            cup.aftermath = [set doubleForColumn:@"aftermath"];
            cup.acid = [set doubleForColumn:@"acid"];
            cup.taste = [set doubleForColumn:@"taste"];
            cup.sweet = [set doubleForColumn:@"sweet"];
            cup.balance = [set doubleForColumn:@"balance"];
            cup.overFeel = [set doubleForColumn:@"overFeel"];
            cup.deveUnfull = [set doubleForColumn:@"deveUnfull"];
            cup.overDeve = [set doubleForColumn:@"overDeve"];
            cup.bakePaste = [set doubleForColumn:@"bakePaste"];
            cup.injure = [set doubleForColumn:@"injure"];
            cup.germInjure = [set doubleForColumn:@"germInjure"];
            cup.beanFaceInjure = [set doubleForColumn:@"beanFaceInjure"];
            cup.date = [NSDate YMDDateFromLocalString:[set stringForColumn:@"date"]];
            cup.light = [set doubleForColumn:@"light"];
            [cupArray addObject:cup];
        }
    }];
    return cupArray;
}

- (CupModel *)queryCupWithCupUid:(NSString *)cupUid{
    CupModel *cup = [[CupModel alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM cup WHERE cupUid = ?",cupUid];
        while ([set next]) {
            cup.cupUid = cupUid;
            cup.name = [set stringForColumn:@"cupName"];
            cup.curveUid = [set stringForColumn:@"curveUid"];
            cup.dryAndWet = [set doubleForColumn:@"dryAndWet"];
            cup.flavor = [set doubleForColumn:@"flavor"];
            cup.aftermath = [set doubleForColumn:@"aftermath"];
            cup.acid = [set doubleForColumn:@"acid"];
            cup.taste = [set doubleForColumn:@"taste"];
            cup.sweet = [set doubleForColumn:@"sweet"];
            cup.balance = [set doubleForColumn:@"balance"];
            cup.overFeel = [set doubleForColumn:@"overFeel"];
            cup.deveUnfull = [set doubleForColumn:@"deveUnfull"];
            cup.overDeve = [set doubleForColumn:@"overDeve"];
            cup.bakePaste = [set doubleForColumn:@"bakePaste"];
            cup.injure = [set doubleForColumn:@"injure"];
            cup.germInjure = [set doubleForColumn:@"germInjure"];
            cup.beanFaceInjure = [set doubleForColumn:@"beanFaceInjure"];
            cup.date = [NSDate YMDDateFromLocalString:[set stringForColumn:@"date"]];
            cup.light = [set doubleForColumn:@"light"];
        }
    }];
    return cup;
}
#pragma mark - 增
//- (void)insertBaseEvent{
//    NSArray *eventTextArray = @[@"开始烘焙",@"脱水结束",@"一爆开始",@"一爆结束",@"二爆开始",@"二爆结束",@"烘焙结束"];
//    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
//        for (int i = 0; i < eventTextArray.count; i++) {
//            BOOL result = [db executeUpdate:@"REPLACE INTO user_setting_events (eventId,event) VALUES (?,?)",[NSNumber numberWithInt:i],eventTextArray[i]];
//            if (!result) {
//                NSLog(@"插入失败");
//            }
//        }
//    }];
//}

- (BOOL)insertNewReport:(ReportModel *)report{
    static BOOL result = YES;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"INSERT INTO beanInfo (curveUid,curveName,date,deviceName,sn,rawBeanWeight,bakeBeanWeight,light,curveValue,bakeTime,developTime,developRate,bakerName,shareName,isShare) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",report.curveUid,report.curveName,[NSDate YMDHMStringFromUTCDate:report.date],report.deviceName,report.sn,[NSNumber numberWithDouble:report.rawBeanWeight],[NSNumber numberWithDouble:report.bakeBeanWeight],[NSNumber numberWithFloat:report.light],report.curveValueJson,[NSNumber numberWithInteger:report.bakeTime],[NSNumber numberWithInteger:report.developTime],[NSNumber numberWithFloat:report.developRate],report.bakerName,report.sharerName,[NSNumber numberWithInteger:report.isShare]];
        //result = [db executeUpdate:@"INSERT INTO curveInfo (curveUid,curveName,date,deviceName,sn,rawBeanWeight,bakeBeanWeight,light,curveValue,bakeTime,developTime,developRate,bakerName,shareName,isShare) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)",@"yangpin",@"样品豆",[NSDate localStringFromUTCDate:[NSDate dateWithTimeInterval:3*24*60*60 sinceDate:[NSDate date]]],@"HR型烘焙机",@"fcc",@0,@0,@0,@"",@0,@0,@"",@"",@"",@0];
        if (!result) {
            NSLog(@"添加报告失败");
        }
    }];
    return result;
}

- (BOOL)insertNewBean:(BeanModel *)bean{
    if (!bean.nation) {
        bean.nation = @"";
    }
    
    if (!bean.area) {
        bean.area = @"";
    }
    
    if (!bean.stock) {
        bean.stock = 0;
    }
    
    if (!bean.manor) {
        bean.manor = @"";
    }
    
    if (!bean.supplier) {
        bean.supplier = @"";
    }
    
    if (!bean.water) {
        bean.water = 0;
    }
    
    if (!bean.altitude) {
        bean.altitude = 0;
    }
    
    if (!bean.price) {
        bean.price = 0;
    }
    
    if (!bean.beanSpecies) {
        bean.beanSpecies = @"";
    }
    if (!bean.grade) {
        bean.grade = @"";
    }
    if (!bean.process) {
        bean.process = @"";
    }
    if (!bean.time) {
        bean.time = [NSDate date];
    }
    static BOOL result = YES;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"INSERT INTO beanInfo (beanUid,beanName,nation,area,manor,altitude,beanSpecies,grade,process,water,supplier,price,stock,time) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)",bean.beanUid,bean.name,bean.nation,bean.area,bean.manor,[NSNumber numberWithFloat:bean.altitude],bean.beanSpecies,bean.grade,bean.process,[NSNumber numberWithFloat:bean.water],bean.supplier,[NSNumber numberWithFloat:bean.price],[NSNumber numberWithFloat:bean.stock],[NSDate YMDStringFromDate:bean.time]];
        NSLog(@"%@",bean.name);
        if (!result) {
            NSLog(@"添加咖啡豆失败");
        }
    }];
    return result;
}

- (BOOL)insertNewCup:(CupModel *)cup{
    static BOOL result = YES;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"INSERT INTO cup (cupUid,cupName,curveUid,dryAndWet,flavor,aftermath,acid,taste,sweet,balance,overFeel,deveUnfull,overDeve,bakePaste,injure,germInjure ,beanFaceInjure,date,light,total) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",cup.cupUid,cup.name,cup.curveUid,[NSNumber numberWithFloat:cup.dryAndWet],[NSNumber numberWithFloat:cup.flavor],[NSNumber numberWithFloat:cup.aftermath],[NSNumber numberWithFloat:cup.acid],[NSNumber numberWithFloat:cup.taste],[NSNumber numberWithFloat:cup.sweet],[NSNumber numberWithFloat:cup.balance],[NSNumber numberWithFloat:cup.overFeel],[NSNumber numberWithFloat:cup.deveUnfull],[NSNumber numberWithFloat:cup.overDeve],[NSNumber numberWithFloat:cup.bakePaste],[NSNumber numberWithFloat:cup.injure],[NSNumber numberWithFloat:cup.germInjure],[NSNumber numberWithFloat:cup.beanFaceInjure],[NSDate YMDStringFromDate:[NSDate date]],[NSNumber numberWithFloat:cup.light],[NSNumber numberWithFloat:cup.grade]];
        NSLog(@"%@",cup.cupUid);
        if (!result) {
            NSLog(@"添加咖啡豆失败");
        }
    }];
    return result;
}

- (BOOL)insertSetting{
    static BOOL result = YES;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"INSERT INTO user_setting (weightunit,tempunit,bakechromareferstandard,timeaxis,tempaxis,tempcurvesmooth,tempratesmooth,language) VALUES (?,?,?,?,?,?,?,?)",_setting.weightUnit,_setting.tempUnit,_setting.bakeChromaReferStandard,[NSNumber numberWithInteger:_setting.timeAxis],[NSNumber numberWithInteger:_setting.tempAxis],[NSNumber numberWithInteger:_setting.tempCurveSmooth],[NSNumber numberWithInteger:_setting.tempRateSmooth],_setting.language];
        if (!result) {
            NSLog(@"添加咖啡豆失败");
        }
    }];
    return result;
}

#pragma mark - 删
- (BOOL)deleteqBean:(BeanModel *)bean{
    static BOOL result = YES;
    [_queueDB inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from beanInfo where beanUid = ?",bean.beanUid];
    }];
    return result;
}

- (BOOL)deleteqReport:(ReportModel *)report{
    static BOOL result = YES;
    [_queueDB inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from curveInfo where curveUid = ?",report.curveUid];
    }];
    return result;
}

- (BOOL)deleteqCup:(CupModel *)cup{
    static BOOL result = YES;
    [_queueDB inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from cup where cupUid = ?",cup.cupUid];
    }];
    return result;
}

- (BOOL)deleteSetting{
    static BOOL result = YES;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"delete from user_setting"];
    }];
    return result;
}

#pragma mark - 改
- (BOOL)updateReportWithReport:(ReportModel *)report WithBean:(NSMutableArray *)beanArr{
    NSMutableArray *beanArrayBeforeUpdate = [[self queryReportRelaBean:report.curveUid] mutableCopy];
    static BOOL isSucc = NO;
    [_queueDB inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        BOOL result = [db executeUpdate:@"UPDATE curveInfo SET curveName = ?,light = ?,bakeBeanWeight = ? WHERE curveUid = ?",report.curveName,[NSNumber numberWithFloat:report.light],[NSNumber numberWithFloat:report.bakeBeanWeight],report.curveUid];
        if (!result) {
            *rollback = YES;
            NSLog(@"修改曲线失败");
            [NSObject showHudTipStr:@"修改曲线失败"];
            return;
        }
        
        //更新曲线生豆关联
        for (int i = 0; i < beanArr.count; i++) {
            BeanModel *bean = beanArr[i];
            result = [db executeUpdate:@"REPLACE INTO bean_curve (beanUid,curveUid,beanWeight) VALUES (?,?,?)",bean.beanUid,report.curveUid,[NSNumber numberWithFloat:bean.weight]];
            if (!result) {
                *rollback = YES;
                NSLog(@"插入曲线失败，生豆信息有误");
                [NSObject showHudTipStr:@"修改曲线失败，生豆信息有误"];
                return;
            }
        }
        
        //本地同步要删除的生豆
        for (BeanModel *bean in beanArrayBeforeUpdate) {
            BOOL isDeleted = YES;
            for (BeanModel *newBean in beanArr) {
                if ([bean.beanUid isEqualToString:newBean.beanUid]) {
                    isDeleted = NO;
                }
            }
            if (isDeleted) {
                result = [db executeUpdate:@"UPDATE beanInfo SET stock = stock + ? WHERE beanUid = ?",[NSNumber numberWithFloat:bean.weight],bean.beanUid];
                if (!result) {
                    *rollback = YES;
                    NSLog(@"添加生豆重量失败");
                    [NSObject showHudTipStr:@"数据库操作失败"];
                    return;
                }
                result = [db executeUpdate:@"delete from bean_curve where beanUid = ? AND curveUid = ?",bean.beanUid,report.curveUid];
                if (!result) {
                    *rollback = YES;
                    NSLog(@"删除曲线关联豆失败");
                    [NSObject showHudTipStr:@"删除曲线关联豆失败"];
                    return;
                }
            }
        }
        
        //更新生豆库存
        for (int i = 0; i < beanArr.count; i++) {
            BeanModel *bean = beanArr[i];
            
            BOOL isContain = NO;
            for (BeanModel *oldBean in beanArrayBeforeUpdate) {
                if ([oldBean.beanUid isEqualToString:bean.beanUid]) {
                    isContain = YES;
                    result = [db executeUpdate:@"UPDATE beanInfo SET stock = stock - ? + ? WHERE beanUid = ?",[NSNumber numberWithFloat:bean.weight],[NSNumber numberWithFloat:oldBean.weight],bean.beanUid];
                    if (!result) {
                        *rollback = YES;
                        NSLog(@"更新生豆重量失败");
                        [NSObject showHudTipStr:@"更新生豆重量失败"];
                        return;
                    }
                }
            }
            if (!isContain) {
                result = [db executeUpdate:@"UPDATE beanInfo SET stock = stock - ? WHERE beanUid = ?",[NSNumber numberWithFloat:bean.weight],bean.beanUid];
                if (!result) {
                    *rollback = YES;
                    NSLog(@"更新生豆重量失败");
                    [NSObject showHudTipStr:@"更新生豆重量失败"];
                    return;
                }
            }
        }
        
        isSucc = YES;
    }];
    return isSucc;
}

- (BOOL)updateBean:(BeanModel *)bean{
    static BOOL result = YES;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"UPDATE beanInfo SET beanName = ?,nation = ?,area = ?,manor = ?,altitude = ?,beanSpecies = ?,grade = ?,process = ?,water = ?,supplier = ?,price = ?,stock = ?,time = ? WHERE beanUid = ?",bean.name,bean.nation,bean.area,bean.manor,[NSNumber numberWithFloat:bean.altitude],bean.beanSpecies,bean.grade,bean.process,[NSNumber numberWithFloat:bean.water],bean.supplier,[NSNumber numberWithFloat:bean.price],[NSNumber numberWithFloat:bean.stock],[NSDate YMDStringFromDate:bean.time],bean.beanUid];
        NSLog(@"%@",bean.name);
        if (!result) {
            NSLog(@"更新咖啡豆失败");
        }
    }];
    return result;
}

- (BOOL)updateBeanWeight:(BeanModel *)bean{
    static BOOL result = YES;
    //计算使用后豆的库存量
    BeanModel *beanW = [self queryBean:bean.beanUid];
    bean.stock = beanW.stock - bean.weight;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"UPDATE beanInfo SET stock = ? WHERE beanUid = ?",[NSNumber numberWithFloat:bean.stock],bean.beanUid];
        if (!result) {
            NSLog(@"更新咖啡豆失败");
        }
    }];
    return result;
}

- (BOOL)updateCup:(CupModel *)cup{
    static BOOL result = YES;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"UPDATE cup SET cupName = ?,curveUid = ?,dryAndWet = ?,flavor = ?,aftermath = ?,acid = ?,taste = ?,sweet = ?,balance = ?,overFeel = ?,deveUnfull = ?,overDeve = ?,bakePaste = ?,injure = ?,germInjure = ?,beanFaceInjure = ?,date = ?,light = ?,total = ? WHERE cupUid = ?",cup.name,cup.curveUid,[NSNumber numberWithFloat:cup.dryAndWet],[NSNumber numberWithFloat:cup.flavor],[NSNumber numberWithFloat:cup.aftermath],[NSNumber numberWithFloat:cup.acid],[NSNumber numberWithFloat:cup.taste],[NSNumber numberWithFloat:cup.sweet],[NSNumber numberWithFloat:cup.balance],[NSNumber numberWithFloat:cup.overFeel],[NSNumber numberWithFloat:cup.deveUnfull],[NSNumber numberWithFloat:cup.overDeve],[NSNumber numberWithFloat:cup.bakePaste],[NSNumber numberWithFloat:cup.injure],[NSNumber numberWithFloat:cup.germInjure],[NSNumber numberWithFloat:cup.beanFaceInjure],[NSDate YMDStringFromDate:cup.date],[NSNumber numberWithFloat:cup.light],[NSNumber numberWithFloat:cup.grade],cup.cupUid];
        NSLog(@"%@",cup.name);
        if (!result) {
            NSLog(@"修改咖啡豆失败");
        }
    }];
    return result;
}
#pragma mark - 删表(用来重新生成表格)
- (void)deleteAllTable{
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:@"DROP TABLE cup"];
        result = [db executeUpdate:@"DROP TABLE beanInfo"];
        result = [db executeUpdate:@"DROP TABLE curveInfo"];
        result = [db executeUpdate:@"DROP TABLE bean_curve"];
        result = [db executeUpdate:@"DROP TABLE user_setting_events"];
        result = [db executeUpdate:@"DROP TABLE curve_event"];
        result = [db executeUpdate:@"DROP TABLE user_setting"];
        result = [db executeUpdate:@"DROP TABLE device"];
        if (result) {
            NSLog(@"Drop table success");
        }else
        {
            NSLog(@"Drop table Failure");
        }
    }];
}

#pragma mark - api
- (void)getSettingByApi{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 4.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/setting"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    NSLog(@"%@",[DataBase shareDataBase].userId);
    NSLog(@"%@",[DataBase shareDataBase].token);
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            if ([responseDic objectForKey:@"data"]) {
                NSDictionary *settingDic = [responseDic objectForKey:@"data"];
                if (settingDic == nil) {
                    [self addSettingByApi];
                }else{
                    self.setting.weightUnit = [settingDic objectForKey:@"weightUnit"];
                    self.setting.tempUnit = [settingDic objectForKey:@"tempUnit"];
                    self.setting.bakeChromaReferStandard = [settingDic objectForKey:@"roasterChroma"];
                    self.setting.timeAxis = [[settingDic objectForKey:@"timer"] integerValue];
                    self.setting.tempAxis = [[settingDic objectForKey:@"temp"] integerValue];
                    self.setting.tempCurveSmooth = [[settingDic objectForKey:@"tempCurveSmooth"] integerValue];
                    self.setting.tempRateSmooth = [[settingDic objectForKey:@"tempRateSmooth"] integerValue];
                    self.setting.language = [settingDic objectForKey:@"language"];
                    [self deleteSetting];//删除之前可能存在的设置
                    if (![self insertSetting]) {
                        [NSObject showHudTipStr:@"通用设置本地同步失败"];
                    }
                }
            }
        }else{
            [self addSettingByApi];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
    }];
}

- (void)addSettingByApi{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 4.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/setting"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"weightUnit":self.setting.weightUnit,@"tempUnit":self.setting.tempUnit,@"roasterChroma":self.setting.bakeChromaReferStandard,@"timer":[NSNumber numberWithInteger:self.setting.timeAxis],@"temp":[NSNumber numberWithInteger:self.setting.tempAxis],@"tempCurveSmooth":[NSNumber numberWithInteger:self.setting.tempCurveSmooth],@"tempRateSmooth":[NSNumber numberWithInteger:self.setting.tempRateSmooth],@"language":self.setting.language};
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [self insertSetting];
        }else{
            [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

@end
