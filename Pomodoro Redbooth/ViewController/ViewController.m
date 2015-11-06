//
//  ViewController.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 05/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "ViewController.h"
#import "PRApiManager.h"
#import "PRConstants.h"
#import "PRTimerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAuthorizationCodeReceived:)
                                                 name:PR_NOTIF_AUTHORIZATION_RECEIVED
                                               object:nil];
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
            [self.navigationController
             pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"timer_vc"]
             animated:YES];
        }
    }];
}

#pragma mark - IBActions

- (IBAction)onGetStarted:(UIButton *)btn
{
    [[UIApplication sharedApplication] openURL:[[PRApiManager sharedManager] authorizationUrl]];
}

@end
