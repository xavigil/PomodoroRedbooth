//
//  PRKeychainManager.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 06/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRKeychainManager : NSObject

- (NSDictionary *) userAccessToken;
- (void) setUserAccessToken:(NSDictionary *)token;
- (void)resetUserToken;

@end
