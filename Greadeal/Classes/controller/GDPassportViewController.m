#import "GDPassportViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ZJSwitch.h"
#import "RDVTabBarController.h"

@interface GDPassportViewController ()

@end

@implementation GDPassportViewController

- (void)exit
{
    [iDLable resignFirstResponder];
    [passportLable resignFirstResponder];
    [userName resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Button Event
/////////////////////////////////////////////////////////////////////////////////
- (void)tapSignUp
{
    if (passportLable.text.length<=0 && iDLable.text.length<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"No ID Or Passport", @"身份证或者护照没有填写")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        return;
    }
    
    if (userName.text.length<=0 && userName.text.length<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"No Name", @"姓名没有填写")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        return;

    }

    
  
    if ([self.target respondsToSelector:self.callback])
    {
        NSDictionary *parameters;
        parameters = @{@"id":iDLable.text,@"passport":passportLable.text,@"username":userName.text};
        
        [self.target performSelector:self.callback withObject:parameters afterDelay:0];
    }
             
    [self exit];
             
    
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
        
        self.title = NSLocalizedString(@"ID Or Passport",@"身份证 或 护照");
        
        self.tableView.backgroundView  = nil;
        MOInitTableView(self.tableView);
        self.tableView.backgroundColor = MOLiveBackgroundColor();
        
        float offsetX = 100;
        if ([GDSettingManager instance].isRightToLeft)
        {
            offsetX = 15;
        }
        
        iDLable    = [[UITextField alloc]
                            initWithFrame:CGRectMake(offsetX, 10, 200*[GDPublicManager instance].screenScale, 24)];
        iDLable.keyboardType = UIKeyboardTypeDefault;
        iDLable.returnKeyType = UIReturnKeyDone;
        iDLable.autocorrectionType = UITextAutocorrectionTypeNo;
        iDLable.autocapitalizationType = UITextAutocapitalizationTypeNone;
        iDLable.textColor = MOColorTextFieldColor();
        iDLable.delegate = self;
        iDLable.text = @"";
        iDLable.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        passportLable    = [[UITextField alloc]
                    initWithFrame:CGRectMake(offsetX, 10, 200*[GDPublicManager instance].screenScale, 24)];
        passportLable.keyboardType = UIKeyboardTypeDefault;
        passportLable.returnKeyType = UIReturnKeyDone;
        passportLable.autocorrectionType = UITextAutocorrectionTypeNo;
        passportLable.autocapitalizationType = UITextAutocapitalizationTypeNone;
        passportLable.textColor = MOColorTextFieldColor();
        passportLable.delegate = self;
        passportLable.clearButtonMode = UITextFieldViewModeWhileEditing;
        passportLable.text = @"";
      
        userName= [[UITextField alloc]
                   initWithFrame:CGRectMake(offsetX, 10, 200*[GDPublicManager instance].screenScale, 24)];
        userName.keyboardType = UIKeyboardTypeDefault;
        userName.returnKeyType = UIReturnKeyDone;
        userName.autocorrectionType = UITextAutocorrectionTypeNo;
        userName.autocapitalizationType = UITextAutocapitalizationTypeNone;
        userName.textColor = MOColorTextFieldColor();
        userName.delegate = self;
        userName.clearButtonMode = UITextFieldViewModeWhileEditing;
        userName.text = @"";

        
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
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == iDLable)
    {
        if (iDLable.text.length > maxEmailLength && string.length>0)
        {
            return NO;
        } else {
            return YES;
        }
    }
    
    if (textField == passportLable)
    {
        if (passportLable.text.length > maxEmailLength && string.length>0)
        {
            return NO;
        } else {
            return YES;
        }
    }
   
    if (textField == userName)
    {
        if (userName.text.length > maxNameLength && string.length>0)
        {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if  (section == 0)
        return 50;
    else
        return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UILabel* titleLabel = MOCreateLabelAutoRTL();
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font =  MOLightFont(14);
        titleLabel.text =  NSLocalizedString(@"ID or Passport number is required for hotel check-in", @"酒店要求入住人员提供身份证或者护照号");
        titleLabel.numberOfLines = 0;
        
        CGRect r =self.view.bounds;
        UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, 0, r.size.width, 50)];
        titleLabel.frame = CGRectMake(r.origin.x+15, 0, r.size.width-30, 60);
        hView.backgroundColor = MOSectionBackgroundColor();
        
        [hView addSubview:titleLabel];
    
    
        return hView;
    }
    if (section == 1)
    {
        UILabel* titleLabel = MOCreateLabelAutoRTL();
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font =  MOLightFont(14);
        titleLabel.text =  NSLocalizedString(@"Please enter your name", @"请输入您的姓名");
        titleLabel.numberOfLines = 0;
        
        CGRect r =self.view.bounds;
        UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, 0, r.size.width, 50)];
        titleLabel.frame = CGRectMake(r.origin.x+15, 0, r.size.width-30, 60);
        hView.backgroundColor = MOSectionBackgroundColor();
        
        [hView addSubview:titleLabel];
        
        
        return hView;

    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return 2;
    else
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
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text= NSLocalizedString(@"ID", @"身份证");
            [cell.contentView addSubview:iDLable];
        
            [iDLable becomeFirstResponder];
        }
        else
        {
            cell.textLabel.text= NSLocalizedString(@"Passport", @"护照号");
            [cell.contentView addSubview:passportLable];
        }
    }
    else if (indexPath.section == 1)
    {
        cell.textLabel.text= NSLocalizedString(@"Name", @"姓名");
        [cell.contentView addSubview:userName];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end