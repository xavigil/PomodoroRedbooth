//
//  PRTaskListInteractor.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 08/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRInteractorDelegate.h"
#import "PRTaskListViewControllerDelegate.h"
#import "PRTaskListInteractorDelegate.h"

@interface PRTaskListInteractor : NSObject<PRInteractorDelegate, PRTaskListInteractorDelegate>

@property(nonatomic, weak) id<PRTaskListViewControllerDelegate> vcDelegate;

@end
