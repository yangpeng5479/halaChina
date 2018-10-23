#import "GDEditProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ZJSwitch.h"
#import "RDVTabBarController.h"

@interface GDEditProfileViewController ()

@end

@implementation GDEditProfileViewController

- (void)exit
{
    [email resignFirstResponder];
    
    [userpass resignFirstResponder];
    [username resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Button Event
/////////////////////////////////////////////////////////////////////////////////
- (void)tapSignUp
{
    if (email.text.length<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
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
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"E-Mail Format Error", @"邮件格式错误")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        
        return;
    }
    
    if (username.text.length<MinNameLength)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"Your name should contain 3 or more characters", @"您的用户名至少要有3位")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        return;
    }
    
    if (userpass.text.length < MinPassLength)
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
    
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/update_baseinfo"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString* sha1 = [[GDPublicManager instance] getSha1String:userpass.text];
    
    NSDictionary *parameters;
    
    parameters = @{@"email":email.text,@"pwdsha1":sha1,@"fname":username.text,@"token":[GDPublicManager instance].token};
    
    [ProgressHUD show:NSLocalizedString(@"Processing...", @"处理中...") Interaction:NO];
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"JSON: %@", responseObject);
         [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             [GDPublicManager instance].username = username.text;
             [GDPublicManager instance].email    = email.text;
             
             int customer_id = [GDPublicManager instance].cid;
             
             [[WCDatabaseManager instance] Login:email.text withid:customer_id withCountry:[GDPublicManager instance].phoneCountry withPhone:[GDPublicManager instance].phonenumber withpass:sha1];
             
             [self exit];
             
             [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
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
/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark INIT

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [ProgressHUD dismiss];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        self.title = NSLocalizedString(@"Edit Profile",@"编辑个人资料");
       
        
        self.tableView.backgroundColor = MOColorAppBackgroundColor();
        self.tableView.backgroundView  = nil;
        MOInitTableView(self.tableView);
        
        email    = [[UITextField alloc]
                    initWithFrame:CGRectMake(70, 10, 220*[GDPublicManager instance].screenScale, 24)];
        email.keyboardType = UIKeyboardTypeEmailAddress;
        email.returnKeyType = UIReturnKeyNext;
        email.autocorrectionType = UITextAutocorrectionTypeNo;
        email.autocapitalizationType = UITextAutocapitalizationTypeNone;
        email.textColor = MOColorTextFieldColor();
        email.delegate = self;
        email.clearButtonMode = UITextFieldViewModeWhileEditing;
        email.placeholder = NSLocalizedString(@"Enter your e-mail",@"输入您的邮箱");
        email.text = [GDPublicManager instance].email;
        
        username   = [[UITextField alloc]
                      initWithFrame:CGRectMake(70, 10, 220*[GDPublicManager instance].screenScale, 24)];
        username.keyboardType = UIKeyboardTypeASCIICapable;
        username.returnKeyType = UIReturnKeyNext;
        username.autocorrectionType = UITextAutocorrectionTypeNo;
        username.autocapitalizationType = UITextAutocapitalizationTypeNone;
        username.textColor = MOColorTextFieldColor();
        username.delegate = self;
        username.clearButtonMode = UITextFieldViewModeWhileEditing;
        username.placeholder = NSLocalizedString(@"Enter your name",@"输入您的姓名");
        username.text = [GDPublicManager instance].username;
        
        userpass = [[UITextField alloc]
                    initWithFrame:CGRectMake(70, 10, 160*[GDPublicManager instance].screenScale, 24)];
        
        userpass.keyboardType = UIKeyboardTypeASCIICapable;
        userpass.returnKeyType = UIReturnKeyDone;
        userpass.autocorrectionType = UITextAutocorrectionTypeNo;
        userpass.autocapitalizationType = UITextAutocapitalizationTypeNone;
        userpass.textColor = MOColorTextFieldColor();
        userpass.delegate = self;
        userpass.secureTextEntry = YES;
        userpass.clearButtonMode = UITextFieldViewModeWhileEditing;
        userpass.placeholder = NSLocalizedString(@"Enter password",@"输入密码");
        
        UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 120)];
        
        ACPButton *editBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        editBut.frame = CGRectMake(10, (footerView.frame.size.height-40)/2, self.view.bounds.size.width-20, 40);
        [editBut setStyleRedButton];
        [editBut setTitle: NSLocalizedString(@"Save", @"保存") forState:UIControlStateNormal];
        [editBut addTarget:self action:@selector(tapSignUp) forControlEvents:UIControlEventTouchUpInside];
        [editBut setLabelFont:MOLightFont(16)];
        
        [footerView addSubview:editBut];
        
        self.tableView.tableFooterView = footerView;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - textField Delegate

-(BOOL)textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    
    if (textField == email )
    {
        [username becomeFirstResponder];
    }
    else if (textField == username)
    {
        [userpass becomeFirstResponder];
    }
    else if (textField == userpass)
    {
        [textField resignFirstResponder];
    }
    
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
    else if (textField == userpass)
    {
        if (userpass.text.length > maxPassLength && string.length>0)
        {
            return NO;
        } else {
            return YES;
        }
    }
    else if (textField == username)
    {
        if (username.text.length > maxNameLength && string.length>0)
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
        userpass.secureTextEntry = NO;
    }
    else
    {
        userpass.secureTextEntry = YES;
    }
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
    return 3;
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
        
        cell.imageView.image = [UIImage imageNamed:@"email.png"];
        [cell.contentView addSubview:email];
        [email becomeFirstResponder];
    }
    else if (indexPath.row==1)
    {
        cell.imageView.image = [UIImage imageNamed:@"user.png"];
        [cell.contentView addSubview:username];
    }
    else if (indexPath.row==2)
    {
        cell.imageView.image = [UIImage imageNamed:@"locker.png"];
        [cell.contentView addSubview:userpass];
        
        ZJSwitch *switchBut = [[ZJSwitch alloc] initWithFrame:CGRectMake(260, 5, 60, 25)];
        switchBut.backgroundColor = [UIColor clearColor];
        [switchBut addTarget:self action:@selector(handleSwitchEvent:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchBut;
        
        switchBut.on = YES;
        switchBut.onText = NSLocalizedString(@"On",@"开");
        switchBut.offText = NSLocalizedString(@"Off",@"关");
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end