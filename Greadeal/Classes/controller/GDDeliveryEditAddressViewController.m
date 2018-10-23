//
//  GDDeliveryEditAddressViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/5.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDDeliveryEditAddressViewController.h"
#import "MOItemSelectViewController.h"
#import "RDVTabBarController.h"
#import "MOCountryViewController.h"
#import "ZJSwitch.h"

@implementation GDDeliveryEditAddressViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.backgroundColor = MOColorAppBackgroundColor();
        self.tableView.backgroundView  = nil;
        
        self.canBeChangeArea = YES;
        
        MOInitTableView(self.tableView);
        
        isLoadData = NO;
        setDefault = 0;
        self.addressDict = nil;
        
        float offset = 100;
        if ([GDSettingManager instance].isRightToLeft)
        {
            offset = 30;
        }
        
        name    = [[UITextField alloc]
                    initWithFrame:CGRectMake(offset, 10, 200*[GDPublicManager instance].screenScale, 24)];
        name.keyboardType = UIKeyboardTypeASCIICapable;
        name.returnKeyType = UIReturnKeyNext;
        name.textColor = MOColorTextFieldColor();
        name.delegate = self;
        name.clearButtonMode = UITextFieldViewModeWhileEditing;
        name.placeholder = NSLocalizedString(@"Enter your name",@"输入您的姓名");
        name.font =  MOLightFont(15);
        
        countryBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        countryBut.frame = CGRectMake(offset, 5, 70, 30);
        [countryBut setStyleRedButton];
        [countryBut setTitle:[[GDPublicManager instance] getMobileCountryCode] forState:UIControlStateNormal];
        [countryBut addTarget:self action:@selector(tapCountry) forControlEvents:UIControlEventTouchUpInside];
        [countryBut setLabelFont:MOLightFont(15)];

        
        phoneNumber    = [[UITextField alloc]
                          initWithFrame:CGRectMake(offset+80*[GDPublicManager instance].screenScale, 5, 140*[GDPublicManager instance].screenScale, 30)];
        phoneNumber.keyboardType = UIKeyboardTypePhonePad;
        phoneNumber.returnKeyType = UIReturnKeyNext;
        phoneNumber.textColor = MOColorTextFieldColor();
        phoneNumber.delegate = self;
        phoneNumber.clearButtonMode = UITextFieldViewModeWhileEditing;
        phoneNumber.placeholder = @"551234567";
        [phoneNumber setBorderStyle:UITextBorderStyleRoundedRect];
        phoneNumber.font =  MOLightFont(15);
        
        address = [[UITextField alloc]
                   initWithFrame:CGRectMake(offset, 10, 200*[GDPublicManager instance].screenScale, 24)];
        address.keyboardType = UIKeyboardTypeASCIICapable;
        address.returnKeyType = UIReturnKeyNext;
        address.textColor = MOColorTextFieldColor();
        address.delegate = self;
        address.clearButtonMode = UITextFieldViewModeWhileEditing;
        address.placeholder = NSLocalizedString(@"Enter your address",@"输入您的地址");
        address.font =  MOLightFont(15);
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    if (self.addNew && !isLoadData)
    {
        if ([GDSettingManager instance].userDeliveryInfo!=nil)
        {
            NSDictionary* parameters = [GDSettingManager instance].userDeliveryInfo;
            selCountryId = 221;
            selCityId = [parameters[@"selCityId"] intValue];
            selCommunityId = [parameters[@"selAreaId"] intValue];
            
            selCountry = @"United Arab Emirates";
            selCity = parameters[@"selCity"];
            selCommunity = parameters[@"selArea"];
            
            SET_IF_NOT_NULL(address.text, parameters[@"address"]);
         
        }
       
        self.title = NSLocalizedString(@"New Address",@"添加地址");
        
        name.text = [GDPublicManager instance].username;
        [countryBut setTitle: [GDPublicManager instance].phoneCountry forState:UIControlStateNormal];
        phoneNumber.text = [GDPublicManager instance].phonenumber;
        
    }
    else if (!isLoadData)
    {
        self.title = NSLocalizedString(@"Edit Address",@"编辑地址");
        
        UIBarButtonItem*  delButItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete",@"删除") style:UIBarButtonItemStylePlain target:self action:@selector(tapDel)];
        self.navigationItem.rightBarButtonItem = delButItem;
        
        if (self.addressDict!=nil)
        {
            selCountryId = [self.addressDict[@"country_id"] intValue];
            selCityId = [self.addressDict[@"zone_id"] intValue];
            selCommunityId = [self.addressDict[@"zone_area_id"] intValue];
           
            SET_IF_NOT_NULL(selCountry, self.addressDict[@"country_name"]);
            SET_IF_NOT_NULL(selCity, self.addressDict[@"zone_name"]);
            SET_IF_NOT_NULL(selCommunity, self.addressDict[@"zonearea_name"]);
            SET_IF_NOT_NULL(name.text, self.addressDict[@"firstname"]);
            
            [countryBut setTitle: self.addressDict[@"telephone_area_code"] forState:UIControlStateNormal];

            SET_IF_NOT_NULL(phoneNumber.text, self.addressDict[@"telephone"]);
            SET_IF_NOT_NULL(address.text, self.addressDict[@"address_1"]);
            
            setDefault=[self.addressDict[@"selected"] intValue];
        }
    }
    isLoadData = YES;
    [name becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)selectedCountryNumber:(NSDictionary *)value
{
    LOG(@"%@,%@",value,countryBut.titleLabel.text);
    
    [countryBut setTitle: value[@"id"] forState:UIControlStateNormal];
    
    [self.tableView reloadData];
}

