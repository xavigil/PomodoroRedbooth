//
//  PRTaskListInteractorDelegate.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 08/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRTask.h"

@protocol PRTaskListInteractorDelegate

- (void)requestTasks;

- (void)showTimerForTask:(PRTask *)task;

- (void)logout;

@end