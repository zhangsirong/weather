//
//  area.h
//  weather
//
//  Created by hp on 6/24/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface area : NSObject

@property (nonatomic, copy) NSString *areaid;
@property (nonatomic, copy) NSString *districtcn;
@property (nonatomic, copy) NSString *districten;
@property (nonatomic, copy) NSString *namecn;
@property (nonatomic, copy) NSString *nameen;
@property (nonatomic, copy) NSString *nationcn;
@property (nonatomic, copy) NSString *nationzn;
@property (nonatomic, copy) NSString *provcn;
@property (nonatomic, copy) NSString *proven;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)areaWithDict:(NSDictionary *)dict;

+ (NSArray *)areaList;

@end
