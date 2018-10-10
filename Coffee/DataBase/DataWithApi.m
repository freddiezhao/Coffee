//
//  DataWithApi.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/10.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DataWithApi.h"

@implementation DataWithApi

#pragma mark - 烘焙报告列表页面
//- (void)getAllReportByApi{
//    [SVProgressHUD show];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    manager.requestSerializer.timeoutInterval = 6.f;
//    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//
//    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roastCurve/list"];
//    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
//
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
//    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
//        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
//        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
//            NSLog(@"success:%@",daetr);
//            if ([responseDic objectForKey:@"data"]) {
//                [[responseDic objectForKey:@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    ReportModel *report = [[ReportModel alloc] init];
//                    report.curveUid = [obj objectForKey:@"curveUid"];
//                    report.curveName = [obj objectForKey:@"name"];
//                    report.date = [NSDate UTCDateFromLocalString:[obj objectForKey:@"createTime"]];
//                    report.sn = [obj objectForKey:@"sn"];
//                    report.sharerName = [obj objectForKey:@"sharedName"];
//                    if (report.sharerName) {
//                        report.isShare = 1;
//                    }else{
//                        report.isShare = 0;
//                    }
//                    static BOOL isStored = NO;
//                    [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
//                        FMResultSet *set = [db executeQuery:@"SELECT curveId FROM curveInfo WHERE curveUid = ?",[obj objectForKey:@"curveUid"]];
//                        while ([set next]) {
//                            isStored = YES;
//                            NSLog(@"1");
//                        }
//                        [set close];
//                    }];
//                    if (!isStored) {
//                        BOOL result = [[DataBase shareDataBase] insertNewReport:report];
//                        if (result) {
//                            NSLog(@"烘焙报告移入数据库成功");
//                        }else{
//                            NSLog(@"烘焙报告移入数据库失败");
//                        }
//                    }
//                }];
//                _currentReportArr = [self getAllReportWithCurrentDevice];
//                [_currentTable reloadData];
//            }
//        }else{
//            [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"Error:%@",error);
//        [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    }];
//}

