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
#import "PRUser.h"
#import "PRTask.h"

@interface PRApiManager : AFHTTPSessionManager

@property(nonatomic, strong) id<PRApiOAuthDelegate> delegate;

+(PRApiManager *) sharedManager;

- (NSURL *)authorizationUrl;

- (void)setTokenToHTTPHeader:(NSString *)token;

- (void)grantAccessWithCode:(NSString *)code completion:(void(^)(NSError *error))completion;

- (void)userInfoCompletion:(void(^)(PRUser *user, NSError *error))completion;

- (void)taskListAssignedToUserId:(NSInteger)userId completion:(void (^)(NSArray *tasks, NSError *error))completion;

- (void)addTimeSpent:(NSInteger)minutes toTaskId:(NSInteger)taskId completion:(void (^)(NSError *error))completion;

- (void)changeStatus:(NSString *)newStatus toTaskId:(NSInteger)taskId completion:(void (^)(PRTask *task, NSError *error))completion;

@end
