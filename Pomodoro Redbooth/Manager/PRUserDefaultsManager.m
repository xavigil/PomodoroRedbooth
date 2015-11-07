//
//  PRUserDefaults.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 07/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRUserDefaultsManager.h"

NSString * const kPRUserDefaultsUserId = @"userId";

@implementation PRUserDefaultsManager

+(PRUserDefaultsManager *) sharedManager
{
    static PRUserDefaultsManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once( &oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)setUserId:(NSInteger)userId
{
    NSUserDefaults *ud = [self userDefaults];
    [ud setInteger:userId forKey:kPRUserDefaultsUserId];
    [ud synchronize];
}

- (NSInteger)userId
{
    return [[[self userDefaults] objectForKey:kPRUserDefaultsUserId] integerValue];
}

#pragma mark - private methods

- (NSUserDefaults *)userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

@end
