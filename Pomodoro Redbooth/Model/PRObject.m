//
//  PRObject.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 06/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRObject.h"
#import <Motis/Motis.h>

@implementation PRObject

+ (NSDateFormatter*)mts_validationDateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY'-'MM'-'dd'";
    });
    
    return dateFormatter;
}

@end
