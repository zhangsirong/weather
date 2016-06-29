//
//  ZSRHttpTool.h
//  weather
//
//  Created by hp on 6/29/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSRHttpTool : NSObject

+(void)requestDataWithCity:(NSString *)city success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success;

@end
