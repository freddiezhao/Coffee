//
//  DetailGradeCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DetailGradeCell.h"

#define degreesToRadians(x) (M_PI*(x)/180.0)//把角度转换成PI的方式

@implementation DetailGradeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_bakeGradeView) {
            _bakeGradeView = [[UIView alloc] initWithFrame:CGRectMake(36/WScale, 30/HScale, 70/WScale, 70/WScale)];
            _bakeGradeView.backgroundColor = [UIColor colorWithHexString:@"EDF1F5"];
            _bakeGradeView.layer.cornerRadius = 35/WScale;
            [self.contentView addSubview:_bakeGradeView];
            
            UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 54/WScale, 54/WScale)];
            whiteView.backgroundColor = [UIColor whiteColor];
            whiteView.layer.cornerRadius = 27/WScale;
            whiteView.center = CGPointMake(35/WScale, 35/WScale);
            [_bakeGradeView addSubview:whiteView];
            
            _bakeGrade = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 47/WScale, 33/HScale)];
            _bakeGrade.center = CGPointMake(27/WScale, 27/WScale);
            _bakeGrade.text = @"0.0";
            _bakeGrade.font = [UIFont fontWithName:@"Avenir" size:20];
            _bakeGrade.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            _bakeGrade.textAlignment = NSTextAlignmentCenter;
            _bakeGrade.adjustsFontSizeToFitWidth = YES;
            [whiteView addSubview:_bakeGrade];
        }
        if (!_bakeDefectView) {
            _bakeDefectView = [[UIView alloc] initWithFrame:CGRectMake(153/WScale, 30/HScale, 70/WScale, 70/WScale)];
            _bakeDefectView.backgroundColor = [UIColor colorWithHexString:@"EDF1F5"];
            _bakeDefectView.layer.cornerRadius = 35/WScale;
            [self.contentView addSubview:_bakeDefectView];
            
            UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 54/WScale, 54/WScale)];
            whiteView.backgroundColor = [UIColor whiteColor];
            whiteView.layer.cornerRadius = 27/WScale;
            whiteView.center = CGPointMake(35/WScale, 35/WScale);
            [_bakeDefectView addSubview:whiteView];
            
            _bakeDefect = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 47/WScale, 33/HScale)];
            _bakeDefect.center = CGPointMake(27/WScale, 27/WScale);
            _bakeDefect.text = @"0.0";
            _bakeDefect.font = [UIFont fontWithName:@"Avenir" size:20];
            _bakeDefect.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            _bakeDefect.textAlignment = NSTextAlignmentCenter;
            _bakeDefect.adjustsFontSizeToFitWidth = YES;
            [whiteView addSubview:_bakeDefect];
        }
        if (!_resultView) {
            _resultView = [[UIView alloc] initWithFrame:CGRectMake(270/WScale, 30/HScale, 70/WScale, 70/WScale)];
            _resultView.backgroundColor = [UIColor colorWithHexString:@"EDF1F5"];
            _resultView.layer.cornerRadius = 35/WScale;
            [self.contentView addSubview:_resultView];
            
            UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 54/WScale, 54/WScale)];
            whiteView.backgroundColor = [UIColor whiteColor];
            whiteView.layer.cornerRadius = 27/WScale;
            whiteView.center = CGPointMake(35/WScale, 35/WScale);
            [_resultView addSubview:whiteView];
            
            _result = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 47/WScale, 33/HScale)];
            _result.center = CGPointMake(27/WScale, 27/WScale);
            _result.text = @"0.0";
            _result.font = [UIFont fontWithName:@"Avenir" size:20];
            _result.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            _result.textAlignment = NSTextAlignmentCenter;
            _result.adjustsFontSizeToFitWidth = YES;
            [whiteView addSubview:_result];
        }
        UILabel *minusLabel = [[UILabel alloc] init];
        minusLabel.frame = CGRectMake(0,0,20,39);
        minusLabel.center = CGPointMake(_bakeGradeView.center.x + 58.5/WScale, _bakeGradeView.center.y);
        minusLabel.text = @"-";
        minusLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:28];
        minusLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        minusLabel.textAlignment = NSTextAlignmentCenter;
        minusLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:minusLabel];
        
        UILabel *equalLabel = [[UILabel alloc] init];
        equalLabel.frame = CGRectMake(0,0,20,39);
        equalLabel.center = CGPointMake(_bakeDefectView.center.x + 58.5/WScale, _bakeDefectView.center.y);
        equalLabel.text = @"=";
        equalLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:28];
        equalLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        equalLabel.textAlignment = NSTextAlignmentCenter;
        equalLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:equalLabel];
        
        UILabel *gradeText = [[UILabel alloc] init];
        gradeText.text = @"烘焙评分";
        gradeText.font = [UIFont fontWithName:@"Avenir" size:13];
        gradeText.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        gradeText.textAlignment = NSTextAlignmentCenter;
        gradeText.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:gradeText];
        [gradeText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80/WScale, 19/HScale));
            make.centerX.equalTo(self.bakeGradeView.mas_centerX);
            make.top.equalTo(self.bakeGradeView.mas_bottom).offset(10/HScale);
        }];
        
        UILabel *defectText = [[UILabel alloc] init];
        defectText.text = @"烘焙瑕疵";
        defectText.font = [UIFont fontWithName:@"Avenir" size:13];
        defectText.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        defectText.textAlignment = NSTextAlignmentCenter;
        defectText.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:defectText];
        [defectText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80/WScale, 19/HScale));
            make.centerX.equalTo(self.bakeDefectView.mas_centerX);
            make.top.equalTo(self.bakeDefectView.mas_bottom).offset(10/HScale);
        }];
        
        UILabel *resultText = [[UILabel alloc] init];
        resultText.text = @"最终结果";
        resultText.font = [UIFont fontWithName:@"Avenir" size:13];
        resultText.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        resultText.textAlignment = NSTextAlignmentCenter;
        resultText.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:resultText];
        [resultText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80/WScale, 19/HScale));
            make.centerX.equalTo(self.resultView.mas_centerX);
            make.top.equalTo(self.resultView.mas_bottom).offset(10/HScale);
        }];
    }
    return self;
}

