//
//  Data.h
//  weather
//
//  Created by hp on 6/24/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Yesterday;
@interface MyData : NSObject

@property (nonatomic, copy) NSString *wendu;
@property (nonatomic, copy) NSString *ganmao;

@property (nonatomic, strong) NSArray *forecast;
@property (nonatomic, copy) NSString *aqi;
@property (nonatomic, copy) NSString *city;

@property (nonatomic, strong)  Yesterday *yesterday;

@end