#pragma mark - 烘焙报告详情页面数据获取
//- (void)getFirstCurveInfoByApi{
//    [SVProgressHUD show];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    manager.requestSerializer.timeoutInterval = 6.f;
//    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//
//    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roastCurve/bean/message?curveUid=%@",_reportModel.curveUid];
//    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
//
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
//    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
//        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
//        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
//            NSLog(@"success:%@",daetr);
//            if ([responseDic objectForKey:@"data"]) {
//                //第一页信息获取
//                NSDictionary *dic = [responseDic objectForKey:@"data"];
//                _reportModel.deviceName = [dic objectForKey:@"roasterName"];
//                _reportModel.light = [[dic objectForKey:@"light"] floatValue];
//                _reportModel.rawBeanWeight = [[dic objectForKey:@"rawBean"] doubleValue];
//                _reportModel.bakeBeanWeight = [[dic objectForKey:@"cooked"] doubleValue];
//                _reportModel.outWaterRate = [[dic objectForKey:@"dryingRate"] doubleValue];
//                if ([dic objectForKey:@"beans"]) {
//                    [[dic objectForKey:@"beans"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                        BeanModel *bean = [[BeanModel alloc] init];
//                        bean.name = [obj objectForKey:@"name"];
//                        bean.weight = [[obj objectForKey:@"used"] floatValue];
//                        bean.nation = [obj objectForKey:@"country"];
//                        bean.area = [obj objectForKey:@"origin"];
//                        bean.grade = [obj objectForKey:@"grade"];
//                        bean.process = [obj objectForKey:@"processingMethod"];
//                        bean.manor = [obj objectForKey:@"farm"];
//                        bean.altitude = [[obj objectForKey:@"altitude"] floatValue];
//                        [_beanArray addObject:bean];
//                    }];
//                }
//            }
//            [self getSecondCurveInfoByApi];
//        }else{
//            [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD dismiss];
//            });
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"Error:%@",error);
//        [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    }];
//}
//
//- (void)getSecondCurveInfoByApi{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    manager.requestSerializer.timeoutInterval = 6.f;
//    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//
//    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roastCurve?curveUid=%@",_reportModel.curveUid];
//    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
//
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
//    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
//        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
//        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
//            NSLog(@"success:%@",daetr);
//            if ([responseDic objectForKey:@"data"]) {
//                //第二页信息获取
//                NSDictionary *dic = [responseDic objectForKey:@"data"];
//                _reportModel.bakeTime = [[dic objectForKey:@"roastedTime"] integerValue];
//                _reportModel.developRate = [[dic objectForKey:@"devRate"] floatValue];
//                _reportModel.developTime = [[dic objectForKey:@"devTime"] integerValue];
//                _In = [NSString toArrayOrNSDictionary:[[dic objectForKey:@"in"] dataUsingEncoding:NSUTF8StringEncoding]];
//                _Out = [NSString toArrayOrNSDictionary:[[dic objectForKey:@"out"] dataUsingEncoding:NSUTF8StringEncoding]];
//                _Bean = [NSString toArrayOrNSDictionary:[[dic objectForKey:@"bean"] dataUsingEncoding:NSUTF8StringEncoding]];
//                _Environment = [NSString toArrayOrNSDictionary:[[dic objectForKey:@"env"] dataUsingEncoding:NSUTF8StringEncoding]];
//
//                NSLog(@"%lu",(unsigned long)_Bean.count);
//                NSLog(@"%lu",_Out.count);
//                NSLog(@"%lu",_In.count);
//                NSLog(@"%lu",_Environment.count);
//
//                for (int i = 0; i<_Bean.count; i++) {
//                    [_yVals_Bean removeAllObjects];
//                    [_yVals_Bean addObject:[[ChartDataEntry alloc] initWithX:i y:[_Bean[i] doubleValue]]];
//                }
//                for (int i = 0; i<_Out.count; i++) {
//                    [_yVals_Out removeAllObjects];
//                    [_yVals_Out addObject:[[ChartDataEntry alloc] initWithX:i y:[_Out[i] doubleValue]]];
//                }
//                for (int i = 0; i<_In.count; i++) {
//                    [_yVals_In removeAllObjects];
//                    [_yVals_In addObject:[[ChartDataEntry alloc] initWithX:i y:[_In[i] doubleValue]]];
//                }
//                for (int i = 0; i<_Environment.count; i++) {
//                    [_yVals_Environment removeAllObjects];
//                    [_yVals_Environment addObject:[[ChartDataEntry alloc] initWithX:i y:[_Environment[i] doubleValue]]];
//                }
//            }
//            [self getCurveEventInfoByApi];
//        }else{
//            [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD dismiss];
//            });
//        }
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"Error:%@",error);
//        [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    }];
//}
//
//- (void)getCurveEventInfoByApi{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    manager.requestSerializer.timeoutInterval = 6.f;
//    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//
//    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roastCurve/event?curveUid=%@",_reportModel.curveUid];
//    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
//
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
//    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
//        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
//        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
//            NSLog(@"success:%@",daetr);
//            if ([responseDic objectForKey:@"data"]) {
//                //事件信息获取
//                [[responseDic objectForKey:@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    EventModel *event = [[EventModel alloc] init];
//                    event.eventId = [[obj objectForKey:@"type"] integerValue];
//                    event.eventTime = [[obj objectForKey:@"time"] integerValue];
//                    event.eventText = [obj objectForKey:@"content"];
//                    event.eventBeanTemp = [[obj objectForKey:@"eventBeanTemp"] doubleValue];
//                    [_eventArray addObject:event];
//                }];
//            }
//            [self updateReportInfoAfterApi];
//        }else{
//            [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD dismiss];
//            });
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"Error:%@",error);
//        [NSObject showHudTipStr:LocalString(@"从服务器获取烘焙报告失败")];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    }];
//}

