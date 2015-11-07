//
//  PRUserDefaults.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 07/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRUserDefaultsManager : NSObject

+(PRUserDefaultsManager *) sharedManager;

- (void)setUserId:(NSInteger)userId;

- (NSInteger)userId;

@end
