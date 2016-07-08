//
//  ZSRAddCityController.m
//  weather
//
//  Created by hp on 6/28/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRAddCityController.h"
#import "ZSRResultsController.h"
#import "ZSRArea.h"
#import "ZSRCityView.h"
#import "ZSRMainViewController.h"
#import "INTULocationManager.h"
@interface ZSRAddCityController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating,ZSRCityViewDelegate>

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) ZSRResultsController *resultsController;

@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, copy) NSArray *areas;
@property (nonatomic, strong) ZSRCityView *cityView;
@property(nonatomic ,strong) NSMutableArray *exitCity;

@end


@implementation ZSRAddCityController

-(NSMutableArray *)exitCity{
    if (_exitCity == nil) {
        _exitCity = [NSMutableArray arrayWithCapacity:1];
    }
    return _exitCity;
}
-(ZSRCityView *)cityView{
    if (_cityView == nil) {
        _cityView = [[ZSRCityView alloc] initWithFrame:CGRectMake(20, 50, ScreenW-40, ScreenH)];
        _cityView.delegate = self;
    }
    return _cityView;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupSubViews];
    self.areas = [ZSRArea areaList];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.exitCity = [ZSRMainViewController sharedMainViewController].citys;
    self.resultsController.exitCity = self.exitCity;
    for (UIButton *btn in self.cityView.cityButtons) {
        for (NSString *cityName in self.exitCity) {
            if ([cityName isEqualToString:btn.titleLabel.text]) {
                btn.selected = YES;
                btn.userInteractionEnabled=NO;
                break;
            }else{
                btn.selected = NO;
                btn.userInteractionEnabled=YES;
            }
        }
    }
    self.searchController.searchBar.text = @"";
}

-(void)setupSubViews{
    
    self.view.backgroundColor = [UIColor clearColor];
    UIImage *background = [UIImage imageNamed:@"bg1.jpg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:background];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView = backgroundImageView;
    [self.view insertSubview:self.backgroundImageView atIndex:0];
    
    _resultsController = [[ZSRResultsController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsController];
    
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.resultsController.tableView.delegate = self;
    self.resultsController.tableView.backgroundColor = [UIColor clearColor];
    self.resultsController.tableView.tableFooterView = [[UIView alloc] init];
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    self.searchController.searchBar.placeholder = @"输入城市中文或拼音";
    [self.searchController.searchBar becomeFirstResponder];
    self.definesPresentationContext = YES;
    
    [self.view addSubview:self.cityView];
    self.title = @"添加城市";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}

-(void)viewWillLayoutSubviews{
    CGRect bounds = self.view.bounds;
    self.backgroundImageView.frame = bounds;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text = @"";
    ZSRMainViewController *mainController = [ZSRMainViewController sharedMainViewController];
    if (mainController.citys.count >0) {
        [self.navigationController pushViewController:mainController animated:YES];

    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    BOOL isLogin = YES;
//    [userDefault setBool:isLogin forKey:@"isLogin"];
    ZSRArea *area = self.resultsController.filteredAreas[indexPath.row];
    ZSRMainViewController *mainController = [ZSRMainViewController sharedMainViewController];
    [mainController.citys addObject:area.namecn];
    [self.navigationController pushViewController:mainController animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addcity" object:nil];

}
#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.areas mutableCopy];
    
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.cityView.hidden = NO;
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        self.cityView.hidden = YES;
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"nameen"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        
        NSExpression *lhs2 = [NSExpression expressionForKeyPath:@"namecn"];
        NSPredicate *finalPredicate2 = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs2
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        
        [searchItemsPredicate addObject:finalPredicate];
        [searchItemsPredicate addObject:finalPredicate2];

        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
    ZSRResultsController *tableController = (ZSRResultsController *)self.searchController.searchResultsController;
    
    tableController.filteredAreas = searchResults;
    [tableController.tableView reloadData];
}

-(void)cityView:(ZSRCityView *)cityView didClickButton:(UIButton *)button{
    
    
    if ([button.titleLabel.text isEqualToString:@"定位"]) {
        [self searchLocation];
    }else{
        [self.searchController.searchBar becomeFirstResponder];
        self.searchController.searchBar.text = button.titleLabel.text;
    }
}


#pragma mark - 定位


- (void)searchLocation {
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:10.0 delayUntilAuthorized:YES block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        //定位成功 到网络获取数据
        if (status == INTULocationStatusSuccess) {
            [[[CLGeocoder alloc] init] reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                if(!error){
                    for (CLPlacemark *placemark in placemarks) {
                        NSLog(@"%@ %@ %f %f", placemark.subLocality, placemark.addressDictionary, placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
                       [self locationSuccess:placemark];
                    }
                }else{
                    [self showAlertController:@"定位失败，请手动选择城市"];
                }
            }];
        }else if (status == INTULocationStatusServicesDenied){
            [self showAlertController:@"打开定位权限才可以定位哦"];
            
        }else{
            [self showAlertController:@"请检查定位权限或者手动选择城市"];
        }
    }];
}

- (void)showAlertController:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"定位失败" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)locationSuccess:(CLPlacemark *)placemark {
    [MBProgressHUD showSuccess:@"定位成功"];
    NSString *cityName = @"";
    NSString *realSubLocality = [placemark.subLocality substringWithRange:NSMakeRange(0, placemark.subLocality.length-1)];
    NSString *realCity = [placemark.locality substringWithRange:NSMakeRange(0, placemark.locality.length-1)];
    
    for (ZSRArea *area in self.areas) {
        cityName = [area.namecn isEqualToString:realSubLocality] ? realSubLocality : realCity;
    }
    if(cityName == NULL){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"不支持该定位城市" message:@"请选择中国大陆内的城市，谢谢" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    [self.searchController.searchBar becomeFirstResponder];
    self.searchController.searchBar.text = cityName;
}

@end
