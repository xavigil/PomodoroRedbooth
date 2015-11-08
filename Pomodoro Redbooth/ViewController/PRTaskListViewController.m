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
    BOOL _showSpinnerAfterViewLoad;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
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

- (void)showTasksInSections:(NSDictionary *)tasksSections
{
    [_refreshControl endRefreshing];
    BOOL anyTask = (((NSArray *)tasksSections[@(0)]).count > 0 ||
                    ((NSArray *)tasksSections[@(1)]).count > 0 ||
                    ((NSArray *)tasksSections[@(2)]).count > 0);
    _tasksSections = anyTask?tasksSections:nil;
    [self.tableView reloadData];
}

#pragma mark - Private methods


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
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
