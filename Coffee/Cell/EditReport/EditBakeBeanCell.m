//
//  EditBakeBeanCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/11.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "EditBakeBeanCell.h"

@implementation EditBakeBeanCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_nameLabel) {
            _nameLabel = [[UILabel alloc] init];
            _nameLabel.textColor = [UIColor colorWithHexString:@"222222"];
            _nameLabel.font = [UIFont systemFontOfSize:15.0];
            _nameLabel.textAlignment = NSTextAlignmentLeft;
            _nameLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_nameLabel];
            
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(150/WScale, 21/HScale));
                make.left.equalTo(self.contentView.mas_left).offset(15/WScale);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_weightTF) {
            _weightTF = [[UITextField alloc] init];
            _weightTF.font = [UIFont systemFontOfSize:13.f];
            
            _weightTF.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
            _weightTF.placeholder = LocalString(@"0.0");
            _weightTF.font = [UIFont fontWithName:@"Arial" size:15.0f];
            _weightTF.keyboardType = UIKeyboardTypeDecimalPad;
            _weightTF.textColor = [UIColor colorWithHexString:@"333333"];
            _weightTF.layer.cornerRadius = 15.f/HScale;
            _weightTF.clearButtonMode = UITextFieldViewModeWhileEditing;
            _weightTF.autocorrectionType = UITextAutocorrectionTypeNo;
            _weightTF.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            _weightTF.textAlignment = NSTextAlignmentCenter;
            //设置为YES时文本会自动缩小以适应文本窗口大小.默认是保持原来大小,而让长文本滚动
            _weightTF.adjustsFontSizeToFitWidth = YES;
            //设置自动缩小显示的最小字体大小
            _weightTF.minimumFontSize = 11.f;
            [_weightTF addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
            
            [self.contentView addSubview:_weightTF];
            [_weightTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100/WScale, 30/HScale));
                make.right.equalTo(self.contentView.mas_right).offset(-40/WScale);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        UILabel *label = [[UILabel alloc] init];
        label.text = [DataBase shareDataBase].setting.weightUnit;
        label.font = [UIFont systemFontOfSize:16.f];
        label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentRight;
        label.alpha = 1;
        label.numberOfLines = 0;
        label.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(9.5/WScale, 22.5/HScale));
            make.left.equalTo(self.weightTF.mas_right).offset(8/WScale);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
    }
    return self;
}

-(void)textField1TextChange:(UITextField *)textField{
    if (self.TFBlock) {
        self.TFBlock(textField.text);
    }
}

@end
