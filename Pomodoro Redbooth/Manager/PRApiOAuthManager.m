//
//  PRApiOAuthManager.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 07/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRApiOAuthManager.h"
#import <Motis/Motis.h>
#import "PRKeychainManager.h"
#import "PRApiManager.h"
#import "PRToken.h"

NSString * const kPRNotificationUnAuthorized = @"unauthorized";

@interface PRApiOAuthManager()
{
    PRToken *_token;
}

@end

@implementation PRApiOAuthManager

- (id)init
{
    self = [super init];
    if(self)
    {
        [self setup];
    }
    return self;
}

#pragma mark - Private methods

- (void)setup
{
    PRKeychainManager *keychain = [[PRKeychainManager alloc] init];
    _token = [[PRToken alloc] initWithDictionary:[keychain userAccessToken]];
    [[PRApiManager sharedManager] setTokenToHTTPHeader:_token.accessToken];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"logout" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self onOAuthUnauthorized];
    }];
}

- (void)parseAndUpdateNewToken:(id)json
{
    // parse
    PRToken *token = [[PRToken alloc] init];
    [token mts_setValuesForKeysWithDictionary:json];
    
    // ivar
    _token = token;

    // update header
    [[PRApiManager sharedManager] setTokenToHTTPHeader:_token.accessToken];

    // keychain
    PRKeychainManager *keychain = [[PRKeychainManager alloc] init];
    [keychain setUserAccessToken:[token dictionary]];
}

- (void)resetToken
{
    // keychain
    PRKeychainManager *keychain = [[PRKeychainManager alloc] init];
    [keychain resetUserToken];
    
    // update header
    [[PRApiManager sharedManager] setTokenToHTTPHeader:nil];
    
    // ivar
    _token = nil;
}

#pragma mark - PRApiOAuthDelegate methods

- (NSString *)token
{
    return _token.accessToken;
}

- (NSString *)refrehToken
{
    return _token.refreshToken;
}

- (void)onOAuthNewToken:(id)json
{
    [self parseAndUpdateNewToken:json];
}

- (void)onOAuthUnauthorized
{
    [self resetToken];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPRNotificationUnAuthorized object:self userInfo:nil];
}

- (BOOL)isTokenExpiredOrAboutToExpire
{
    if( !_token ) return YES;
    int offset = -60; // <-- We substract one minut to the actual expiring date to avoid problems in low connections.
    NSDate *expiringDateWithOffset = [NSDate dateWithTimeInterval:offset sinceDate:[_token expirationDate]];
    return ([expiringDateWithOffset compare:[NSDate date]] == NSOrderedAscending);
}


@end
