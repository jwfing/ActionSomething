//
//  AVVMasterViewController.m
//  ActionSomething
//
//  Created by Feng Junwen on 3/18/14.
//  Copyright (c) 2014 Feng Junwen. All rights reserved.
//

#import "AVVMasterViewController.h"
#import "AVVDetailViewController.h"

#import "AVVLoginViewController.h"

@interface AVVMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation AVVMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(logInOut:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AVUser *currentUser = [AVUser currentUser];
    if (!currentUser) {
        // force to login
        AVVLoginViewController *loginVC = [[AVVLoginViewController alloc] initWithNibName:@"AVVLoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    if (_objects) {
        return;
    }
    // list user list;
    AVQuery *query = [AVUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!_objects) {
            _objects = [[NSMutableArray alloc] init];
        }
        [_objects removeAllObjects];
        [_objects addObjectsFromArray:objects];
        [self.tableView reloadData];
    }];
    [AVAnalytics beginLogPageView:@"PeopleList"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [AVAnalytics endLogPageView:@"PeopleList"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logInOut:(id)sender
{
    AVUser *user = [AVUser currentUser];
    if (user) {
        [AVUser logOut];
        [_objects removeAllObjects];
    }
    AVVLoginViewController *loginVC = [[AVVLoginViewController alloc] initWithNibName:@"AVVLoginViewController" bundle:nil];
    [self.navigationController pushViewController:loginVC animated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    AVUser *user = _objects[indexPath.row];
    cell.textLabel.text = [user username];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
