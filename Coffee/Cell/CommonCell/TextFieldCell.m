//
//  TextFieldCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/20.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "TextFieldCell.h"

@implementation TextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_textField) {
            _textField = [[UITextField alloc] init];
            _textField.backgroundColor = [UIColor clearColor];
            _textField.font = [UIFont fontWithName:@"Arial" size:16.0f];
            _textField.textColor = [UIColor colorWithHexString:@"222222"];
            //_textField.borderStyle = UITextBorderStyleRoundedRect;
            _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            _textField.autocorrectionType = UITextAutocorrectionTypeNo;
            _textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            //设置为YES时文本会自动缩小以适应文本窗口大小.默认是保持原来大小,而让长文本滚动
            _textField.adjustsFontSizeToFitWidth = YES;
            //设置自动缩小显示的最小字体大小
            _textField.minimumFontSize = 11.f;
            [_textField addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
            [self.contentView addSubview:_textField];
            
            [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(350/WScale, 30/HScale));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.contentView.mas_left).offset(18/WScale);
            }];
        }
    }
    return self;
}

-(void)textFieldTextChange:(UITextField *)textField{
    if (self.TFBlock) {
        self.TFBlock(textField.text);
    }
}

@end
