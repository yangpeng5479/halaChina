//
//  GDPayMemberViewController.m
//  Greadeal
//
//  Created by Elsa on 15/11/27.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "GDPayMemberViewController.h"
#import "RDVTabBarController.h"
#import "GDPaymentCell.h"

#define  toolViewHeight 60

#define  paypal    0
#define  payOnCash 1
#define  payVisa   2

@implementation GDPayMemberViewController

#pragma mark - Init

- (id)init:(int)selectRank withPrice:(float)aPrice withLevel:(int)aLevel
{
    self = [super init];
    if (self)
    {
        self.title  = NSLocalizedString(@"Pay", @"支付");
        
        order_id    = @"";
        
        memberRank  = selectRank;
        memberPrice = aPrice;
        cardLevel   = aLevel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    exchangeCnyRate = exCnyRate;
    exchangeUsdRate = exUsdRate;
    
    [self getExchange];
    
    CGRect r = self.view.bounds;
    r.size.height-=toolViewHeight;
    
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    r.origin.y= self.view.bounds.size.height-toolViewHeight-[[UIApplication sharedApplication] statusBarFrame].size.height-self.navigationController.navigationBar.frame.size.height;
    r.size.height=toolViewHeight;
    
    paymentView = [[UIView alloc] initWithFrame:r];
    [self.view addSubview:paymentView];
    
    ACPButton* confirmBut = [ACPButton buttonWithType:UIButtonTypeCustom];
    confirmBut.frame = CGRectMake(10, 10, [GDPublicManager instance].screenWidth-20, 40);
    [confirmBut setStyleRedButton];
    [confirmBut setTitle: NSLocalizedString(@"Pay", @"支付") forState:UIControlStateNormal];
    [confirmBut addTarget:self action:@selector(tapMakeOrder) forControlEvents:UIControlEventTouchUpInside];
    [confirmBut setLabelFont:MOLightFont(16)];
    [paymentView addSubview:confirmBut];
    
    UIImageView* backgroundView = [[UIImageView alloc] init];
    backgroundView.image = [[UIImage imageNamed:@"productLline.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    backgroundView.frame= CGRectMake(r.origin.x, 0,
                                     r.size.width, 0.5);
    [paymentView addSubview:backgroundView];
    
    if (self.rdv_tabBarController.tabBar.translucent) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0,
                                               0,
                                               CGRectGetHeight(self.rdv_tabBarController.tabBar.frame),
                                               0);
        
        mainTableView.contentInset = insets;
        mainTableView.scrollIndicatorInsets = insets;
    }
    
    payWayInfo  = [[NSMutableArray alloc] init];
    [self getPayWay];
}

#pragma mark - Data

- (void)getExchange
{
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/currency/get_all_currency"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"JSON: %@", responseObject);
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             NSArray* temp = responseObject[@"data"];
             for (NSDictionary* dict in temp) {
                 NSString* code = dict[@"code"];
                 if ([code isEqualToString:PaypalCurrency])
                     exchangeUsdRate = [dict[@"value"] floatValue];
                 else if ([code isEqualToString:AlipalCurrency])
                     exchangeCnyRate = [dict[@"value"] floatValue];
             }
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
         [ProgressHUD showError:error.localizedDescription];
     }];
}

- (void)getPayWay
{
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Payment/get_payment_list"];
    
    parameters = @{@"type":@"live",@"language_id":@([[GDSettingManager instance] language_id:NO])};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             @synchronized(payWayInfo)
             {
                 [payWayInfo removeAllObjects];
             }
             
             if(responseObject[@"data"][@"payment_list"]!= [NSNull null] && responseObject[@"data"][@"payment_list"]!= nil)
             {
                 [payWayInfo addObjectsFromArray:responseObject[@"data"][@"payment_list"]];
             }
             
             if (payWayInfo.count>0)
             {
                 [self setChoosePay:0];
             }
           
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
         [ProgressHUD showError:error.localizedDescription];
     }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}


