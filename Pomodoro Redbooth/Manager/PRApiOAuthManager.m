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
    NSLog(@"token = %@", _token.accessToken);
}

- (void)parseAndUpdateNewToken:(id)json
{
    // parse
    PRToken *token = [[PRToken alloc] init];
    [token mts_setValuesForKeysWithDictionary:json];

    // update header
    [[PRApiManager sharedManager] setTokenToHTTPHeader:_token.accessToken];

    // keychain
    PRKeychainManager *keychain = [[PRKeychainManager alloc] init];
    [keychain setUserAccessToken:[token dictionary]];

    // ivar
    _token = token;

    NSLog(@"token = %@", _token.accessToken);
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

- (void)onOAuthNewToken:(id)json
{
    [self parseAndUpdateNewToken:json];
}

- (void)onOAuthUnauthorized
{
    [self resetToken];
}

- (BOOL)isTokenExpiredOrAboutToExpire
{
    if( !_token ) return YES;
    int offset = -60; // <-- We substract one minut to the actual expiring date to avoid problems in low connections.
    NSDate *expiringDateWithOffset = [NSDate dateWithTimeInterval:offset sinceDate:[_token expirationDate]];
    return ([expiringDateWithOffset compare:[NSDate date]] == NSOrderedAscending);
}


@end
