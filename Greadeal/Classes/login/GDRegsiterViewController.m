//
//  GDRegsiterViewController.m
//  greadeal
//
//  Created by tao tao on 06/06/13.
//  Copyright (c) 2013年 tao tao. All rights reserved.
//

#import "GDRegsiterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ZJSwitch.h"
#import "MOCountryViewController.h"

#define faceBookButSize  35

#define butViewWidth  90
#define butViewHeight 60

static int countValue[] = {3, 10, 30};

@interface GDRegsiterViewController ()

@end

@implementation GDRegsiterViewController

- (void)exit
{
 //   [email resignFirstResponder];
    [phoneNumber resignFirstResponder];
    [userpass resignFirstResponder];
    [emailLabel resignFirstResponder];
 //   [verifyPass resignFirstResponder];
    [username resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Button Event
/////////////////////////////////////////////////////////////////////////////////
- (void)tapFacebook
{
    if ([FBSDKAccessToken currentAccessToken]) {
        [[facebookAccountManage sharedInstance] logout];
    }
    else
    {
        [[facebookAccountManage sharedInstance] login];
    }
}

- (void)tapQQ
{
    [[qqAccountManage sharedInstance] loginQQ];
}

- (void)tapCountry
{
    MOCountryViewController* countryController=[[MOCountryViewController alloc] init];
    countryController.callback = @selector(selectedCountry:);
    countryController.target = self;
    [self.navigationController pushViewController:countryController animated:YES];
}

- (void)tapSignUp
{
    if (useEmail)
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
        //email.text = [NSString stringWithFormat:@"%@%@%@",countryBut.titleLabel.text,phoneNumber.text,[GDPublicManager instance].emailDomain];
    }
    
    if (emailLabel.text.length<=0)
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
    
    if (![[GDPublicManager instance] NSStringIsValidEmail:emailLabel.text])
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
    
    

//    if (verifyPass.text.length<maxVerifyLength)
//    {
//        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
//                           message:NSLocalizedString(@"Your verification code should contain 6 characters", @"您的验证码应该是6位")
//                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                 otherButtonTitles:nil
//                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                              if (buttonIndex == [alertView cancelButtonIndex]) {
//                                  
//                              }
//                          }];
//        return;
//    }
    
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
    
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/register"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString* sha1 = [[GDPublicManager instance] getSha1String:userpass.text];
    
    //055123456789  remove first is 0
    NSString* newPhone = phoneNumber.text;
    char c = [newPhone characterAtIndex:0];
    if (c=='0')
    {
        newPhone = [phoneNumber.text substringFromIndex:1];
    }
    
    NSDictionary *parameters;
    if (useEmail)
        parameters = @{@"email":email.text,@"pwdsha1":sha1,@"fname":username.text};
    else
        parameters = @{@"pwdsha1":sha1,@"fname":username.text,@"phone":[NSString stringWithFormat:@"%@-%@",countryBut.titleLabel.text,newPhone],@"vercode":@"9999",@"email":emailLabel.text};
    
    [ProgressHUD show:NSLocalizedString(@"Processing...", @"处理中...")];
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"JSON: %@", responseObject);
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
            [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
             
             NSDictionary *dictData = responseObject[@"data"];
//             
//             "customer_id": "573",
//             "telephone": "11-11111122",
//             "score": "0", #注意： 字段修改了
//             "fname": "fffffffff",
//             "token": "730bab58999092b3c960ee946b602899",
//             "setting": {
//                 "receive_notice": 1
             
             int customer_id = [dictData[@"customer_id"] intValue];
             NSString* fname = dictData[@"fname"];
             NSString* token = dictData[@"token"];
        
             NSDictionary* setting = dictData[@"setting"];
             int receive_notice = [setting[@"receive_notice"] intValue];
             
             [GDPublicManager instance].cid = customer_id;
             
             int point = [dictData[@"score"] intValue];
             [GDPublicManager instance].point = point;
             
             [GDPublicManager instance].receive_notice = receive_notice;
             
             [GDPublicManager instance].username = fname;
             [GDPublicManager instance].token    = token;
             
             [GDPublicManager instance].password = sha1;
             
             [GDPublicManager instance].loginstauts = GREADEAL;
             
             NSString* phonecode   = @"";
             SET_IF_NOT_NULL(phonecode, dictData[@"telephone"]);
         
             NSString*  strCountry=@"";
             NSString*  strPhoneNumber=@"";
             
             NSString*  strEmail=@"";
             strEmail = [NSString stringWithFormat:@"%@@greadeal.com",phonecode];
             
             NSRange findslash = [phonecode rangeOfString:@"-"];
             if (findslash.location != NSNotFound)
             {
                 strCountry= [phonecode substringToIndex:findslash.location];
                 strPhoneNumber = [phonecode substringFromIndex:findslash.location+1];
                
                 [GDPublicManager instance].phoneCountry = strCountry;
                 [GDPublicManager instance].phonenumber  = strPhoneNumber;
                 
             }
             
             [[WCDatabaseManager instance] Login:strEmail withid:customer_id withCountry:strCountry withPhone:strPhoneNumber withpass:sha1];
             
             [[GDPublicManager instance] getMemberInfo];
             [[GDPublicManager instance] getCartData];
             [[GDPublicManager instance] updateToken];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationJoinActivity object:nil userInfo:nil];
             
             [self exit];
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             
             if (status==10005)
             {
                 if ([[GDSettingManager instance] language_id:NO]==3)
                 {
                     if ([errorInfo isEqualToString:@"Verification code failure"])
                     {
                         [ProgressHUD showError:@"验证码失效"];
                     }
                 }
             }
             else
                 [ProgressHUD showError:errorInfo];
         }
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         LOG(@"error: %@", error.localizedDescription);
         [ProgressHUD showError:error.localizedDescription];
     }];
}