#pragma mark - Paypal
- (NSMutableArray*)caluItemsPrice
{
    float ex = 1;
    if ([choosePayType isEqualToString:kPaypal])
    {
        ex = exchangeUsdRate;
    }
    
    NSMutableArray* items = [[NSMutableArray alloc] init];
  
    NSString* SKU;
    switch (memberRank) {
        case 1:
            SKU = NSLocalizedString(@"Buy Gold Card", @"购买金卡");
            break;
        case 2:
            SKU = NSLocalizedString(@"Buy Gold Card", @"购买金卡");
            break;
        case 3:
            SKU = NSLocalizedString(@"Buy Platinum Card", @"购买白金卡");
            break;
        default:
            break;
    }
    PayPalItem *item = [PayPalItem itemWithName:NSLocalizedString(@"Buy Member Card", @"购买会员卡")
                                       withQuantity:1
                                          withPrice:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",memberPrice*ex]]
                                       withCurrency:PaypalCurrency
                                            withSku:SKU];
    [items addObject:item];
    
    return items;
}

- (void)completePay
{
    
    [UIAlertView showWithTitle:NSLocalizedString(@"Order Successful", @"购买成功")
                       message:NSLocalizedString(@"Succeeded to purchase membership card and\n able to purchase coupons for free now.", @"您购买会员卡已经成功, 现在可以免费购买优惠券.")
             cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              //refresh me page
                              [[GDPublicManager instance] getMemberInfo];

                              [self.navigationController popToRootViewControllerAnimated:NO];
                          }
                      }];
}

- (void)tapMakeOrder
{
    
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Membership/gen_order"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    NSDictionary *parameters = @{@"membership_card_id":@(cardLevel),@"token":[GDPublicManager instance].token,@"payment_code":choosePayType};
    
    
    [ProgressHUD show:NSLocalizedString(@"Submiting...",@"提交订单...")];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [ProgressHUD dismiss];
         LOG(@"JSON: %@", responseObject);
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             NSDictionary* dict = responseObject[@"data"];
             order_id = dict[@"order_id"];
             
            if ([choosePayType isEqualToString:kCashPay] || [choosePayType isEqualToString:kShopPay])
            {
                [self completePay];
            }
            else if ([choosePayType isEqualToString:kPaypal])
            {
                [self toPaypal];
            }
            else if ([choosePayType isEqualToString:kAliPay])
            {
                [self toAlipay:order_id];
            }
            else if ([choosePayType isEqualToString:kEtisalat])
            {
                [self toEtisalat];
            }
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
         [ProgressHUD showError:error.localizedDescription];
     }];
    
}

- (void)toAlipay:(NSString*)payId
{
    AlipayProduct *product = [[AlipayProduct alloc] init];
    
    NSString* subject;
    switch (memberRank) {
        case 1:
            subject = NSLocalizedString(@"Buy Gold Card", @"购买金卡");
            break;
        case 2:
            subject = NSLocalizedString(@"Buy Gold Card", @"购买金卡");
            break;
        case 3:
            subject = NSLocalizedString(@"Buy Platinum Card", @"购买白金卡");
            break;
        default:
            break;
    }
    
    product.subject = subject;
    
    if (cardLevel>1)
        product.body = NSLocalizedString(@"A Year", @"一年");
    else
        product.body = NSLocalizedString(@"6 Months", @"半年");
    
    product.price = memberPrice*exchangeUsdRate;
    
    [AliPayment instance].delegate = self;
    [[AliPayment instance] callAli:product withNo:payId withUrl:@"http://api.greadeal.com/rest2/v1/Membership/alipay_notify"];
    
}

- (void)toPaypal
{
    NSMutableArray* items = [self caluItemsPrice];
    
    NSDecimalNumber *shipping=[NSDecimalNumber decimalNumberWithString:@"0.0"];
    
    GDPaypal* pay = [[GDPaypal alloc] init];
    
    if ([choosePayType isEqualToString:kPaypal])
    {
        [pay callPaypal:items withShipFee:shipping withSuper:self withCard:NO];
    }
   
}

- (void)toEtisalat
{
    NSString* subject;
    switch (memberRank) {
        case 1:
            subject = NSLocalizedString(@"Buy Gold Card", @"购买金卡");
            break;
        case 2:
            subject = NSLocalizedString(@"Buy Gold Card", @"购买金卡");
            break;
        case 3:
            subject = NSLocalizedString(@"Buy Platinum Card", @"购买白金卡");
            break;
        default:
            break;
    }
    
    [[GDEtisalat instance] callEtisalat:order_id withName:subject withPrice:memberPrice withType:@"membership_card" withNav:self.navigationController withId:self];
}

