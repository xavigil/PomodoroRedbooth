//
//  PRTimerInteractor.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 08/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRTimerInteractor.h"
#import "PRTask.h"
#import "PRAPiManager.h"

#define POMODORO_INTERVAL 10 * 60 * 1000
#define POMODORO_BREAK_INTERVAL 1 * 60 * 1000

NSInteger const kPRPomodoroInterval = POMODORO_INTERVAL;
NSInteger const kPRPomodoroBreakInterval = POMODORO_BREAK_INTERVAL;

typedef enum{
    IDLE,
    PLAYING,
    PAUSED
}ePlaybackState;

typedef enum{
    FOCUS = 0,
    BREAK = 1
}ePomodoroPhase;

@interface PRTimerInteractor()
{
    ePlaybackState _state;
    ePomodoroPhase _phase;
    NSInteger _pomodoroCounter;
}

@end

@implementation PRTimerInteractor

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _state = -1;
        _phase = -1;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"deallocated");
}

#pragma mark - PRInteractorDelegate methods

- (void)presentViewFromViewController:(UIViewController *)vc
{
    [vc.navigationController pushViewController:[_vcDelegate vc] animated:YES];
}

#pragma mark - PRTimerInteractorDelegate methods

- (void)viewWillAppear
{
    [self setNewState:IDLE];
    [self.vcDelegate setTaskName:self.task.name];    
}

- (void)playbackTouch
{
    ePlaybackState newState = (_state==PLAYING?PAUSED:PLAYING);
    [self setNewState:newState];
}

- (void)pomodoroPhaseFinished
{
    if(_phase == FOCUS)
    {
        _pomodoroCounter++;
        [self.vcDelegate setNumPomodoros:_pomodoroCounter];
    }
    [self setNewState:IDLE];
}

- (void)exit
{
    [((UIViewController *)self.vcDelegate).navigationController popViewControllerAnimated:YES];
}

- (void)addTimeSpentToTask
{
    [self.vcDelegate showHUD];
    [[PRApiManager sharedManager] addTimeSpent:[self minutesSpent] toTaskId:[_task.id integerValue] completion:^(NSError *error) {
        [self.vcDelegate hideHUD];
        [((UIViewController *)self.vcDelegate).navigationController popViewControllerAnimated:YES];
    }];
}

- (void)addTimeSpentToTaskAndResolve
{
    [self.vcDelegate showHUD];
    NSInteger taskId = [_task.id integerValue];
    [[PRApiManager sharedManager] addTimeSpent:[self minutesSpent] toTaskId:taskId completion:^(NSError *error)
    {
        if(!error)
        {
            [[PRApiManager sharedManager] changeStatus:@"resolved" toTaskId:taskId completion:^(PRTask *task, NSError *error) {
                if(!error){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"task_resolved" object:self userInfo:@{@"task_id":task.id}];
                }
                [self.vcDelegate hideHUD];
                [((UIViewController *)self.vcDelegate).navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
}

#pragma mark - Private methods

- (NSInteger)minutesSpent
{
    return (_pomodoroCounter * POMODORO_INTERVAL/1000)/60;
}

- (void)setNextPhase
{
    ePomodoroPhase nextPhase;
    if((int)_phase == -1){
        nextPhase = FOCUS;
        [self.vcDelegate setNumPomodoros:_pomodoroCounter];
    }
    else {
        nextPhase = (_phase+1)%2;
    }
    
    _phase = nextPhase;
    if(_phase == FOCUS){
        [self.vcDelegate setFocusUI];
    }
    else if (_phase == BREAK){
        [self.vcDelegate setBreakUI];
    }
    NSNumber *interval = @(POMODORO_INTERVAL);
    if(_phase == BREAK){
        interval = @(POMODORO_BREAK_INTERVAL);
    }
    [self.vcDelegate setTimerViewInterval:interval];
}

- (void)setNewState:(ePlaybackState)newState
{
    if(_state == newState) return;
    
    ePlaybackState oldState = _state;
    _state = newState;
    
    if(_state == PLAYING)
    {
        if(oldState == PAUSED)
            [self.vcDelegate resumeTimerView];
        else
            [self.vcDelegate playTimerView];
    }
    else if (_state == PAUSED)
    {
        [self.vcDelegate pauseTimerView];
    }
    else if (_state == IDLE)
    {
        [self setNextPhase];
    }
}

@end
