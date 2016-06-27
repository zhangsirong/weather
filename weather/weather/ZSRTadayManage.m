//
//  ZSRForcsatManage.m
//  weather
//
//  Created by hp on 6/26/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRTadayManage.h"
#import "ZSRTadayModel.h"
#import "ForecastPart.h"
#import "MyData.h"
@implementation ZSRTadayManage

+(id)tadayWeatherWithMyData:(MyData *)myData{
    
    ZSRTadayModel *model = [[ZSRTadayModel alloc]init];
    ForecastPart *cast = [myData.forecast objectAtIndex:0];
    model.wendu = myData.wendu;
    model.city = myData.city;
    model.ganmao = myData.ganmao;
    model.aqi = [NSString stringWithFormat:@"aqi:%@",myData.aqi];
    model.conditions = cast.type;
    return model;
}
@end
