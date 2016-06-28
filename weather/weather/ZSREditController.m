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
@interface ZSREditController()<UITableViewDataSource,UITabBarDelegate>

@end

@implementation ZSREditController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width-40,40)];
    btn.backgroundColor = [UIColor greenColor];
    [btn setTitle:@"添加城市" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addCity) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = btn;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:ID];
    }
    MyData *myData = self.dataSource[indexPath.row];
    
    cell.textLabel.text = myData.city;
    cell.detailTextLabel.text = myData.wendu;
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
