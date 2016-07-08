//
//  ZSRCityView.h
//  weather
//
//  Created by hp on 7/1/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZSRCityView;
@protocol ZSRCityViewDelegate <NSObject>

-(void)cityView:(ZSRCityView *)cityView didClickButton:(UIButton *)button;
@end

@interface ZSRCityView : UIView
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic,weak) id<ZSRCityViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *cityButtons;

@end
