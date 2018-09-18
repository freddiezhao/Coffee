//
//  ArcProgressView.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "ArcProgressView.h"

#define degreesToRadians(x) (M_PI*(x)/180.0)//把角度转换成PI的方式

@implementation ArcProgressView

- (void)drawRect:(CGRect)rect {
    CGFloat radius = MIN(rect.size.width, rect.size.height)/2;
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
    CGFloat startA =  degreesToRadians(-90);  //设置进度条起点位置
    CGFloat endA = degreesToRadians(-90) + degreesToRadians(360)  * _progress;  //设置进度条终点位置
    //获取环形路径（画一个圆形，填充色透明，设置线框宽度为10，这样就获得了一个环形）
    
    _progressLayer = [CAShapeLayer layer];//创建一个track shape layer
    
    _progressLayer.frame = self.bounds;
    
    _progressLayer.fillColor = [[UIColor clearColor] CGColor];  //填充色为无色
    
    _progressLayer.strokeColor = [[UIColor cyanColor] CGColor]; //指定path的渲染颜色,这里可以设置任意不透明颜色
    
    _progressLayer.opacity = 1; //背景颜色的透明度
    
    _progressLayer.lineCap = kCALineCapRound;//指定线的边缘是圆的
    
    _progressLayer.lineWidth = 10;//线的宽度
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];//上面说明过了用来构建圆形
    
    _progressLayer.path =[path CGPath]; //把path传递給layer，然后layer会处理相应的渲染，整个逻辑和CoreGraph是一致的。
    
    [self.layer addSublayer:_progressLayer];
    
    
    //生成渐变色
    
    CALayer *gradientLayer = [CALayer layer];
    
    //左侧渐变色
    
    CAGradientLayer *leftLayer = [CAGradientLayer layer];
    
    leftLayer.frame = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);    // 分段设置渐变色
    
    leftLayer.locations = @[@0.3, @0.9, @1];
    
    leftLayer.colors = @[(id)[UIColor yellowColor].CGColor, (id)[UIColor clearColor].CGColor];
    
    [gradientLayer addSublayer:leftLayer];
    
    
    
    //右侧渐变色
    
    CAGradientLayer *rightLayer = [CAGradientLayer layer];
    
    rightLayer.frame = CGRectMake(self.bounds.size.width / 2, 0, self.bounds.size.width / 2, self.bounds.size.height);
    
    rightLayer.locations = @[@0.3, @0.9, @1];
    
    rightLayer.colors = @[(id)[UIColor yellowColor].CGColor, (id)[UIColor redColor].CGColor];
    
    [gradientLayer addSublayer:rightLayer];
    
    
    
    [gradientLayer setMask:_progressLayer]; //用progressLayer来截取渐变层
    
    [self.layer addSublayer:gradientLayer];

}

- (void)drawProgress:(CGFloat )progress

{
    _progress = progress;
    
    _progressLayer.opacity = 0;
    
    [self setNeedsDisplay];
}

@end
