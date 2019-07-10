//
//  CollectInfoCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/20.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "CollectInfoCell.h"
#import "CollectInfoCellCell.h"
#import "ReportModel.h"
#import "CollectEventCell.h"
#import "EventModel.h"

NSString *const CollectCellIdentifier_curve = @"CollectCellID_curve";
NSString *const CollectCellIdentifier_curveEvent = @"CollectCellID_curveEvent";
NSString *const CollectHeaderIdentifier_curve = @"CollectHeaderID_curve";

@implementation CollectInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!_curveCollectView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _curveCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(15/WScale, 0/HScale, 345/WScale, 1072/HScale) collectionViewLayout:layout];
        [self.contentView addSubview:_curveCollectView];
        _curveCollectView.backgroundColor = [UIColor clearColor];
        _curveCollectView.scrollEnabled = NO;
        
        [_curveCollectView registerClass:[CollectInfoCellCell class] forCellWithReuseIdentifier:CollectCellIdentifier_curve];
        [_curveCollectView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CollectHeaderIdentifier_curve];
        [_curveCollectView registerClass:[CollectEventCell class] forCellWithReuseIdentifier:CollectCellIdentifier_curveEvent];
        
        _curveCollectView.delegate = self;
        _curveCollectView.dataSource = self;
    }

    return self;
}

