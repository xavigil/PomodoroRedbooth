//
//  PRApiManager.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 05/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface PRApiManager : AFHTTPSessionManager

+(PRApiManager *) sharedManager;

- (NSURL *)authorizationUrl;

- (void)grantAccessWithCode:(NSString *)code completion:(void(^)(NSError *error))completion;

- (void)taskListCompletion:(void(^)(NSArray *tasks, NSError *error))completion;

@end
