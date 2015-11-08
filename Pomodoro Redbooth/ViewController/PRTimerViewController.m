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


@implementation PRTimerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.title = NSLocalizedString(@"timer_title", nil);
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"ic_close_white_36pt"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(onCancel)];
    
    self.timer.outerCircleThickness = [NSNumber numberWithFloat:20.0];
    self.timer.innerTrackColor = [UIColor grayColor];
    self.timer.outerTrackColor = [UIColor grayColor];
    
    self.timer.outerProgressColor = SECONDARY_COLOR;
    self.timer.innerProgressColor = SECONDARY_COLOR;
    self.timer.labelColor = [UIColor grayColor];
    
    self.timer.hideFraction = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timerTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.vTimerDummy addGestureRecognizer:tap];
    [self.vTimerDummy setUserInteractionEnabled:YES];
    
    [self.imgPlayback setBackgroundColor:[UIColor clearColor]];
    [self.imgPlayback setTintColor:SECONDARY_COLOR];
    
    [self.vTitleMarginLeft setBackgroundColor:SECONDARY_COLOR];
    [self.vTitleMarginRight setBackgroundColor:SECONDARY_COLOR];
    [self.lblTaskTitle setBackgroundColor:SECONDARY_COLOR];
    [self.lblTaskTitle setTextColor:[UIColor whiteColor]];
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

- (void)setTaskName:(NSString *)name
{
    [self.lblCurrentTask setText:name];
}

- (void)setTimerViewInterval:(NSNumber *)interval
{
    self.timer.intervals = @[interval];
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


#pragma mark - Private methods

- (void)timerTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self.interactor playbackTouch];
}

- (void)onCancel
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert_abandon_title", nil)
                                                                             message:NSLocalizedString(@"alert_abandon_message", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yes = [UIAlertAction
                          actionWithTitle:NSLocalizedString(@"yes", nil)
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {

                          }];
    UIAlertAction* no = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"no", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alertController dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alertController addAction:no];
    [alertController addAction:yes];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
