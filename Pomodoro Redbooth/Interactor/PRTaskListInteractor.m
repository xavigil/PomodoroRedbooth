//
//  PRTaskListInteractor.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 08/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRTaskListInteractor.h"
#import "PRApiManager.h"
#import "PRUserDefaultsManager.h"
#import "PRConstants.h"
#import "AppDelegate.h"
#import "PRTimerInteractor.h"

typedef enum{
    TODAY,
    DUE_SOON,
    FAR_FUTURE
}eSection;


@interface PRTaskListInteractor()
{
    NSArray *_tasksReceived;
}


@end

@implementation PRTaskListInteractor

#pragma mark - PRInteractorDelegate methods

- (void)presentViewFromViewController:(UIViewController *)vc
{
    [vc.navigationController pushViewController:[_vcDelegate vc] animated:NO];
    [self.vcDelegate showSpinner];
    [self requestTasks];
}

#pragma mark - PRTaskListInteractorDelegate methods

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskResolved:) name:@"task_resolved" object:nil];
    }
    return self;
}

- (void)requestTasks
{
    NSInteger userId = [[PRUserDefaultsManager sharedManager] userId];
    void(^taskListRequest)(NSInteger) = ^(NSInteger uid){
        [[PRApiManager sharedManager] taskListAssignedToUserId:uid completion:^(NSArray *tasks, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.vcDelegate showTasksInSections:[self filterTasksIntoSections:tasks] afterDeletion:NO];
            });
        }];
    };
    
    if(userId>0){
        taskListRequest(userId);
    }
    else
    {
        [[PRApiManager sharedManager]userInfoCompletion:^(PRUser *user, NSError *error) {
            if(!error){
                [[PRUserDefaultsManager sharedManager] setUserId:[user.id integerValue]];
                taskListRequest([user.id integerValue]);
            }
        }];
    }
}

- (void)showTimerForTask:(PRTask *)task
{
    if(!task) return;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    id<PRInteractorDelegate> interactor = [appDelegate interactorForView:@"timer"];
    [interactor presentViewFromViewController:(UIViewController *)self.vcDelegate];
    ((PRTimerInteractor *)interactor).task = task;
}

- (void)logout
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self userInfo:nil];
}

#pragma mark - Private methods

- (NSDictionary *)filterTasksIntoSections:(NSArray *)tasks
{
    _tasksReceived = tasks;
    NSMutableArray *sortedTasks = [tasks mutableCopy];
    [sortedTasks sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dueOn" ascending:YES]]];
    
    NSMutableArray *dueToday = [@[]mutableCopy];
    NSMutableArray *dueSoon = [@[]mutableCopy];
    NSMutableArray *dueFarFuture = [@[]mutableCopy];
    NSString *todayLimit = [self dateLimitForSection:TODAY];
    NSString *dueSoonLimit = [self dateLimitForSection:DUE_SOON];
    
    for(PRTask *t in sortedTasks){
        NSMutableArray *ar;
        if([self string:t.dueOn smallerOrEqualThanString:todayLimit])
            ar = dueToday;
        else if([self string:t.dueOn smallerOrEqualThanString:dueSoonLimit])
            ar = dueSoon;
        else
            ar = dueFarFuture;
        [ar addObject:t];
    }
    
    return @{@(TODAY):[dueToday copy], @(DUE_SOON):[dueSoon copy], @(FAR_FUTURE):[dueFarFuture copy]};
}

- (BOOL)string:(NSString *)string1 smallerOrEqualThanString:(NSString *)string2
{
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch | NSNumericSearch |
    NSWidthInsensitiveSearch | NSForcedOrderingSearch;
    
    NSRange string1Range = NSMakeRange(0, [string1 length]);
    
    NSComparisonResult comparison = [string1 compare:string2
                                             options:comparisonOptions
                                               range:string1Range
                                              locale:nil];
    return (comparison == NSOrderedAscending || comparison == NSOrderedSame);
}

- (NSString *)dateLimitForSection:(eSection)section
{
    NSUInteger units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:units fromDate:[NSDate date]];
    switch (section) {
        case DUE_SOON:
            comps.day += 7;
            break;
        case FAR_FUTURE:
            NSAssert(NO, @"There is no limit for FAR_FUTURE");
            break;
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%ld-%02ld-%02ld",comps.year, comps.month, comps.day];
}


- (void)taskResolved:(NSNotification *)notification
{
    NSInteger taskId = [[notification.userInfo objectForKey:@"task_id"] integerValue];
    NSMutableArray *mutableArray = [_tasksReceived mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == %ld", taskId]];
    [mutableArray removeObjectsInArray:[_tasksReceived filteredArrayUsingPredicate:predicate]];
    NSDictionary *newTasksInSections = [self filterTasksIntoSections:[mutableArray copy]];
    [self.vcDelegate showTasksInSections:newTasksInSections afterDeletion:YES];
}

@end
