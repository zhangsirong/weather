//
//  ZSRPageView.m
//  weather
//
//  Created by hp on 6/27/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRPageView.h"
#import "ZSRTadayViewCell.h"
#import "ZSRWeatherCell.h"
#import "MyData.h"
#import "ZSRTadayManage.h"
#import "AFNetworking.h"
#import "WeatherData.h"
#import "MJExtension.h"
#import "ZSRTadayViewCell.h"
#import "ZSRTadayModel.h"
#import "MJRefresh.h"

@interface ZSRPageView()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray *forecasts;
@property (nonatomic, strong) ZSRTadayModel *tadayModels;

@end

@implementation ZSRPageView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

-(instancetype)initWithCity:(NSString *)city{
    
    if (self = [self initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH)]) {
        self.city = city;
    }
    return self;
}

- (instancetype)init
{
    
  return [self initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH)];
}


-(NSArray *)forecasts{
    
    if (_forecasts == nil) {
        _forecasts = [[NSArray alloc] init];
    }
    return _forecasts;
}

-(void)setupSubViews{

    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    tableView.pagingEnabled = YES;
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadMoreData" object:nil];
    }];
    self.tableView = tableView;
    [self addSubview:tableView];
}

-(void)layoutSubviews{
    self.tableView.frame = CGRectMake(0, 0, ScreenW, ScreenH  - 44);
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        ZSRTadayViewCell *tadayCell = [ZSRTadayViewCell tadayCellWithTableView:tableView];
        tadayCell.model = self.tadayModels;
        return tadayCell;
    }
    ZSRWeatherCell *cell = [ZSRWeatherCell weatherCellWithTableView:tableView];
    cell.forecastPartModel = self.forecasts[indexPath.row - 1];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.forecasts.count + 1 ;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 &&indexPath.row ==0) {
        return ScreenH/2;
    }else{
            return 80;
    }
}

-(void)setMydata:(MyData *)mydata
{
    _mydata = mydata;
    self.forecasts = mydata.forecast;
    self.tadayModels = [ZSRTadayManage tadayWeatherWithMyData:mydata];
    
}

-(void)setCity:(NSString *)city{
    _city = city;
}
@end
