//
//  TempPer30sCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/20.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "TempPer30sCell.h"

@implementation TempPer30sCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_Label1) {
            _Label1 = [[UILabel alloc] initWithFrame:CGRectMake(15/WScale, 0, 54/WScale, 36/HScale)];
            _Label1.textColor = [UIColor colorWithHexString:@"999999"];
            _Label1.font = [UIFont systemFontOfSize:10.0];
            _Label1.textAlignment = NSTextAlignmentCenter;
            _Label1.numberOfLines = 0;
            [self.contentView addSubview:_Label1];
        }
        if (!_Label2) {
            _Label2 = [[UILabel alloc] initWithFrame:CGRectMake(15/WScale + 54*1/WScale, 0, 54/WScale, 36/HScale)];
            _Label2.textColor = [UIColor colorWithHexString:@"999999"];
            _Label2.font = [UIFont systemFontOfSize:10.0];
            _Label2.textAlignment = NSTextAlignmentCenter;
            _Label2.numberOfLines = 0;
            [self.contentView addSubview:_Label2];
        }
        if (!_Label3) {
            _Label3 = [[UILabel alloc] initWithFrame:CGRectMake(15/WScale + 54*2/WScale, 0, 54/WScale, 36/HScale)];
            _Label3.textColor = [UIColor colorWithHexString:@"999999"];
            _Label3.font = [UIFont systemFontOfSize:10.0];
            _Label3.textAlignment = NSTextAlignmentCenter;
            _Label3.numberOfLines = 0;
            [self.contentView addSubview:_Label3];
        }
        if (!_Label4) {
            _Label4 = [[UILabel alloc] initWithFrame:CGRectMake(15/WScale + 54*3/WScale, 0, 54/WScale, 36/HScale)];
            _Label4.textColor = [UIColor colorWithHexString:@"999999"];
            _Label4.font = [UIFont systemFontOfSize:10.0];
            _Label4.textAlignment = NSTextAlignmentCenter;
            _Label4.numberOfLines = 0;
            [self.contentView addSubview:_Label4];
        }
        if (!_Label5) {
            _Label5 = [[UILabel alloc] initWithFrame:CGRectMake(15/WScale + 54*4/WScale, 0, 54/WScale, 36/HScale)];
            _Label5.textColor = [UIColor colorWithHexString:@"999999"];
            _Label5.font = [UIFont systemFontOfSize:10.0];
            _Label5.textAlignment = NSTextAlignmentCenter;
            _Label5.numberOfLines = 0;
            [self.contentView addSubview:_Label5];
        }
        if (!_Label6) {
            _Label6 = [[UILabel alloc] initWithFrame:CGRectMake(15/WScale + 54*5/WScale, 0, 54/WScale, 36/HScale)];
            _Label6.textColor = [UIColor colorWithHexString:@"999999"];
            _Label6.font = [UIFont systemFontOfSize:10.0];
            _Label6.textAlignment = NSTextAlignmentCenter;
            _Label6.numberOfLines = 0;
            [self.contentView addSubview:_Label6];
        }
    }
    return self;
}

@end
