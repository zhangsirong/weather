//
//  ZSRResultsController.m
//  weather
//
//  Created by hp on 6/28/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRResultsController.h"
#import "ZSRArea.h"

@implementation ZSRResultsController
-(NSMutableArray *)exitCity{
    if (_exitCity == nil) {
        _exitCity = [NSMutableArray arrayWithCapacity:1];
    }
    return _exitCity;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredAreas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"cellID";
    static NSString *exitID = @"exitID";

    UITableViewCell *cell;

    ZSRArea *area = self.filteredAreas[indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    cell.detailTextLabel.text = @"";

    for (NSString *cityName in self.exitCity) {
        if ([cityName isEqualToString:area.namecn]) {
            cell = [tableView dequeueReusableCellWithIdentifier:exitID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:exitID];
            }
            cell.detailTextLabel.text = @"已添加";
            cell.userInteractionEnabled = NO;
        }
    }
    cell.textLabel.text = area.namecn;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = area.description;
    
    return cell;
}

@end