- (void)selectedCountry:(NSDictionary *)value
{
    LOG(@"%@,%@",value,countryBut.titleLabel.text);
    
    [countryBut setTitle: value[@"id"] forState:UIControlStateNormal];
    
    [self.tableView reloadData];
}
/////////////////////////////////////////////////////////////////

- (UIView*)loginButton:(UIImage*)image withAction:(SEL)actionFuc withIndex:(int)index withTitle:(NSString*)aTitle
{
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(index*butViewWidth, 110, butViewWidth, butViewHeight)];
    
    UIButton* but  = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame = CGRectMake((butViewWidth-faceBookButSize)/2, 0, faceBookButSize, faceBookButSize);
    [but addTarget:self action:actionFuc forControlEvents:UIControlEventTouchUpInside];
    [but setImage:image forState:UIControlStateNormal];
    
    if (index == 0)
    {
        facebooktitle= [[UILabel alloc] initWithFrame:CGRectMake(0, faceBookButSize+5,butViewWidth,20)];
        facebooktitle.font = MOLightFont(16);
        facebooktitle.textAlignment = NSTextAlignmentCenter;
        facebooktitle.textColor = [UIColor grayColor];
        facebooktitle.backgroundColor = [UIColor clearColor];
        facebooktitle.text = aTitle;
        [buttonView addSubview:facebooktitle];
    }
    else if (index == 1)
    {
        qqtitle= [[UILabel alloc] initWithFrame:CGRectMake(0, faceBookButSize+5,butViewWidth,20)];
        qqtitle.font = MOLightFont(16);
        qqtitle.textAlignment = NSTextAlignmentCenter;
        qqtitle.textColor = [UIColor grayColor];
        qqtitle.backgroundColor = [UIColor clearColor];
        qqtitle.text = aTitle;
        [buttonView addSubview:qqtitle];
    }
    
    [buttonView addSubview:but];
    
    return buttonView;
}

