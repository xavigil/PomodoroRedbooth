//
//  PRTask.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 06/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRObject.h"

@interface PRTask : PRObject

@property(nonatomic, strong) NSNumber *id;
@property(nonatomic, copy)   NSString *name;
@property(nonatomic, strong) NSNumber *projectId;
@property(nonatomic, copy)   NSString *dueOn;


@end
