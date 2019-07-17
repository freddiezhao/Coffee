//
//  EditNameCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/11.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "EditNameCell.h"

@implementation EditNameCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self) {
        if (!_nameLabel) {
            _nameLabel = [[UILabel alloc] init];
            _nameLabel.textColor = [UIColor colorWithHexString:@"222222"];
            _nameLabel.font = [UIFont fontWithName:@"Arial" size:15.0f];
            _nameLabel.textAlignment = NSTextAlignmentLeft;
            _nameLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_nameLabel];
            
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(60/WScale, 21/HScale));
                make.left.equalTo(self.contentView.mas_left).offset(15.f/WScale);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        
        if (!_nameTF) {
            _nameTF = [[UITextField alloc] init];
            _nameTF.font = [UIFont systemFontOfSize:15.f];
            
            _nameTF.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
            _nameTF.placeholder = LocalString(@"请填写");
            _nameTF.font = [UIFont fontWithName:@"Arial" size:15.0f];
            _nameTF.textColor = [UIColor colorWithHexString:@"999999"];
            _nameTF.layer.cornerRadius = 15.f/HScale;
            _nameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
            _nameTF.autocorrectionType = UITextAutocorrectionTypeNo;
            _nameTF.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            _nameTF.textAlignment = NSTextAlignmentLeft;
            //设置为YES时文本会自动缩小以适应文本窗口大小.默认是保持原来大小,而让长文本滚动
            _nameTF.adjustsFontSizeToFitWidth = YES;
            //设置自动缩小显示的最小字体大小
            _nameTF.minimumFontSize = 11.f;
            [_nameTF addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
            
            UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10/WScale, 0)];
            _nameTF.leftView = paddingView;
            _nameTF.leftViewMode = UITextFieldViewModeAlways;
            
            [self.contentView addSubview:_nameTF];
            [_nameTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(self.contentView.bounds.size.width - 80, self.contentView.bounds.size.height));
                make.left.equalTo(self.nameLabel.mas_right).offset(50/WScale);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

-(void)textField1TextChange:(UITextField *)textField{
    if (self.TFBlock) {
        self.TFBlock(textField.text);
    }
}
@end