- (void)tapCountry
{
    MOCountryViewController* countryController=[[MOCountryViewController alloc] init];
    countryController.callback = @selector(selectedCountryNumber:);
    countryController.target = self;
    [self.navigationController pushViewController:countryController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selCountry = @"";
    selCity = @"";
    selCommunity = @"";
    selCountryId = 0;
    selCityId =0;
    selCommunityId=0;
   
    NSArray* tempArrar = [GDSettingManager instance].nDeliveryCity;
    if (tempArrar.count>0)
    {
        info = [tempArrar objectAtIndex:0];
    }
}

#pragma mark - Table view data

- (BOOL)checkData
{
    if (countryBut.titleLabel.text.length<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"No Country Code", @"国家区号没有填写")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        return NO;
    }
    
    if (phoneNumber.text.length<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"No Phone Number", @"电话没有填写")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        return NO;
    }

    if (name.text.length<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                       message:NSLocalizedString(@"No Name", @"姓名没有填写")
             cancelButtonTitle:NSLocalizedString(@"OK", nil)
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              
                          }
                      }];
        return NO;
    }

    if (address.text.length<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                       message:NSLocalizedString(@"No Address", @"地址没有填写")
             cancelButtonTitle:NSLocalizedString(@"OK", nil)
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              
                          }
                      }];
        return NO;
    }
    
    if (address.text.length<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"No Address", @"地址没有填写")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        return NO;
    }

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

- (void)tapDel
{
    if (self.addressDict!=nil)
    {
        int address_id = [self.addressDict[@"address_id"] intValue];
        
        [UIAlertView showWithTitle:nil
                           message:NSLocalizedString(@"Are you sure to delete this address?", @"您确定要删除此收货地址吗?")
                 cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
                 otherButtonTitles:@[NSLocalizedString(@"OK", @"确定")]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             if (buttonIndex ==1) {
                 
                 NSString* url;
                 url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/TakeoutAddress/del_address_of_customer"];
                 
                 NSDictionary *parameters=@{@"token":[GDPublicManager instance].token,
                                            @"address_id":@(address_id)};
                 
                 AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                 
                 [manager POST:url
                    parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
                  {
                      int status = [responseObject[@"status"] intValue];
                      if (status==1)
                      {
                          [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
                          [self.navigationController popViewControllerAnimated:YES];
                      }
                      else
                      {
                          NSString *errorInfo =@"";
                          SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
                          LOG(@"errorInfo: %@", errorInfo);
                          [ProgressHUD showError:errorInfo];
                      }
                      
                  }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
                  {
                      LOG(@"%@",operation.responseObject);

                      [ProgressHUD showError:error.localizedDescription];
                }];
             }
             
         }];
    }
}

