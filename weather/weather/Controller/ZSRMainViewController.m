//
//  ViewController.m
//  weather
//
//  Created by hp on 6/23/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRMainViewController.h"
#import "Foundation+Log.h"
#import "ZSRArea.h"
#import "ZSREditController.h"
#import "UIImageView+LBBlurredImage.h"
#import "ZSRPageView.h"
#import "MyData.h"
#import "INTULocationManager.h"
#import "MBProgressHUD+ZSR.h"
#import "AFNetworking.h"
#import "ZSRHttpTool.h"
#import "MJExtension.h"
#import "WeatherData.h"
#import "MJRefresh.h"

#define filePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"localDicts.plist"]

@interface ZSRMainViewController ()<UIScrollViewDelegate,ZSREditControllerDelegate,CLLocationManagerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;

@property (nonatomic, strong) NSArray *areas;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, strong) NSMutableDictionary *localDicts;
@property (nonatomic, strong) ZSREditController *editController;
@end

@implementation ZSRMainViewController


-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    if (self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}

#pragma mark - getter
-(ZSREditController *)editController{
    if (_editController == nil) {
        _editController = [[ZSREditController alloc] init];
        _editController.delegate = self;
    }
    return _editController;
}

-(NSMutableArray *)pageViews{
    if (_pageViews ==nil) {
        _pageViews = [NSMutableArray arrayWithCapacity:1];
    }
    return _pageViews;
}

-(NSMutableDictionary *)localDicts{
    if (_localDicts ==nil) {
        _localDicts = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _localDicts;
}

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, self.view.frame.size.height)];
        _scrollView.backgroundColor = [UIColor clearColor];
        // 有弹簧效果
        _scrollView.bounces = YES;
        // 取消水平滚动条
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        // 要分页
        _scrollView.pagingEnabled = YES;
        // contentSize
        _scrollView.contentSize = CGSizeMake(1 * _scrollView.bounds.size.width, 0);
        // 设置代理
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl
{
    if (_pageControl == nil) {
        // 分页控件，本质上和scrollView没有任何关系，是两个独立的控件
        _pageControl = [[UIPageControl alloc] init];
        // 总页数默认是1
        _pageControl.numberOfPages = 1;
        
        _pageControl.bounds = CGRectMake(0, 0, ScreenW-44, 44);
        
        _pageControl.center = CGPointMake(self.view.center.x, ScreenH-20);
        
        // 设置颜色
        _pageControl.pageIndicatorTintColor = [UIColor redColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        
        
        // 添加监听方法
        /** 在OC中，绝大多数"控件"，都可以监听UIControlEventValueChanged事件，button除外" */
        [_pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    self.areas = [ZSRArea areaList];
    [self loadRecond];
    [self networkChange];
    [self setupSubViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityChange:) name:@"CityChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveAction) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMoreData) name:@"loadMoreData" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}
-(void)dealloc{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}
#pragma mark - 定位
- (void)searchLocation {
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:10.0 delayUntilAuthorized:YES block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        //定位成功 到网络获取数据
        if (status == INTULocationStatusSuccess) {
            [MBProgressHUD hideHUDForView:[self.pageViews firstObject]];
            [MBProgressHUD showSuccess:@"定位成功"];
            [[[CLGeocoder alloc] init] reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                for (CLPlacemark *placemark in placemarks) {
                    NSLog(@"%@ %@ %f %f", placemark.subLocality, placemark.addressDictionary, placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
                    [self locationSuccess:placemark];
                    
                }
            }];
        }
        else if(status == INTULocationStatusTimedOut){
            NSLog(@"INTULocationStatusTimedOut");
        }
        else if (status == INTULocationStatusServicesNotDetermined){
            NSLog(@"INTULocationStatusServicesNotDetermined");

        }else if (status == INTULocationStatusServicesDenied){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"打开定位权限" message:@"请在设置中打开定位权限,本程序将退出" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                exit(0);
            }];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
            NSLog(@"INTULocationStatusServicesDenied");

        }else if (status == INTULocationStatusServicesRestricted){
            
            NSLog(@"INTULocationStatusServicesRestricted");

        }else if (status == INTULocationStatusServicesDisabled){
            NSLog(@"INTULocationStatusServicesDisabled");

            
        }else{
            
        }
        
    }];
}

