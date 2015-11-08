//
//  PRTimerViewControllerDelegate.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 08/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

@protocol PRTimerViewControllerDelegate

- (UIViewController *)vc;

- (void)setTaskName:(NSString *)name;
- (void)setNumPomodoros:(NSInteger)value;

- (void)setFocusUI;
- (void)setBreakUI;

- (void)setTimerViewInterval:(NSNumber *)interval;
- (void)playTimerView;
- (void)resumeTimerView;
- (void)pauseTimerView;

- (void)showHUD;
- (void)hideHUD;

@end