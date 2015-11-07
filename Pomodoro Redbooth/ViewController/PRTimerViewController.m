//
//  PRTimerViewController.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 05/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRTimerViewController.h"
#import "PRApiManager.h"
#import "PRUserDefaultsManager.h"
#import "PRTask.h"

@implementation PRTimerViewController

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"timer", nil);
}

- (IBAction)onGetTasks:(UIButton *)button
{
    [[PRApiManager sharedManager] changeStatus:@"resolved" toTaskId:20822879 completion:^(PRTask *task, NSError *error) {
        
    }];

//    NSInteger userId = [[PRUserDefaultsManager sharedManager] userId];
//    void(^taskListRequest)(NSInteger) = ^(NSInteger uid){
//        [[PRApiManager sharedManager] taskListAssignedToUserId:uid completion:^(NSArray *tasks, NSError *error){
//        }];
//    };
//    
//    if(userId>0){
//        taskListRequest(userId);
//    }
//    else
//    {
//        [[PRApiManager sharedManager]userInfoCompletion:^(PRUser *user, NSError *error) {
//            if(!error){
//                [[PRUserDefaultsManager sharedManager] setUserId:[user.id integerValue]];
//                taskListRequest([user.id integerValue]);
//            }
//        }];
//    }
}

@end
