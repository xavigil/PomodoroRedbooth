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
#import "PRConstants.h"
#import <MBProgressHUD/MBProgressHUD.h>


@implementation PRTimerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.title = NSLocalizedString(@"timer_title", nil);
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"ic_close_white_36pt"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(onCancel)];
    
    self.timer.outerCircleThickness = [NSNumber numberWithFloat:20.0];
    self.timer.innerTrackColor = [UIColor grayColor];
    self.timer.outerTrackColor = [UIColor grayColor];
    self.timer.labelColor = [UIColor grayColor];
    self.timer.hideFraction = YES;
    self.timer.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timerTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.vTimerDummy addGestureRecognizer:tap];
    [self.vTimerDummy setUserInteractionEnabled:YES];
    
    [self.imgPlayback setBackgroundColor:[UIColor clearColor]];
    
    [self.lblPhase setFont:FONT_PHASE];
    [self.vTitleMarginLeft setBackgroundColor:SECONDARY_COLOR];
    [self.vTitleMarginRight setBackgroundColor:SECONDARY_COLOR];
    [self.lblTaskTitle setBackgroundColor:SECONDARY_COLOR];
    [self.lblTaskTitle setTextColor:[UIColor whiteColor]];
    [self.lblNumPomodoros setTextColor:[UIColor whiteColor]];
    [self.lblTaskTitle setFont:FONT_TITLE];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.interactor viewWillAppear];
}

#pragma mark - PRTimerViewControllerDelegate methods

- (UIViewController *)vc
{
    return self;
}

- (void)setFocusUI
{
    [self setUIForFocusMode:true];
}

- (void)setBreakUI
{
    [self setUIForFocusMode:false];
}

- (void)setTaskName:(NSString *)name
{
    [self.lblCurrentTask setText:name];
}

- (void)setNumPomodoros:(NSInteger)value
{
    [self.lblNumPomodoros setText:[NSString stringWithFormat:@"Pomodoros: %ld", value]];
}

- (void)setTimerViewInterval:(NSNumber *)interval
{
    [self.imgPlayback setImage:[UIImage imageNamed:@"ic_play_arrow_white_48pt"]];
    self.timer.intervals = @[interval];
    
    // Hack to show the next phase colors
    [self.timer start];
    [self.timer stop];
}

- (void)playTimerView
{
    [self.imgPlayback setImage:[UIImage imageNamed:@"ic_pause_white_48pt"]];
    [self.timer start];
}

- (void)resumeTimerView
{
    [self.imgPlayback setImage:[UIImage imageNamed:@"ic_pause_white_48pt"]];
    [self.timer resume];
}

- (void)pauseTimerView
{
    [self.imgPlayback setImage:[UIImage imageNamed:@"ic_play_arrow_white_48pt"]];
    [self.timer stop];
}

- (void)showHUD
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)hideHUD
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark - SFRoundProgressCounterViewDelegate methods

- (void)countdownDidEnd:(SFRoundProgressCounterView *)progressCounterView
{
    [self.interactor pomodoroPhaseFinished];
}

#pragma mark - Private methods

- (void)setUIForFocusMode:(BOOL)isFocusMode
{
    self.lblPhase.text = isFocusMode?NSLocalizedString(@"focus", nil):NSLocalizedString(@"break", nil);
    
    UIColor *color = isFocusMode?SECONDARY_COLOR:BREAK_MODE_COLOR;
    self.timer.outerProgressColor = color;
    self.timer.innerProgressColor = color;
    self.imgPlayback.tintColor = color;
    self.lblPhase.textColor = color;
}

- (void)timerTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self.interactor playbackTouch];
}

- (void)onCancel
{
    [self.timer stop];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:NSLocalizedString(@"alert_abandon_message", nil)
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* add_time = [UIAlertAction
                          actionWithTitle:NSLocalizedString(@"add_time", nil)
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [alertController dismissViewControllerAnimated:YES completion:nil];
                              [self.interactor addTimeSpentToTask];
                          }];
    UIAlertAction* add_time_and_resolve = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"add_time_and_resolve", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alertController dismissViewControllerAnimated:YES completion:nil];
                             [self.interactor addTimeSpentToTaskAndResolve];
                         }];
    
    UIAlertAction* just_exit = [UIAlertAction
                           actionWithTitle:NSLocalizedString(@"just_exit", nil)
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               [alertController dismissViewControllerAnimated:YES completion:nil];
                               [self.interactor exit];
                           }];
    
    UIAlertAction* cancel = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"cancel", nil)
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                    [self.timer resume];
                                }];
    
    [alertController addAction:add_time];
    [alertController addAction:add_time_and_resolve];
    [alertController addAction:just_exit];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