- (void)setProgress{
    CAShapeLayer *sl1 = [CAShapeLayer layer];
    CGFloat radius1 = 31/WScale;
    CGPoint center1 = CGPointMake(35/WScale, 35/WScale);
    CGFloat startA1 =  degreesToRadians(-90);  //设置进度条起点位置
    CGFloat endA1 = degreesToRadians(-90) + degreesToRadians(360)  * _gradeProgress;  //设置进度条终点位置
    //获取环形路径（画一个圆形，填充色透明，设置线框宽度为10，这样就获得了一个环形）
    sl1 = [CAShapeLayer layer];//创建一个track shape layer
    sl1.frame = self.bounds;
    sl1.fillColor = [[UIColor clearColor] CGColor];  //填充色为无色
    sl1.strokeColor = [[UIColor colorWithHexString:@"FFCC66"] CGColor]; //指定path的渲染颜色,这里可以设置任意不透明颜色
    sl1.opacity = 1; //背景颜色的透明度
    sl1.lineCap = kCALineCapRound;//指定线的边缘是圆的
    sl1.lineWidth = 8;//线的宽度
    UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:center1 radius:radius1 startAngle:startA1 endAngle:endA1 clockwise:YES];//上面说明过了用来构建圆形
    sl1.path =[path1 CGPath]; //把path传递給layer，然后layer会处理相应的渲染，整个逻辑和CoreGraph是一致的。
    [self.bakeGradeView.layer addSublayer:sl1];

    CAShapeLayer *sl2 = [CAShapeLayer layer];
    CGFloat radius2 = 31/WScale;
    CGPoint center2 = CGPointMake(35/WScale, 35/WScale);
    CGFloat startA2 =  degreesToRadians(-90);  //设置进度条起点位置
    CGFloat endA2 = degreesToRadians(-90) + degreesToRadians(360)  * _defectProgress;  //设置进度条终点位置
    //获取环形路径（画一个圆形，填充色透明，设置线框宽度为10，这样就获得了一个环形）
    sl2 = [CAShapeLayer layer];//创建一个track shape layer
    sl2.frame = self.bounds;
    sl2.fillColor = [[UIColor clearColor] CGColor];  //填充色为无色
    sl2.strokeColor = [[UIColor colorWithHexString:@"D7C3A3"] CGColor]; //指定path的渲染颜色,这里可以设置任意不透明颜色
    sl2.opacity = 1; //背景颜色的透明度
    sl2.lineCap = kCALineCapRound;//指定线的边缘是圆的
    sl2.lineWidth = 8;//线的宽度
    UIBezierPath *path2 = [UIBezierPath bezierPathWithArcCenter:center2 radius:radius2 startAngle:startA2 endAngle:endA2 clockwise:YES];//上面说明过了用来构建圆形
    sl2.path =[path2 CGPath]; //把path传递給layer，然后layer会处理相应的渲染，整个逻辑和CoreGraph是一致的。
    [self.bakeDefectView.layer addSublayer:sl2];

    CAShapeLayer *sl3 = [CAShapeLayer layer];
    CGFloat radius3 = 31/WScale;
    CGPoint center3 = CGPointMake(35/WScale, 35/WScale);
    CGFloat startA3 =  degreesToRadians(-90);  //设置进度条起点位置
    CGFloat endA3 = degreesToRadians(-90) + degreesToRadians(360)  * _resultProgress;  //设置进度条终点位置
    //获取环形路径（画一个圆形，填充色透明，设置线框宽度为10，这样就获得了一个环形）
    sl3 = [CAShapeLayer layer];//创建一个track shape layer
    sl3.frame = self.bounds;
    sl3.fillColor = [[UIColor clearColor] CGColor];  //填充色为无色
    sl3.strokeColor = [[UIColor colorWithHexString:@"4778CC"] CGColor]; //指定path的渲染颜色,这里可以设置任意不透明颜色
    sl3.opacity = 1; //背景颜色的透明度
    sl3.lineCap = kCALineCapRound;//指定线的边缘是圆的
    sl3.lineWidth = 8;//线的宽度
    UIBezierPath *path3 = [UIBezierPath bezierPathWithArcCenter:center3 radius:radius3 startAngle:startA3 endAngle:endA3 clockwise:YES];//上面说明过了用来构建圆形
    sl3.path =[path3 CGPath]; //把path传递給layer，然后layer会处理相应的渲染，整个逻辑和CoreGraph是一致的。
    [self.resultView.layer addSublayer:sl3];

}

@end
