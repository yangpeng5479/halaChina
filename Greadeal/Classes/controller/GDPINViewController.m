//
//  GDPINViewController.m
//  Greadeal
//
//  Created by Elsa on 16/4/12.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDPINViewController.h"
#import "RDVTabBarController.h"


#define textWidth 40
#define textSpace 18

@interface GDPINViewController ()

@end

@implementation GDPINViewController

-(id)init:(NSString*)consume_code
{
    self = [super init];
    if (self)
    {
        consumeCode = consume_code;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [ProgressHUD dismiss];
    
    [_firstDigitTextField resignFirstResponder];
    [_secondDigitTextField resignFirstResponder];
    [_thirdDigitTextField resignFirstResponder];
    [_fourthDigitTextField resignFirstResponder];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapRedeem
{
    NSString* pinpass = _passcodeTextField.text;
    
    if (pinpass.length<4)
    {
        [UIAlertView showWithTitle:[[GDSettingManager instance] isSwitchChinese]?@"错误":@"Error"
                           message:[[GDSettingManager instance] isSwitchChinese]?@"您的PIN至少要有4位":@"PIN must be a 4-digit number"
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                        }];
        return;
        
    }

    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Coupon/confirm_consumed_by_ping_code"];
    
    NSString* shaold = [[GDPublicManager instance] getSha1String:pinpass];
    
    parameters = @{@"ping_code_sha1":shaold,@"consume_code":consumeCode,@"token":[GDPublicManager instance].token};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"JSON: %@", responseObject);
         [ProgressHUD dismiss];
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             [UIAlertView showWithTitle:[[GDSettingManager instance] isSwitchChinese]?@"完成":@"Done"
                      message:[[GDSettingManager instance] isSwitchChinese]?@"验证成功,优惠券有效":@"Successful, Code is vaild"
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil
                               tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                   if (buttonIndex == [alertView cancelButtonIndex]) {
                                       [self.navigationController popViewControllerAnimated:YES];
                                   }
                               }];
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             //[ProgressHUD showError:errorInfo];
             [UIAlertView showWithTitle:[[GDSettingManager instance] isSwitchChinese]?@"错误":@"Error"
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
         [ProgressHUD showError:error.localizedDescription];
     }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"PIN";
    
    self.view.backgroundColor =  MOColorAppBackgroundColor();
    
    _passcodeTextField = [[UITextField alloc] initWithFrame: CGRectZero];
    _passcodeTextField.hidden = YES;
    _passcodeTextField.delegate = self;
    _passcodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_passcodeTextField becomeFirstResponder];
    [self.view addSubview:_passcodeTextField];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(([GDPublicManager instance].screenWidth - 100)/2, 25, 100, 100)];
    imageView.image = [UIImage imageNamed:@"facePIN.png"];
    [self.view addSubview:imageView];
    
    UILabel* pinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, [GDPublicManager instance].screenWidth,20)];
    pinLabel.font = MOLightFont(12);
    pinLabel.textAlignment = NSTextAlignmentCenter;
    pinLabel.textColor = colorFromHexString(@"999999");
    pinLabel.text = [[GDSettingManager instance] isSwitchChinese]?@"商家输入PIN确认使用":@"Vendor, Please enter your PIN code to make verification";
    [self.view addSubview:pinLabel];
    
    float offset = ([GDPublicManager instance].screenWidth - textWidth*4 -textSpace*3)/2;
    
    _firstDigitTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _firstDigitTextField.textColor = MOColor66Color();
    _firstDigitTextField.font = MOBlodFont(36);
    [_firstDigitTextField setBorderStyle:UITextBorderStyleLine];
    _firstDigitTextField.userInteractionEnabled = NO;
    _firstDigitTextField.layer.borderColor= colorFromHexString(@"B5B5B5").CGColor;
    _firstDigitTextField.layer.borderWidth= 0.5;
    _firstDigitTextField.secureTextEntry = NO;
    [self.view addSubview:_firstDigitTextField];
    _firstDigitTextField.frame = CGRectMake(offset, 190, textWidth, textWidth);
    _firstDigitTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _firstDigitTextField.textAlignment = NSTextAlignmentCenter;
    _firstDigitTextField.text = @" ";
    
    offset+=textWidth+textSpace;
    _secondDigitTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _secondDigitTextField.textAlignment = NSTextAlignmentCenter;
    _secondDigitTextField.textColor = MOColor66Color();
    _secondDigitTextField.font = MOBlodFont(36);
    [_secondDigitTextField setBorderStyle:UITextBorderStyleLine];
    _secondDigitTextField.secureTextEntry = NO;
    _secondDigitTextField.userInteractionEnabled = NO;
    _secondDigitTextField.layer.borderColor= colorFromHexString(@"B5B5B5").CGColor;
    _secondDigitTextField.layer.borderWidth= 0.5;
    [self.view addSubview:_secondDigitTextField];
    _secondDigitTextField.frame = CGRectMake(offset, 190, textWidth, textWidth);
    _secondDigitTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _secondDigitTextField.text = @" ";

    
    offset+=textWidth+textSpace;
    _thirdDigitTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _thirdDigitTextField.textAlignment = NSTextAlignmentCenter;
    _thirdDigitTextField.textColor = MOColor66Color();
    _thirdDigitTextField.font = MOBlodFont(36);
    [_thirdDigitTextField setBorderStyle:UITextBorderStyleLine];
    _thirdDigitTextField.userInteractionEnabled = NO;
    _thirdDigitTextField.layer.borderColor= colorFromHexString(@"B5B5B5").CGColor;
    _thirdDigitTextField.layer.borderWidth= 0.5;
    _thirdDigitTextField.secureTextEntry = NO;
    [self.view addSubview:_thirdDigitTextField];
    _thirdDigitTextField.frame = CGRectMake(offset, 190, textWidth, textWidth);
    _thirdDigitTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _thirdDigitTextField.text = @" ";
    
    offset+=textWidth+textSpace;
    _fourthDigitTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _fourthDigitTextField.textAlignment = NSTextAlignmentCenter;
    _fourthDigitTextField.textColor = MOColor66Color();
    _fourthDigitTextField.font = MOBlodFont(36);
    [_fourthDigitTextField setBorderStyle:UITextBorderStyleLine];
    _fourthDigitTextField.userInteractionEnabled = NO;
    _fourthDigitTextField.layer.borderColor= colorFromHexString(@"B5B5B5").CGColor;
    _fourthDigitTextField.secureTextEntry = NO;
    _fourthDigitTextField.layer.borderWidth= 0.5;
    [self.view addSubview:_fourthDigitTextField];
    _fourthDigitTextField.frame = CGRectMake(offset, 190, textWidth, textWidth);
    _fourthDigitTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
     _fourthDigitTextField.text = @" ";
    
    ACPButton* tapBut = [ACPButton buttonWithType:UIButtonTypeCustom];
    tapBut.frame = CGRectMake(30,245, [GDPublicManager instance].screenWidth-60, 36);
    [tapBut setStyleRedButton];
    [tapBut setLabelTextColor:[UIColor whiteColor] highlightedColor:[UIColor greenColor] disableColor:nil];
    [tapBut setLabelFont:MOLightFont(18)];
    [tapBut setCornerRadius:8];
    [tapBut setTitle:[[GDSettingManager instance] isSwitchChinese]?@"使用":@"REDEEM" forState:UIControlStateNormal];
    [tapBut addTarget:self action:@selector(tapRedeem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tapBut];
    
    UIBarButtonItem*  buyButItem = [[UIBarButtonItem alloc] initWithTitle:[[GDSettingManager instance] isSwitchChinese]?@"帮助":@"Help"  style:UIBarButtonItemStylePlain
                                                                   target:self action:@selector(tapHelp)];
    self.navigationItem.rightBarButtonItem = buyButItem;
    

}

- (void)tapHelp
{
    [[GDPublicManager instance] makeHelp];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString: @"\n"]) return NO;
    
    NSString *typedString = [textField.text stringByReplacingCharactersInRange: range withString: string];

    if (typedString.length >= 1)
        _firstDigitTextField.secureTextEntry = YES;
    else
        _firstDigitTextField.secureTextEntry = NO;
    
    if (typedString.length >= 2)
        _secondDigitTextField.secureTextEntry = YES;
    else
        _secondDigitTextField.secureTextEntry = NO;
    
    if (typedString.length >= 3)
        _thirdDigitTextField.secureTextEntry = YES;
    else
        _thirdDigitTextField.secureTextEntry = NO;
    
    if (typedString.length >= 4)
        _fourthDigitTextField.secureTextEntry = YES;
    else
        _fourthDigitTextField.secureTextEntry = NO;
    
    if (typedString.length > 4)
        return NO;
    return YES;
    
}


@end
