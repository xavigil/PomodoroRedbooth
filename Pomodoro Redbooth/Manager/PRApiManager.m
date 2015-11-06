//
//  PRApiManager.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 05/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRApiManager.h"
#import <Motis/Motis.h>
#import "PRKeychainManager.h"
#import "PRToken.h"
#import "PRTask.h"

NSString * const kPRHost = @"https://redbooth.com";
NSString * const kPRApiVersion = @"api/3/";

NSString * const kPRAuthorization = @"oauth2/authorize";
NSString * const kPRAuthentication = @"oauth2/token";

NSString * const kPRTaskList = @"tasks";

NSString * const kPRClientId = @"2d7b763a04c61aead033059a3027ef5ed6b09391701e6aa3e95173d222078b41";
NSString * const kPRClientSecret = @"8c58a8cfb74b366b9cf9f97c2916114d4da1b804db409f35194b3b7d5be96b36";
NSString * const kPRRedirectUri = @"pomodoro-redbooth://return-uri";

NSString * const kPRAuthorizationUrl = @"https://redbooth.com/oauth2/authorize?client_id=2d7b763a04c61aead033059a3027ef5ed6b09391701e6aa3e95173d222078b41&redirect_uri=pomodoro-redbooth%3A%2F%2Freturn-uri&response_type=code";

@interface PRApiManager()
{
    PRToken *_token;
}

@end

@implementation PRApiManager

+(PRApiManager *) sharedManager
{
    static PRApiManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once( &oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:kPRHost]];
    if(self)
    {
        PRKeychainManager *keychain = [[PRKeychainManager alloc] init];
        _token = [[PRToken alloc] initWithDictionary:[keychain userAccessToken]];
        NSLog(@"token = %@", _token.accessToken);
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

- (NSURL *)authorizationUrl
{
    return [NSURL URLWithString:kPRAuthorizationUrl];
}

- (void)grantAccessWithCode:(NSString *)code completion:(void (^)(NSError *))completion
{
    NSAssert(completion, @"completion can't be nil");
    NSDictionary *params = @{@"client_id":kPRClientId,
                             @"client_secret":kPRClientSecret,
                             @"code":code,
                             @"grant_type":@"authorization_code",
                             @"redirect_uri":kPRRedirectUri};
    [self POST:kPRAuthentication parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject)
    {
        [self parseAndUpdateNewToken:responseObject];
        completion(nil);
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        completion(error);
    }];
}

#pragma mark - Requests with token

- (void)taskListCompletion:(void (^)(NSArray *, NSError *))completion
{
    NSAssert(completion, @"completion can't be nil");
    NSString *params = @"assigned_user_id=469981&status=open";
    [self GET:[self urlWithPath:kPRTaskList queryParams:params] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject)
     {
         NSLog(@"tasks = %@", responseObject);
         NSMutableArray *tasks = [@[]mutableCopy];
         for(id taskJson in responseObject)
         {
             PRTask *task = [[PRTask alloc]init];
             [task mts_setValuesForKeysWithDictionary:taskJson];
             [tasks addObject:task];
         }
         completion([tasks copy], nil);
         
     } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
         completion(nil, error);
     }];
}

#pragma mark - Private methods

- (NSString *)urlWithPath:(NSString *)path queryParams:(NSString *)params
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kPRApiVersion, path];
    if(params)
    {
        url = [url stringByAppendingString:[NSString stringWithFormat:@"?%@",params]];
    }
    return url;
}

- (BOOL)isTokenExpiredOrAboutToExpire:(PRToken *)token
{
    if( !token ) return YES;
    int offset = -60; // <-- We substract one minut to the actual expiring date to avoid problems in low connections.
    NSDate *expiringDateWithOffset = [NSDate dateWithTimeInterval:offset sinceDate:[token expirationDate]];
    return ([expiringDateWithOffset compare:[NSDate date]] == NSOrderedAscending);
}

- (void)parseAndUpdateNewToken:(id)json
{
    // parse
    PRToken *token = [[PRToken alloc] init];
    [token mts_setValuesForKeysWithDictionary:json];
    
    // update header
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token.accessToken] forHTTPHeaderField:@"Authorization"];
    
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
    [self.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
    
    // ivar
    _token = nil;
}

@end
