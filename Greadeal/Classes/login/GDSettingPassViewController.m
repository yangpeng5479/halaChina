//
//  GDSettingPassViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/27.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDSettingPassViewController.h"
#import "ZJSwitch.h"

@interface GDSettingPassViewController ()

@end

@implementation GDSettingPassViewController

@synthesize phonenumber;

static int countValue[] = {3, 10, 30};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    finishCount = NO;
    countIndex  = 0 ;
    
    CGRect r = self.view.bounds;
    
    UILabel* heaeView = MOCreateLabelAutoRTL();
    heaeView.frame = CGRectMake(r.origin.x+10, r.origin.y, r.size.width-20, 30);
    heaeView.font = MOLightFont(14);
    heaeView.textColor = [UIColor grayColor];
    heaeView.backgroundColor = [UIColor clearColor];
    heaeView.text = NSLocalizedString(@"Verification code has been sent to your phone",@"验证码已送到您的手机号码");
    self.tableView.tableHeaderView = heaeView;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getCodeAgain
{
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/forget_password"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"phone":self.phonenumber};
    
    [ProgressHUD show:NSLocalizedString(@"Processing...",@"处理中...")];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"JSON: %@", responseObject);
         [ProgressHUD dismiss];
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             [UIAlertView showWithTitle:nil
                                message: NSLocalizedString(@"Verification code has been sent to your phone",@"验证码已送到您的手机号码")
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil
                               tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                   if (buttonIndex == [alertView cancelButtonIndex]) {
                                       
                                   }
                               }];
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

- (void)teleButtonEvent
{
    if (countIndex<2)
    {
        countIndex++;
        [self getCodeAgain];
        
        [countDown setCountDownTime:countValue[countIndex]*60];
        [countDown start];
        
        logoutBut.enabled = YES;
        finishCount = NO;
        
        [self.tableView reloadData];
    }
    else
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"Can Only send 3 SMS every day", @"一天只能发送3条短信")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
    }
}
#pragma mark -
#pragma mark INIT

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    [verifypass resignFirstResponder];
    [ProgressHUD dismiss];
}

- (void)reSetting
{
   
    if (verifypass.text.length<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                        message:NSLocalizedString(@"No verification code", @"验证码没有填写")
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      
                                  }
                              }];
                return;
        }
        
    
     if (newPass.text.length<=0)
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                               message:NSLocalizedString(@"No Password", @"新密码没有填写")
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      
                                  }
                              }];
            return;
        }
    
    if (newPass.text.length < MinPassLength)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"Your password should contain 4 or more characters", @"您的密码至少要有4位")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        return;
    }
    
    NSString* sha1 = [[GDPublicManager instance] getSha1String:newPass.text];
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/modify_password_by_phone"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"vercode":verifypass.text,@"new_pwdsha1":sha1,@"phone":self.phonenumber};
    
    [ProgressHUD show:NSLocalizedString(@"Processing...", @"处理中...")];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"JSON: %@", responseObject);
         [ProgressHUD dismiss];
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             [GDPublicManager instance].loginstauts = UNLOGIN;
             
             [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidLogout object:nil userInfo:nil];
             
             [UIAlertView showWithTitle:NSLocalizedString(@"Successfully", @"成功")
                                message:NSLocalizedString(@"Password reset successfully! please login again.", @"重置密码成功,请重新登录")
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil
                               tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                   if (buttonIndex == [alertView cancelButtonIndex]) {
                                       [self.navigationController popToRootViewControllerAnimated:YES];
                                   }
                               }];
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
         LOG(@"error: %@", operation.response);
         [ProgressHUD showError:error.localizedDescription];
     }];

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
      
        self.title = NSLocalizedString(@"Reset Password",@"重置登录密码");
        
        self.tableView.backgroundColor = MOColorAppBackgroundColor();
        self.tableView.backgroundView  = nil;
        MOInitTableView(self.tableView);
        
        verifypass    = [[UITextField alloc]
                          initWithFrame:CGRectMake(140, 5, 100*[GDPublicManager instance].screenScale, 30)];
        verifypass.keyboardType = UIKeyboardTypePhonePad;
        verifypass.returnKeyType = UIReturnKeyNext;
        verifypass.textColor = MOColorTextFieldColor();
        verifypass.delegate = self;
        verifypass.clearButtonMode = UITextFieldViewModeWhileEditing;
        verifypass.placeholder = NSLocalizedString(@"Code",@"验证码");
        [verifypass becomeFirstResponder];
        [verifypass setBorderStyle:UITextBorderStyleRoundedRect];
        
        newVerify= [[UILabel alloc] initWithFrame:CGRectMake(245*[GDPublicManager instance].screenScale, 0,65*[GDPublicManager instance].screenScale,40)];
        newVerify.font = MOLightFont(14);
        newVerify.textAlignment = NSTextAlignmentRight;
        newVerify.textColor = [UIColor redColor];
        newVerify.backgroundColor = [UIColor clearColor];
        newVerify.text = NSLocalizedString(@"Get Code",@"获取验证码");
        newVerify.userInteractionEnabled=YES;
        UITapGestureRecognizer *tapGestureTel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(teleButtonEvent)];
        [newVerify addGestureRecognizer:tapGestureTel];
        MODebugLayer(newVerify, 1.f, [UIColor redColor].CGColor);
        
        countDown = [[MZTimerLabel alloc] initWithFrame:CGRectMake(210*[GDPublicManager instance].screenScale, 8, 90*[GDPublicManager instance].screenScale, 20)];
        countDown.timerType = MZTimerLabelTypeTimer;
        countDown.timeFormat = @"mm:ss";
        [countDown setCountDownTime:countValue[countIndex]*60];
        countDown.timeLabel.backgroundColor = [UIColor clearColor];
        countDown.timeLabel.font = MOLightFont(14);
        countDown.timeLabel.textColor = [UIColor redColor];
        countDown.timeLabel.textAlignment = NSTextAlignmentRight;
        countDown.delegate = self;
        [countDown start];
       
        
        newPass    = [[UITextField alloc]
                         initWithFrame:CGRectMake(140, 5, 100*[GDPublicManager instance].screenScale, 30)];
        newPass.keyboardType = UIKeyboardTypeASCIICapable;
        newPass.returnKeyType = UIReturnKeyDone;
        newPass.autocorrectionType = UITextAutocorrectionTypeNo;
        newPass.autocapitalizationType = UITextAutocapitalizationTypeNone;
        newPass.textColor = MOColorTextFieldColor();
        newPass.delegate = self;
        newPass.secureTextEntry = YES;
        newPass.clearButtonMode = UITextFieldViewModeWhileEditing;
        newPass.placeholder = NSLocalizedString(@"Enter password",@"输入新密码");
        
    }
    return self;
}

