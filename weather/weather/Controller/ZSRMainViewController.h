//
//  ViewController.h
//  weather
//
//  Created by hp on 6/23/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSRMainViewController : UIViewController
+ (instancetype)sharedMainViewController;

@property(nonatomic,strong) NSMutableArray *citys;

@end

