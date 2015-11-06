//
//  PRKeychainManager.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 06/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRKeychainManager.h"
#import "KeychainItemWrapper.h"

NSString * const kPRKeychainUserToken = @"com.xavigil.pomodoroRedbooth.userToken";


@implementation PRKeychainManager

-(NSDictionary *) userAccessToken
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kPRKeychainUserToken accessGroup:nil];
    NSString *stringToken = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    if( !stringToken || [stringToken length] == 0 ) return nil;
    return [stringToken propertyList];
}

-(void) setUserAccessToken:(NSDictionary *)token
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kPRKeychainUserToken accessGroup:nil];
    [wrapper setObject:kPRKeychainUserToken forKey: (__bridge id)kSecAttrService];
    [wrapper setObject:(__bridge id)(kSecAttrAccessibleWhenUnlocked) forKey:(__bridge id)(kSecAttrAccessible)];
    [wrapper setObject:[token description] forKey:(__bridge id)(kSecValueData)];
    wrapper = nil;
}

-(void)resetUserToken
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kPRKeychainUserToken accessGroup:nil];
    [wrapper resetKeychainItem];
}


@end