#pragma mark -
#pragma mark INIT

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        finishCount = YES;
        countIndex  = 0 ;
        
        useEmail = NO;
        self.title = NSLocalizedString(@"Sign Up",@"注册");
               
        self.tableView.backgroundColor = MOColorAppBackgroundColor();
        self.tableView.backgroundView  = nil;
        MOInitTableView(self.tableView);
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",nil) style:UIBarButtonItemStylePlain target:self action:@selector(exit)];
        
        //        CGRect r = self.view.bounds;
        //
        //        RFSegmentView* segmentView = [[RFSegmentView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, 50) items:@[NSLocalizedString(@"E-Mail",@"邮箱注册"),NSLocalizedString(@"Phone Number",@"手机注册")]];
        //
        //        segmentView.tintColor = [UIColor colorWithRed:0.0862745 green:0.658824 blue:0.913725 alpha:1.0];
        //        segmentView.delegate = self;
        //        self.tableView.tableHeaderView = segmentView;
        
        float offsetX = 70;
        if ([GDSettingManager instance].isRightToLeft)
        {
            offsetX = 15;
        }
        
        email    = [[UITextField alloc]
                    initWithFrame:CGRectMake(offsetX, 10, 220*[GDPublicManager instance].screenScale, 24)];
        email.keyboardType = UIKeyboardTypeEmailAddress;
        email.returnKeyType = UIReturnKeyNext;
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
        
        phoneNumber    = [[UITextField alloc]
                          initWithFrame:CGRectMake([GDSettingManager instance].isRightToLeft?100:150, 5, 150*[GDPublicManager instance].screenScale, 30)];
        phoneNumber.keyboardType = UIKeyboardTypePhonePad;
        phoneNumber.returnKeyType = UIReturnKeyNext;
        phoneNumber.autocorrectionType = UITextAutocorrectionTypeNo;
        phoneNumber.autocapitalizationType = UITextAutocapitalizationTypeNone;
        phoneNumber.textColor = MOColorTextFieldColor();
        phoneNumber.delegate = self;
        phoneNumber.clearButtonMode = UITextFieldViewModeWhileEditing;
        phoneNumber.placeholder = @"551234567";
        [phoneNumber setBorderStyle:UITextBorderStyleRoundedRect];
        
        emailLabel    = [[UITextField alloc] initWithFrame:CGRectMake(offsetX, 5, 240*[GDPublicManager instance].screenScale, 30)];
        emailLabel.keyboardType = UIKeyboardTypeEmailAddress;
        emailLabel.returnKeyType = UIReturnKeyNext;
        emailLabel.textColor = MOColorTextFieldColor();
        emailLabel.delegate = self;
        emailLabel.clearButtonMode = UITextFieldViewModeWhileEditing;
        emailLabel.placeholder = @"example@mail.com";
        
