//
//  PRApiManager.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 05/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "PRApiOAuthDelegate.h"

@interface PRApiManager : AFHTTPSessionManager

+(PRApiManager *) sharedManager;

- (void)setOAuthDelegate:(id<PRApiOAuthDelegate>)delegate;

- (NSURL *)authorizationUrl;

- (void)setTokenToHTTPHeader:(NSString *)token;

- (void)grantAccessWithCode:(NSString *)code completion:(void(^)(NSError *error))completion;

- (void)taskListCompletion:(void(^)(NSArray *tasks, NSError *error))completion;

@end
