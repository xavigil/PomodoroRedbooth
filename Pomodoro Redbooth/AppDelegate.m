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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setup];
    return YES;
}

- (void)setup
{
    PRApiOAuthManager *oauthDelegate = [[PRApiOAuthManager alloc] init];
    [[PRApiManager sharedManager] setOAuthDelegate:oauthDelegate];
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

@end