- (void)locationSuccess:(CLPlacemark *)placemark {
    
    NSString *cityName = @"";
    NSString *realSubLocality = [placemark.subLocality substringWithRange:NSMakeRange(0, placemark.subLocality.length-1)];
    NSString *realCity = [placemark.locality substringWithRange:NSMakeRange(0, placemark.locality.length-1)];
    
    for (ZSRArea *area in self.areas) {
        cityName = [area.namecn isEqualToString:realSubLocality] ? realSubLocality : realCity;
    }
    ((ZSRPageView *)[self.pageViews firstObject]).city = cityName;
    [MBProgressHUD showMessage:@"加载数据"];

    [ZSRHttpTool requestDataWithCity:cityName success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable data) {
        [MBProgressHUD hideHUD];

        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        [self.localDicts setObject:dict forKey:@"0"];
        // MJExtension框架里,字典转模型的方法
        ((ZSRPageView *)[self.pageViews firstObject]).mydata = [WeatherData mj_objectWithKeyValues:dict].data;
        [((ZSRPageView *)[self.pageViews firstObject]).tableView reloadData];
        [self reflashPageViews];
        
    }];
}

//网络改变
-(void)networkChange{
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态发生改变的时候调用这个block
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [self searchLocation];
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                [MBProgressHUD showError:@"无网络连接，请检查网络"];
                break;
                
            case AFNetworkReachabilityStatusUnknown:
                [MBProgressHUD showError:@"未知网络"];
                break;
            default:
                break;
        }
    }];
    [mgr startMonitoring];
}

// 分页控件的监听方法
- (void)pageChanged:(UIPageControl *)page
{
    NSLog(@"%ld", page.currentPage);
    // 根据页数，调整滚动视图中的图片位置 contentOffset
    CGFloat x = page.currentPage * self.scrollView.bounds.size.width;
    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)setupSubViews{
    UIImage *background = [UIImage imageNamed:@"bg1.jpg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:background];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView = backgroundImageView;
    [self.view addSubview:backgroundImageView];
    
    UIImageView *blurredImageView = [[UIImageView alloc] init];
    blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    blurredImageView.alpha = 0;
    [blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    self.blurredImageView = blurredImageView;
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.pageControl];
    for (ZSRPageView *pageView in self.pageViews) {
        [self.scrollView addSubview:pageView];
    }
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenW-44, ScreenH-44, 44, 44)];
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];
}

-(void)viewWillLayoutSubviews{
    CGRect bounds = self.view.bounds;
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
}

-(void)buttonClick{
    [self transferDataSourceTOEditController];
    [self presentViewController:self.editController animated:YES completion:nil];
}

//加载本地数据
-(void)loadRecond{
    //取出字典排序
    NSMutableDictionary *dicts = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *myKeys = [dicts allKeys];
    NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableArray *sortedValues = [[NSMutableArray alloc] init];
    for(id key in sortedKeys) {
        NSDictionary *dict = [dicts objectForKey:key];
        [sortedValues addObject:dict];
    }
    self.localDicts = dicts;
    for (int i = 0; i < dicts.count; i++) {
        ZSRPageView *pageView = [[ZSRPageView alloc] init];
        NSDictionary *dict = sortedValues[i];
        pageView.mydata = [WeatherData mj_objectWithKeyValues:dict].data;
        [pageView.tableView.mj_header beginRefreshing];
        [pageView.tableView reloadData];
        [self.pageViews addObject:pageView];
        [self.scrollView addSubview:pageView];
    }
    if (self.pageViews.count>0) {
        [self reflashPageViews];
    }else{
        ZSRPageView *pageView = [[ZSRPageView alloc] init];
        [self.pageViews addObject:pageView];
        [self.scrollView addSubview:pageView];
    }
}

#pragma mark - ZSREditControllerDelegate

-(void)editControllerView:(ZSREditController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.pageControl.currentPage = indexPath.row;
    self.scrollView.contentOffset = CGPointMake(ScreenW * indexPath.row, 0);
}

