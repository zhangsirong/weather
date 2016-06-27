//
//  ZSRPageView.m
//  weather
//
//  Created by hp on 6/27/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRPageView.h"
#import "UIImageView+LBBlurredImage.h"
#import "ZSRTadayView.h"
#import "ZSRWeatherCell.h"
#import "MyData.h"
#import "ZSRTadayManage.h"
#import "AFNetworking.h"
#import "WeatherData.h"
#import "MJExtension.h"
@interface ZSRPageView()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) ZSRTadayView *headerView;
@property (nonatomic, strong) NSArray *forecasts;
@end

@implementation ZSRPageView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

-(NSArray *)forecasts{
    
    if (_forecasts == nil) {
        _forecasts = [[NSArray alloc] init];
    }
    return _forecasts;
}

-(ZSRTadayView *)headerView{
    if (_headerView == nil) {
        _headerView = [[ZSRTadayView alloc] initWithFrame:CGRectMake(0, 0, sWidth, sHeight/2)];
    }
    return _headerView;
}


-(void)setupSubViews{
    UIImage *background = [UIImage imageNamed:@"bg.png"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:background];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView = backgroundImageView;
    [self addSubview:backgroundImageView];
    
    UIImageView *blurredImageView = [[UIImageView alloc] init];
    blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    blurredImageView.alpha = 0;
    [blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    self.blurredImageView = blurredImageView;
    [self addSubview:blurredImageView];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    tableView.pagingEnabled = YES;
    self.tableView = tableView;
    self.tableView.tableHeaderView = self.headerView;
    [self addSubview:tableView];
}

-(void)layoutSubviews{
    CGRect bounds = self.bounds;
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = CGRectMake(0, 0, sWidth, sHeight-44);
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZSRWeatherCell *cell = [ZSRWeatherCell weatherCellWithTableView:tableView];
    cell.forecastPartModel = self.forecasts[indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.forecasts.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(void)setMydata:(MyData *)mydata
{
    _mydata = mydata;
    self.forecasts = mydata.forecast;
    self.headerView.model = [ZSRTadayManage tadayWeatherWithMyData:mydata];
    
}

-(void)setCity:(NSString *)city{
    _city = city;
    [self requestData:city];
}

-(void)requestData:(NSString *)city{
    NSString *URLString = @"http://wthrcdn.etouch.cn/weather_mini";
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    dict[@"city"] = city;
    AFHTTPSessionManager *httpManager = [AFHTTPSessionManager manager];
    httpManager.responseSerializer = [AFJSONResponseSerializer serializer];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionDataTask * task = [httpManager GET:URLString parameters:dict progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, NSData* data) {
        
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            // MJExtension框架里,字典转模型的方法
            WeatherData *weather = [WeatherData mj_objectWithKeyValues:dict];
            self.mydata = weather.data;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    [task resume];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = scrollView.bounds.size.height/2;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    CGFloat percent = MIN(position / height, 1.0);
    self.blurredImageView.alpha = percent;
}
@end
