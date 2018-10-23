//
//  GDCSViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/5.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDCSViewController.h"
#import "RDVTabBarController.h"

#import "ALCustomColoredAccessory.h"
#import "GDChatViewController.h"

@interface GDCSViewController ()

@end

@implementation GDCSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!expandedSections)
    {
        expandedSections = [[NSMutableIndexSet alloc] init];
    }
    
    self.title = NSLocalizedString(@"Online Support", @"在线支持");
       
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

#pragma mark - Table View
- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    if (section>0) return YES;
    
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1)
    {
        return 80;
    }
    return 35;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self tableView:tableView canCollapseSection:section])
    {
        if ([expandedSections containsIndex:section])
        {
            return 2; // return rows when expanded
        }
        
        return 1; // only top row showing
    }
    
    // Return the number of rows in the section.
    return 1;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    if ([self tableView:tableView canCollapseSection:indexPath.section])
    {
        if (!indexPath.row)
        {
            // first row
            cell.textLabel.text = [NSString stringWithFormat:@"Expandable cell %ld",(long)indexPath.section]; // only top row showing
            
            if ([expandedSections containsIndex:indexPath.section])
            {
                cell.accessoryView = [ALCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:ALCustomColoredAccessoryTypeUp];
            }
            else
            {
                cell.accessoryView = [ALCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:ALCustomColoredAccessoryTypeDown];
            }
        }
        else
        {
            // all other rows
            cell.textLabel.text = [NSString stringWithFormat:@"Sub Row %ld",(long)indexPath.row];
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else
    {
        cell.accessoryView = nil;
        cell.textLabel.text = @"Normal Cell";
        
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self tableView:tableView canCollapseSection:indexPath.section])
    {
        if (!indexPath.row)
        {
            // only first row toggles exapand/collapse
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            NSInteger section = indexPath.section;
            BOOL currentlyExpanded = [expandedSections containsIndex:section];
            NSInteger rows;
            
            NSMutableArray *tmpArray = [NSMutableArray array];
            
            if (currentlyExpanded)
            {
                rows = [self tableView:tableView numberOfRowsInSection:section];
                [expandedSections removeIndex:section];
                
            }
            else
            {
                [expandedSections addIndex:section];
                rows = [self tableView:tableView numberOfRowsInSection:section];
            }
            
            for (int i=1; i<rows; i++)
            {
                NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:i
                                                               inSection:section];
                [tmpArray addObject:tmpIndexPath];
            }
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (currentlyExpanded)
            {
                [tableView deleteRowsAtIndexPaths:tmpArray
                                 withRowAnimation:UITableViewRowAnimationTop];
                
                cell.accessoryView = [ALCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:ALCustomColoredAccessoryTypeDown];
                
            }
            else
            {
                [tableView insertRowsAtIndexPaths:tmpArray
                                 withRowAnimation:UITableViewRowAnimationTop];
                cell.accessoryView =  [ALCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:ALCustomColoredAccessoryTypeUp];
                
            }
        }
        else {
            LOG(@"Selected Section is %ld and subrow is %ld ",(long)indexPath.section ,(long)indexPath.row);
            
            GDChatViewController* chatView = [[GDChatViewController alloc] init];
            [self.navigationController pushViewController:chatView animated:YES];
        }
        
    }
    else{
       
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}
@end
