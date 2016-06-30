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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredAreas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    ZSRArea *area = self.filteredAreas[indexPath.row];
    cell.textLabel.text = area.description;
    return cell;
}

@end
