//
//  PRTimerInteractor.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 08/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRTimerInteractor.h"
#import "PRTask.h"

#define POMODORO_INTERVAL 25 * 60 * 1000
#define POMODORO_REST_INTERVAL 5 * 60 * 1000

typedef enum{
    IDLE,
    PLAYING,
    PAUSED
}ePlaybackState;

@interface PRTimerInteractor()
{
    ePlaybackState _state;
}

@end

@implementation PRTimerInteractor

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _state = -1;
    }
    return self;
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

#pragma mark - Private methods

- (void)setNewState:(ePlaybackState)newState
{
    if(_state == newState) return;
    
    ePlaybackState oldState = _state;
    _state = newState;
    
    if(_state == PLAYING){
        if(oldState == PAUSED)
            [self.vcDelegate resumeTimerView];
        else
            [self.vcDelegate playTimerView];
    }
    else if (_state == PAUSED){
        [self.vcDelegate pauseTimerView];
    }
    else if (_state == IDLE){
        [self.vcDelegate pauseTimerView];
        [self.vcDelegate setTimerViewInterval:@(POMODORO_INTERVAL)];
    }
}

@end
