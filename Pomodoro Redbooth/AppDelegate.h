//
//  AppDelegate.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 05/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRInteractorDelegate.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (id<PRInteractorDelegate>)interactorForView:(NSString *)view;

@end