#pragma mark - 生豆列表页面
//- (void)getAllBeanByApi{
//    [SVProgressHUD show];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    manager.requestSerializer.timeoutInterval = 6.f;
//    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//
//    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/bean/list"];
//    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
//
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:_myDB.userId forHTTPHeaderField:@"userId"];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",_myDB.token] forHTTPHeaderField:@"Authorization"];
//    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
//        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
//        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
//            NSLog(@"success:%@",daetr);
//            if ([responseDic objectForKey:@"data"]) {
//                NSDictionary *beansDic = [responseDic objectForKey:@"data"];
//                [[beansDic objectForKey:@"beans"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    BeanModel *bean = [[BeanModel alloc] init];
//                    bean.beanUid = [obj objectForKey:@"beanUid"];
//                    bean.name = [obj objectForKey:@"name"];
//                    bean.stock = [[obj objectForKey:@"stock"] floatValue];
//                    bean.time = [NSDate UTCDateFromLocalString:[obj objectForKey:@"purchaseTime"]];
//                    static BOOL isStored = NO;
//                    [_myDB.queueDB inDatabase:^(FMDatabase * _Nonnull db) {
//                        FMResultSet *set = [db executeQuery:@"SELECT beanId FROM beanInfo WHERE beanUid = ?",[obj objectForKey:@"beanUid"]];
//                        while ([set next]) {
//                            isStored = YES;
//                            NSLog(@"1");
//                        }
//                        [set close];
//                    }];
//                    if (!isStored) {
//                        BOOL result = [_myDB insertNewBean:bean];
//                        if (result) {
//                            NSLog(@"咖啡豆移入数据库成功");
//                        }else{
//                            NSLog(@"咖啡豆移入数据库失败");
//                        }
//                    }
//                }];
//                _beanArr = [[DataBase shareDataBase] queryAllBean];
//                [self afterGetBeanArr];
//            }
//        }else{
//            [NSObject showHudTipStr:LocalString(@"从服务器获取生豆信息失败")];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"Error:%@",error);
//        [NSObject showHudTipStr:LocalString(@"从服务器获取生豆信息失败")];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    }];
//}

#pragma mark - 生豆详情API data
//- (void)getBeanInfoByAPI{
//    [SVProgressHUD show];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    manager.requestSerializer.timeoutInterval = 6.f;
//    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//
//    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/bean?beanUid=%@",_myBean.beanUid];
//    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
//
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
//    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
//        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
//        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
//            NSLog(@"success:%@",daetr);
//            if ([responseDic objectForKey:@"data"]) {
//                NSDictionary *beansDic = [responseDic objectForKey:@"data"];
//                _myBean.name = [beansDic objectForKey:@"name"];
//                _myBean.nation = [beansDic objectForKey:@"country"];
//                _myBean.area = [beansDic objectForKey:@"origin"];
//                _myBean.grade = [beansDic objectForKey:@"grade"];
//                _myBean.process = [beansDic objectForKey:@"processingMethod"];
//                _myBean.stock = [[beansDic objectForKey:@"stock"] floatValue];
//                _myBean.manor = [beansDic objectForKey:@"farm"];
//                _myBean.altitude = [[beansDic objectForKey:@"altitude"] floatValue];
//                _myBean.beanSpecies = [beansDic objectForKey:@"species"];
//                _myBean.water = [[beansDic objectForKey:@"waterContent"] floatValue];
//                _myBean.supplier = [beansDic objectForKey:@"supplier"];
//                _myBean.price = [[beansDic objectForKey:@"price"] floatValue];
//                _myBean.time = [NSDate UTCDateFromLocalString:[beansDic objectForKey:@"purchaseTime"]];
//                BOOL result = [[DataBase shareDataBase] updateBean:_myBean];
//                if (result) {
//                    _myBean = [[DataBase shareDataBase] queryBean:_myBean.beanUid];
//                    [_beanDetailTable reloadData];
//                }else{
//                    [NSObject showHudTipStr:@"从服务器获取生豆信息失败"];
//                }
//            }
//        }else{
//            [NSObject showHudTipStr:LocalString(@"从服务器获取生豆信息失败")];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"Error:%@",error);
//        [NSObject showHudTipStr:LocalString(@"从服务器获取生豆信息失败")];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    }];
//}

