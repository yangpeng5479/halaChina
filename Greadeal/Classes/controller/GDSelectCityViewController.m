//
//  GDSelectCityViewController.m
//  Greadeal
//
//  Created by Elsa on 15/10/10.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "GDSelectCityViewController.h"
#import "MOItemSelectViewController.h"
#import "RDVTabBarController.h"

@interface GDSelectCityViewController ()

@end

@implementation GDSelectCityViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"Choose Country",@"选择国家");
        
        self.tableView.backgroundColor = MOColorAppBackgroundColor();
        self.tableView.backgroundView  = nil;
        
        MOInitTableView(self.tableView);
        
        UIBarButtonItem*  searchButItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getCityInfo)];
        self.navigationItem.rightBarButtonItem = searchButItem;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getCityInfo
{
    [[GDPublicManager instance] checkCityChange];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
//    CGRect r = self.view.bounds;
//    
//    UILabel* headView = MOCreateLabelAutoRTL();
//    headView.frame = CGRectMake(r.origin.x+10, r.origin.y, r.size.width-20,40);
//    headView.font = MOLightFont(14);
//    headView.textColor = [UIColor whiteColor];
//    headView.numberOfLines = 0;
//    headView.textAlignment = NSTextAlignmentCenter;
//    headView.backgroundColor = colorFromHexString(@"e71748");
//    
//    headView.text=NSLocalizedString(@"Please choose your area for discounts.", @"请选择您的城市,获取优惠.");
//    
//    self.tableView.tableHeaderView = headView;
//    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
    
    NSArray* tempArrar = [GDSettingManager instance].nAllAddress;
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
    
    selCountry = NSLocalizedString(@"UAE",@"阿联酋");
    //selCity = [GDSettingManager instance].currentCountry;
   
    selCountryId = 221;
    //selCityId    = [GDSettingManager instance].currentCountryId;
  
    if ([GDSettingManager instance].nUserCity!=nil)
    {
        NSDictionary* parameters = [GDSettingManager instance].nUserCity;
        selCountryId = [parameters[@"selCountryId"] intValue];
        //selCityId = [parameters[@"selCityId"] intValue];
       
        selCountry = parameters[@"selCountry"];
        //selCity = parameters[@"selCity"];
      
    }
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
    
//    selCity = @"";
//    selCityId = 0;
//   
    [self.tableView reloadData];
}

//- (void)selectedCity:(NSDictionary *)value
//{
//    LOG(@"%@",value);
//    selCityId = [value[@"id"] intValue];
//    selCity = value[@"name"];
//    
//    [self.tableView reloadData];
//}

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
    
//    if (selCityId<=0)
//    {
//        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
//                           message:NSLocalizedString(@"No City", @"城市没有选择")
//                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                 otherButtonTitles:nil
//                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                              if (buttonIndex == [alertView cancelButtonIndex]) {
//                                  
//                              }
//                          }];
//        return NO;
//    }
    
    return YES;
}

- (void)tapOk
{
    if ([self checkData])
    {
        NSDictionary* parameters;
        parameters = @{@"selCountryId":@(selCountryId),@"selCountry":selCountry};
        [[GDSettingManager instance] saveUserCity:parameters];
        
        if ([self.target respondsToSelector:self.callback])
        {
            [self.target performSelector:self.callback withObject:parameters afterDelay:0];
        }
        
        [self exit];
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
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
//    else if (indexPath.row==1)
//    {
//        cell.textLabel.text = NSLocalizedString(@"City", @"城市");
//        cell.detailTextLabel.text = selCity;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }
  
    cell.detailTextLabel.font = MOLightFont(15);
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
                [ProgressHUD showRemind:NSLocalizedString(@"Downloading city information, please try again later", @"正在下载城市信息,请稍后重试")];
            }
            break;
        }
//        case 1:
//        {
//            if (info!=nil)
//            {
//                if (cityDict == nil)
//                {
//                    cityDict = [[NSMutableDictionary alloc] init];
//                    
//                    NSArray* tempArray = nil;
//                    SET_IF_NOT_NULL(tempArray,info[@"zone_list"]);
//                    
//                    for (NSDictionary* dict in tempArray)
//                    {
//                        NSString*  cityName = @"";
//                        int        cityId = [dict[@"zone_id"] intValue];
//                        SET_IF_NOT_NULL(cityName, dict[@"name"]);
//                        
//                        [cityDict setObject:cityName forKey:@(cityId)];
//                        
//                    }
//                }
//                
//                MOItemSelectViewController *selectItem = [[MOItemSelectViewController alloc] initWithStyle:UITableViewStylePlain withDict:cityDict value:selCity target:self action:@selector(selectedCity:) withTitle:selCountry];
//                [self.navigationController pushViewController:selectItem animated:YES];
//            }
//            else
//            {
//                [ProgressHUD showRemind:NSLocalizedString(@"Downloading city information, please try again later", @"正在下载城市信息,请稍后重试")];
//            }
//            break;
//        }
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
    [registerBut setStyleRedButton];
    [registerBut setTitle: NSLocalizedString(@"OK", @"确定") forState:UIControlStateNormal];
    [registerBut addTarget:self action:@selector(tapOk) forControlEvents:UIControlEventTouchUpInside];
    [registerBut setLabelFont:MOLightFont(18)];
    [footer addSubview:registerBut];
    
    return footer;
}

@end
