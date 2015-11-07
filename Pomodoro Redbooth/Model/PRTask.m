//
//  PRTask.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 06/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRTask.h"
#import <Motis/Motis.h>

@implementation PRTask

+ (NSDictionary*)mts_mapping
{
    return @{@"id": mts_key(id),
             @"name": mts_key(name),
             @"project_id": mts_key(projectId),
             @"due_on": mts_key(dueOn),
             };
}

@end
