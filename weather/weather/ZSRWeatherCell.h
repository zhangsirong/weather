//
//  ZSRWeatherCell.h
//  weather
//
//  Created by hp on 6/24/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ForecastPart;
@interface ZSRWeatherCell : UITableViewCell

@property (nonatomic,strong) ForecastPart *forecastModel;
+ (instancetype)weatherCellWithTableView:(UITableView *)tableview;

@end
