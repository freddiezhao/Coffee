//
//  DataWithApi.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/10.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DataWithApi.h"
#import "BeanModel.h"
#import "ReportModel.h"
#import "CupModel.h"
#import "FMDB.h"

@implementation DataWithApi
- (void)startGetInfo{
    [self getAllBeanByApi];
    //[self getAllCupByApi];
    //[self getAllReportByApi]
}

#pragma mark - 生豆列表页面
- (void)getAllBeanByApi{
    [SVProgressHUD showWithStatus:LocalString(@"从服务器同步用户存储内容中...")];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/bean/list"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];

    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSMutableArray *beanArr = [[NSMutableArray alloc] init];
            if ([responseDic objectForKey:@"data"]) {
                NSDictionary *beansDic = [responseDic objectForKey:@"data"];
                [[beansDic objectForKey:@"beans"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *beanUid = [obj objectForKey:@"beanUid"];
                    [beanArr addObject:beanUid];
                }];
            }
            [self getBeanInfoByAPIWithBeanUidArr:beanArr];
        }else{
            [NSObject showHudTipStr:LocalString(@"从服务器获取生豆信息失败")];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        [NSObject showHudTipStr:LocalString(@"从服务器获取生豆信息失败")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}

#pragma mark - 生豆详情API data
- (void)getBeanInfoByAPIWithBeanUidArr:(NSMutableArray *)beanArr{
    if (beanArr.count == 0) {
        [self getAllReportByApi];
        return;
    }
    for (int i = 0; i < beanArr.count; i++) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 6.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/bean?beanUid=%@",beanArr[i]];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
        
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
                    NSDictionary *beansDic = [responseDic objectForKey:@"data"];
                    BeanModel *bean = [[BeanModel alloc] init];
                    bean.beanUid = beanArr[i];
                    bean.name = [beansDic objectForKey:@"name"];
                    bean.nation = [beansDic objectForKey:@"country"];
                    bean.area = [beansDic objectForKey:@"origin"];
                    bean.grade = [beansDic objectForKey:@"grade"];
                    bean.process = [beansDic objectForKey:@"processingMethod"];
                    bean.stock = [[beansDic objectForKey:@"stock"] floatValue];
                    bean.manor = [beansDic objectForKey:@"farm"];
                    bean.altitude = [[beansDic objectForKey:@"altitude"] floatValue];
                    bean.beanSpecies = [beansDic objectForKey:@"species"];
                    bean.water = [[beansDic objectForKey:@"waterContent"] floatValue];
                    bean.supplier = [beansDic objectForKey:@"supplier"];
                    bean.price = [[beansDic objectForKey:@"price"] floatValue];
                    bean.time = [NSDate UTCDateFromLocalString:[beansDic objectForKey:@"purchaseTime"]];
                    BOOL result = [[DataBase shareDataBase] insertNewBean:bean];
                    if (result) {
                        NSLog(@"生豆信息插入本地成功");
                    }else{
                        NSLog(@"生豆信息插入本地失败");
                    }
                }
                NSLog(@"%d",i);
                NSLog(@"%ld",beanArr.count - 1);
                if (i == (beanArr.count - 1)) {
                    [self getAllReportByApi];
                }
            }else{
                [NSObject showHudTipStr:LocalString(@"从服务器获取生豆信息失败")];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error:%@",error);
            [NSObject showHudTipStr:LocalString(@"从服务器获取生豆信息失败")];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }];
    }
}

