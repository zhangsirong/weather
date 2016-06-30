//
//  ZSRTadayViewCell.h
//  weather
//
//  Created by hp on 6/30/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSRTadayModel;
@interface ZSRTadayViewCell : UITableViewCell
@property (nonatomic, strong) ZSRTadayModel* model;
+ (instancetype)tadayCellWithTableView:(UITableView *)tableview;

@end
