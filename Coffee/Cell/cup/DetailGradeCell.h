//
//  DetailGradeCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailGradeCell : UITableViewCell

@property (nonatomic, strong) UIView *bakeGradeView;
@property (nonatomic, strong) UILabel *bakeGrade;
@property (nonatomic, strong) UIView *bakeDefectView;
@property (nonatomic, strong) UILabel *bakeDefect;
@property (nonatomic, strong) UIView *resultView;
@property (nonatomic, strong) UILabel *result;
@property (nonatomic, assign) float gradeProgress;
@property (nonatomic, assign) float defectProgress;
@property (nonatomic, assign) float resultProgress;

- (void)setProgress;
@end