#pragma mark - 杯测列表页面
//- (void)getAllCupByApi{
//    [SVProgressHUD show];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    
//    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    manager.requestSerializer.timeoutInterval = 6.f;
//    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//    
//    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/cupping/list"];
//    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
//    
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
//    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
//        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
//        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
//            NSLog(@"success:%@",daetr);
//            if ([responseDic objectForKey:@"data"]) {
//                [[responseDic objectForKey:@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    CupModel *cup = [[CupModel alloc] init];
//                    cup.cupUid = [obj objectForKey:@"cupUid"];
//                    cup.name = [obj objectForKey:@"name"];
//                    cup.date = [NSDate YMDDateFromLocalString:[obj objectForKey:@"createTime"]];
//                    cup.grade = [[obj objectForKey:@"total"] floatValue];
//                    static BOOL isStored = NO;
//                    [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
//                        FMResultSet *set = [db executeQuery:@"SELECT cupId FROM cup WHERE cupUid = ?",[obj objectForKey:@"cupUid"]];
//                        while ([set next]) {
//                            isStored = YES;
//                            NSLog(@"1");
//                        }
//                        [set close];
//                    }];
//                    if (!isStored) {
//                        BOOL result = [[DataBase shareDataBase] insertNewCup:cup];
//                        if (result) {
//                            NSLog(@"杯测移入数据库成功");
//                        }else{
//                            NSLog(@"杯测移入数据库失败");
//                        }
//                    }
//                }];
//                _cupArr = [[DataBase shareDataBase] queryAllCup];
//            }
//            [self afterGetCupArr];
//        }else{
//            [NSObject showHudTipStr:LocalString(@"从服务器获取杯测信息失败")];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"Error:%@",error);
//        [NSObject showHudTipStr:LocalString(@"从服务器获取杯测信息失败")];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    }];
//}

#pragma mark - 杯测详情API data
//- (void)getCupInfoByAPI{
//    [SVProgressHUD show];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    manager.requestSerializer.timeoutInterval = 6.f;
//    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//
//    NSLog(@"%@",_cup.cupUid);
//    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/cupping?cupUid=%@",_cup.cupUid];
//    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
//
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
//    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
//        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
//        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
//            NSLog(@"success:%@",daetr);
//            if ([responseDic objectForKey:@"data"]) {
//                NSDictionary *beansDic = [responseDic objectForKey:@"data"];
//                _cup.name = [beansDic objectForKey:@"name"];
//                _cup.curveUid = [beansDic objectForKey:@"curveUid"];
//                _cup.date = [NSDate UTCDateFromLocalString:[beansDic objectForKey:@"createTime"]];
//                _cup.light = [[beansDic objectForKey:@"roastDegree"] floatValue];
//                _cup.dryAndWet = [[beansDic objectForKey:@"aroma"] floatValue];
//                _cup.flavor = [[beansDic objectForKey:@"flavor"] floatValue];
//                _cup.aftermath =[[beansDic objectForKey:@"aftertaste"] floatValue];
//                _cup.acid = [[beansDic objectForKey:@"acidity"] floatValue];
//                _cup.taste = [[beansDic objectForKey:@"taste"] floatValue];
//                _cup.sweet = [[beansDic objectForKey:@"sweetness"] floatValue];
//                _cup.balance = [[beansDic objectForKey:@"balance"] floatValue];
//                _cup.overFeel = [[beansDic objectForKey:@"overall"] floatValue];
//                _cup.deveUnfull = [[beansDic objectForKey:@"undevelopment"] floatValue];
//                _cup.overDeve = [[beansDic objectForKey:@"overdevelopment"] floatValue];
//                _cup.bakePaste = [[beansDic objectForKey:@"baked"] floatValue];
//                _cup.injure = [[beansDic objectForKey:@"scorched"] floatValue];
//                _cup.germInjure = [[beansDic objectForKey:@"tipped"] floatValue];
//                _cup.beanFaceInjure = [[beansDic objectForKey:@"faced"] floatValue];
//                [_cup caculateGrade];
//                BOOL result = [[DataBase shareDataBase] updateCup:_cup];
//                if (result) {
//
//                }else{
//                    [NSObject showHudTipStr:@"杯测信息更新到本地服务器失败"];
//                    NSLog(@"杯测信息更新到本地服务器失败");
//                }
//                [_cupDetailTable reloadData];
//            }
//        }else{
//            [NSObject showHudTipStr:LocalString(@"从服务器获取杯测信息失败")];
//            NSLog(@"从服务器获取杯测信息失败");
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"Error:%@",error);
//        [NSObject showHudTipStr:LocalString(@"从服务器获取杯测信息失败")];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    }];
//}
@end
