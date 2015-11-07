//
//  PRUser.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 07/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRUser : NSObject

@property(readonly, nonatomic, strong) NSNumber *id;
@property(readonly, nonatomic, copy)   NSString *username;

@end
