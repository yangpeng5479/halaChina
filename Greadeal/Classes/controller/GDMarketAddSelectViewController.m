//
//  GDMarketAddSelectViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/16.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDMarketAddSelectViewController.h"
#import "MOItemSelectViewController.h"
#import "RDVTabBarController.h"

@interface GDMarketAddSelectViewController ()

@end

@implementation GDMarketAddSelectViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"Choose Your Area",@"选择您的小区");
        
        self.tableView.backgroundColor = MOColorAppBackgroundColor();
        self.tableView.backgroundView  = nil;
        
        MOInitTableView(self.tableView);
        
        UIBarButtonItem*  searchButItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getAddressInfo)];
        self.navigationItem.rightBarButtonItem = searchButItem;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getAddressInfo
{
    [[GDPublicManager instance] checkAddressChange];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    CGRect r = self.view.bounds;
    
    UILabel* headView = MOCreateLabelAutoRTL();
    headView.frame = CGRectMake(r.origin.x+10, r.origin.y, r.size.width-20,40);
    headView.font = [UIFont systemFontOfSize:14.0];
    headView.textColor = [UIColor whiteColor];
    headView.numberOfLines = 0;
    headView.textAlignment = NSTextAlignmentCenter;
    headView.backgroundColor = colorFromHexString(@"70a800");
    
    headView.text=NSLocalizedString(@"Please choose your area for free shipping.", @"请选择您要收货的区域,超市将会为您免费配送.");
    
    self.tableView.tableHeaderView = headView;
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
    
    NSArray* tempArrar = [GDPublicManager instance].allAddress;
    if (tempArrar.count>0)
    {
        info = [tempArrar objectAtIndex:0];
        SET_IF_NOT_NULL(selCountry, info[@"name"]);
        selCountryId=[info[@"country_id"] intValue];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}


- (void)exit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reload
{
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIBarButtonItemStylePlain target:self action:@selector(exit)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:kNotificationGetCountryInfo object:nil];
    
    selCountry = @"";
    selCity = @"";
    selCommunity = @"";
    selCountryId = 0;
    selCityId = 0;
    selCommunityId=0;
    if ([GDSettingManager instance].nUserCityAddress!=nil)
    {
        NSDictionary* parameters = [GDSettingManager instance].nUserCityAddress;
        selCountryId = [parameters[@"selCountryId"] intValue];
        selCityId = [parameters[@"selCityId"] intValue];
        selCommunityId = [parameters[@"selCommunityId"] intValue];
        selCountry = parameters[@"selCountry"];
        selCity = parameters[@"selCity"];
        selCommunity = parameters[@"selCommunity"];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)selectedCountry:(NSDictionary *)value
{
    LOG(@"%@",value);
    selCountryId = [value[@"id"] intValue];
    selCountry = value[@"name"];
    
    selCity = @"";
    selCommunity = @"";
    selCityId = 0;
    selCommunityId=0;

    [self.tableView reloadData];
}

- (void)selectedCity:(NSDictionary *)value
{
    LOG(@"%@",value);
    selCityId = [value[@"id"] intValue];
    selCity = value[@"name"];
    
    selCommunity = @"";
    selCommunityId=0;

    [self.tableView reloadData];
}

- (void)selectedArea:(NSDictionary *)value
{
    LOG(@"%@",value);
    selCommunityId = [value[@"id"] intValue];
    selCommunity = value[@"name"];
    [self.tableView reloadData];
}

- (BOOL)checkData
{
    if (selCountryId<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"No Country", @"国家没有选择")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        return NO;
    }
    
    if (selCityId<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"No City", @"城市没有选择")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        return NO;
    }
    if (selCommunityId<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"No Area", @"小区没有选择")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        return NO;
    }
    
    return YES;
}

