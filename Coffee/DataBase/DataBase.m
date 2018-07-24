//
//  DataBase.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DataBase.h"
#import "FMDB.h"

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
        NSString *filePath = [docPath stringByAppendingPathComponent:@"Coffee.sql"];
        NSLog(@"%@",filePath);
        _queueDB = [FMDatabaseQueue databaseQueueWithPath:filePath];
        [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS user_setting (userId integer PRIMARY KEY,weightUnit text NOT NULL,tempUnit text NOT NULL,bakeChromaReferStandard text NOT NULL,timeAxis text NOT NULL,tempAxis text NOT NULL,tempCurveSmooth integer NOT NULL,tempRateSmooth integer NOT NULL,language text NOT NULl)"];
            if (result) {
                NSLog(@"创建表成功");
            }else{
                NSLog(@"创建表失败");
            }
        }];
        
        _userName = @"y52";
    }
    return self;
}

- (SettingModel *)selectSetting{
    SettingModel *model = [[SettingModel alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM user_setting WHERE userId = ?",@1];
        model.weightUnit = [set stringForColumn:@"weightUnit"];
    }];
    return model;
}

@end
