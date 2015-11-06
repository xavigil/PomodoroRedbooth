//
//  PRTask.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 06/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRObject.h"

@interface PRTask : PRObject

@property(readonly, nonatomic, copy)   NSString *name;
@property(readonly, nonatomic, strong) NSNumber *projectId;
@property(readonly, nonatomic, copy)   NSString *dueOn;


@end
