//
//  PRTaskListViewController.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 07/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRTaskListViewController.h"
#import "PRApiManager.h"
#import "PRUserDefaultsManager.h"
#import "PRConstants.h"

typedef enum{
    TODAY,
    DUE_SOON,
    FAR_FUTURE
}eSection;

@implementation PRTaskListViewController{
    NSDictionary *_tasksSections;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    UINavigationBar *bar = self.navigationController.navigationBar;
//    bar.hidden = NO;
//
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    
//}


- (void)setup
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.title = @"SELECT TASK";
    
    [self mockRequest];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *bar = self.navigationController.navigationBar;
    bar.hidden = NO;
    self.navigationItem.hidesBackButton = YES;
}

//- (void) viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    [self.navigationController setNavigationBarHidden:NO];
//}


// **********************************
// TODO: Remove the request logic from the view controller
- (void)mockRequest
{
    NSInteger userId = [[PRUserDefaultsManager sharedManager] userId];
    void(^taskListRequest)(NSInteger) = ^(NSInteger uid){
        [[PRApiManager sharedManager] taskListAssignedToUserId:uid completion:^(NSArray *tasks, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showTasksInSections:[self filterTasksIntoSections:tasks]];
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

- (NSDictionary *)filterTasksIntoSections:(NSArray *)tasks
{
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

- (IBAction)onLogout:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self userInfo:nil];
}


// **********************************


- (void)showTasksInSections:(NSDictionary *)tasksSections
{
    BOOL anyTask = (((NSArray *)tasksSections[@(0)]).count > 0 ||
                    ((NSArray *)tasksSections[@(1)]).count > 0 ||
                    ((NSArray *)tasksSections[@(2)]).count > 0);
    _tasksSections = anyTask?tasksSections:nil;
    [self.tableView reloadData];
}

#pragma mark - Private methods


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_tasksSections){
        self.tableView.backgroundView = nil;
        return 3;
    }
    else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No tasks assigned to you.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)_tasksSections[@(section)]).count;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSString *title;
//    switch (section) {
//        case TODAY:
//            title = NSLocalizedString(@"today", nil);
//            break;
//        case DUE_SOON:
//            title = NSLocalizedString(@"due_soon", nil);
//            break;
//        case FAR_FUTURE:
//            title = NSLocalizedString(@"far_future", nil);
//            break;
//    }
//    return title;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, tableView.frame.size.width, 18)];
    [label setFont:FONT_SECTIONS];
    [label setTextColor:[UIColor whiteColor]];
    
    NSString *title;
    switch (section) {
        case TODAY:
            title = NSLocalizedString(@"today", nil);
            break;
        case DUE_SOON:
            title = NSLocalizedString(@"due_soon", nil);
            break;
        case FAR_FUTURE:
            title = NSLocalizedString(@"far_future", nil);
            break;
    }

    [label setText:title];
    [view addSubview:label];
    [view setBackgroundColor:SECONDARY_COLOR];
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"taskListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    PRTask *task = (PRTask *)((NSArray *)_tasksSections[@(indexPath.section)])[indexPath.row];
    cell.textLabel.text = task.name;
    return cell;
}


@end
