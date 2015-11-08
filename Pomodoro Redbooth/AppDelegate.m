//
//  AppDelegate.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 05/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "AppDelegate.h"
#import "PRApiManager.h"
#import "PRApiOAuthManager.h"
#import "PRConstants.h"
#import "PRApiOAuthManager.h"
#import "PRUserDefaultsManager.h"
#import "PRTaskListInteractor.h"
#import "PRTaskListViewControllerDelegate.h"
#import "PRTaskListViewController.h"
#import "PRTimerInteractor.h"
#import "PRTimerViewControllerDelegate.h"
#import "PRTimerViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setup];
    [self setupAppearance];
    return YES;
}

- (void)setup
{
    PRApiOAuthManager *oauthDelegate = [[PRApiOAuthManager alloc] init];
    [PRApiManager sharedManager].delegate = oauthDelegate;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kPRNotificationUnAuthorized
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [((UINavigationController *)self.window.rootViewController) popToRootViewControllerAnimated:YES];
            [[PRUserDefaultsManager sharedManager] setUserId:-1];
        });
    }];
}

- (void)setupAppearance
{
    
    [[UINavigationBar appearance] setBarTintColor:PRIMARY_COLOR];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                           FONT_TITLE, NSFontAttributeName, nil]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    NSLog(@"url=%@", url);
    if(![[url host] isEqualToString:@"return-uri"]) return NO;
    
    NSArray *components = [[url query] componentsSeparatedByString:@"="];
    if(!components) return NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PR_NOTIF_AUTHORIZATION_RECEIVED
                                                        object:self
                                                      userInfo:@{PR_NOTIF_AUTHORIZATION_RECEIVED_PARAM_CODE:components[1]}];
    return YES;
}

- (id<PRInteractorDelegate>)interactorForView:(NSString *)view
{
    id<PRInteractorDelegate> delegate;
    if([view isEqualToString:@"list"])
    {
        delegate = [[PRTaskListInteractor alloc]init];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PRTaskListViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"task_list"];
        vc.interactor = (PRTaskListInteractor *)delegate;
        ((PRTaskListInteractor *)delegate).vcDelegate = vc;
    }
    else if([view isEqualToString:@"timer"])
    {
        delegate = [[PRTimerInteractor alloc]init];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PRTimerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"timer"];
        vc.interactor = (PRTimerInteractor *)delegate;
        ((PRTimerInteractor *)delegate).vcDelegate = vc;
    }
    return delegate;
}

@end
