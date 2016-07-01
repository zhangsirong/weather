//
//  ZSRTadayViewCell.m
//  weather
//
//  Created by hp on 6/30/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRTadayViewCell.h"
#import "Masonry.h"
#import "ZSRTadayModel.h"
@interface ZSRTadayViewCell()
//城市
@property (nonatomic, weak)UILabel *cityLabel;

//实时温度
@property (nonatomic, weak)UILabel *temperLabel;

//感冒
@property (nonatomic, weak)UILabel *ganmaoLabel;

//天气
@property (nonatomic, weak)UILabel *conditionsLabel;

//天气图标
@property (nonatomic, weak)UIImageView *iconView;

//空气指数
@property (nonatomic, weak)UILabel *aqiLabel;
@end

@implementation ZSRTadayViewCell

+ (instancetype)tadayCellWithTableView:(UITableView *)tableview{
    static NSString *ID = @"tadayCell";
    ZSRTadayViewCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *cityLabel= [[UILabel alloc] init];
        cityLabel.backgroundColor = [UIColor clearColor];
        cityLabel.translatesAutoresizingMaskIntoConstraints = NO;
        cityLabel.textColor = [UIColor whiteColor];
        cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        cityLabel.textAlignment = NSTextAlignmentCenter;
        cityLabel.text = @"加载数据中。。。";
        self.cityLabel = cityLabel;
        [self addSubview:cityLabel];
        
        
        UILabel *temperLabel= [[UILabel alloc] init];
        temperLabel.translatesAutoresizingMaskIntoConstraints = NO;
        temperLabel.backgroundColor = [UIColor clearColor];
        temperLabel.textColor = [UIColor whiteColor];
        temperLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:60];
        temperLabel.textAlignment = NSTextAlignmentLeft;
        self.temperLabel = temperLabel;
        [self addSubview:temperLabel];
        
        UILabel *ganmaoLabel = [[UILabel alloc] init];
        ganmaoLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        ganmaoLabel.backgroundColor = [UIColor clearColor];
        ganmaoLabel.textColor = [UIColor whiteColor];
        ganmaoLabel.numberOfLines = 0;
        ganmaoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        self.ganmaoLabel = ganmaoLabel;
        [self addSubview:ganmaoLabel];
        
        UILabel *conditionsLabel = [[UILabel alloc] init];
        conditionsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        conditionsLabel.backgroundColor = [UIColor clearColor];
        conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        conditionsLabel.textColor = [UIColor whiteColor];
        conditionsLabel.textAlignment = NSTextAlignmentRight;
        self.conditionsLabel = conditionsLabel;
        [self addSubview:conditionsLabel];
        
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.backgroundColor = [UIColor clearColor];
        self.iconView = iconView;
        [self addSubview:iconView];
        
        
        UILabel *aqiLabel = [[UILabel alloc] init];
        aqiLabel.translatesAutoresizingMaskIntoConstraints = NO;
        aqiLabel.backgroundColor = [UIColor clearColor];
        aqiLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        aqiLabel.textColor = [UIColor whiteColor];
        aqiLabel.textAlignment = NSTextAlignmentLeft;
        self.aqiLabel = aqiLabel;
        [self addSubview:aqiLabel];
        
        
        [cityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.mas_top).offset(20);
            make.height.mas_equalTo(50);
        }];
        
        [temperLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(30);
            make.top.equalTo(self.mas_top).offset(60);
            make.width.mas_equalTo(150);
            make.height.mas_equalTo(100);
        }];
        
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-30);
            make.top.equalTo(self.mas_top).offset(60);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(100);
        }];
        
        [conditionsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(iconView.mas_left).offset(-10);
            make.top.equalTo(iconView.mas_top).offset(0);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(50);
        }];
        
        [ganmaoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).offset(-20);
            make.left.equalTo(self.mas_left).offset(20);
            make.right.equalTo(self.mas_right).offset(-20);
            
            make.height.mas_equalTo(60);
        }];
        
        [aqiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(ganmaoLabel.mas_top).offset(-20);
            make.left.equalTo(self.mas_left).offset(20);
            make.width.mas_equalTo(300);
            make.height.mas_equalTo(20);
        }];
    }
    return self;
}

-(void)setModel:(ZSRTadayModel *)model{
    _model = model;
    self.cityLabel.text = model.city;
    self.conditionsLabel.text = model.conditions;
    self.temperLabel.text = [model.wendu stringByAppendingString:@"°"];
    if (model.aqi != nil) {
        self.aqiLabel.text = [NSString stringWithFormat:@"空气质量指数:%@",model.aqi];
    }
    self.ganmaoLabel.text = model.ganmao;
    
    if ([model.conditions isEqualToString:@"晴"]) {
        self.iconView.image = [UIImage imageNamed:@"sunny"];
    }else if ([model.conditions isEqualToString:@"小雨"]){
        self.iconView.image = [UIImage imageNamed:@"light_rain"];
    }else if ([model.conditions containsString:@"阵雨"]){
        self.iconView.image = [UIImage imageNamed:@"shower1"];
    }else if ([model.conditions isEqualToString:@"暴雨"]){
        self.iconView.image = [UIImage imageNamed:@"shower3"];
    }else if ([model.conditions isEqualToString:@"大雨"]){
        self.iconView.image = [UIImage imageNamed:@"shower3"];
    }else if ([model.conditions containsString:@"中雨"]){
        self.iconView.image = [UIImage imageNamed:@"shower2"];
    }else if ([model.conditions containsString:@"多云"]){
        self.iconView.image = [UIImage imageNamed:@"cloudy3"];
    }else if ([model.conditions containsString:@"阴"]){
        self.iconView.image = [UIImage imageNamed:@"overcast"];
    }
}
@end
