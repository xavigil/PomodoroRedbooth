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
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = SECONDARY_COLOR;
    [_refreshControl addTarget:self
                        action:@selector(refreshData)
              forControlEvents:UIControlEventValueChanged];

    [self.tableView addSubview:_refreshControl];
}

- (void)refreshData
{
    NSLog(@"refreshData");
    [self.interactor requestTasks];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *bar = self.navigationController.navigationBar;
    bar.hidden = NO;
    self.navigationItem.hidesBackButton = YES;
}

// **********************************
// TODO: Remove the request logic from the view controller


- (IBAction)onLogout:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self userInfo:nil];
}


// **********************************


#pragma mark - PRTaskListViewControllerDelegate

- (UIViewController *)vc
{
    return self;
}

- (void)showSpinner
{
    NSLog(@"not impleemnted yet");
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


@end
