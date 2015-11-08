//
//  ViewController.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 05/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRGetStartedViewController.h"
#import "PRApiManager.h"
#import "PRConstants.h"
#import "AppDelegate.h"
#import "PRInteractorDelegate.h"
#import "PRConstants.h"


@interface PRGetStartedViewController ()

@end

@implementation PRGetStartedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAuthorizationCodeReceived:)
                                                 name:PR_NOTIF_AUTHORIZATION_RECEIVED
                                               object:nil];
    if([PRApiManager sharedManager].delegate.token )
    {
        [self pushNextViewControllerAnimated:NO];
    }
}

- (void)setup
{
    [self.lblTItle setFont:FONT_GET_STARTED_TITLE];
    [self.lblTItle setText:@"POMODORO\nREDBOOTH"];
    [self.btnGetStarted setBackgroundColor:PRIMARY_COLOR];
    [self.btnGetStarted setTintColor:[UIColor whiteColor]];
    [self.btnGetStarted.titleLabel setFont:FONT_SECTIONS];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *bar = self.navigationController.navigationBar;
    bar.hidden = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private methods

- (void)onAuthorizationCodeReceived:(NSNotification *)notification
{
    NSString *code = [notification.userInfo objectForKey:PR_NOTIF_AUTHORIZATION_RECEIVED_PARAM_CODE];
    [[PRApiManager sharedManager] grantAccessWithCode:code completion:^(NSError *error) {
        if(!error)
        {
            [self pushNextViewControllerAnimated:YES];
        }
    }];
}

- (void)pushNextViewControllerAnimated:(BOOL)animated
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    id<PRInteractorDelegate> interactor = [appDelegate interactorForView:@"list"];
    [interactor presentViewFromViewController:self];
}

#pragma mark - IBActions

- (IBAction)onGetStarted:(UIButton *)btn
{
    [[UIApplication sharedApplication] openURL:[[PRApiManager sharedManager] authorizationUrl]];
}

@end
