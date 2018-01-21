//
//  ZSREditController.m
//  weather
//
//  Created by hp on 6/27/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSREditController.h"
#import "MyData.h"
#import "ZSRAddCityController.h"
@interface ZSREditController()<UITableViewDelegate,UITableViewDataSource, UITabBarDelegate>
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *footerView;
@end

@implementation ZSREditController
-(NSMutableArray *)dataSource{
    if (_dataSource ==nil) {
        _dataSource = [NSMutableArray arrayWithCapacity:4];
    }
    return _dataSource;
}

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, 80)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20, 20, _footerView.frame.size.width - 40, 45);
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [button.layer setBorderWidth:1.0];   //边框宽度
        [button setTitle:@"添加城市" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor greenColor]];
        [button addTarget:self action:@selector(addCity) forControlEvents:UIControlEventTouchUpInside];
        
        [_footerView addSubview:button];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 0, _footerView.frame.size.width - 10, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_footerView addSubview:line];
    }
    
    return _footerView;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    UIImage *background = [UIImage imageNamed:@"bg1.jpg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:background];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView = backgroundImageView;
    self.tableView.backgroundView = self.backgroundImageView;
    self.title = @"添加／删除城市";
    self.navigationItem.hidesBackButton = YES;
    self.tableView.tableFooterView = self.footerView;
    self.tableView.backgroundColor = [UIColor clearColor];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)viewWillLayoutSubviews{
    CGRect bounds = self.view.bounds;
    self.backgroundImageView.frame = bounds;
}

-(void)addCity{

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    for (MyData *data in self.dataSource) {
        [array addObject:data.city];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"editCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    MyData *myData = self.dataSource[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = myData.city;
    cell.detailTextLabel.text = [myData.wendu stringByAppendingString:@"°"];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.delegate respondsToSelector:@selector(editControllerView:didSelectRowAtIndexPath:)]) {
        [self.delegate editControllerView:self didSelectRowAtIndexPath:indexPath];
        [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }    
}


-(void)refreshDataSource{
    [self.tableView reloadData];
    
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
    
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self.delegate respondsToSelector:@selector(editControllerView:deleteRowAtIndexPath:)]) {
            [self.delegate editControllerView:self deleteRowAtIndexPath:indexPath];
        }
        [self.tableView reloadData];
    }
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataSource.count > 1) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;

}
@end
