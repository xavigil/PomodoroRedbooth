//
//  PRTimerInteractorTests.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 09/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "PRTimerInteractor.h"
#import "PRTimerViewControllerDelegate.h"
#import "PRTask.h"
#import "PRApiManager.h"

@interface PRTimerInteractorTests : XCTestCase

@property (nonatomic, strong) PRTimerInteractor *timerInteractor;
@property (nonatomic, strong) id                 timerViewControllerDelegate;
@property (nonatomic, strong) PRTask *           task;
@property (nonatomic, strong) NSString *         taskName;


@end

@implementation PRTimerInteractorTests

- (void)setUp {
    [super setUp];

    self.timerInteractor = [[PRTimerInteractor alloc] init];
    self.timerViewControllerDelegate = [OCMockObject mockForProtocol:@protocol(PRTimerViewControllerDelegate)];
    self.timerInteractor.vcDelegate = self.timerViewControllerDelegate;
    
    self.taskName = @"MyTask";
    PRTask *task = [[PRTask alloc] init];
    task.id = @(1);
    task.name = self.taskName;
    
    self.task = task;
    self.timerInteractor.task = self.task;
    
}

- (void)tearDown {
    [super tearDown];
    [self.timerViewControllerDelegate verify];
}

- (void)testViewWillAppear
{
    [self expectScenarioForViewWillAppear];
    [self.timerInteractor viewWillAppear];
}

- (void)testPlaybackTouch
{
    [[self.timerViewControllerDelegate expect] playTimerView];
    [self.timerInteractor playbackTouch];
     
    [[self.timerViewControllerDelegate expect] pauseTimerView];
    [self.timerInteractor playbackTouch];
    
    [[self.timerViewControllerDelegate expect] resumeTimerView];
    [self.timerInteractor playbackTouch];
}

- (void)testPomodoroPhaseFinished
{
    [self finishFirstPhase];
}

- (void)testAddTimeSpentToTask
{
    [self finishFirstPhase];
    [[self.timerViewControllerDelegate expect] showHUD];

    id mockApiManager = [OCMockObject niceMockForClass:[PRApiManager class]];
    [[[mockApiManager stub] andReturn:mockApiManager] sharedManager];
    [[mockApiManager expect] addTimeSpent:(kPRPomodoroInterval / 1000)/60 toTaskId:[self.task.id integerValue] completion:OCMOCK_ANY];
    [self.timerInteractor addTimeSpentToTask];

    [mockApiManager verify];
}

- (void)testAddTimeSpentToTaskAndResolve
{
    [self finishFirstPhase];
    [[self.timerViewControllerDelegate expect] showHUD];
    
    id mockApiManager = [OCMockObject niceMockForClass:[PRApiManager class]];
    [[[mockApiManager stub] andReturn:mockApiManager] sharedManager];    
    [[[mockApiManager expect] andDo:^(NSInvocation *invocation)
    {
        void (^completion)(NSError *error) = nil;
        [invocation getArgument:&completion atIndex:4];
        completion(nil);

    }] addTimeSpent:(kPRPomodoroInterval / 1000)/60 toTaskId:[self.task.id integerValue] completion:OCMOCK_ANY];
    [[mockApiManager expect] changeStatus:@"resolved" toTaskId:[self.task.id integerValue] completion:OCMOCK_ANY];
    
    [self.timerInteractor addTimeSpentToTaskAndResolve];
    
    [mockApiManager verify];
    
}

#pragma mark - Private methods

- (void)finishFirstPhase
{
    [self expectScenarioForViewWillAppear];
    [[self.timerViewControllerDelegate expect] playTimerView];
    [self expectScenarioForPomodoroPhaseFinished];
    
    [self.timerInteractor viewWillAppear];
    [self.timerInteractor playbackTouch];
    [self.timerInteractor pomodoroPhaseFinished];
}

- (void)expectScenarioForViewWillAppear
{
    [[self.timerViewControllerDelegate expect] setNumPomodoros:0];
    [[self.timerViewControllerDelegate expect] setFocusUI];
    [[self.timerViewControllerDelegate expect] setTimerViewInterval:@(kPRPomodoroInterval)];
    [[self.timerViewControllerDelegate expect] setTaskName:self.taskName];
}

- (void)expectScenarioForPomodoroPhaseFinished
{
    [[self.timerViewControllerDelegate expect] setNumPomodoros:1];
    [[self.timerViewControllerDelegate expect] setBreakUI];
    [[self.timerViewControllerDelegate expect] setTimerViewInterval:@(kPRPomodoroBreakInterval)];
}

@end