- (void)tapOk
{
    if ([self checkData])
    {
        NSDictionary* parameters;
        parameters = @{@"selCountryId":@(selCountryId),@"selCityId":@(selCityId),@"selCommunityId":@(selCommunityId),@"selCountry":selCountry,@"selCity":selCity,@"selCommunity":selCommunity};
        [[GDSettingManager instance] setUserSuperAddress:parameters];
    
        [self exit];
    
        if ([self.target respondsToSelector:self.callback])
        {
            [self.target performSelector:self.callback withObject:parameters afterDelay:0];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
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
    
    if (indexPath.row==0)
    {
        cell.textLabel.text = NSLocalizedString(@"Country", @"国家");
        cell.detailTextLabel.text = selCountry;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row==1)
    {
        cell.textLabel.text = NSLocalizedString(@"City", @"城市");
        cell.detailTextLabel.text = selCity;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row==2)
    {
        cell.textLabel.text = NSLocalizedString(@"Area", @"区域");
        cell.detailTextLabel.text = selCommunity;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            if (info!=nil)
            {
                if (countryDict == nil)
                {
                NSString*  countryName = @"";
                int        countryId = [info[@"country_id"] intValue];
                SET_IF_NOT_NULL(countryName, info[@"name"]);

                countryDict = [[NSMutableDictionary alloc] init];
                [countryDict setObject:countryName forKey:@(countryId)];
                }
            
                MOItemSelectViewController *selectItem = [[MOItemSelectViewController alloc] initWithStyle:UITableViewStylePlain withDict:countryDict value:selCountry target:self action:@selector(selectedCountry:) withTitle:NSLocalizedString(@"Country",nil)];
                [self.navigationController pushViewController:selectItem animated:YES];
            }
            else
            {
                [ProgressHUD showRemind:NSLocalizedString(@"Downloading city information, please try later", @"正在下载城市信息,请稍后重试")];
            }
            break;
        }
        case 1:
        {
            if (info!=nil)
            {
                if (cityDict == nil)
                {
                cityDict = [[NSMutableDictionary alloc] init];
                            
                NSArray* tempArray = nil;
                SET_IF_NOT_NULL(tempArray,info[@"zone_list"]);
                
                for (NSDictionary* dict in tempArray)
                {
                    NSString*  cityName = @"";
                    int        cityId = [dict[@"zone_id"] intValue];
                    SET_IF_NOT_NULL(cityName, dict[@"name"]);
                    
                    [cityDict setObject:cityName forKey:@(cityId)];
                  
                }
                }
            
                MOItemSelectViewController *selectItem = [[MOItemSelectViewController alloc] initWithStyle:UITableViewStylePlain withDict:cityDict value:selCity target:self action:@selector(selectedCity:) withTitle:selCountry];
                [self.navigationController pushViewController:selectItem animated:YES];
            }
            else
            {
                [ProgressHUD showRemind:NSLocalizedString(@"Downloading city information, please try later", @"正在下载城市信息,请稍后重试")];
            }
            break;
        }
        case 2:
        {
            if (info!=nil)
            {
                if (areaDict == nil)
                {
                    areaDict = [[NSMutableDictionary alloc] init];
                }
                @synchronized(areaDict)
                {
                    [areaDict removeAllObjects];
                }
            
                NSArray* tempArray = nil;
                SET_IF_NOT_NULL(tempArray,info[@"zone_list"]);
                
                NSArray* areaArray = nil;
    
                for (NSDictionary* dict in tempArray)
                {
                    int        cityId = [dict[@"zone_id"] intValue];
                    if (cityId==selCityId)
                    {
                        SET_IF_NOT_NULL(areaArray,dict[@"zone_area_list"]);
                        break;
                    }
                }
                
                if (areaArray!=nil)
                {
                     for (NSDictionary* dict in areaArray)
                     {
                         
                         NSString*  areaName = @"";
                         int        areaId = [dict[@"zone_area_id"] intValue];
                         SET_IF_NOT_NULL(areaName,dict[@"name"]);
                        
                         [areaDict setObject:areaName forKey:@(areaId)];
                     }
                }
            
                MOItemSelectViewController *selectItem = [[MOItemSelectViewController alloc] initWithStyle:UITableViewStylePlain withDict:areaDict value:selCommunity target:self action:@selector(selectedArea:) withTitle:selCity];
                [self.navigationController pushViewController:selectItem animated:YES];
            }
            else
            {
                [ProgressHUD showRemind:NSLocalizedString(@"Downloading city information, please try later", @"正在下载城市信息,请稍后重试")];
            }
            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGRect r = self.view.bounds;
    
    UIView *footer = [[UIView alloc] initWithFrame:r];
    footer.backgroundColor = [UIColor whiteColor];
    
    ACPButton* registerBut = [ACPButton buttonWithType:UIButtonTypeCustom];
    registerBut.frame = CGRectMake(10, 40, r.size.width-20, 36);
    [registerBut setStyleWithImage:@"loginNormal.png" highlightedImage:@"loginPress.png" disableImage:@"loginPress.png" andInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [registerBut setTitle: NSLocalizedString(@"OK", @"确定") forState:UIControlStateNormal];
    [registerBut addTarget:self action:@selector(tapOk) forControlEvents:UIControlEventTouchUpInside];
    [registerBut setLabelFont:[UIFont systemFontOfSize:18]];
    [footer addSubview:registerBut];
    
    return footer;
}


@end
