//
//  ZSREditController.m
//  weather
//
//  Created by hp on 6/27/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSREditController.h"
#import "MyData.h"
@interface ZSREditController()<UITableViewDataSource,UITabBarDelegate>



@end

@implementation ZSREditController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
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


@end
