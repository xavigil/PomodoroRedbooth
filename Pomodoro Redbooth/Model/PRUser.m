//
//  PRUser.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 07/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRUser.h"
#import <Motis/Motis.h>


@implementation PRUser

+ (NSDictionary*)mts_mapping
{
    return @{@"id": mts_key(id),
             @"name": mts_key(name),
             };
}

@end
