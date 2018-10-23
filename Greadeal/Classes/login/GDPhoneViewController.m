#import "GDPhoneViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ZJSwitch.h"
#import "RDVTabBarController.h"

@interface GDPhoneViewController ()

@end

@implementation GDPhoneViewController

- (void)exit
{
    [phonecall resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Button Event
/////////////////////////////////////////////////////////////////////////////////
- (void)tapSignUp
{
    if (phonecall.text.length<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"No Phone Number", @"没填电话号码")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        return;
    }
    if (phonecall.text.length < MinPhoneLength)
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

    
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/update_baseinfo"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    NSDictionary *parameters;
    
    parameters = @{@"phone":phonecall.text,@"token":[GDPublicManager instance].token};
    
    [ProgressHUD show:NSLocalizedString(@"Processing...", @"处理中...") Interaction:NO];
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"JSON: %@", responseObject);
         [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             [GDPublicManager instance].phonenumber = phonecall.text;
           
             if ([self.target respondsToSelector:self.callback])
             {
                 [self.target performSelector:self.callback withObject:nil afterDelay:0];
             }
             
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
        
        self.title = NSLocalizedString(@"Phone Number",@"电话号码");
        
        self.tableView.backgroundColor = MOColorAppBackgroundColor();
        self.tableView.backgroundView  = nil;
        MOInitTableView(self.tableView);
        
        phonecall    = [[UITextField alloc]
                    initWithFrame:CGRectMake(70, 10, 220*[GDPublicManager instance].screenScale, 24)];
        phonecall.keyboardType = UIKeyboardTypeEmailAddress;
        phonecall.returnKeyType = UIReturnKeyNext;
        phonecall.autocorrectionType = UITextAutocorrectionTypeNo;
        phonecall.autocapitalizationType = UITextAutocapitalizationTypeNone;
        phonecall.textColor = MOColorTextFieldColor();
        phonecall.delegate = self;
        phonecall.clearButtonMode = UITextFieldViewModeWhileEditing;
        phonecall.placeholder = NSLocalizedString(@"Enter your phone number",@"输入您的电话号码");
      
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
    if (textField == phonecall)
    {
        if (phonecall.text.length > maxEmailLength && string.length>0)
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
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
   
    UILabel* titleLabel = MOCreateLabelAutoRTL();
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font =  MOLightFont(14);
    titleLabel.text =  NSLocalizedString(@"Please enter your phone number, we will contact you after you placing an order successfully.", @"请输入您的电话号码,订单成功后,我们会与您联系");
    titleLabel.numberOfLines = 0;
        
    CGRect r =self.view.bounds;
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, 0, r.size.width, 60)];
    titleLabel.frame = CGRectMake(r.origin.x+15, 0, r.size.width-30, 60);
    hView.backgroundColor = MOSectionBackgroundColor();
        
    [hView addSubview:titleLabel];
    return hView;
  
}

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
        
        cell.imageView.image = [UIImage imageNamed:@"phone.png"];
        [cell.contentView addSubview:phonecall];
        [phonecall becomeFirstResponder];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end