//
//  PRTaskListViewControllerDelegate.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 08/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

@protocol PRTaskListViewControllerDelegate

- (UIViewController *)vc;

- (void)showSpinner;

- (void)showTasksInSections:(NSDictionary *)tasksSections;

@end