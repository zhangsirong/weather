//
//  ZSRCityView.m
//  weather
//
//  Created by hp on 7/1/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRCityView.h"
#define btnH 39
@interface ZSRCityView()
@end

@implementation ZSRCityView
-(NSMutableArray *)cityButtons{
    if (_cityButtons == nil) {
        _cityButtons = [NSMutableArray arrayWithCapacity:1];
    }
    return _cityButtons;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        NSArray *cityArray = [NSArray arrayWithObjects:@"定位",@"北京",@"上海",@"广州",@"深圳",@"珠海",@"佛山",@"南京",@"苏州",@"杭州",@"济南",@"青岛",@"郑州",@"石家庄",@"福州",@"厦门",@"武汉",@"长沙",@"成都",@"重庆",@"太原",@"沈阳",@"南宁",@"西安", nil];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 20)];
        label.text = @"快速添加";
        label.textColor = [UIColor grayColor];
        [self addSubview:label];
        
        //列数
        int columns = 3;
        int count = (int)cityArray.count;
        for (int i = 0 ; i< count; i++) {
            //第几行
            int row = i / columns;
            //第几咧
            int col = i % columns;
            
            UIButton *cityBtn = [[UIButton alloc] initWithFrame:CGRectMake(col * (self.bounds.size.width)/columns, row * btnH+ 50, self.bounds.size.width/columns  , btnH)];
            cityBtn.layer.borderWidth = 0.5;
            cityBtn.layer.borderColor = [UIColor grayColor].CGColor;
            cityBtn.backgroundColor = [UIColor colorWithRed:198 green:198 blue:202 alpha:0.2];
            cityBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            [cityBtn setTitle:cityArray[i] forState:UIControlStateNormal];
            [cityBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [cityBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
            [cityBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:cityBtn];
            [self.cityButtons addObject:cityBtn];
        }
    }
    return self;
}

- (void)btnClick:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(cityView:didClickButton:)]) {
        [self.delegate cityView:self didClickButton:button];
    }
}
@end