#pragma mark Alipay methods
- (void)aliPayCompleted:(BOOL)success
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (success)
    {
        order_id = @"";
        [self completePay];
    }
    else
    {
        order_id = @"";
        [UIAlertView showWithTitle:NSLocalizedString(@"Payment Failed", @"支付失败")
                           message:NSLocalizedString(@"Payment is not completed, please try it again!", @"支付没有完成, 请重新支付!")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  [self.navigationController popViewControllerAnimated:YES];
                              }
                          }];
    }
}

- (void)etisalatCompleted:(BOOL)success
{
    [self aliPayCompleted:success];
}

#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    LOG(@"PayPal Payment Success!");
    //resultText = [completedPayment description];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Payment was processed successfully; send to server for verification and fulfillment
    [self sendCompletedPaymentToServer:completedPayment];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    LOG(@"PayPal Payment Canceled");
    //resultText = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    
     order_id = @"";
    
    [UIAlertView showWithTitle:NSLocalizedString(@"Payment Failed", @"支付失败")
                       message:NSLocalizedString(@"Payment is not completed, please try it again!", @"支付没有完成, 请重新支付!")
             cancelButtonTitle:NSLocalizedString(@"OK", nil)
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              [self.navigationController popViewControllerAnimated:YES];
                          }
                      }];
    
}

#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    //  account:  taotaosend-buyer@outlook.com
    //  password: Taotao007
    
    LOG(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
    
    NSDictionary* response = completedPayment.confirmation[@"response"];
    
    NSString* paypemtID = response[@"id"];
    
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Membership/verify_payment"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    NSDictionary *parameters = @{@"membership_card_id":@(cardLevel),@"token":[GDPublicManager instance].token,@"payment_code":choosePayType,@"verify_payment_id":paypemtID};
    
    [ProgressHUD show:NSLocalizedString(@"Verify Payment...",@"验证支付") Interaction:NO];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [ProgressHUD dismiss];
         LOG(@"JSON: %@", responseObject);
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             [self completePay];
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
         [ProgressHUD showError:error.localizedDescription];
     }];
    
    order_id = @"";
    
}

#pragma mark - Choose
- (void)setChoosePay:(int)nIndex
{
    if (nIndex>=payWayInfo.count)
        return;
    
    choosePay = nIndex;
    
    NSMutableDictionary* obj = [payWayInfo objectAtIndex:choosePay];
    
    if (![obj isKindOfClass:[NSNull class]] && obj!= nil)
    {
        choosePayType = obj[@"payment_code"];
        [mainTableView reloadData];
    }

}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row ==0)
    {
            static NSString *CellIdentifier = @"cellPay";
            UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsZero];
            }
            
            if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                [cell setLayoutMargins:UIEdgeInsetsZero];
            }
            
            cell.textLabel.text= NSLocalizedString(@"Payment Option", @"支付方式");
            return cell;
    }
    else
    {
            static NSString *CellIdentifier = @"cellPayWay";
            
            GDPaymentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GDPaymentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                
            }
            
            NSDictionary* obj = [payWayInfo objectAtIndex:indexPath.row-1];
            if (![obj isKindOfClass:[NSNull class]] && obj!= nil)
            {
                if(obj[@"payment_image"] != [NSNull null] && obj[@"payment_image"] != nil)
                {
                    NSString* imageUrl = obj[@"payment_image"];
                    [cell.iconImage sd_setImageWithURL:[NSURL URLWithString:[imageUrl encodeUTF]] placeholderImage:[UIImage imageNamed:@"market_product_default.png"]];
                    cell.iconImage.contentMode = UIViewContentModeScaleAspectFit;
                }
                
                SET_IF_NOT_NULL(cell.title.text, obj[@"payment_name"]);
                
                NSString* codeId = obj[@"payment_code"];
                if ([codeId isEqualToString:kShopPay])
                {
                    SET_IF_NOT_NULL(cell.fees.text, obj[@"detail"]);
                    cell.fees.textColor = MOColorSaleFontColor();
                }
                else if ([codeId isEqualToString:kVisaPay])
                {
                    cell.fees.text = NSLocalizedString(@"Pay with Card",@"信用卡支付");
                    cell.fees.textColor = [UIColor grayColor];
                }
                else
                {
                    cell.fees.text = @"";
                }
                
                [cell.fees findCurrency:CurrencyFontSize];
                
                if (choosePay==indexPath.row-1)
                {
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick.png"]];
                }
                else
                {
                    cell.accessoryView = nil;
                }
            }
            return cell;
        }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1+payWayInfo.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return 40;
    else
        return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row>0)
    {
        [self setChoosePay:(int)indexPath.row-1];
    }
}


@end
