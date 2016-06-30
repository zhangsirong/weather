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

@end

@implementation ZSREditController
-(NSMutableArray *)dataSource{
    if (_dataSource ==nil) {
        _dataSource = [NSMutableArray arrayWithCapacity:4];
    }
    return _dataSource;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    UIImage *background = [UIImage imageNamed:@"bg1.jpg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:background];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView = backgroundImageView;
    [self.view insertSubview:self.backgroundImageView atIndex:0];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 100,40)];
    [btn setTitle:@"添加城市" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addCity) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    label.text = @"添加／删除城市";
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor colorWithRed:230 green:230 blue:230 alpha:0.4];
    
    self.tableView.tableHeaderView = label;
    self.tableView.tableFooterView = btn;
    self.tableView.tableFooterView.backgroundColor = [UIColor greenColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

-(void)viewWillLayoutSubviews{
    CGRect bounds = self.view.bounds;
    self.backgroundImageView.frame = bounds;
}

-(void)addCity{
    ZSRAddCityController *Vc = [[ZSRAddCityController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:Vc];
    [self presentViewController:nav animated:YES completion:nil];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
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
    NSLog(@"%ld",indexPath.row);
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self.delegate respondsToSelector:@selector(editControllerView:deleteRowAtIndexPath:)]) {
            [self.delegate editControllerView:self deleteRowAtIndexPath:indexPath];
        }
        [self.tableView reloadData];
    }
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete;
}
@end
