//
//  WeatherData.h
//  weather
//
//  Created by hp on 6/24/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyData;
@interface WeatherData : NSObject
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) MyData *data;


@end
