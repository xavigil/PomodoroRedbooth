//
//  PRToken.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 06/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRObject.h"

@interface PRToken : PRObject

@property(readonly, nonatomic, copy)   NSString *accessToken;
@property(readonly, nonatomic, strong) NSNumber *expiresIn;
@property(readonly, nonatomic, copy)   NSString *refreshToken;
@property(readonly, nonatomic, copy)   NSString *scope;
@property(readonly, nonatomic, copy)   NSString *tokenType;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (NSDate *)expirationDate;

- (NSDictionary *)dictionary;

@end
