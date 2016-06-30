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
@interface ZSRAddCityController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) ZSRResultsController *resultsController;

@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, copy) NSArray *areas;

@end


@implementation ZSRAddCityController


-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupSubViews];
    self.areas = [ZSRArea areaList];
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
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    self.searchController.searchBar.placeholder = @"输入城市中文或拼音";
    [self.searchController.searchBar becomeFirstResponder];
    self.definesPresentationContext = YES;
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    return NULL;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ZSRArea *area = self.resultsController.filteredAreas[indexPath.row];
    NSDictionary *dict = @{@"city":area.namecn};
    NSLog(@"%@",area);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CityChange" object:nil userInfo:dict];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.areas mutableCopy];
    
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
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

@end
