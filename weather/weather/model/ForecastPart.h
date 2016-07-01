//
//  forecast.h
//  weather
//
//  Created by hp on 6/24/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForecastPart : NSObject

@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *fengxiang;
@property (nonatomic, copy) NSString *fengli;
@property (nonatomic, copy) NSString *high;
@property (nonatomic, copy) NSString *low;

@end
