//
//  ZSRWeatherCell.m
//  weather
//
//  Created by hp on 6/24/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRWeatherCell.h"
#import "ForecastPart.h"
#import "Masonry.h"

@interface ZSRWeatherCell()
//天气图标
@property (nonatomic, weak)UIImageView *iconView;

//时间
@property (nonatomic, weak)UILabel *timeLabel;

//天气
@property (nonatomic, weak)UILabel *conditionsLabel;

//风向
@property (nonatomic, weak)UILabel *fengXLabel;

//风力
@property (nonatomic, weak)UILabel *fengLLabel;

//高低温
@property (nonatomic, weak)UILabel *wenduLabel;

@end

@implementation ZSRWeatherCell
+ (instancetype)weatherCellWithTableView:(UITableView *)tableview{
    static NSString *ID = @"weatherCell";
    ZSRWeatherCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
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
        
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.backgroundColor = [UIColor clearColor];
        iconView.image = [UIImage imageNamed:@"cloudy3"];
        
        self.iconView = iconView;
        [self addSubview:iconView];
        
        UILabel *timeLabel= [[UILabel alloc] init];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.text = @"26日星期天";
        timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel = timeLabel;
        [self addSubview:timeLabel];
        
        UILabel *conditionsLabel= [[UILabel alloc] init];
        conditionsLabel.backgroundColor = [UIColor clearColor];
        conditionsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        conditionsLabel.textColor = [UIColor whiteColor];
        conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        conditionsLabel.textAlignment = NSTextAlignmentCenter;
        conditionsLabel.backgroundColor = [UIColor clearColor];
        conditionsLabel.text = @"晴";
        self.conditionsLabel = conditionsLabel;
        [self addSubview:conditionsLabel];
        
        
        UILabel *fengXLabel= [[UILabel alloc] init];
        fengXLabel.backgroundColor = [UIColor clearColor];
        fengXLabel.translatesAutoresizingMaskIntoConstraints = NO;
        fengXLabel.textColor = [UIColor whiteColor];
        fengXLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        fengXLabel.textAlignment = NSTextAlignmentCenter;
        fengXLabel.text = @"无持续风向";

        self.fengXLabel = fengXLabel;
        [self addSubview:fengXLabel];
        
        UILabel *fengLLabel= [[UILabel alloc] init];
        fengLLabel.backgroundColor = [UIColor clearColor];
        fengLLabel.translatesAutoresizingMaskIntoConstraints = NO;
        fengLLabel.textColor = [UIColor whiteColor];
        fengLLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        fengLLabel.textAlignment = NSTextAlignmentCenter;
        fengLLabel.text = @"微风级";

        self.fengLLabel = fengLLabel;
        [self addSubview:fengLLabel];
        
        UILabel *wenduLabel= [[UILabel alloc] init];
        wenduLabel.backgroundColor = [UIColor clearColor];
        wenduLabel.translatesAutoresizingMaskIntoConstraints = NO;
        wenduLabel.textColor = [UIColor whiteColor];
        wenduLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
        wenduLabel.textAlignment = NSTextAlignmentCenter;
        wenduLabel.text = @"36°/28°";
        self.wenduLabel = wenduLabel;
        [self addSubview:wenduLabel];
        
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(10);
            make.top.equalTo(self.mas_top).offset(20);
            make.bottom.equalTo(self.mas_bottom).offset(-20);
            make.width.mas_equalTo(50);
        }];
        
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.mas_right).offset(0);
            make.top.equalTo(self.mas_top).offset(10);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(80);
        }];
        
        [conditionsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.mas_right).offset(0);
            make.bottom.equalTo(self.mas_bottom).offset(-10);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(80);
        }];
        
        [fengXLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(timeLabel.mas_right).offset(0);
            make.top.equalTo(self.mas_top).offset(10);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(80);
        }];
        
        [fengLLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(timeLabel.mas_right).offset(0);
            make.bottom.equalTo(self.mas_bottom).offset(-10);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(80);
        }];
        
        [wenduLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-10);
            make.top.equalTo(self.mas_top).offset(10);
            make.bottom.equalTo(self.mas_bottom).offset(-10);
            make.width.mas_equalTo(100);
        }];
    }
    return self;
}

-(void)setForecastPartModel:(ForecastPart *)forecastModel{
    _forecastPartModel = forecastModel;
    self.timeLabel.text = forecastModel.date;
    self.conditionsLabel.text = forecastModel.type;
    self.fengXLabel.text = forecastModel.fengxiang;
    self.fengLLabel.text = forecastModel.fengli;
    self.wenduLabel.text = [NSString stringWithFormat:@"%@°/%@°",[forecastModel.high substringWithRange:NSMakeRange(3, 2)],[forecastModel.low substringWithRange:NSMakeRange(3, 2) ]];
   
    if ([forecastModel.type isEqualToString:@"晴"]) {
        self.iconView.image = [UIImage imageNamed:@"sunny"];
    }else if ([forecastModel.type isEqualToString:@"小雨"]){
        self.iconView.image = [UIImage imageNamed:@"light_rain"];
    }else if ([forecastModel.type containsString:@"阵雨"]){
        self.iconView.image = [UIImage imageNamed:@"shower1"];
    }else if ([forecastModel.type isEqualToString:@"暴雨"]){
        self.iconView.image = [UIImage imageNamed:@"shower3"];
    }else if ([forecastModel.type isEqualToString:@"大雨"]){
        self.iconView.image = [UIImage imageNamed:@"shower3"];
    }else if ([forecastModel.type containsString:@"中雨"]){
        self.iconView.image = [UIImage imageNamed:@"shower2"];
    }else if ([forecastModel.type containsString:@"多云"]){
        self.iconView.image = [UIImage imageNamed:@"cloudy3"];
    }else if ([forecastModel.type containsString:@"阴"]){
        self.iconView.image = [UIImage imageNamed:@"overcast"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
