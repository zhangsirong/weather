//
//  ViewController.m
//  weather
//
//  Created by hp on 6/23/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "AFURLSessionManager.h"
#import "Foundation+Log.h"
#import "WeatherData.h"
#import "MyData.h"
#import "MJExtension.h"
#import "ForecastPart.h"
#import "yesterday.h"
#import "area.h"
#import "UIImageView+LBBlurredImage.h"
#import "ZSRTadayView.h"
#import "ZSRTadayModel.h"
#import "ZSRWeatherCell.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) MyData *mydata;
@property (nonatomic, strong) NSArray *areas;
@property (nonatomic, strong) ForecastPart *tadayPart;
@property (nonatomic, weak) UIView *headTempView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) UILabel *tempLabel;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) ZSRTadayView *headerView;
@property (nonatomic, strong) UIView *footView;
//@property (nonatomic, strong) ZSRTadayModel *model;



@end

@implementation ViewController
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    if (self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
    [self requestData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated{

}
-(ZSRTadayView *)headerView{
    if (_headerView == nil) {
        _headerView = [[ZSRTadayView alloc] initWithFrame:CGRectMake(0, 0, sWidth, sHeight/2)];
    }
    return _headerView;
}

-(UIView *)footView{
    if (_footView == nil) {
        _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sWidth, sHeight/2)];
    }
    return _footView;
}


- (UIView *)headView{
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sWidth, sHeight / 2)];
    headView.backgroundColor = [UIColor orangeColor];
    [headView addSubview:self.headTempView];
    return headView;
    
}

- (UIView *)headTempView{
    UIView *headTempView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 200, 200)];
    headTempView.backgroundColor = [UIColor blueColor];
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    tempLabel.backgroundColor = [UIColor clearColor];
    
    UIImageView *tickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloudy1"]];
    tickImage.backgroundColor = [UIColor blackColor];
    tempLabel.text = @"35";
    [headTempView addSubview:tickImage];
    [headTempView addSubview:tempLabel];
    
    return headTempView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZSRWeatherCell *cell = [ZSRWeatherCell weatherCellWithTableView:tableView];
    switch (indexPath.row) {
        case 0:{
            
//            cell.textLabel.text =  self.tadayPart.low;
//            cell.textLabel.backgroundColor = [UIColor grayColor];
//            cell.textLabel.textColor = [UIColor redColor];
//            cell.imageView.image = [UIImage imageNamed:@"cloudy1"];
//            cell.detailTextLabel.text = self.tadayPart.type;
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
//            label.text = self.tadayPart.low;
////            label.backgroundColor = [UIColor redColor];
//            self.tempLabel = label;
//            cell.accessoryView =self.tempLabel;
        }
            break;
        case 1:
//            cell.textLabel.text = @"2555";
            break;
        case 2:
//            cell.textLabel.text = @"2555";
            break;
        case 3:
//            cell.textLabel.text = @"2555";
            break;
        default:
            break;
    }
    return cell;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}



-(void)setupSubViews{
//    [self.view addSubview:self.headView];
    UIImage *background = [UIImage imageNamed:@"bg"];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = self.footView;
    [self.view addSubview:self.tableView];
}



- (void)Forecast {
    NSArray *forecast = self.mydata.forecast;
    ForecastPart *tadayPart = forecast[0];
    self.tadayPart = tadayPart;
    for (ForecastPart *cast in forecast) {
        NSLog(@"%@",cast);
    }
   
    ZSRTadayModel *model = [[ZSRTadayModel alloc]init];
    model.wendu = self.mydata.wendu;
    model.city = self.mydata.city;
    model.ganmao = self.mydata.ganmao;
    model.aqi = self.mydata.aqi;
    model.conditions = tadayPart.type;
    self.headerView.model = model;
    
    
    NSString *wendu = self.mydata.wendu;
    NSString *ganmao = self.mydata.ganmao;
    NSString *aqi = self.mydata.aqi;
    NSString *city = self.mydata.city;
    
    
    NSLog(@"wendu:%@ ganmao:%@ aqi:%@ city:%@",wendu,ganmao,aqi,city);
}


-(void)requestData{
    self.areas = [area areaList];
    for (int i = 0; i<self.areas.count; i++) {
//        area *myarea = self.areas[i];
//        NSLog(@"%@",myarea.areaid);
    }
    NSString *URLString = @"http://wthrcdn.etouch.cn/weather_mini";
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    area *myarea = self.areas[0];
    
    dict[@"citykey"] = myarea.areaid;
    //    dict[@"city"] = @"新疆";／
    
    
    AFHTTPSessionManager *httpManager = [AFHTTPSessionManager manager];
    httpManager.responseSerializer = [AFJSONResponseSerializer serializer];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask * task = [httpManager GET:URLString parameters:dict progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, NSData* data) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        // MJExtension框架里,字典转模型的方法
        WeatherData *weather = [WeatherData mj_objectWithKeyValues:dict];
        
        weakSelf.mydata = weather.data;
        [weakSelf Forecast];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    [task resume];

}



-(void)loadText{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"area" ofType:@"txt"];
    
    NSString *contents = [[NSString alloc] initWithContentsOfFile:path encoding:NSUnicodeStringEncoding error:nil];
    NSArray *contentsArray = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"];
    //    NSString *contents = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    ////    NSArray *contentsArray = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    //    NSArray *contentsArray = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    for (int i = 0; i<contentsArray.count; i++) {
        NSString *constString = contentsArray[i];
        if (constString.length > 0 ) {
            [mutableArray addObject:constString];
        }
    }
    
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"data.plist"];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSInteger idx;
    for (idx = 0; idx < mutableArray.count; idx++) {
        NSString* currentContent = [mutableArray objectAtIndex:idx];
        NSArray* timeDataArr = [currentContent componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[timeDataArr objectAtIndex:0] forKey:@"areaid"];
        [dic setObject:[timeDataArr objectAtIndex:1] forKey:@"nameen"];
        [dic setObject:[timeDataArr objectAtIndex:2] forKey:@"namecn"];
        [dic setObject:[timeDataArr objectAtIndex:3] forKey:@"districten"];
        [dic setObject:[timeDataArr objectAtIndex:4] forKey:@"districtcn"];
        [dic setObject:[timeDataArr objectAtIndex:5] forKey:@"proven"];
        [dic setObject:[timeDataArr objectAtIndex:6] forKey:@"provcn"];
        [dic setObject:[timeDataArr objectAtIndex:7] forKey:@"nationzn"];
        [dic setObject:[timeDataArr objectAtIndex:8] forKey:@"nationcn"];
        
        
        
        [arr addObject:dic];
    }
    [arr writeToFile:filePath atomically:YES];

}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    CGFloat percent = MIN(position / height, 1.0);
    self.blurredImageView.alpha = percent;
}
@end
