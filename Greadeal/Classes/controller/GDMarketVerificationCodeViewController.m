//
//  GDMarketVerificationCodeViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/29.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDMarketVerificationCodeViewController.h"
#import "RDVTabBarController.h"

@interface GDMarketVerificationCodeViewController ()

@end

@implementation GDMarketVerificationCodeViewController

@synthesize userPhone;
@synthesize address_id;

static int countValue[] = {3, 10, 30};


- (void)viewDidLoad {
    [super viewDidLoad];
    
    finishCount = NO;
    countIndex =0 ;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)teleButtonEvent
{
    if (countIndex<2)
    {
        countIndex++;
        [self GetVerification];
    }
    
    [countDown setCountDownTime:countValue[countIndex]*60];
    [countDown start];
    
    okBut.enabled = YES;
    finishCount = NO;
    
    [self.tableView reloadData];
}
#pragma mark -
#pragma mark INIT

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    [self GetVerification];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [verifypass resignFirstResponder];
    [ProgressHUD dismiss];
}

- (void)GetVerification
{
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Message/send_cod_vercode"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"address_id":@(address_id),@"token":[GDPublicManager instance].token};
    
    [ProgressHUD show:NSLocalizedString(@"Processing...", @"处理中...")];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"JSON: %@", responseObject);
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             [ProgressHUD showSuccess:NSLocalizedString(@"Verification code has been sent to your phone", @"验证码已送到您的手机号码")];
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

- (void)GotVerification
{
    if (verifypass.text.length<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"No Verification Code", @"验证码没有填写")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Message/verify_cod_vercode"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"vercode":verifypass.text,@"address_id":@(address_id),@"token":[GDPublicManager instance].token,@"vercode":verifypass.text};
    
    [ProgressHUD show:NSLocalizedString(@"Processing...", @"处理中...")];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"JSON: %@", responseObject);
         [ProgressHUD dismiss];
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             if ([self.target respondsToSelector:self.callback])
             {
                 [self.target performSelector:self.callback withObject:nil afterDelay:0];
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
         LOG(@"error: %@", operation.response);
         [ProgressHUD showError:error.localizedDescription];
     }];
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        self.title = NSLocalizedString(@"Verification",@"验证");
        
        self.tableView.backgroundColor = MOColorAppBackgroundColor();
        self.tableView.backgroundView  = nil;
        MOInitTableView(self.tableView);
        
        verifypass    = [[UITextField alloc]
                         initWithFrame:CGRectMake(140, 5, 100, 30)];
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
       // MODebugLayer(newVerify, 1.f, [UIColor redColor].CGColor);
        
        countDown = [[MZTimerLabel alloc] initWithFrame:CGRectMake(210, 8, 90, 20)];
        countDown.timerType = MZTimerLabelTypeTimer;
        countDown.timeFormat = @"mm:ss";
        [countDown setCountDownTime:countValue[countIndex]*60];
        countDown.timeLabel.backgroundColor = [UIColor clearColor];
        countDown.timeLabel.font = MOLightFont(14);
        countDown.timeLabel.textColor = [UIColor redColor];
        countDown.timeLabel.textAlignment = NSTextAlignmentRight;
        countDown.delegate = self;
        [countDown start];
        
        okBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        okBut.frame = CGRectMake(0, 0, self.view.bounds.size.width, 36);
        [okBut setStyleRedButton];
        [okBut setTitle: NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
        [okBut addTarget:self action:@selector(GotVerification) forControlEvents:UIControlEventTouchUpInside];
        [okBut setLabelFont:MOLightFont(18)];
        
        self.tableView.tableFooterView = okBut;
        
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
        titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"A message with verification code has been sent to your phone %@.", @"一条带有验证码的短信已经发送到您的手机 %@"),userPhone];
        
        CGRect r =self.view.bounds;
        UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, 0, r.size.width, 40)];
        
        titleLabel.frame = CGRectMake(r.origin.x+10, 0, r.size.width-30, 40);
        
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
  
    return cell;
}

-(void)timerLabel:(MZTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime
{
    finishCount = YES;
    okBut.enabled = NO;
    [self.tableView reloadData];
}

@end