#pragma mark - collectionView代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 5;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 12;
            break;
            
        case 1:
        case 2:
        case 3:
            return 2;
            break;
            
        case 4:
            return _eventArray.count + 1;
            break;
            
        default:
            return 0;
            break;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4) {
        CollectEventCell *cell = (CollectEventCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CollectCellIdentifier_curveEvent forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        
        if (indexPath.row == 0) {
            cell.leftLabel.text = LocalString(@"事件类型");
            cell.centerLabel.text = LocalString(@"发生时间");
            cell.rightLabel.text = LocalString(@"温度");
            cell.leftLabel.layer.borderWidth = 0.5;
            cell.leftLabel.layer.borderColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
            cell.centerLabel.layer.borderWidth = 0.5;
            cell.centerLabel.layer.borderColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
            cell.rightLabel.layer.borderWidth = 0.5;
            cell.rightLabel.layer.borderColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
        }else{
            EventModel *event = _eventArray[indexPath.row - 1];
            if (event.eventId == Wind_Fire_Power) {
                cell.leftLabel.text = LocalString(@"风力/火力");
            }else{
                cell.leftLabel.text = [event getEventText:event.eventId];
            }
            cell.centerLabel.text = [NSString stringWithFormat:@"%ld:%02ld",event.eventTime/60,event.eventTime%60];
            cell.rightLabel.text = [NSString stringWithFormat:@"%.1f%@",[NSString diffTempUnitStringWithTemp:event.eventBeanTemp],[DataBase shareDataBase].setting.tempUnit];

        }
        return cell;
    }
    
    CollectInfoCellCell *cell = (CollectInfoCellCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CollectCellIdentifier_curve forIndexPath:indexPath];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                cell.titleLabel.text = LocalString(@"日期");
                if (_reportModel.date) {
                    cell.valueLabel.text = [NSDate YMDStringFromDate:_reportModel.date];
                }else{
                    cell.valueLabel.text = LocalString(@"空");
                }
            }
                break;
                
            case 1:
            {
                cell.titleLabel.text = LocalString(@"用户");
                if (_reportModel.bakerName) {
                    cell.valueLabel.text = _reportModel.bakerName;
                }else{
                    cell.valueLabel.text = LocalString(@"空");
                }
            }
                break;
            case 2:
            {
                cell.titleLabel.text = LocalString(@"设备");
                if (_reportModel.deviceName) {
                    cell.valueLabel.text = _reportModel.deviceName;
                }else{
                    cell.valueLabel.text = LocalString(@"空");
                }
            }
                break;
            case 3:
            {
                cell.titleLabel.text = LocalString(@"开始/结束重量");
                cell.valueLabel.text = [NSString stringWithFormat:@"%.1lf%@/%.1lf%@",[NSString diffWeightUnitStringWithWeight:_reportModel.rawBeanWeight],[DataBase shareDataBase].setting.weightUnit,[NSString diffWeightUnitStringWithWeight:_reportModel.bakeBeanWeight],[DataBase shareDataBase].setting.weightUnit];
            }
                break;
            case 4:
            {
                cell.titleLabel.text = LocalString(@"脱水率");
                if (_reportModel.rawBeanWeight) {
                    cell.valueLabel.text = [NSString stringWithFormat:@"%.1lf%%",(_reportModel.rawBeanWeight - _reportModel.bakeBeanWeight)/_reportModel.rawBeanWeight*100.f];
                }else{
                    cell.valueLabel.text = [NSString stringWithFormat:@"0%%"];
                }
            }
                break;
            case 5:
            {
                cell.titleLabel.text = LocalString(@"烘焙时长");
                if (_reportModel.bakeTime) {
                    cell.valueLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",_reportModel.bakeTime/60,_reportModel.bakeTime%60];
                }else{
                    cell.valueLabel.text = LocalString(@"空");
                }
            }
                break;
            case 6:
            {
                cell.titleLabel.text = LocalString(@"回温点时间/温度");
                for (EventModel *event in _eventArray) {
                    if (event.eventId == BakeBackTemp) {
                        cell.valueLabel.text = [NSString stringWithFormat:@"%ld:%02ld/%.1f%@",event.eventTime/60,event.eventTime%60,[NSString diffTempUnitStringWithTemp:event.eventBeanTemp],[DataBase shareDataBase].setting.tempUnit];
                    }
                }
            }
                break;
            case 7:
            {
                cell.titleLabel.text = LocalString(@"一爆时间/温度");
                for (EventModel *event in _eventArray) {
                    if (event.eventId == First_Burst_Start) {
                        cell.valueLabel.text = [NSString stringWithFormat:@"%ld:%02ld/%.1f%@",event.eventTime/60,event.eventTime%60,[NSString diffTempUnitStringWithTemp:event.eventBeanTemp],[DataBase shareDataBase].setting.tempUnit];
                    }
                }
            }
                break;
            case 8:
            {
                cell.titleLabel.text = LocalString(@"发展时间");
                if (_reportModel.developTime) {
                    cell.valueLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",_reportModel.developTime/60,_reportModel.developTime%60];
                }else{
                    cell.valueLabel.text = LocalString(@"空");
                }
            }
                break;
            case 9:
            {
                cell.titleLabel.text = LocalString(@"发展率");
                if (_reportModel.developRate) {
                    cell.valueLabel.text = [NSString stringWithFormat:@"%.1lf%%",_reportModel.developRate];
                }else{
                    cell.valueLabel.text = LocalString(@"空");
                }
            }
                break;
            case 10:
            {
                cell.titleLabel.text = LocalString(@"开始温度");
                cell.valueLabel.text = LocalString(@"空");
                for (EventModel *event in _eventArray) {
                    if (event.eventId == StartBake) {
                        cell.valueLabel.text = [NSString stringWithFormat:@"%.1f%@",[NSString diffTempUnitStringWithTemp:event.eventBeanTemp],[DataBase shareDataBase].setting.tempUnit];
                        NSLog(@"%f",event.eventBeanTemp);
                    }
                }
            }
                break;
            case 11:
            {
                cell.titleLabel.text = LocalString(@"结束温度");
                cell.valueLabel.text = LocalString(@"空");
                for (EventModel *event in _eventArray) {
                    if (event.eventId == EndBake) {
                        cell.valueLabel.text = [NSString stringWithFormat:@"%.1f%@",[NSString diffTempUnitStringWithTemp:event.eventBeanTemp],[DataBase shareDataBase].setting.tempUnit];
                    }
                }
            }
                break;
            default:
            {
                cell.titleLabel.text = LocalString(@"空");
                cell.valueLabel.text = LocalString(@"空");
            }
                break;
        }
    }else if (indexPath.section == 1){
        EventModel *event1;
        EventModel *event2;
        for (EventModel *event in _eventArray) {
            if (event.eventId == BakeBackTemp) {
                event1 = event;
            }else if (event.eventId == OutWater){
                event2 = event;
            }
        }
        switch (indexPath.row) {
            case 0:
                {
                    if (event1 && event2) {
                        cell.titleLabel.text = LocalString(@"平均温升");
                        cell.valueLabel.text = [NSString stringWithFormat:@"%.1lf%@",([NSString diffTempUnitStringWithTemp:event2.eventBeanTemp] - [NSString diffTempUnitStringWithTemp:event1.eventBeanTemp])/(event2.eventTime - event1.eventTime)*60.f,[DataBase shareDataBase].setting.tempUnit];
                    }else{
                        cell.titleLabel.text = LocalString(@"平均温升");
                        cell.valueLabel.text = LocalString(@"空");
                    }
                }
                break;
               
            case 1:
                {
                    if (event1 && event2) {
                        cell.titleLabel.text = LocalString(@"时间");
                        cell.valueLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(event2.eventTime - event1.eventTime)/60,(event2.eventTime - event1.eventTime)%60];
                    }else{
                        cell.titleLabel.text = LocalString(@"时间");
                        cell.valueLabel.text = LocalString(@"空");
                    }
                }
                break;
                
            default:
                break;
        }
    }else if (indexPath.section == 2){
        EventModel *event1;
        EventModel *event2;
        for (EventModel *event in _eventArray) {
            if (event.eventId == OutWater) {
                event1 = event;
            }else if (event.eventId == First_Burst_Start){
                event2 = event;
            }
        }
        switch (indexPath.row) {
            case 0:
            {
                if (event1 && event2) {
                    cell.titleLabel.text = LocalString(@"平均温升");
                    cell.valueLabel.text = [NSString stringWithFormat:@"%.1lf%@",([NSString diffTempUnitStringWithTemp:event2.eventBeanTemp] - [NSString diffTempUnitStringWithTemp:event1.eventBeanTemp])/(event2.eventTime - event1.eventTime)*60.f,[DataBase shareDataBase].setting.tempUnit];
                }else{
                    cell.titleLabel.text = LocalString(@"平均温升");
                    cell.valueLabel.text = LocalString(@"空");
                }
            }
                break;
                
            case 1:
            {
                if (event1 && event2) {
                    cell.titleLabel.text = LocalString(@"时间");
                    cell.valueLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(event2.eventTime - event1.eventTime)/60,(event2.eventTime - event1.eventTime)%60];
                }else{
                    cell.titleLabel.text = LocalString(@"时间");
                    cell.valueLabel.text = LocalString(@"空");
                }
            }
                break;
                
            default:
                break;
        }
    }else if (indexPath.section == 3){
        EventModel *event1;
        EventModel *event2;
        for (EventModel *event in _eventArray) {
            if (event.eventId == First_Burst_Start) {
                event1 = event;
            }else if (event.eventId == EndBake){
                event2 = event;
            }
        }
        switch (indexPath.row) {
            case 0:
            {
                if (event1 && event2) {
                    cell.titleLabel.text = LocalString(@"平均温升");
                    cell.valueLabel.text = [NSString stringWithFormat:@"%.1lf%@",([NSString diffTempUnitStringWithTemp:event2.eventBeanTemp] - [NSString diffTempUnitStringWithTemp:event1.eventBeanTemp])/(event2.eventTime - event1.eventTime)*60.f,[DataBase shareDataBase].setting.tempUnit];
                }else{
                    cell.titleLabel.text = LocalString(@"平均温升");
                    cell.valueLabel.text = LocalString(@"空");
                }
            }
                break;
                
            case 1:
            {
                if (event1 && event2) {
                    cell.titleLabel.text = LocalString(@"时间");
                    cell.valueLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(event2.eventTime - event1.eventTime)/60,(event2.eventTime - event1.eventTime)%60];
                }else{
                    cell.titleLabel.text = LocalString(@"时间");
                    cell.valueLabel.text = LocalString(@"空");
                }
            }
                break;
                
            default:
                break;
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            {
                return CGSizeMake(115/WScale, 72/HScale);
            }
            break;
            
        case 1:
        case 2:
        case 3:
            {
                return CGSizeMake(172.5/WScale, 72/HScale);
            }
            break;
        
        case 4:
            {
                return CGSizeMake(345/WScale, 36/HScale);
            }
            break;
            
        default:
            return CGSizeMake(115/WScale, 72/HScale);
            break;
    }
    
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

//header的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(345/WScale, (36 + 20)/HScale);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CollectHeaderIdentifier_curve forIndexPath:indexPath];
    headerView.backgroundColor =[UIColor clearColor];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 20/HScale, 345/WScale, 36/HScale)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.layer.borderWidth = 0.5;
    titleView.layer.borderColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    [headerView addSubview:titleView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:titleView.bounds];
    if (indexPath.section == 0) {
        label.text = LocalString(@"图表简述");
    }else if (indexPath.section == 1){
        label.text = LocalString(@"回温点至脱水结束");
    }else if (indexPath.section == 2){
        label.text = LocalString(@"脱水结束至一爆开始");
    }else if (indexPath.section == 3){
        label.text = LocalString(@"一爆开始至烘焙结束");
    }else if (indexPath.section == 4){
        label.text = LocalString(@"事件列表");
    }
    label.textColor = [UIColor colorWithHexString:@"999999"];
    label.font = [UIFont systemFontOfSize:15.0];
    label.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:label];
    return headerView;
}

@end
