//
//  area.m
//  weather
//
//  Created by hp on 6/24/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "area.h"

@implementation area
- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)areaWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSArray *)areaList
{
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area.plist" ofType:nil]];
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        [arrayM addObject:[area areaWithDict:dict]];
    }
    return arrayM;
}

@end