#pragma mark - 烘焙报告列表页面
- (void)getAllReportByApi{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roastCurve/list"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];

    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSMutableArray *reportArr = [[NSMutableArray alloc] init];
            if ([responseDic objectForKey:@"data"]) {
                [[responseDic objectForKey:@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    ReportModel *report = [[ReportModel alloc] init];
                    report.curveUid = [obj objectForKey:@"curveUid"];
                    report.curveName = [obj objectForKey:@"name"];
                    report.date = [NSDate UTCDateFromLocalString:[obj objectForKey:@"createTime"]];
                    report.sn = [obj objectForKey:@"sn"];
                    report.sharerName = [obj objectForKey:@"sharedName"];
                    if (report.sharerName) {
                        report.isShare = 1;
                    }else{
                        report.isShare = 0;
                        report.sharerName = @"";
                    }
                    [reportArr addObject:report];
                }];
            }
            [self getFullCurveInfoByApiWithReportArr:reportArr];
        }else{
            [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}

#pragma mark - 烘焙报告详情页面数据获取
- (void)getFullCurveInfoByApiWithReportArr:(NSMutableArray *)reportArr{
    if (reportArr.count == 0) {
        [self getAllCupByApi];
    }
    for (int i = 0; i < reportArr.count; i++) {
        ReportModel *report = reportArr[i];
        NSLog(@"%@",report.curveUid);
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 6.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roastCurve/allReport?curveUid=%@",report.curveUid];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
        
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
                    //第一页信息获取
                    NSDictionary *dic = [responseDic objectForKey:@"data"];
                    if ([dic objectForKey:@"roastReportPageOne"]) {
                        NSDictionary *curveDic = [dic objectForKey:@"roastReportPageOne"];
                        report.curveName = [curveDic objectForKey:@"name"];
                        report.deviceName = [curveDic objectForKey:@"roasterName"];
                        report.bakerName = [curveDic objectForKey:@"userName"];
                        report.date = [NSDate UTCDateFromLocalString:[curveDic objectForKey:@"createTime"]];
                        report.light = [[curveDic objectForKey:@"light"] floatValue];
                        report.rawBeanWeight = [[curveDic objectForKey:@"rawBean"] doubleValue];
                        report.bakeBeanWeight = [[curveDic objectForKey:@"cooked"] doubleValue];
                        
                        if ([curveDic objectForKey:@"beans"]) {
                            [[curveDic objectForKey:@"beans"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
                                    BOOL result;
                                    if (report.isShare) {
                                        //不是分享的存储生豆uid，从uid获取本地生豆信息
                                        result = [db executeUpdate:@"INSERT INTO bean_curve (beanUid,curveUid,beanWeight) VALUES (?,?,?)",[obj objectForKey:@"beanUid"],report.curveUid,[NSNumber numberWithFloat:[[obj objectForKey:@"used"] floatValue]]];
                                    }else{
                                        //分享曲线存储所有生豆信息在关联表，因为本地没有该生豆存储
                                        result = [db executeUpdate:@"INSERT INTO bean_curve (beanUid,curveUid,beanWeight,beanName,nation,area,manor,altitude,beanSpecies,grade,process,water) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",[obj objectForKey:@"beanUid"],report.curveUid,[NSNumber numberWithFloat:[[obj objectForKey:@"used"] floatValue]],[obj objectForKey:@"name"],[obj objectForKey:@"country"],[obj objectForKey:@"origin"],[obj objectForKey:@"farm"],[NSNumber numberWithFloat:[[obj objectForKey:@"altitude"] floatValue]],[obj objectForKey:@"species"],[obj objectForKey:@"grade"],[obj objectForKey:@"processingMethod"],[NSNumber numberWithFloat:[[obj objectForKey:@"waterContent"] floatValue]]];
                                    }
                                    if (!result) {
                                        NSLog(@"插入生豆%@失败",[obj objectForKey:@"name"]);
                                    }
                                }];
                            }];
                        }

                    }
                    NSArray *eventArr = [dic objectForKey:@"eventList"];
                    if (eventArr.count > 0) {
                        [eventArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
                                BOOL result = [db executeUpdate:@"INSERT INTO curve_event (curveUid,eventId,eventText,eventTime,eventBeanTemp) VALUES (?,?,?,?,?)",report.curveUid,[NSNumber numberWithInteger:[[obj objectForKey:@"type"] integerValue]],[obj objectForKey:@"content"],[NSNumber numberWithInteger:[[obj objectForKey:@"time"] integerValue]],[NSNumber numberWithDouble:[[obj objectForKey:@"name"] doubleValue]]];
                                if (!result) {
                                    NSLog(@"插入事件%@失败",[obj objectForKey:@"content"]);
                                }
                            }];
                        }];
                    }
                    NSDictionary *curveDataDic = [dic objectForKey:@"curveData"];
                    if (curveDataDic != nil) {
//                        NSArray *In = [NSString toArrayOrNSDictionary:[[curveDataDic objectForKey:@"in"] dataUsingEncoding:NSUTF8StringEncoding]];
//                        NSArray *Out = [NSString toArrayOrNSDictionary:[[curveDataDic objectForKey:@"out"] dataUsingEncoding:NSUTF8StringEncoding]];
//                        NSArray *Bean = [NSString toArrayOrNSDictionary:[[curveDataDic objectForKey:@"bean"] dataUsingEncoding:NSUTF8StringEncoding]];
//                        NSArray *Environment = [NSString toArrayOrNSDictionary:[[curveDataDic objectForKey:@"env"] dataUsingEncoding:NSUTF8StringEncoding]];
                        NSArray *In = [curveDataDic objectForKey:@"in"];
                        NSArray *Out = [curveDataDic objectForKey:@"out"];
                        NSArray *Bean = [curveDataDic objectForKey:@"bean"];
                        NSArray *Environment = [curveDataDic objectForKey:@"env"];

                        NSLog(@"%lu",(unsigned long)Bean.count);
                        NSDictionary *curveValueDic = @{@"out":Out,@"in":In,@"bean":Bean,@"env":Environment};
                        NSData *curveData = [NSJSONSerialization dataWithJSONObject:curveValueDic options:NSJSONWritingPrettyPrinted error:nil];
                        NSString *curveValueJson = [[NSString alloc] initWithData:curveData encoding:NSUTF8StringEncoding];
                        report.curveValueJson = curveValueJson;
                    }
                    [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
                        BOOL result = [db executeUpdate:@"INSERT INTO curveInfo (curveUid,curveName,date,deviceName,sn,rawBeanWeight,bakeBeanWeight,light,bakeTime,developTime,developRate,bakerName,curveValue,shareName,isShare) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",report.curveUid,report.curveName,[NSDate localStringFromUTCDate:report.date],report.deviceName,report.sn,[NSNumber numberWithFloat:report.rawBeanWeight],[NSNumber numberWithFloat:report.bakeBeanWeight],[NSNumber numberWithFloat:report.light],@0,@0,@0,report.bakerName,report.curveValueJson,report.sharerName,[NSNumber numberWithInteger:report.isShare]];//烘焙总时间、发展时间、发展率都通过事件计算,不再存储
                        if (!result) {
                            NSLog(@"插入报告失败");
                        }
                    }];
                    
                }
                NSLog(@"%d",i);
                NSLog(@"%ld",reportArr.count - 1);
                if (i == (reportArr.count - 1)) {
                    [self getAllCupByApi];
                }
            }else{
                [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error:%@",error);
            [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }];

    }
}

