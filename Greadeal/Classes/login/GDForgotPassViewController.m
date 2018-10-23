//
//  GDForgotPassViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/27.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDForgotPassViewController.h"
#import "GDSettingPassViewController.h"
#import "MOCountryViewController.h"

@interface GDForgotPassViewController ()

@end

@implementation GDForgotPassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MOInitTableView(self.tableView);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark INIT

- (void)exit
{
    [email resignFirstResponder];
    [phoneNumber resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reSetting
{
    if (useEmail)
    {
        if (email.text.length<=0)
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"错误")
            message:NSLocalizedString(@"No E-Mail", @"邮件没有填写")
            cancelButtonTitle:NSLocalizedString(@"OK", nil)
            otherButtonTitles:nil
            tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == [alertView cancelButtonIndex]) {
               
            }
        }];
            return;
        }
        
        if (![[GDPublicManager instance] NSStringIsValidEmail:email.text])
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"错误")
                               message:NSLocalizedString(@"Error e-Mail Format", nil)
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      
                                  }
                                  }];
            return;
        }
        
        NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/forget_password"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"email":email.text};
        
        [ProgressHUD show:NSLocalizedString(@"Requesting...", @"请求...")];
        
        [manager POST:url
           parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             LOG(@"JSON: %@", responseObject);
             [ProgressHUD dismiss];
             int status = [responseObject[@"status"] intValue];
             if (status==1)
             {
                 [ProgressHUD showSuccess:NSLocalizedString(@"Password has been sent, please check your E-Mail", @"重置密码已发送,请到您的邮箱查收")];
                 [self exit];
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
             [ProgressHUD dismiss];
             LOG(@"error: %@", error.localizedDescription);
             [ProgressHUD showError:error.localizedDescription];

         }];
    }
    else
    {
        if (countryBut.titleLabel.text.length < MinCountryLength)
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                               message:NSLocalizedString(@"Your country code should contain 2 or more characters", @"您的国家区号至少要有2位")
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      
                                  }
                              }];
            return;
        }
        
        if (phoneNumber.text.length < MinPhoneLength)
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                               message:NSLocalizedString(@"Your phonenumber should contain 7 or more characters", @"您的电话号码至少要有7位")
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      
                                  }
                              }];
            return;
        }
        else
        {
            NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/forget_password"];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSDictionary *parameters = @{@"phone":[NSString stringWithFormat:@"%@-%@",countryBut.titleLabel.text,phoneNumber.text]};
            
            [ProgressHUD show:NSLocalizedString(@"Processing...",@"处理中...")];
            
            [manager POST:url
               parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 LOG(@"JSON: %@", responseObject);
                 [ProgressHUD dismiss];
                 int status = [responseObject[@"status"] intValue];
                 if (status==1)
                 {
                    GDSettingPassViewController* nv = [[GDSettingPassViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    nv.phonenumber = [NSString stringWithFormat:@"%@-%@",countryBut.titleLabel.text,phoneNumber.text];
                    [self.navigationController pushViewController:nv animated:YES];
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
                 LOG(@"error: %@", error.localizedDescription);
                 [ProgressHUD showError:error.localizedDescription];
             }];
        }
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        useEmail = NO;
        self.title = NSLocalizedString(@"Forgot Password",@"忘记密码");
        
        
        self.tableView.backgroundColor = MOColorAppBackgroundColor();
        self.tableView.backgroundView  = nil;
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back","返回") style:UIBarButtonItemStylePlain target:self action:@selector(exit)];
        
//        CGRect r = self.view.bounds;
        
//        RFSegmentView* segmentView = [[RFSegmentView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, 50) items:@[NSLocalizedString(@"E-Mail",@"邮箱账号"),NSLocalizedString(@"Phone Number",@"手机帐号")]];
//        
//        segmentView.tintColor = [UIColor colorWithRed:0.0862745 green:0.658824 blue:0.913725 alpha:1.0];
//        segmentView.delegate = self;
//        self.tableView.tableHeaderView = segmentView;
//
        float offsetX =70;
        if ([GDSettingManager instance].isRightToLeft)
        {
            offsetX = 15;
        }
        
        email    = [[UITextField alloc]
                    initWithFrame:CGRectMake(offsetX, 12, 220*[GDPublicManager instance].screenScale, 24)];
        email.keyboardType = UIKeyboardTypeEmailAddress;
        email.returnKeyType = UIReturnKeyDone;
        email.autocorrectionType = UITextAutocorrectionTypeNo;
        email.autocapitalizationType = UITextAutocapitalizationTypeNone;
        email.textColor = MOColorTextFieldColor();
        email.delegate = self;
        email.clearButtonMode = UITextFieldViewModeWhileEditing;
        email.placeholder = NSLocalizedString(@"Enter your e-mail",@"输入您的邮箱");
        
        countryBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        countryBut.frame = CGRectMake(offsetX, 5, 70, 30);
        [countryBut setStyleRedButton];
        [countryBut setTitle:[[GDPublicManager instance] getMobileCountryCode] forState:UIControlStateNormal];
        [countryBut addTarget:self action:@selector(tapCountry) forControlEvents:UIControlEventTouchUpInside];
        [countryBut setLabelFont:MOLightFont(18)];
        
        [countryBut setTitle: [GDPublicManager instance].phoneCountry forState:UIControlStateNormal];
        
        phoneNumber    = [[UITextField alloc]
                          initWithFrame:CGRectMake([GDSettingManager instance].isRightToLeft?100:150, 5, 150*[GDPublicManager instance].screenScale, 30)];
        phoneNumber.keyboardType = UIKeyboardTypePhonePad;
        phoneNumber.returnKeyType = UIReturnKeyDone;
        phoneNumber.autocorrectionType = UITextAutocorrectionTypeNo;
        phoneNumber.autocapitalizationType = UITextAutocapitalizationTypeNone;
        phoneNumber.textColor = MOColorTextFieldColor();
        phoneNumber.delegate = self;
        phoneNumber.clearButtonMode = UITextFieldViewModeWhileEditing;
        [phoneNumber setBorderStyle:UITextBorderStyleRoundedRect];
        phoneNumber.placeholder = @"551234567";
        phoneNumber.text = [GDPublicManager instance].phonenumber;
        
        NSMutableDictionary* userdata = [[WCDatabaseManager instance] getUserInfo];
        email.text = [userdata objectForKey:@"useremail"];
        NSString* temp = [userdata objectForKey:@"userphone"];
        if (temp.length>0)
            phoneNumber.text = temp;
        
        temp = [userdata objectForKey:@"phonecountry"];
        if (temp.length>0)
            [countryBut setTitle: [userdata objectForKey:@"phonecountry"] forState:UIControlStateNormal];
        
    }
    return self;
}

