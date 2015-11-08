//
//  PRTaskListViewController.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 07/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRTaskListViewControllerDelegate.h"
#import "PRTaskListInteractorDelegate.h"

@interface PRTaskListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, PRTaskListViewControllerDelegate>

@property (nonatomic, strong) id<PRTaskListInteractorDelegate> interactor;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
