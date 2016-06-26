//
//  ZSRTadayView.h
//  weather
//
//  Created by hp on 6/25/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

#define sHeight [UIScreen mainScreen].bounds.size.height
#define sWidth [UIScreen mainScreen].bounds.size.width
@class ZSRTadayModel;

@interface ZSRTadayView : UIView
@property (nonatomic, strong) ZSRTadayModel* model;
@property (nonatomic, weak)UILabel *cityLabel;
@end
