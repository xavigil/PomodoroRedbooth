//
//  PRTimerViewController.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 05/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRTimerViewController.h"
#import "PRApiManager.h"

@implementation PRTimerViewController

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"timer", nil);
}

- (IBAction)onGetTasks:(UIButton *)button
{
    [[PRApiManager sharedManager] taskListCompletion:^(NSArray *tasks, NSError *error) {
        
    }];
}

@end
