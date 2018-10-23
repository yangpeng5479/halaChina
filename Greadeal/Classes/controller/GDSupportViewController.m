//
//  GDSupportViewController.m
//  Greadeal
//
//  Created by Elsa on 15/8/20.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDSupportViewController.h"
#import "RDVTabBarController.h"

@interface GDSupportViewController ()

@end

@implementation GDSupportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Online Support", @"在线支持");
    
    MOInitTableView(self.tableView);
    self.tableView.backgroundColor = MOColorSaleProductBackgroundColor();
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Facebook",@"Facebook");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
            break;
        case 1:
        {
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"E-Mail",@"邮件");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
            break;
            
        default:
            break;
    }
    cell.textLabel.font= MOLightFont(15);
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0)
            {
                 //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/pages/Greadealcom/422253087975546"]];
                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://m.facebook.com/messages/compose?ids=422253087975546"]];
                
            }
            break;
        case 1:
        {
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
                
                mailComposeViewController.mailComposeDelegate = self;
                
                NSMutableArray *emailContacts = [NSMutableArray new];
                [emailContacts addObject:@"support@greadeal.com"];
                
                [mailComposeViewController setToRecipients:emailContacts];
                [self presentViewController:mailComposeViewController animated:YES completion:nil];
            }
            else
            {
                [UIAlertView showWithTitle:NSLocalizedString(@"Unable to send E-Mail", @"不能发送邮件")
                                   message:NSLocalizedString(@"Please configure your E-Mail in this phone first.", @"您的手机没有配置发送邮件账号")
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      if (buttonIndex == [alertView cancelButtonIndex]) {
                                          
                                      }
                                  }];
                
            }

        }
            break;
        default:
            break;
    }
    
}

#pragma mark - MFMailComposeViewControllerDelegate method

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultSaved:
        case MFMailComposeResultCancelled:
        {
            [self dismissViewControllerAnimated:NO completion:nil];
            break;
        }
        case MFMailComposeResultSent:
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Done",@"完成")
                               message:nil
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      [self dismissViewControllerAnimated:NO completion:nil];
                                  }
                              }];
            break;
        }
        case MFMailComposeResultFailed:
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"错误")
                               message:NSLocalizedString(@"Failed to send E-Mail.", @"发送邮件失败")
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      
                                  }
                              }];
            break;
        }
        default:
            break;
    }
}

@end
