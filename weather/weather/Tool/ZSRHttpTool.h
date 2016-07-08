//
//  ZSRHttpTool.h
//  weather
//
//  Created by hp on 6/29/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSRHttpTool : NSObject

+(void)requestDataWithCity:(NSString *)city success:(void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable data))success failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;
@end
