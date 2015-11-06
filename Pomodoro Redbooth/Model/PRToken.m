//
//  PRToken.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 06/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRToken.h"
#import <Motis/Motis.h>


NSString * const kPRTokenAccessToken      = @"access_token";
NSString * const kPRTokenExpiresIn        = @"expires_in";
NSString * const kPRTokenRefreshToken     = @"refresh_token";
NSString * const kPRTokenScope            = @"scope";
NSString * const kPRTokenTokenType        = @"token_type";
NSString * const kPRTokenCreationDate     = @"creation_date";

@interface PRToken()
{
    NSDate *_creation;
}

@end

@implementation PRToken

+ (NSDictionary*)mts_mapping
{
    return @{kPRTokenAccessToken: mts_key(accessToken),
             kPRTokenExpiresIn: mts_key(expiresIn),
             kPRTokenRefreshToken: mts_key(refreshToken),
             kPRTokenTokenType: mts_key(tokenType),
             kPRTokenScope: mts_key(scope),
             };
}

- (id)init
{
    self = [super init];
    if(self)
    {
        _creation = [NSDate date];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if(!dictionary) return nil;
    self = [super init];
    if(self)
    {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init] ;
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
        _creation = [dateFormatter dateFromString:dictionary[kPRTokenCreationDate]];
        _accessToken = dictionary[kPRTokenAccessToken];
        _expiresIn = @([dictionary[kPRTokenExpiresIn] integerValue]);
        _refreshToken = dictionary[kPRTokenRefreshToken];
        _tokenType = dictionary[kPRTokenTokenType];
        _scope = dictionary[kPRTokenScope];
    }
    return self;
}

- (NSDate *)expirationDate
{
    return [NSDate dateWithTimeInterval:[self.expiresIn integerValue] sinceDate:_creation];
}

- (NSDictionary *)dictionary
{
    return @{
             kPRTokenAccessToken: self.accessToken,
             kPRTokenExpiresIn: self.expiresIn,
             kPRTokenRefreshToken: self.refreshToken,
             kPRTokenTokenType: self.tokenType,
             kPRTokenScope: self.scope,
             kPRTokenCreationDate: _creation,
             };
}

@end