//        verifyPass    = [[UITextField alloc]
//                         initWithFrame:CGRectMake(50, 5, 170*[GDPublicManager instance].screenScale, 30)];
//        verifyPass.keyboardType = UIKeyboardTypePhonePad;
//        verifyPass.returnKeyType = UIReturnKeyNext;
//        verifyPass.textColor = MOColorTextFieldColor();
//        verifyPass.delegate = self;
//        verifyPass.clearButtonMode = UITextFieldViewModeWhileEditing;
//        verifyPass.placeholder = NSLocalizedString(@"Verification Code",@"验证码");
//        
        username   = [[UITextField alloc]
                      initWithFrame:CGRectMake(offsetX, 5, 220, 30)];
        username.keyboardType = UIKeyboardTypeASCIICapable;
        username.returnKeyType = UIReturnKeyNext;
        username.autocorrectionType = UITextAutocorrectionTypeNo;
        username.autocapitalizationType = UITextAutocapitalizationTypeNone;
        username.textColor = MOColorTextFieldColor();
        username.delegate = self;
        username.clearButtonMode = UITextFieldViewModeWhileEditing;
        username.placeholder =  NSLocalizedString(@"Your name",@"您的姓名");
        //username.text = [GDPublicManager instance].username;

        newVerify= [[UILabel alloc] initWithFrame:CGRectMake(230*[GDPublicManager instance].screenScale, 0,80*[GDPublicManager instance].screenScale,40)];
        newVerify.font = MOLightFont(14);
        newVerify.textAlignment = NSTextAlignmentRight;
        newVerify.textColor = [UIColor redColor];
        newVerify.backgroundColor = [UIColor clearColor];
        newVerify.text = NSLocalizedString(@"Get Code",@"获取验证码");
        newVerify.userInteractionEnabled=YES;
        UITapGestureRecognizer *tapGestureTel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(teleButtonEvent)];
        [newVerify addGestureRecognizer:tapGestureTel];
        MODebugLayer(newVerify, 1.f, [UIColor redColor].CGColor);
        
        countDown = [[MZTimerLabel alloc] initWithFrame:CGRectMake(230*[GDPublicManager instance].screenScale, 5, 80*[GDPublicManager instance].screenScale, 30)];
        countDown.timerType = MZTimerLabelTypeTimer;
        countDown.timeFormat = @"mm:ss";
        [countDown setCountDownTime:countValue[countIndex]*60];
        countDown.timeLabel.backgroundColor = [UIColor clearColor];
        countDown.timeLabel.font = MOLightFont(14);
        countDown.timeLabel.textColor = [UIColor redColor];
        countDown.timeLabel.textAlignment = NSTextAlignmentRight;
        countDown.delegate = self;
        
        userpass = [[UITextField alloc]
                    initWithFrame:CGRectMake(offsetX, 10, 180*[GDPublicManager instance].screenScale, 24)];
        
        userpass.keyboardType = UIKeyboardTypeASCIICapable;
        userpass.returnKeyType = UIReturnKeyDone;
        userpass.autocorrectionType = UITextAutocorrectionTypeNo;
        userpass.autocapitalizationType = UITextAutocapitalizationTypeNone;
        userpass.textColor = MOColorTextFieldColor();
        userpass.delegate = self;
        userpass.secureTextEntry = YES;
        userpass.clearButtonMode = UITextFieldViewModeWhileEditing;
        userpass.placeholder = NSLocalizedString(@"Enter password",@"输入密码");
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginSuccess) name:kNotificationDidLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeProfileChange:) name:FBSDKProfileDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Code
- (void)getCodeAgain
{
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Message/send_register_vercode"];
    
    //055123456789  remove first is 0
    NSString* newPhone = phoneNumber.text;
    char c = [newPhone characterAtIndex:0];
    if (c=='0')
    {
        newPhone = [phoneNumber.text substringFromIndex:1];
    }

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"phone":[NSString stringWithFormat:@"%@-%@",countryBut.titleLabel.text,newPhone],@"language_id":@([[GDSettingManager instance] language_id:NO])};
    
    [ProgressHUD show:NSLocalizedString(@"Processing...",@"处理中...")];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"JSON: %@", responseObject);
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             [ProgressHUD dismiss];
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

             [UIAlertView showWithTitle:nil
                                message:errorInfo
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil
                               tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                   if (buttonIndex == [alertView cancelButtonIndex]) {
                                       
                                   }
                               }];
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
    if (countryBut.titleLabel.text.length<=0 || phoneNumber.text.length<=0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"No Country or No Phone Number", @"没有输入区号或电话号码")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        return;
    }
    
    if (countIndex<3)
    {
        [self getCodeAgain];
        
        [countDown setCountDownTime:countValue[countIndex]*60];
        [countDown start];
        
        countIndex++;
        
        registerBut.enabled = YES;
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

#pragma mark - textField Delegate

-(BOOL)textFieldShouldReturn: (UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField == email)
    {
        [username becomeFirstResponder];
    }
    else if (textField == emailLabel)
    {
        [username becomeFirstResponder];
    }
    else if (textField == username)
    {
        [userpass becomeFirstResponder];
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
    else if (textField == phoneNumber)
    {
        if (phoneNumber.text.length > maxPhoneLength && string.length>0)
        {
            return NO;
        } else {
            return  [[GDPublicManager instance] validateNumber:string];
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
    else if (textField == emailLabel)
    {
        if (emailLabel.text.length > maxEmailLength && string.length>0)
        {
              return NO;
        } else {
              return YES;
        }
    }
//    else if (textField == verifyPass)
//    {
//        if (verifyPass.text.length > maxVerifyLength && string.length>0)
//        {
//            return NO;
//        } else {
//            return YES;
//        }
//    }
    else if (textField == userpass)
    {
        if (userpass.text.length > maxPassLength && string.length>0)
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

- (void)tapCall:(UITapGestureRecognizer *)tapRecognizer
{
    [[GDPublicManager instance] makeHelp];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 60;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//    UILabel* titleLabel = MOCreateLabelAutoRTL();
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.textColor = [UIColor blackColor];
//    titleLabel.font =  MOLightFont(14);
//    titleLabel.text =  NSLocalizedString(@"If you are not receiving the verification SMS, please try resending it or call customer service 045511614.", @"如果您未收到验证短信，请尝试重新发送验证码或致电客服解决此问题 045511614");
//    titleLabel.numberOfLines = 0;
//    
//    CGRect r =self.view.bounds;
//    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, 0, r.size.width, 60)];
//    titleLabel.frame = CGRectMake(r.origin.x+15, 0, r.size.width-30, 60);
//    hView.backgroundColor = MOSectionBackgroundColor();
//    
//    [hView addSubview:titleLabel];
//    
//    hView.userInteractionEnabled = YES;
//    [hView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCall:)]];
//    
//    return hView;
//    
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
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
            //[email becomeFirstResponder];
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"phone.png"];
            [cell.contentView addSubview:countryBut];
            [cell.contentView addSubview:phoneNumber];
            //[phoneNumber becomeFirstResponder];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
//    else if (indexPath.row==1)
//    {
//        for (UIView *view in cell.contentView.subviews)
//        {
//            [view removeFromSuperview];
//        }
//        
//        cell.imageView.image = [UIImage imageNamed:@"verify.png"];
//        [cell.contentView addSubview:verifyPass];
//        
//        if (finishCount)
//            [cell.contentView addSubview:newVerify];
//        else
//            [cell.contentView addSubview:countDown];
//        
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        
//    }
    else if (indexPath.row==1)
    {
        cell.imageView.image = [UIImage imageNamed:@"email.png"];
        [cell.contentView addSubview:emailLabel];
    }
    else if (indexPath.row==2)
    {
        cell.imageView.image = [UIImage imageNamed:@"user.png"];
        [cell.contentView addSubview:username];
    }
    else if (indexPath.row==3)
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 180;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGRect r = self.view.bounds;
    
    UIView *footer = [[UIView alloc] initWithFrame:r];
    
    registerBut = [ACPButton buttonWithType:UIButtonTypeCustom];
    registerBut.frame = CGRectMake(10, 20, r.size.width-20, 36);
    [registerBut setStyleRedButton];
    [registerBut setTitle: NSLocalizedString(@"Sign Up", @"注册") forState:UIControlStateNormal];
    [registerBut addTarget:self action:@selector(tapSignUp) forControlEvents:UIControlEventTouchUpInside];
    [registerBut setLabelFont:MOLightFont(18)];
    [footer addSubview:registerBut];
    
//    NSString* url;
//    NSDictionary *parameters;
//    
//    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/page/get_html"];
//    
//    parameters = @{@"key":@"register_note",@"language_id":@([[GDSettingManager instance] language_id:NO])};
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
//    
//    [manager POST:url
//       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         int status = [responseObject[@"status"] intValue];
//         if (status==1)
//         {
//             NSString* html = responseObject[@"data"][@"html"];
//             
//             UILabel* noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, r.size.width-20,100)];
//             noticeLabel.font = MOLightFont(14);
//             noticeLabel.textAlignment = NSTextAlignmentCenter;
//             noticeLabel.textColor = MOColorSaleFontColor();
//             noticeLabel.numberOfLines = 0;
//             noticeLabel.backgroundColor =  MOColorAppBackgroundColor();
//             
//             NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
//             noticeLabel.attributedText = attrStr;
//             
//             noticeLabel.frame = CGRectMake(10, 60, [GDPublicManager instance].screenWidth-20,100);
//             
//             [footer addSubview:noticeLabel];
//         }
//         else
//         {
//             NSString *errorInfo =@"";
//             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
//             LOG(@"errorInfo: %@", errorInfo);
//             [ProgressHUD showError:errorInfo];
//         }
//         
//         [ProgressHUD dismiss];
//         
//     }
//     failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         [ProgressHUD showError:error.localizedDescription];
//     }];

    UIImageView *backTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 90, r.size.width,1)];
    backTitle.image = [[UIImage imageNamed:@"cutOff.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [footer addSubview:backTitle];
    
    UILabel* titleName = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, r.size.width,20)];
    titleName.font = MOLightFont(16);
    titleName.textAlignment = NSTextAlignmentCenter;
    titleName.textColor = [UIColor grayColor];
    titleName.backgroundColor =  MOColorAppBackgroundColor();
    titleName.text = NSLocalizedString(@"Or sign in with", @"用以下方式登录");
    [footer addSubview:titleName];
    
    CGSize titleSize = [titleName.text moSizeWithFont:titleName.font withWidth:r.size.width];
    CGRect tr = titleName.frame;
    tr.origin.x = (r.size.width-titleSize.width)/2;
    tr.size.width = titleSize.width;
    titleName.frame = tr;
    r.origin.x = (r.size.width-butViewWidth)/2;
    
    UIView *facebookView= [self loginButton:[UIImage imageNamed:@"facebook.png"] withAction:@selector(tapFacebook)  withIndex:0 withTitle:[FBSDKAccessToken currentAccessToken] ? NSLocalizedString(@"Logout",nil) : NSLocalizedString(@"Login",nil)];
    [footer addSubview:facebookView];
    
    CGRect cr = facebookView.frame;
    cr.origin.x = r.origin.x;
    facebookView.frame = cr;
    
    if ([[qqAccountManage sharedInstance] isInstalled])
    {
        UIView *qqView= [self loginButton:[UIImage imageNamed:@"sns_icon_qq.png"] withAction:@selector(tapQQ)  withIndex:1 withTitle:[[qqAccountManage sharedInstance] qqAuthValid] ? NSLocalizedString(@"Logout",@"退出") : NSLocalizedString(@"Login",nil)];
        [footer addSubview:qqView];
    
        cr = facebookView.frame;
        cr.origin.x = (r.size.width-butViewWidth*2)/2;
        facebookView.frame = cr;
    
        cr = qqView.frame;
        cr.origin.x = facebookView.frame.origin.x + butViewWidth;
        qqView.frame = cr;
    }
    
    return footer;
}

- (void)LoginSuccess
{
    if ([GDPublicManager instance].loginstauts==FACEBOOK)
    {
        if ([FBSDKAccessToken currentAccessToken])
        {
            [self exit];
            facebooktitle.text = NSLocalizedString(@"Logout",nil);
        }
        else
        {
            facebooktitle.text = NSLocalizedString(@"Login",nil);
        }
    }
    else if ([GDPublicManager instance].loginstauts==QQ)
    {
        if ([[qqAccountManage sharedInstance] qqAuthValid])
        {
                [self exit];
                qqtitle.text = NSLocalizedString(@"Logout",nil);
        }
        else
        {
                qqtitle.text = NSLocalizedString(@"Login",nil);
        }
    }
}

- (void)observeProfileChange:(NSNotification *)notfication {
    if ([FBSDKAccessToken currentAccessToken])
    {
        facebooktitle.text = NSLocalizedString(@"Logout",nil);
    }
    else
    {
        facebooktitle.text = NSLocalizedString(@"Login",nil);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)timerLabel:(MZTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime
{
    finishCount = YES;
    registerBut.enabled = NO;
    [self.tableView reloadData];
}

#pragma mark - RFSegment

- (void)segmentViewSelectIndex:(NSInteger)index
{
    if (index == 0)
        useEmail = YES;
    else
        useEmail = NO;
    [self.tableView reloadData];
}

@end
