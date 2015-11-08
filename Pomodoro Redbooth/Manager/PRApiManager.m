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

NSString * const kPRUserInfo = @"me";
NSString * const kPRTasks = @"tasks";
NSString * const kPRComments = @"comments";

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
    
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
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

    [self POST:kPRAuthentication parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [_delegate onOAuthNewToken:responseObject];
        completion(nil);
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        completion(error);
    }];
}

#pragma mark - Requests with token

- (void)userInfoCompletion:(void (^)(PRUser *, NSError *))completion
{
    NSAssert(completion, @"completion can't be nil");
    [self runAuthRequestBlock:^{
        [self pr_userInfoCompletion:completion];
    }];
}

- (void)taskListAssignedToUserId:(NSInteger)userId completion:(void (^)(NSArray *, NSError *))completion
{
    NSAssert(completion, @"completion can't be nil");
    [self runAuthRequestBlock:^{
        [self pr_taskListAssignedToUserId:userId completion:completion];
    }];
}

- (void)addTimeSpent:(NSInteger)minutes toTaskId:(NSInteger)taskId completion:(void (^)(NSError *))completion
{
    NSAssert(completion, @"completion can't be nil");
    [self runAuthRequestBlock:^{
        [self pr_addTimeSpent:minutes toTaskId:taskId completion:completion];
    }];
}

- (void)changeStatus:(NSString *)newStatus toTaskId:(NSInteger)taskId completion:(void (^)(PRTask *task, NSError *))completion
{
    NSAssert(completion, @"completion can't be nil");
    [self runAuthRequestBlock:^{
        [self pr_changeStatus:newStatus toTaskId:taskId completion:completion];
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
    
    [self POST:kPRAuthentication parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [_delegate onOAuthNewToken:responseObject];
        _isTokenBeingRefreshed = NO;
        [_requestQueue setSuspended:NO];
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [_delegate onOAuthUnauthorized];
        _isTokenBeingRefreshed = NO;
        [_requestQueue cancelAllOperations];
        [_requestQueue setSuspended:NO];
        
    }];

}

 /**
  * Checks the returned error looking for unathorized responses
  */
//- (void)runFailureBlock:(void(^)(void))block forRequestOperation:(AFHTTPRequestOperation *)operation andError:(NSError *)error
- (void)runFailureBlock:(void(^)(void))block forSessionDataTask:(NSURLSessionDataTask *)task andError:(NSError *)error
{
    NSLog(@"error = %@", error);
    if(((NSHTTPURLResponse*)task.response).statusCode == 401){
        [_delegate onOAuthUnauthorized];
    }
    else{
        if(block) block();
    }
}

#pragma mark - Private requests

- (void)pr_userInfoCompletion:(void (^)(PRUser *, NSError *))completion
{
    // There is a bug in AFNetworking. Making a GET request with nil as parameters results in a content-type error.
    // Therefore, we set the the token as a query parameter
    NSString *url = [self urlWithPath:kPRUserInfo queryParams:[NSString stringWithFormat:@"access_token=%@",[_delegate token]]];
    [self GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"user response = %@", responseObject);
        PRUser *user = [[PRUser alloc]init];
        [user mts_setValuesForKeysWithDictionary:responseObject];
        completion(user, nil);
        
    }failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [self runFailureBlock:^{
            completion(nil, error);
        } forSessionDataTask:task andError:error];
    }];
    
}

- (void)pr_taskListAssignedToUserId:(NSInteger)userId completion:(void (^)(NSArray *, NSError *))completion
{
    NSString *params = [NSString stringWithFormat:@"assigned_user_id=%ld&status=open", userId];
    [self GET:[self urlWithPath:kPRTasks queryParams:params] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSMutableArray *tasks = [@[]mutableCopy];
        for(id taskJson in responseObject)
        {
            PRTask *task = [[PRTask alloc]init];
            [task mts_setValuesForKeysWithDictionary:taskJson];
            [tasks addObject:task];
        }
        NSLog(@"ApiManager: received tasks count = %ld", tasks.count);
        completion([tasks copy], nil);
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error){
        [self runFailureBlock:^{
            completion(nil, error);
        } forSessionDataTask:task andError:error];
    }];
}

- (void)pr_addTimeSpent:(NSInteger)minutes toTaskId:(NSInteger)taskId completion:(void (^)(NSError *))completion
{
    NSDictionary *params = @{@"target_type":@"task",
                             @"target_id":@(taskId),
                             @"minutes":@(minutes)
                             };
    // There is a bug in AFNetworking. Making a GET request with nil as parameters results in a content-type error.
    // Therefore, we set the the token as a query parameter
    NSString *url = [self urlWithPath:kPRComments queryParams:@""];
    [self POST:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        completion(nil);
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [self runFailureBlock:^{
            completion(error);
        } forSessionDataTask:task andError:error];
    }];
}

- (void)pr_changeStatus:(NSString *)newStatus toTaskId:(NSInteger)taskId completion:(void (^)(PRTask *task, NSError *))completion
{
    NSDictionary *params = @{ @"status":newStatus };

    NSString *path = [NSString stringWithFormat:@"%@/%ld",kPRTasks,taskId];
    NSString *url = [self urlWithPath:path queryParams:@""];
    [self PUT:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        PRTask *response = [[PRTask alloc]init];
        [response mts_setValuesForKeysWithDictionary:responseObject];
        completion(response, nil);
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error){
        [self runFailureBlock:^{
            completion(nil, error);
        } forSessionDataTask:task andError:error];
    }];
}

@end