#pragma mark - 杯测列表页面
- (void)getAllCupByApi{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/cupping/list"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSMutableArray *cupArr = [[NSMutableArray alloc] init];
            if ([responseDic objectForKey:@"data"]) {
                [[responseDic objectForKey:@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *cupUid = [obj objectForKey:@"cupUid"];
                    [cupArr addObject:cupUid];
                }];
            }
            [self getCupInfoByAPIWithCupArr:cupArr];
        }else{
            [NSObject showHudTipStr:LocalString(@"从服务器获取杯测信息失败")];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        [NSObject showHudTipStr:LocalString(@"从服务器获取杯测信息失败")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}

#pragma mark - 杯测详情API data
- (void)getCupInfoByAPIWithCupArr:(NSMutableArray *)cupArr{
    if (cupArr.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:LocalString(@"数据同步完成")];
        });
    }
    for (int i = 0; i < cupArr.count; i++) {
        CupModel *cup = [[CupModel alloc] init];
        cup.cupUid = cupArr[i];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 6.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/cupping?cupUid=%@",cup.cupUid];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
        
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
                    NSDictionary *beansDic = [responseDic objectForKey:@"data"];
                    cup.name = [beansDic objectForKey:@"name"];
                    cup.curveUid = [beansDic objectForKey:@"curveUid"];
                    cup.date = [NSDate UTCDateFromLocalString:[beansDic objectForKey:@"createTime"]];
                    cup.light = [[beansDic objectForKey:@"roastDegree"] floatValue];
                    cup.dryAndWet = [[beansDic objectForKey:@"aroma"] floatValue];
                    cup.flavor = [[beansDic objectForKey:@"flavor"] floatValue];
                    cup.aftermath =[[beansDic objectForKey:@"aftertaste"] floatValue];
                    cup.acid = [[beansDic objectForKey:@"acidity"] floatValue];
                    cup.taste = [[beansDic objectForKey:@"taste"] floatValue];
                    cup.sweet = [[beansDic objectForKey:@"sweetness"] floatValue];
                    cup.balance = [[beansDic objectForKey:@"balance"] floatValue];
                    cup.overFeel = [[beansDic objectForKey:@"overall"] floatValue];
                    cup.deveUnfull = [[beansDic objectForKey:@"undevelopment"] floatValue];
                    cup.overDeve = [[beansDic objectForKey:@"overdevelopment"] floatValue];
                    cup.bakePaste = [[beansDic objectForKey:@"baked"] floatValue];
                    cup.injure = [[beansDic objectForKey:@"scorched"] floatValue];
                    cup.germInjure = [[beansDic objectForKey:@"tipped"] floatValue];
                    cup.beanFaceInjure = [[beansDic objectForKey:@"faced"] floatValue];
                    [cup caculateGrade];
                    BOOL result = [[DataBase shareDataBase] insertNewCup:cup];
                    if (!result) {
                        NSLog(@"杯测信息%@更新到本地服务器失败",cup.name);
                    }
                }
                if (i == (cupArr.count - 1)) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        [NSObject showHudTipStr:LocalString(@"数据同步完成")];
                    });
                }
            }else{
                [NSObject showHudTipStr:LocalString(@"从服务器获取杯测信息失败")];
                NSLog(@"从服务器获取杯测信息失败");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error:%@",error);
            [NSObject showHudTipStr:LocalString(@"从服务器获取杯测信息失败")];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }];

    }
}
@end
