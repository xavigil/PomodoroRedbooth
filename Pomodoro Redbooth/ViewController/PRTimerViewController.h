//
//  PRTimerViewController.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 05/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRTimerInteractorDelegate.h"
#import "PRTimerViewControllerDelegate.h"

@interface PRTimerViewController : UIViewController<PRTimerViewControllerDelegate>

@property (nonatomic, strong) id<PRTimerInteractorDelegate> interactor;

@end