- (void)tapSave
{
    if ([self checkData])
    {
        NSString* url;
        url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/TakeoutAddress/add_or_update_address"];
        
        NSDictionary *parameters=nil;
        if (self.addNew)
        {
            parameters = @{@"token":[GDPublicManager instance].token,
            @"country_id":@(selCountryId),@"zone_id":@(selCityId),@"area_id":@(selCommunityId),@"firstname":name.text,@"selected":@(setDefault),@"telephone":[NSString stringWithFormat:@"%@-%@",countryBut.titleLabel.text,phoneNumber.text],@"detail_address":address.text};
        }
        else
        {
            if (self.addressDict!=nil)
            {
                int address_id = [self.addressDict[@"address_id"] intValue];
                parameters = @{@"address_id":@(address_id),@"token":[GDPublicManager instance].token,
                                     @"country_id":@(selCountryId),@"zone_id":@(selCityId),@"area_id":@(selCommunityId),@"firstname":name.text,@"selected":@(setDefault),@"telephone":[NSString stringWithFormat:@"%@-%@",countryBut.titleLabel.text,phoneNumber.text],@"telephone_area_code":countryBut.titleLabel.text,@"detail_address":address.text};
            }
        }
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
        [manager POST:url
           parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
             
             if (self.addNew)
             {
                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAddNewAddress object:parameters userInfo:nil];
             }
             [self.navigationController popViewControllerAnimated:YES];
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             [ProgressHUD showError:errorInfo];
         }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
         LOG(@"%@",operation.responseObject);
#if defined MO_DEBUG
             [ProgressHUD showError:error.localizedDescription];
#endif
        }];
    }
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 7;
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
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = NSLocalizedString(@"Name", @"姓名");
        [cell.contentView addSubview:name];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (indexPath.row==1)
    {
        cell.textLabel.text = NSLocalizedString(@"Phone", @"手机号码");
        [cell.contentView addSubview:countryBut];
        [cell.contentView addSubview:phoneNumber];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (indexPath.row==2)
    {
        cell.textLabel.text = NSLocalizedString(@"Country", @"国家");
        cell.detailTextLabel.text = selCountry;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (indexPath.row==3)
    {
        cell.textLabel.text = NSLocalizedString(@"City", @"城市");
        cell.detailTextLabel.text = selCity;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (indexPath.row==4)
    {
        cell.textLabel.text = NSLocalizedString(@"Area", @"区域");
        cell.detailTextLabel.text = selCommunity;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 5)
    {
        cell.textLabel.text = NSLocalizedString(@"Address", @"地址");
        [cell.contentView addSubview:address];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (indexPath.row == 6)
    {
        cell.textLabel.text = NSLocalizedString(@"Setting Default", @"设置默认地址");
        ZJSwitch *switchBut = [[ZJSwitch alloc] initWithFrame:CGRectMake(260, 5, 60, 25)];
        switchBut.backgroundColor = [UIColor clearColor];
        [switchBut addTarget:self action:@selector(handleSwitchEvent:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchBut;
        
        switchBut.onText = NSLocalizedString(@"On",@"开");
        switchBut.offText = NSLocalizedString(@"Off","关");

        if (setDefault==1)
        {
            [switchBut setOn:YES animated:YES];
        }
        else
        {
            [switchBut setOn:NO animated:YES];
        }
    }
    cell.textLabel.font = MOLightFont(15);
    cell.detailTextLabel.font = MOLightFont(15);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    switch (indexPath.row) {
        case 2:
        {
            if (!self.canBeChangeArea)
                return;
            
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
        case 3:
        {
            if (!self.canBeChangeArea)
                return;
            
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
                [ProgressHUD showRemind:NSLocalizedString(@"Downloading city information, please try again later", @"正在下载城市信息,请稍后重试")];
            }
            break;
        }
        case 4:
        {
            if (!self.canBeChangeArea)
                return;
            
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
                        SET_IF_NOT_NULL(areaArray,dict[@"area_list"]);
                        break;
                    }
                }
                
                
                if (areaArray!=nil)
                {
                    for (NSDictionary* dict in areaArray)
                    {
                        
                        NSString*  areaName = @"";
                        int        areaId = [dict[@"area_id"] intValue];
                        SET_IF_NOT_NULL(areaName,dict[@"name"]);
                        
                        [areaDict setObject:areaName forKey:@(areaId)];
                    }
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Note",@"注意")
                            message:NSLocalizedString(@"If you change the delivery address, you may need to pay extra",@"改变收货小区,可能会产生配送费.")
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
                
                MOItemSelectViewController *selectItem = [[MOItemSelectViewController alloc] initWithStyle:UITableViewStylePlain withDict:areaDict value:selCommunity target:self action:@selector(selectedArea:) withTitle:selCity];
                [self.navigationController pushViewController:selectItem animated:YES];
            }
            else
            {
                [ProgressHUD showRemind:NSLocalizedString(@"Downloading city information, please try again later", @"正在下载城市信息,请稍后重试")];
            }
            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGRect r = self.view.bounds;
    
    UIView *footer = [[UIView alloc] initWithFrame:r];
    footer.backgroundColor = [UIColor clearColor];
    
    ACPButton* addBut = [ACPButton buttonWithType:UIButtonTypeCustom];
    addBut.frame = CGRectMake(10, 30, r.size.width-20, 36);
    [addBut setStyleRedButton];
    [addBut setTitle: NSLocalizedString(@"Save", @"保存") forState:UIControlStateNormal];
    [addBut addTarget:self action:@selector(tapSave) forControlEvents:UIControlEventTouchUpInside];
    [addBut setLabelFont:MOLightFont(18)];
    [footer addSubview:addBut];
    
    return footer;
}

#pragma mark - textField Delegate

-(BOOL)textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    
    if (textField == name )
    {
        [phoneNumber becomeFirstResponder];
    }
    else if (textField == phoneNumber)
    {
        [address becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == name)
    {
        if (name.text.length > maxEmailLength && string.length>0)
        {
            return NO;
        } else {
            return YES;
        }
    }
    else if (textField == phoneNumber)
    {
        if (phoneNumber.text.length > maxPhoneLength && string.length>0)
        {
            return NO;
        } else {
            return  [[GDPublicManager instance] validateNumber:string];
        }
    }
    else if (textField == address)
    {
        if (address.text.length > maxAddressLength && string.length>0)
        {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}


- (void)handleSwitchEvent:(id)sender
{
    ZJSwitch *button = (ZJSwitch *)sender;
    if (![button isKindOfClass:ZJSwitch.class]) {
        return;
    }
    
    if (button.isOn)
    {
        setDefault = 1;
    }
    else
    {
        setDefault = 0;
    }
}

@end
