//
//  PRTimerInteractor.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 08/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRInteractorDelegate.h"
#import "PRTimerInteractorDelegate.h"
#import "PRTimerViewControllerDelegate.h"
#import "PRTask.h"

extern NSInteger const kPRPomodoroInterval;
extern NSInteger const kPRPomodoroBreakInterval;

@interface PRTimerInteractor : NSObject<PRInteractorDelegate, PRTimerInteractorDelegate>

@property(nonatomic, weak) id<PRTimerViewControllerDelegate> vcDelegate;

@property(nonatomic, strong) PRTask *task;

@end
