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
#import "SFRoundProgressCounterView.h"

@interface PRTimerViewController : UIViewController<PRTimerViewControllerDelegate,SFRoundProgressCounterViewDelegate>

@property (nonatomic, strong) id<PRTimerInteractorDelegate> interactor;

@property (weak, nonatomic) IBOutlet SFRoundProgressCounterView *timer;
@property (weak, nonatomic) IBOutlet UIView *vTimerDummy;
@property (weak, nonatomic) IBOutlet UIImageView *imgPlayback;

@property (weak, nonatomic) IBOutlet UILabel *lblPhase;
@property (weak, nonatomic) IBOutlet UIView *vTitleMarginLeft;
@property (weak, nonatomic) IBOutlet UIView *vTitleMarginRight;
@property (weak, nonatomic) IBOutlet UILabel *lblTaskTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentTask;
@property (weak, nonatomic) IBOutlet UILabel *lblNumPomodoros;

@end
