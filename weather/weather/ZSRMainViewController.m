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
#import "ZSRTadayView.h"
#import "ZSRPageView.h"
#import "MyData.h"
#import "INTULocationManager.h"


@interface ZSRMainViewController ()<UIScrollViewDelegate,ZSREditControllerDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *areas;

@property (nonatomic, strong) ZSRTadayView *headerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, strong) NSMutableArray *myDatas;
@property (nonatomic, strong) ZSREditController *editController;
@property (nonatomic, strong) CLPlacemark* placemark;

@end

@implementation ZSRMainViewController


-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    if (self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}
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

-(NSMutableArray *)myDatas{
    if (_myDatas ==nil) {
        _myDatas = [NSMutableArray arrayWithCapacity:1];
    }
    return _myDatas;
}

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, sWidth, self.view.frame.size.height)];
        _scrollView.backgroundColor = [UIColor redColor];
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
        
        _pageControl.bounds = CGRectMake(0, 0, sWidth-44, 44);
        
        _pageControl.center = CGPointMake(self.view.center.x, sHeight-20);
        
        // 设置颜色
        _pageControl.pageIndicatorTintColor = [UIColor redColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        
        
        // 添加监听方法
        /** 在OC中，绝大多数"控件"，都可以监听UIControlEventValueChanged事件，button除外" */
        [_pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.areas = [ZSRArea areaList];
    [self searchLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityChange:) name:@"CityChange" object:nil];

  }

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    
}

- (void)searchLocation {
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:10.0 delayUntilAuthorized:YES block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        if (status == INTULocationStatusSuccess) {
            [[[CLGeocoder alloc] init] reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                for (CLPlacemark *placemark in placemarks) {
                    self.placemark = placemark;
                    NSLog(@"%@ %@ %f %f", placemark.subLocality, placemark.addressDictionary, placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
                    [self setupSubViews];
                }
            }];
        }
        else if (status == INTULocationStatusTimedOut) {
            
        }
        else {
        }
        
    }];
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
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.pageControl];
    
    NSString *cityName = @"";
    NSString *realSubLocality = [self.placemark.subLocality substringWithRange:NSMakeRange(0, self.placemark.subLocality.length-1)];
    NSString *realCity = [self.placemark.locality substringWithRange:NSMakeRange(0, self.placemark.locality.length-1)];
    
    for (ZSRArea *area in self.areas) {
        cityName = [area.namecn isEqualToString:realSubLocality] ? realSubLocality : realCity;
    }
    ZSRPageView *firstView = [[ZSRPageView alloc] initWithCity:cityName];



    [self.pageViews addObject:firstView];
    
    for (ZSRPageView *pageView in self.pageViews) {
        [self.scrollView addSubview:pageView];
    }
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(ZSRPageView *pageView, NSUInteger idx, BOOL *stop) {
        
        CGRect frame = pageView.frame;
        frame.origin.x = idx * frame.size.width ;
        pageView.frame = frame;
    }];
    self.scrollView.contentSize = CGSizeMake(self.pageViews.count * self.scrollView.bounds.size.width, 0);
    self.pageControl.numberOfPages = self.pageViews.count;
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(sWidth-44, sHeight-44, 44, 44)];
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];
}

-(void)buttonClick{
    
    [self.myDatas removeAllObjects];
    for (ZSRPageView *pageView in self.pageViews) {
        [self.scrollView addSubview:pageView];
        [self.myDatas addObject:pageView.mydata];
    }
    self.editController.dataSource = self.myDatas;
    [self presentViewController:self.editController animated:YES completion:nil];
}


#pragma mark - ZSREditControllerDelegate

-(void)editControllerView:(ZSREditController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.pageControl.currentPage = indexPath.row;
    self.scrollView.contentOffset = CGPointMake(sWidth * indexPath.row, 0);
}

-(void)editControllerView:(ZSREditController *)controller deleteRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.myDatas removeObjectAtIndex:indexPath.row];
    
    ZSRPageView *removeView =  self.pageViews[indexPath.row];
    [removeView removeFromSuperview];
    
    [self.pageViews removeObject:removeView];
    
    for (ZSRPageView *pageView in self.pageViews) {
        [self.scrollView addSubview:pageView];
    }
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(ZSRPageView *pageView, NSUInteger idx, BOOL *stop) {
        
        CGRect frame = pageView.frame;
        frame.origin.x = idx * frame.size.width ;
        pageView.frame = frame;
    }];
    self.scrollView.contentSize = CGSizeMake(self.pageViews.count * self.scrollView.bounds.size.width, 0);
    self.pageControl.numberOfPages = self.pageViews.count;

    
    
    
}

#pragma mark - UIScrollViewDelegate
// 滚动视图停下来，修改页面控件的小点（页数）
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 计算页数
    int page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.pageControl.currentPage = page;
}

#pragma mark - 城市改变通知
-(void)cityChange:(NSNotification*)note
{
    NSDictionary *userInfo = note.userInfo;
    NSString *cityName = [userInfo objectForKey:@"city"];
    ZSRPageView *pageView = [[ZSRPageView alloc] initWithCity:cityName];
    [pageView requestData:cityName completion:^{
        
        [self.myDatas addObject:pageView.mydata];
        self.editController.dataSource = self.myDatas;
        [self.editController refreshDataSource];

    }];
    CGRect frame = pageView.frame;
    frame.origin.x = self.pageViews.count * frame.size.width;
    pageView.frame = frame;
    
    [self.pageViews addObject:pageView];
    self.pageControl.numberOfPages  = self.pageViews.count;
    _scrollView.contentSize = CGSizeMake(self.pageViews.count * _scrollView.bounds.size.width, 0);
    [self.scrollView addSubview:pageView];
}


@end
