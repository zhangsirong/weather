//
//  ZSRHttpTool.m
//  weather
//
//  Created by hp on 6/29/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRHttpTool.h"
#import "AFNetworking.h"
#import "WeatherData.h"
#import "MJExtension.h"
@implementation ZSRHttpTool

+(void)requestDataWithCity:(NSString *)city success:(void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable data))success failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure{
    NSString *URLString = @"http://wthrcdn.etouch.cn/weather_mini";
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    dict[@"city"] = city;
    AFHTTPSessionManager *httpManager = [AFHTTPSessionManager manager];
    httpManager.responseSerializer = [AFJSONResponseSerializer serializer];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];

    NSURLSessionDataTask * task = [httpManager GET:URLString parameters:dict progress:^(NSProgress * _Nonnull downloadProgress) {

    } success:success failure:failure];
    [task resume];
}
@end
