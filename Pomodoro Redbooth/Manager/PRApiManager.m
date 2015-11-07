//
//  PRApiManager.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 05/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRApiManager.h"
#import <Motis/Motis.h>
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
    id<PRApiOAuthDelegate> _delegate;
    BOOL _isTokenBeingRefreshed;
    NSOperationQueue *_requestQueue;
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
        [self setup];
    }
    return self;
}

- (void)setup
{
    _isTokenBeingRefreshed = NO;
    
    _requestQueue = [[NSOperationQueue alloc]init];
    [_requestQueue setMaxConcurrentOperationCount:1];
    [_requestQueue setSuspended:YES];
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
}

- (void)setOAuthDelegate:(id)delegate
{
    _delegate = delegate;
}

- (NSURL *)authorizationUrl
{
    return [NSURL URLWithString:kPRAuthorizationUrl];
}

- (void)setTokenToHTTPHeader:(NSString *)token
{
    NSLog(@"setTokenToHTTPHeader = %@", token);
    NSString *authHeader = @"Authorization";
    if(token)
        [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:authHeader];
    else
        [self.requestSerializer setValue:nil forHTTPHeaderField:authHeader];
}

- (void)grantAccessWithCode:(NSString *)code completion:(void (^)(NSError *))completion
{
    NSAssert(completion, @"completion can't be nil");
    
    NSDictionary *params = @{@"client_id":kPRClientId,
                             @"client_secret":kPRClientSecret,
                             @"code":code,
                             @"grant_type":@"authorization_code",
                             @"redirect_uri":kPRRedirectUri};

    [self POST:kPRAuthentication parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [_delegate onOAuthNewToken:responseObject];
        completion(nil);
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(error);
    }];
}

#pragma mark - Requests with token

- (void)taskListCompletion:(void (^)(NSArray *, NSError *))completion
{
    NSAssert(completion, @"completion can't be nil");
    
    [self runAuthRequestBlock:^{
        [self pr_taskListCompletion:completion];
    }];
}

#pragma mark - Private methods

- (NSString *)urlWithPath:(NSString *)path queryParams:(NSString *)params
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kPRApiVersion, path];
    if(params){
        url = [url stringByAppendingString:[NSString stringWithFormat:@"?%@",params]];
    }
    return url;
}

- (void)runAuthRequestBlock:(void(^)(void))request
{
    if([_delegate isTokenExpiredOrAboutToExpire])
    {
        if(!_isTokenBeingRefreshed){
            [self refreshToken:[_delegate refrehToken]];
        }
        [_requestQueue setSuspended:YES];
        [_requestQueue addOperationWithBlock:request];
    }
    else{
        request();
    }
}

- (void)refreshToken:(NSString *)refreshToken
{
    NSLog(@"refreshing token...");
    _isTokenBeingRefreshed = YES;
    NSDictionary *params = @{@"client_id":kPRClientId,
                             @"client_secret":kPRClientSecret,
                             @"refresh_token":refreshToken,
                             @"grant_type":@"refresh_token"};
    
    [self POST:kPRAuthentication parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [_delegate onOAuthNewToken:responseObject];
        _isTokenBeingRefreshed = NO;
        [_requestQueue setSuspended:NO];
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        [_delegate onOAuthUnauthorized];
        _isTokenBeingRefreshed = NO;
        [_requestQueue cancelAllOperations];
        [_requestQueue setSuspended:NO];
        
    }];
}

 /**
  * Checks the returned error looking for unathorized responses
  */
- (void)runFailureBlock:(void(^)(void))block forOperationResponse:(AFHTTPRequestOperation *)operation
{
    if(operation.response.statusCode == 401){
        [_delegate onOAuthUnauthorized];
    }
    else{
        if(block) block();
    }
}

#pragma mark - Private requests

- (void)pr_taskListCompletion:(void (^)(NSArray *, NSError *))completion
{
    NSString *params = @"assigned_user_id=469981&status=open";
    [self GET:[self urlWithPath:kPRTaskList queryParams:params] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"tasks = %@", responseObject);
        NSMutableArray *tasks = [@[]mutableCopy];
        for(id taskJson in responseObject)
        {
            PRTask *task = [[PRTask alloc]init];
            [task mts_setValuesForKeysWithDictionary:taskJson];
            [tasks addObject:task];
        }
        completion([tasks copy], nil);
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        [self runFailureBlock:^{
            completion(nil, error);
        } forOperationResponse:operation];
    }];
}

@end
