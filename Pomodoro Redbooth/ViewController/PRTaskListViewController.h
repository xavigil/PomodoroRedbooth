//
//  PRTaskListViewController.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 07/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PRTaskListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (void)showTasksInSections:(NSDictionary *)taskSections;

@end