- (void)tapCountry
{
    MOCountryViewController* countryController=[[MOCountryViewController alloc] init];
    countryController.callback = @selector(selectedCountryNumber:);
    countryController.target = self;
    [self.navigationController pushViewController:countryController animated:YES];
}

- (void)selectedCountryNumber:(NSDictionary *)value
{
    LOG(@"%@,%@",value,countryBut.titleLabel.text);
    
    [countryBut setTitle: value[@"id"] forState:UIControlStateNormal];
    
    [self.tableView reloadData];
}

#pragma mark - textField Delegate

-(BOOL)textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == email)
    {
        if (email.text.length > maxEmailLength && string.length>0)
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
    return NO;
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
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 0)
    {
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        if (useEmail)
        {
            cell.imageView.image = [UIImage imageNamed:@"email.png"];
            [cell.contentView addSubview:email];
            [email becomeFirstResponder];
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"phone.png"];
            [cell.contentView addSubview:countryBut];
            [cell.contentView addSubview:phoneNumber];
            [phoneNumber becomeFirstResponder];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGRect r = self.view.bounds;
    
    UIView *footer = [[UIView alloc] initWithFrame:r];
  
    ACPButton* logoutBut = [ACPButton buttonWithType:UIButtonTypeCustom];
    logoutBut.frame = CGRectMake(10, 20, self.view.bounds.size.width-20, 40);
    [logoutBut setStyleRedButton];
    [logoutBut setTitle: NSLocalizedString(@"Reset Password", @"重置密码") forState:UIControlStateNormal];
    [logoutBut addTarget:self action:@selector(reSetting) forControlEvents:UIControlEventTouchUpInside];
    [logoutBut setLabelFont:MOLightFont(18)];
    [footer addSubview:logoutBut];
    
    return footer;
}

#pragma mark - RFSegment

//- (void)segmentViewSelectIndex:(NSInteger)index
//{
//    if (index == 0)
//        useEmail = YES;
//    else
//        useEmail = NO;
//    [self.tableView reloadData];
//}


@end
