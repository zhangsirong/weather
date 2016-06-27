//
//  ZSREditController.h
//  weather
//
//  Created by hp on 6/27/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZSREditController;
@protocol ZSREditControllerDelegate <NSObject>
@required

-(void)editControllerView:(ZSREditController*)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface ZSREditController : UITableViewController

@property (nonatomic,strong) NSArray *dataSource;
@property (nonatomic, weak) id<ZSREditControllerDelegate> delegate;

@end

