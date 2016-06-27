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

@property (nonatomic, strong) MyData *mydata;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *city;
@end
