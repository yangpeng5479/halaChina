//
//  GDSettingViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/27.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDSettingViewController.h"
#import "ZJSwitch.h"
#import "ACPButton.h"
#import "RDVTabBarController.h"

@interface GDSettingViewController ()

@end

@implementation GDSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.title = NSLocalizedString(@"Setting",@"设置");
    
    MOInitTableView(self.tableView);
    self.tableView.backgroundColor = MOColorSaleProductBackgroundColor();
    if ([GDPublicManager instance].loginstauts!=UNLOGIN)
    {
        ACPButton* logoutBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        logoutBut.frame = CGRectMake(0, 0, self.view.bounds.size.width, 36);
        [logoutBut setStyleRedButton];
        [logoutBut setTitle: NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];
        [logoutBut addTarget:self action:@selector(tapLogout) forControlEvents:UIControlEventTouchUpInside];
        [logoutBut setLabelFont:MOLightFont(18)];
    
        self.tableView.tableFooterView = logoutBut;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [ProgressHUD dismiss];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
#if defined MO_DEBUG
    return 2;
#else
    return 1;
#endif
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 2;
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
                cell.textLabel.text = NSLocalizedString(@"Clear Image Cache",@"清除图片缓存");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else if (indexPath.row == 1)
            {
                cell.textLabel.text = NSLocalizedString(@"Notification",@"接收通知");
                ZJSwitch *switchBut = [[ZJSwitch alloc] initWithFrame:CGRectMake(260, 5, 60, 25)];
                switchBut.backgroundColor = [UIColor clearColor];
                [switchBut addTarget:self action:@selector(handleNotiEvent:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = switchBut;
                
                switchBut.on = [GDPublicManager instance].receive_notice==1?YES:NO;
                switchBut.onText = NSLocalizedString(@"On",nil);
                switchBut.offText = NSLocalizedString(@"Off",nil);

            }
            else if (indexPath.row == 2)
            {
                cell.textLabel.text = NSLocalizedString(@"Remind me",@"开售提醒");
                ZJSwitch *switchBut = [[ZJSwitch alloc] initWithFrame:CGRectMake(260, 5, 60, 25)];
                switchBut.backgroundColor = [UIColor clearColor];
                [switchBut addTarget:self action:@selector(handleOpenEvent:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = switchBut;
                switchBut.on = NO;
                switchBut.onText = NSLocalizedString(@"On",nil);
                switchBut.offText = NSLocalizedString(@"Off",nil);
            }
        }
        break;
        case 1:
        {
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Version",@"版本号");
                cell.detailTextLabel.text = [GDPublicManager instance].app_version;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else if (indexPath.row == 1)
            {
                cell.textLabel.text = NSLocalizedString(@"Release Date",@"发布日期");
                cell.detailTextLabel.text = [GDPublicManager instance].app_date;
                cell.accessoryType = UITableViewCellAccessoryNone;
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
                SDImageCache *imageCache = SDWebImageManager.sharedManager.imageCache;
                //SDImageCache *imageCache = [SDImageCache sharedImageCache];
                [imageCache clearMemory];
                [imageCache clearDisk];
             
                [ProgressHUD showSuccess:NSLocalizedString(@"Cache has been cleared.", @"图片缓存已清空")];
            }
            break;
        case 1:
        {
            //check update
            //[[GDPublicManager instance] startupUpload];
        }
            break;
        default:
            break;
    }

}

- (void)tapLogout
{
    [UIAlertView showWithTitle:nil
                       message:NSLocalizedString(@"Are you sure to exit?", @"您确定要退出?")
             cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
             otherButtonTitles:@[NSLocalizedString(@"OK", @"确定")]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex ==1) {
             switch ([GDPublicManager instance].loginstauts) {
                 case GREADEAL:
                 {
                     int cid = [GDPublicManager instance].cid;
                     if (cid>0)
                     {
                         [[WCDatabaseManager instance] Logout:cid];
                     }
                     [[GDPublicManager instance] logoutEvent];
                 }
                     break;
                 case FACEBOOK:
                     [[GDPublicManager instance] logoutEvent];
                     [[facebookAccountManage sharedInstance] logout];
                     break;
                 case QQ:
                     [[GDPublicManager instance] logoutEvent];
                     [[qqAccountManage sharedInstance] Logout];
                     break;
                 default:
                     break;
             }
             [self.navigationController popViewControllerAnimated:YES];
         }
     }];
}
#pragma mark - RFSegment


- (void)handleNotiEvent:(id)sender
{
    int status = 0;
    ZJSwitch *button = (ZJSwitch *)sender;
    if (![button isKindOfClass:ZJSwitch.class]) {
        return;
    }
    if (button.isOn)
    {
        status = 1;
    }
    else
    {
       status = 0;
    }
    
    NSString* url;
    
    NSDictionary *para = @{@"receive_notice":@(status)};
    NSData *data = [NSJSONSerialization dataWithJSONObject:para options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    
    NSDictionary *parameters = @{@"token":[GDPublicManager instance].token ,@"setting_json":jsonStr};
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/update_setting"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
         }
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         LOG(@"%@",operation.responseObject);
         [ProgressHUD showError:error.localizedDescription];
     }];

}

- (void)handleOpenEvent:(id)sender
{
    ZJSwitch *button = (ZJSwitch *)sender;
    if (![button isKindOfClass:ZJSwitch.class]) {
        return;
    }
    if (button.isOn)
    {
       
    }
    else
    {
        
    }
}

@end