-(void)editControllerView:(ZSREditController *)controller deleteRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ZSRPageView *removeView =  self.pageViews[indexPath.row];
    [removeView removeFromSuperview];
    [self.pageViews removeObject:removeView];
    
    [self.localDicts removeObjectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
    NSMutableDictionary *dicts = [NSMutableDictionary dictionaryWithDictionary:self.localDicts];

    [self.localDicts removeAllObjects];
    
    NSArray *myKeys = [dicts allKeys];
    
    NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    for (int i = 0; i < sortedKeys.count; i++) {
        NSString *key = sortedKeys[i];
        
        NSDictionary *dict = [dicts objectForKey:key];
        [self.localDicts setObject:dict forKey:[NSString stringWithFormat:@"%d", i]];
    }
    
    for (ZSRPageView *pageView in self.pageViews) {
        [self.scrollView addSubview:pageView];
    }
    [self reflashPageViews];
}

#pragma mark - UIScrollViewDelegate
// 滚动视图停下来，修改页面控件的小点（页数）
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 计算页数
    int page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.pageControl.currentPage = page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = scrollView.bounds.size.height/2;
    CGFloat position = MAX(scrollView.contentOffset.x, 0.0);
    CGFloat percent = MIN(position / height, 1.0);
    self.blurredImageView.alpha = percent;
}



//刷新整个View
- (void)reflashPageViews {
    self.scrollView.contentSize = CGSizeMake(self.pageViews.count * self.scrollView.bounds.size.width, 0);
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(ZSRPageView *pageView, NSUInteger idx, BOOL *stop) {
        CGRect frame = pageView.frame;
        frame.origin.x = idx * frame.size.width ;
        pageView.frame = frame;
    }];
    self.scrollView.contentSize = CGSizeMake(self.pageViews.count * self.scrollView.bounds.size.width, 0);
    self.pageControl.numberOfPages = self.pageViews.count;
    [self transferDataSourceTOEditController];
}

-(void)transferDataSourceTOEditController{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    for (ZSRPageView *pageView in self.pageViews) {
        [array addObject:pageView.mydata];
    }
    self.editController.dataSource = array;
    [self.editController refreshDataSource];

}

#pragma mark - 通知
-(void)cityChange:(NSNotification*)note
{
    NSDictionary *userInfo = note.userInfo;
    NSString *cityName = [userInfo objectForKey:@"city"];
    
    for (ZSRPageView *pageView in self.pageViews) {
        if ([pageView.mydata.city isEqualToString:cityName]) {
            [MBProgressHUD showSuccess:@"此城市已添加"];
            return;
        }
    }
    [MBProgressHUD showMessage:@"正在添加..." toView:self.editController.view];

    ZSRPageView *pageView = [[ZSRPageView alloc] init];
    pageView.city = cityName;
    
    [ZSRHttpTool requestDataWithCity:cityName success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        [self.localDicts setObject:dict forKey:[NSString stringWithFormat:@"%ld", self.pageViews.count]];
        // MJExtension框架里,字典转模型的方法
        pageView.mydata = [WeatherData mj_objectWithKeyValues:dict].data;
        
        [self.pageViews addObject:pageView];
        [self.scrollView addSubview:pageView];
        [pageView.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.editController.view];
        [MBProgressHUD showSuccess:@"添加成功"];
        [self reflashPageViews];
    }];
}
/** 收到挂起通知做的动作*/
-(void)willResignActiveAction{
    [self.localDicts writeToFile:filePath atomically:YES];
}

-(void)loadMoreData{
    for (ZSRPageView *pageView in self.pageViews) {
        NSString *cityName =  pageView.mydata.city;
        [ZSRHttpTool requestDataWithCity:cityName success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            // MJExtension框架里,字典转模型的方法
            pageView.mydata = [WeatherData mj_objectWithKeyValues:dict].data;
            NSLog(@"%@",pageView.mydata.city);
            [self reflashPageViews];
            [pageView.tableView.mj_header endRefreshing];
        }];
    }
}

@end
