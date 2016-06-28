//
//  ZSRPageView.h
//  weather
//
//  Created by hp on 6/27/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyData;
@interface ZSRPageView : UIView

@property (nonatomic, strong,nonnull) MyData *mydata;
@property (nonatomic, strong,nonnull) UITableView *tableView;
@property (nonatomic, strong,nonnull) NSString *city;
-(void)requestData:(nonnull NSString *)city completion: (void (^ __nullable)(void))completion;
-(instancetype)initWithCity:(nonnull NSString *)city;
@end
