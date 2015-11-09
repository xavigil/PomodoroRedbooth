//
//  PRTaskListViewController.m
//  Pomodoro Redbooth
//
//  Created by Xavi on 07/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#import "PRTaskListViewController.h"
#import "PRConstants.h"
#import "PRTask.h"

@implementation PRTaskListViewController{

    UIRefreshControl *_refreshControl;
    NSDictionary *_tasksSections;
    BOOL _taskResolved;
    NSDictionary *_tasksSectionsAfterDeletion; // <-- Waiting to be applied
    BOOL _showSpinnerAfterViewLoad;
    NSDateFormatter *_dateFormatter;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    _dateFormatter = [[NSDateFormatter alloc] init];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.title = NSLocalizedString(@"task_list_title", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"ic_exit_to_app_white_36pt"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(onLogout)];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = SECONDARY_COLOR;
    [_refreshControl addTarget:self
                        action:@selector(refreshData)
              forControlEvents:UIControlEventValueChanged];

    [self.tableView addSubview:_refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *bar = self.navigationController.navigationBar;
    bar.hidden = NO;
    self.navigationItem.hidesBackButton = YES;

    if(_taskResolved)
    {
        _taskResolved = NO;
        _tasksSections = _tasksSectionsAfterDeletion;
        _tasksSectionsAfterDeletion = nil;
        NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
        if (selectedRowIndexPath) {
            [self.tableView deleteRowsAtIndexPaths:@[selectedRowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(_showSpinnerAfterViewLoad){
        _showSpinnerAfterViewLoad = NO;
        [self showSpinner];
    }
}

- (void)refreshData
{
    [self.interactor requestTasks];
}

- (void)onLogout
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert_logout_title", nil)
                                                                             message:NSLocalizedString(@"alert_logout_message", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yes = [UIAlertAction
                          actionWithTitle:NSLocalizedString(@"yes", nil)
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [self.interactor logout];
                          }];
    UIAlertAction* no = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"no", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alertController dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alertController addAction:no];
    [alertController addAction:yes];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - PRTaskListViewControllerDelegate

- (UIViewController *)vc
{
    return self;
}

- (void)showSpinner
{
    if(!_refreshControl){
        _showSpinnerAfterViewLoad = YES;
    }
    else{
        [_refreshControl beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - _refreshControl.frame.size.height) animated:YES];
    }
}

- (void)showTasksInSections:(NSDictionary *)tasksSections afterDeletion:(BOOL)afterDeletion
{
    if(!afterDeletion)
    {
        [_refreshControl endRefreshing];
        BOOL anyTask = (((NSArray *)tasksSections[@(0)]).count > 0 ||
                        ((NSArray *)tasksSections[@(1)]).count > 0 ||
                        ((NSArray *)tasksSections[@(2)]).count > 0);
        _tasksSections = anyTask?tasksSections:nil;
        [self.tableView reloadData];
    }
    else
    {
        _taskResolved = YES;
        _tasksSectionsAfterDeletion = tasksSections;
    }
}

#pragma mark - Private methods


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)_tasksSections[@(section)]).count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, tableView.frame.size.width, 18)];
    [label setFont:FONT_SECTIONS];
    [label setTextColor:[UIColor whiteColor]];
    
    NSString *title;
    switch (section) {
        case 0:
            title = NSLocalizedString(@"today", nil);
            break;
        case 1:
            title = NSLocalizedString(@"due_soon", nil);
            break;
        case 2:
            title = NSLocalizedString(@"far_future", nil);
            break;
        case 3:
            title = NSLocalizedString(@"no_due_date", nil);
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    PRTask *task = (PRTask *)((NSArray *)_tasksSections[@(indexPath.section)])[indexPath.row];
    NSString *name = task.name;
    NSInteger limit = 22;
    if(name.length > limit){
        name = [NSString stringWithFormat:@"%@...",[task.name substringToIndex:MIN(limit,task.name.length)]];
    }
    cell.textLabel.text = name;
    NSString *monthName = @"";
    NSString *day = @"";
    if(task.dueOn && task.dueOn.length>0)
    {
        NSArray *comps = [task.dueOn componentsSeparatedByString:@"-"];
        monthName = [[_dateFormatter monthSymbols] objectAtIndex:([comps[1] integerValue]-1)];
        day = comps[2];
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", monthName, day];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PRTask *task = ((NSArray *)_tasksSections[@(indexPath.section)])[indexPath.row];
    [self.interactor showTimerForTask:task];
}

@end
