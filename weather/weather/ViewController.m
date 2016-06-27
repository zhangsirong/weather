//
//  ViewController.m
//  weather
//
//  Created by hp on 6/23/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ViewController.h"
#import "Foundation+Log.h"
#import "area.h"
#import "ZSREditController.h"
#import "ZSRTadayView.h"
#import "ZSRPageView.h"
#import "MyData.h"
@interface ViewController ()<UIScrollViewDelegate,ZSREditControllerDelegate>

@property (nonatomic, strong) NSArray *areas;

@property (nonatomic, strong) ZSRTadayView *headerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, strong) NSMutableArray *myDatas;
@property (nonatomic, strong) ZSREditController *editController;


@end

@implementation ViewController


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
        // 取消弹簧效果
        _scrollView.bounces = YES;
        // 取消水平滚动条
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        // 要分页
        _scrollView.pagingEnabled = YES;
        // contentSize
        _scrollView.contentSize = CGSizeMake(3 * _scrollView.bounds.size.width, 0);
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



// 分页控件的监听方法
- (void)pageChanged:(UIPageControl *)page
{
    NSLog(@"%ld", page.currentPage);
    
    // 根据页数，调整滚动视图中的图片位置 contentOffset
    CGFloat x = page.currentPage * self.scrollView.bounds.size.width;
    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self requestData];
    [self setupSubViews];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.myDatas removeAllObjects];
    for (ZSRPageView *pageView in self.pageViews) {
        [self.scrollView addSubview:pageView];
        [self.myDatas addObject:pageView.mydata];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
-(void)setupSubViews{
    
    [self.view addSubview:self.scrollView];
    
    [self.view addSubview:self.pageControl];
    ZSRPageView *firstView = [[ZSRPageView alloc] initWithFrame:self.view.bounds];
    firstView.city = @"北京";
    ZSRPageView *secondView = [[ZSRPageView alloc] initWithFrame:self.view.bounds];
    secondView.city = @"广州";
    ZSRPageView *thirdView = [[ZSRPageView alloc] initWithFrame:self.view.bounds];
    thirdView.city = @"连平";

    [self.pageViews addObject:firstView];
    [self.pageViews addObject:secondView];
    [self.pageViews addObject:thirdView];
    
    for (ZSRPageView *pageView in self.pageViews) {
        [self.scrollView addSubview:pageView];
    }
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(ZSRPageView *pageView, NSUInteger idx, BOOL *stop) {
        
        CGRect frame = pageView.frame;
        frame.origin.x = idx * frame.size.width ;
        pageView.frame = frame;
    }];
    
    self.pageControl.numberOfPages = self.pageViews.count;
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(sWidth-44, sHeight-44, 44, 44)];
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];
    
    

}
-(void)buttonClick{
    self.editController.dataSource = self.myDatas;
    [self presentViewController:self.editController animated:YES completion:nil];
}

-(void)editControllerView:(ZSREditController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.pageControl.currentPage = indexPath.row;
    self.scrollView.contentOffset = CGPointMake(sWidth * indexPath.row, 0);
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
// 滚动视图停下来，修改页面控件的小点（页数）
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 计算页数
    int page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.pageControl.currentPage = page;
}
@end
