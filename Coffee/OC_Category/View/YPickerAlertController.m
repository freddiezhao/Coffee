//
//  YPickerAlertController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/19.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "YPickerAlertController.h"

@interface YPickerAlertController () <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIPickerView *myPicker;
@property (nonatomic, strong) UIButton *dismissBtn;
@property (nonatomic, strong) UIButton *confirmBtn;

@end

@implementation YPickerAlertController{
    NSInteger selectValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];

    self.myPicker = [self myPicker];
    self.dismissBtn = [self dismissBtn];
    self.confirmBtn = [self confirmBtn];
    [self.myPicker selectRow:_index inComponent:0 animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_myPicker) {
        [_myPicker reloadAllComponents];
    }
    NSLog(@"%ld",_pickerArr.count);
}

#pragma mark - LazyLoad
- (UIPickerView *)myPicker{
    if (!_myPicker) {
        _backView = [[UIView alloc] init];
        _backView.frame = CGRectMake(0, ScreenHeight - 260/HScale - 49.f - getRectNavAndStatusHight, ScreenWidth, 260/HScale);
        _backView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor;
        [self.view addSubview:_backView];
        
        _myPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 60/HScale, ScreenWidth, 200/HScale)];
        _myPicker.delegate = self;
        _myPicker.dataSource = self;
        [_backView addSubview:_myPicker];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(0,0,ScreenWidth,60/HScale);
        _titleLabel.font = [UIFont systemFontOfSize:17.f];
        _titleLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_backView addSubview:_titleLabel];
        
        
    }
    return _myPicker;
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 260/HScale);
        [_dismissBtn setBackgroundColor:[UIColor clearColor]];
        [_dismissBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_dismissBtn];
    }
    return _dismissBtn;
}

- (UIButton *)confirmBtn{
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
        [_confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_confirmBtn setBackgroundColor:[UIColor whiteColor]];
        [_confirmBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        _confirmBtn.layer.cornerRadius = 8.f;
        [self.view addSubview:_confirmBtn];
        
        [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 44.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.backView.mas_bottom).offset(5.f);
        }];
    }
    return _confirmBtn;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _pickerArr.count;
}

//返回指定列，行的高度，就是自定义行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 39.f;
    
}

//显示的标题
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSString *str = [NSString stringWithFormat:@"%@",_pickerArr[row]];
    
    return str;
    
}

//显示的标题字体、颜色等属性
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSString *str = [NSString stringWithFormat:@"%@",_pickerArr[row]];

    NSMutableAttributedString *AttributedString = [[NSMutableAttributedString alloc]initWithString:str];
    
    [AttributedString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"222222"]} range:NSMakeRange(0, [AttributedString length])];
    return AttributedString;
    
}//NS_AVAILABLE_IOS(6_0);

//被选择的行
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    selectValue = row;
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirm{
    if (self.pickerBlock) {
        self.pickerBlock(selectValue);
    }
    [self dismissVC];
}

@end
