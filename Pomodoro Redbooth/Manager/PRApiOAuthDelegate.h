//
//  PRApiOAuthDelegate.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 07/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

@protocol PRApiOAuthDelegate

- (NSString *)refrehToken;

- (void)onOAuthNewToken:(id)json;

- (void)onOAuthUnauthorized;

- (BOOL)isTokenExpiredOrAboutToExpire;


@end