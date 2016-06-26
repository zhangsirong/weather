//
//  forecast.m
//  weather
//
//  Created by hp on 6/24/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ForecastPart.h"

@implementation ForecastPart
-(NSString *)description{
    return [NSString stringWithFormat:@"时间:%@ 天气:%@ 风向:%@ 风力:%@ 高温:%@ 低温:%@",self.date,self.type,self.fengxiang,self.fengli,self.high,self.low];
}
@end
