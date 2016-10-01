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
@property (nonatomic, strong) NSTimer *myTimer;
@property (nonatomic, strong) NSString *status;


@end

@implementation ZSRMainViewController


static id _instance;

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    if (self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}



+ (id)allocWithZone:(struct _NSZone *)zone {
    if (_instance == nil) { // 防止创建多次
        _instance = [super allocWithZone:zone];
    }
    return _instance;
}

+ (instancetype)sharedMainViewController {

    if (_instance == nil) { // 防止创建多次
        _instance = [[self alloc] init];
    }
    return _instance;
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return _instance;
}


#pragma mark - getter
-(ZSREditController *)editController{
    if (_editController == nil) {
        _editController = [[ZSREditController alloc] init];
        _editController.delegate = self;
    }
    return _editController;
}

-(NSMutableArray *)citys{
    if (_citys == nil) {
        _citys = [NSMutableArray arrayWithCapacity:1];
    }
    return _citys;
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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg1.jpg"] forBarMetrics:UIBarMetricsCompact];
    self.navigationItem.hidesBackButton = YES;

    [self setupSubViews];
    BOOL login = [userDefault boolForKey:@"isLogin"];

    if (login) {
        [self loadRecond];
    }else{
        [self loadData];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveAction) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveAction) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMoreData) name:@"loadMoreData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCity) name:@"addcity" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChange:) name:networkChangeNotification object:nil];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [self.myTimer setFireDate:[NSDate distantFuture]];
    self.navigationController.navigationBarHidden = NO;
}
    
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
    
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![self.status isEqualToString:networkStatusEnable]) {
        [self.myTimer setFireDate:[NSDate distantPast]];
    }


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
    for (ZSRPageView *pageView in self.pageViews) {
        [self.scrollView addSubview:pageView];
    }
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.pageControl];

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
    [self.navigationController pushViewController:self.editController animated:YES];
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
        pageView.city = pageView.mydata.city;
        [self.citys addObject:pageView.city];

//        [pageView.tableView.mj_header beginRefreshing];
        
        [self.pageViews addObject:pageView];
        [self.scrollView addSubview:pageView];
    }
    [self reflashPageViews];
//    [self loadMoreData];
}



#pragma mark - ZSREditControllerDelegate

-(void)editControllerView:(ZSREditController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.pageControl.currentPage = indexPath.row;
    self.scrollView.contentOffset = CGPointMake(ScreenW * indexPath.row, 0);
}

-(void)editControllerView:(ZSREditController *)controller deleteRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ZSRPageView *removeView =  self.pageViews[indexPath.row];
    [self.citys removeObjectAtIndex:indexPath.row];
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
    [self transferDataSourceTOEditController];
  
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
/** 收到挂起通知做的动作*/
-(void)willResignActiveAction{
    if (self.localDicts.count > 0) {
        [self.localDicts writeToFile:filePath atomically:YES];
        [userDefault setBool:YES forKey:@"isLogin"];
    }else{
        [userDefault setBool:NO forKey:@"isLogin"];

    }
}

-(void)loadData{
    [self.pageViews removeAllObjects];
    [self.localDicts removeAllObjects];
    NSArray *subViews =  self.scrollView.subviews;
    for (UIView *view in subViews) {
        if ([view isKindOfClass:[ZSRPageView class]]) {
            [view removeFromSuperview];
        }
    }
    for (int i = 0;i<self.citys.count; i++) {
        NSString *city = self.citys[i];
        ZSRPageView *pageView = [[ZSRPageView alloc] initWithCity:city];
        [self.pageViews addObject:pageView];
        [self.scrollView addSubview:pageView];
        [ZSRHttpTool requestDataWithCity:city success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            [self.localDicts setObject:dict forKey:[NSString stringWithFormat:@"%d", i]];
            pageView.mydata = [WeatherData mj_objectWithKeyValues:dict].data;
            [pageView.tableView reloadData];
            [self reflashPageViews];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [MBProgressHUD showError:@"获取数据失败，请重试……"];
            
        }];
        
    }
    
}
-(void)addCity{
    [self loadData];
    self.pageControl.numberOfPages = self.citys.count;
    self.pageControl.currentPage = self.citys.count;
    self.scrollView.contentOffset = CGPointMake(ScreenW * self.citys.count, 0);
}

-(void)loadMoreData{
    [self.localDicts removeAllObjects];
    for (int i =0; i<self.pageViews.count; i++) {
        ZSRPageView *pageView = self.pageViews[i];
        NSString *cityName =  pageView.mydata.city;

        [ZSRHttpTool requestDataWithCity:cityName success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            [self.localDicts setObject:dict forKey:[NSString stringWithFormat:@"%d", i]];
            // MJExtension框架里,字典转模型的方法
            pageView.mydata = [WeatherData mj_objectWithKeyValues:dict].data;
            NSLog(@"%@",pageView.mydata.city);
            [self reflashPageViews];
            [pageView.tableView reloadData];
            [pageView.tableView.mj_header endRefreshing];
        }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull data) {
            
        }];
    }
}

-(void)networkChange:(NSNotification *)noti{
    NSDictionary *dict = noti.userInfo;
    self.status = [dict objectForKey:networkStatus];
    
    if ([self.status isEqualToString:networkStatusEnable]) {
        [self.myTimer setFireDate:[NSDate distantFuture]];
        for (ZSRPageView *pageView in self.pageViews) {
            [pageView.tableView.mj_header beginRefreshing];
        }
    }else{
        self.myTimer =  [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [self.myTimer setFireDate:[NSDate distantPast]];
        

    };
}

-(void)timerAction{
    for (ZSRPageView *pageView in self.pageViews) {
        [pageView.tableView.mj_header endRefreshing];
    }
    [MBProgressHUD showError:@"网络连接失败，请检查网络设置"];
}
@end