#pragma mark - textField Delegate

-(BOOL)textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == verifypass)
    {
        if (verifypass.text.length > maxVerifyLength && string.length>0)
        {
            return NO;
        } else {
            return YES;
        }
    }
    else if (textField == newPass)
    {
        if (newPass.text.length > maxPassLength && string.length>0)
        {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
    UILabel* titleLabel = MOCreateLabelAutoRTL();
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = MOLightFont(14);
    titleLabel.numberOfLines = 0;
    titleLabel.text = NSLocalizedString(@"A message with verification code has been sent to your phone.", @"一条带有验证码的短信已经发送到您的手机");
    
    CGRect r =self.view.bounds;
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, 0, r.size.width, 40)];
    
    titleLabel.frame = CGRectMake(r.origin.x+10, 0, r.size.width-20, 40);
    
    [hView addSubview:titleLabel];
    
    hView.backgroundColor =[UIColor colorWithRed:(254/255.0) green:(254/255.0) blue:(254/255.0) alpha:1.0];
    
    return hView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return  40;
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
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
    
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    if (indexPath.section == 0)
    {
       // cell.imageView.image = [UIImage imageNamed:@"verify.png"];
        cell.textLabel.text = NSLocalizedString(@"Verification",@"验证码");
        [cell.contentView addSubview:verifypass];
        if (finishCount)
            [cell.contentView addSubview:newVerify];
        else
            [cell.contentView addSubview:countDown];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1)
    {
        cell.textLabel.text = NSLocalizedString(@"New Password",@"新密码");
        [cell.contentView addSubview:newPass];
        
        ZJSwitch *switchBut = [[ZJSwitch alloc] initWithFrame:CGRectMake(260*[GDPublicManager instance].screenScale, 5, 60*[GDPublicManager instance].screenScale, 25)];
        switchBut.backgroundColor = [UIColor clearColor];
        [switchBut addTarget:self action:@selector(handleSwitchEvent:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchBut;
        switchBut.on = YES;
        
        switchBut.onText = NSLocalizedString(@"On",@"开");
        switchBut.offText = NSLocalizedString(@"Off","关");
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)handleSwitchEvent:(id)sender
{
    ZJSwitch *button = (ZJSwitch *)sender;
    if (![button isKindOfClass:ZJSwitch.class]) {
        return;
    }
    if (button.isOn)
    {
        newPass.secureTextEntry = NO;
    }
    else
    {
        newPass.secureTextEntry = YES;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1)
        return 60;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        CGRect r = self.view.bounds;
    
        UIView *footer = [[UIView alloc] initWithFrame:r];
    
        logoutBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        logoutBut.frame = CGRectMake(10, 20, self.view.bounds.size.width-20, 40);
        [logoutBut setStyleRedButton];
        [logoutBut setTitle: NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
        [logoutBut addTarget:self action:@selector(reSetting) forControlEvents:UIControlEventTouchUpInside];
        [logoutBut setLabelFont:MOLightFont(18)];
        [footer addSubview:logoutBut];
        
        return footer;
    }
    
    return nil;
}


-(void)timerLabel:(MZTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime
{
    finishCount = YES;
    logoutBut.enabled = NO;
    [self.tableView reloadData];
}

@end
