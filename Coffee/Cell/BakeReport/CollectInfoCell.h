//
//  CollectInfoCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/20.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ReportModel;

@interface CollectInfoCell : UITableViewCell <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) ReportModel *reportModel;
@property (nonatomic, strong) UICollectionView *curveCollectView;

@end
