//
//  GDMakeOrderViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/26.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDMakeOrderViewController.h"
#import "RDVTabBarController.h"
#import "GDReceiveCell.h"
#import "GDOrderListCell.h"

#import "GDDeliveryEditAddressViewController.h"
#import "GDDeliveryAddressManageViewController.h"

#import "GDMarketVerificationCodeViewController.h"
#import "GDMessageViewController.h"

#import "GDShipsCell.h"
#import "GDPaymentCell.h"

#import "GDOrderDetailsViewController.h"

#import "GDPhoneViewController.h"
#import "GDPassportViewController.h"

#import "MODayViewController.h"

#import "GDReturnsViewController.h"

#define  toolViewHeight 40

#define  paypal 0
#define  payOnCash 1
#define  payVisa   2

@interface GDMakeOrderViewController ()

@end

@implementation GDMakeOrderViewController

@synthesize vendorId;

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

- (id)init:(NSArray*)aproductData withPrice:(BOOL)is_free withLevel:(int)membership_level
{
    self = [super init];
    if (self)
    {
        self.title = NSLocalizedString(@"Order Details", @"订单详情");
        
        self.productData = aproductData;
        sprice = 0.0;
        choosePayType = @"";
        IdPassport = nil;
        order_type = @"live";
        
        membershipLevel = membership_level;
        isFree = is_free;
        
        require_passport_or_idcard = NO;
        if (self.productData.count>0)
        {
            for (NSDictionary* obj in self.productData)
            {
                date_unavailable =  obj[@"date_unavailable"];
                
                endDate = obj[@"endDate"];
                
                require_passport_or_idcard = [obj[@"require_passport_or_idcard"] intValue];
                if (require_passport_or_idcard)
                    break;
            }
        }
        
        if (!isFree)
        {
            if (self.productData.count>0)
            {
                int order_qty = 0;
                for (NSDictionary* obj in self.productData)
                {
                    order_qty  = [obj[@"order_qty"] intValue];
                    sprice += [obj[@"sprice"] floatValue]*order_qty;
                }
            }
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    deliveryFee = 0.0;
    codFee = 0.0;
    chosseCodFee =0.0;
    
    exchangeCnyRate = exCnyRate;
    exchangeUsdRate = exUsdRate;
    [self getExchange];
    
    comment = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReceiveAddress) name:kNotificationAddNewAddress object:nil];
    
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
   
    confirmBut = [ACPButton buttonWithType:UIButtonTypeCustom];
    confirmBut.frame = CGRectMake(10, 4, [GDPublicManager instance].screenWidth-20, 34);
    [confirmBut setStyleRedButton];
    [confirmBut setTitle: NSLocalizedString(@"Confirm", @"确定") forState:UIControlStateNormal];
    [confirmBut addTarget:self action:@selector(checkQuantity) forControlEvents:UIControlEventTouchUpInside];
    [confirmBut setLabelFont:MOLightFont(18)];
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
    
    deliverInfo = [[NSMutableArray alloc] init];
    payWayInfo  = [[NSMutableArray alloc] init];
    

    if (!isFree)
    {
        [GDOrderCheck instance].target = self;
        [GDOrderCheck instance].callback = @selector(getPrice:);
        [[GDOrderCheck instance] getOrderPrice:self.productData withReturn:0];
    }
    
    //[self getReceiveAddress];
    
    [self getPayWay];
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
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark address 
- (void)tapAdd
{
    GDDeliveryEditAddressViewController *viewController = [[GDDeliveryEditAddressViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.addNew = YES;
    [self.navigationController pushViewController: viewController animated:YES];
}

#pragma mark - Action

- (void)goCheckout:(id)sender
{
    [self checkPay];
}

- (void)checkQuantity
{
//    if (receiveInfo==nil && ![order_type isEqualToString:@"live"])
//    {
//        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
//                           message:NSLocalizedString(@"No Receiving Address.", @"没有收货地址")
//                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                 otherButtonTitles:nil
//                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                              if (buttonIndex == [alertView cancelButtonIndex]) {
//                                  
//                              }
//                          }];
//
//        return;
//    }
    
    if (!isFree)
    {
        if (choosePayType.length<=0)
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"No Choose Payment", @"没有支付方式")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        
            return;
        }
    }
    
    if (require_passport_or_idcard)
    {
        if (IdPassport==nil)
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
        
        if (startDate.length<=0)
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                               message:NSLocalizedString(@"No Check-In Date", @"没有入住日期")
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      
                                  }
                              }];
            
            return;
        }
        
    }
    
    [self checkPay];
}


- (void)choosed:(id)sender
{
    //{"s":<string> sticker name, if applicable, "e":<string> emoji code, if applicable.}
    NSDictionary *dict = sender;
    LOG(@"dict=%@",dict);
    receiveInfo = dict;
    [mainTableView reloadData];
    
    int sel_address_id = [receiveInfo[@"address_id"] intValue];
    [self getShipWay:sel_address_id];
}

- (void)getUserMessage:(id)sender
{
    NSString *dict = sender;
    comment = dict;
    [mainTableView reloadData];
}

- (void)phoneResult:(id)sender
{
    //{"s":<string> sticker name, if applicable, "e":<string> emoji code, if
    [self tapMakeOrder];
}

- (void)passportResult:(id)sender
{
    NSDictionary *dict = sender;
    IdPassport = dict;
    [mainTableView reloadData];
}

- (void)checkPay
{
    //if user choosed cash on shipping,need verification user phonenumber
//    if ([choosePayType isEqualToString:kCashPay])
//    {
//        NSString*  telephone_area_code=@"";
//        NSString*  telephone= @"";
//        
//        SET_IF_NOT_NULL(telephone_area_code, receiveInfo[@"telephone_area_code"]);
//        SET_IF_NOT_NULL(telephone, receiveInfo[@"telephone"]);
//        
//        int sel_address_id = 0;
//        if (receiveInfo!=nil)
//        {
//            sel_address_id = [receiveInfo[@"address_id"] intValue];
//        }
//        
    if ([GDPublicManager instance].phonenumber.length<=0)
    {
        GDPhoneViewController* vc =  [[GDPhoneViewController alloc] init];
        vc.target = self;
        vc.callback = @selector(phoneResult:);
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        [self tapMakeOrder];
    }
}

#pragma mark - Paypal
- (NSMutableArray*)caluItemsPrice
{
    float ex = 1;
    if ([choosePayType isEqualToString:kPaypal] || [choosePayType isEqualToString:kAliPay])
    {
        ex = exchangeUsdRate;
    }
    NSMutableArray* items = [[NSMutableArray alloc] init];
    // Optional: include multiple items
    for (NSDictionary* obj in self.productData)
    {
        NSString*    post_name;
        
        float price = [obj[@"sprice"] floatValue]*ex;
        int qty = [obj[@"order_qty"] intValue];
        int product_id = [obj[@"product_id"] intValue];
        int option_value_id = [obj[@"option_value_id"] intValue];
        
        NSString*  SKU;
        if (option_value_id>0)
        {
            post_name =  [NSString stringWithFormat:@"%@ (%@)",obj[@"name"],obj[@"option_value_name"]];
            SKU = [NSString stringWithFormat:@"SKU%d,%d",product_id,option_value_id];
        }
        else
        {
            post_name = obj[@"name"];
            SKU = [NSString stringWithFormat:@"SKU%d",product_id];
        }
        // field = "transactions[0].item_list.items[0].name";
        if (post_name.length>127)
        {
            post_name = [post_name substringToIndex:127];
        }
        PayPalItem *item = [PayPalItem itemWithName:post_name
                                       withQuantity:qty
                                          withPrice:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",price]]
                                       withCurrency:PaypalCurrency
                                            withSku:SKU];
        [items addObject:item];
    }
    return items;
}

- (void)orderOkAndDelProduct
{
    //delete this items from carts
    for (NSDictionary* obj in self.productData)
    {
        int product_id = [obj[@"product_id"] intValue];
        int option_value_id = [obj[@"option_value_id"] intValue];
        [[WCDatabaseManager instance] deleteCart:product_id withOption:option_value_id];
    }
    NSDictionary *parameters = @{@"verdorId":@(self.vendorId)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDeleteVendorCart object:parameters userInfo:nil];

}

- (void)completePay
{
    [UIAlertView showWithTitle:NSLocalizedString(@"Order Successful", @"购买成功")
                       message:NSLocalizedString(@"You are able to enjoy discounts after\n vendors scan your QR code.", @"请使用二维码去商家享受优惠，商家会对二维码进行扫描确认，您只需要付优惠后的金额.")
             cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              //pop
                              [CATransaction begin];
                              [CATransaction setCompletionBlock:^{
                                  GDOrderDetailsViewController* nv = [[GDOrderDetailsViewController alloc] initWithOrderId:order_id];
                                  [_superNav pushViewController:nv animated:YES];
                              }];
                              
                              [self.navigationController popViewControllerAnimated:NO];
                              
                              [CATransaction commit];
                          }
                      }];
}

- (void)completeBank:(NSString*)url
{
    [UIAlertView showWithTitle:NSLocalizedString(@"Order Successful", @"订单成功")
                       message:NSLocalizedString(@"Please kindly transfer the required amount to the bank account.", @"请按照要求的金额进行银行转账.")
             cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              //pop
                              [CATransaction begin];
                              [CATransaction setCompletionBlock:^{
                                  GDReturnsViewController* nv = [[GDReturnsViewController alloc] init:url];
                                  [_superNav pushViewController:nv animated:YES];
                              }];
                              
                              [self.navigationController popViewControllerAnimated:NO];
                              
                              [CATransaction commit];
                          }
                      }];
}


- (void)tapMakeOrder
{
    int sel_address_id = 0;
    if (receiveInfo!=nil)
    {
        sel_address_id = [receiveInfo[@"address_id"] intValue];
    }
    
    int courier_id = 0;
    if (chooseDeliver<deliverInfo.count)
    {
        NSDictionary* obj = [deliverInfo objectAtIndex:chooseDeliver];
        courier_id = [obj[@"courier_id"] intValue];
    }
    
    NSString *jsonStr = [[GDOrderCheck instance] genJsonStr:self.productData];
    
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/order/gen_order_v2"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    NSDictionary *parameters;

    if (isFree)
    {
         if (![[GDPublicManager instance] isMember])
         {
              parameters = @{@"product_list_json":jsonStr,@"token":[GDPublicManager instance].token,@"language_id":@([[GDSettingManager instance] language_id:NO]),@"comment":comment,@"vendor_id":@(vendorId),@"payment_code":@"free"};
         }
         else
         {
             parameters = @{@"product_list_json":jsonStr,@"token":[GDPublicManager instance].token,@"language_id":@([[GDSettingManager instance] language_id:NO]),@"comment":comment,@"vendor_id":@(vendorId),@"payment_code":@"membership_card"};
         }
    }
    else
    {
         parameters = @{@"product_list_json":jsonStr,@"token":[GDPublicManager instance].token,@"language_id":@([[GDSettingManager instance] language_id:NO]),@"comment":comment,@"vendor_id":@(vendorId),@"payment_code":choosePayType};
    }
    
    [ProgressHUD show:NSLocalizedString(@"Submiting...",@"提交订单...")];
    
    NSMutableDictionary *mutParameters = [parameters mutableCopy];
    if (require_passport_or_idcard)
    {
        if ([IdPassport[@"id"] length])
        {
            [mutParameters setObject:@"idcard" forKey:@"other_info_type"];
            [mutParameters setObject:IdPassport[@"id"] forKey:@"other_info"];
        }
        else if ([IdPassport[@"passport"] length])
        {
            [mutParameters setObject:@"passport" forKey:@"other_info_type"];
            [mutParameters setObject:IdPassport[@"passport"] forKey:@"other_info"];
        }
        [mutParameters setObject:IdPassport[@"username"] forKey:@"other_info_idname"];
        [mutParameters setObject:startDate forKey:@"checkin_date"];
    }
    
    
    [manager POST:url
       parameters:mutParameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [ProgressHUD dismiss];
         LOG(@"JSON: %@", responseObject);

         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             NSDictionary* dict = responseObject[@"data"];
             order_id = dict[@"order_id"];
             
             [self orderOkAndDelProduct];
             
              if (isFree)
              {
                  [self completePay];
              }
              else
              {
                  if ([choosePayType isEqualToString:kCashPay] || [choosePayType isEqualToString:kShopPay])
                  {
                      [self completePay];
                  }
                  else if ([choosePayType isEqualToString:kMashreqbank])
                  {
                      NSMutableDictionary* obj = [payWayInfo objectAtIndex:choosePay];
                      NSString* url = [NSString stringWithFormat:@"%@&order_id=%@&language_id=%d",obj[@"url"],order_id,[[GDSettingManager instance] language_id:NO]];
                      [self completeBank:url];
                  }
                  else if ([choosePayType isEqualToString:kPaypal])
                  {
                      [self toPaypal];
                  }
                  else if ([choosePayType isEqualToString:kAliPay])
                  {
                      [self toAlipay];
                  }
                  else if ([choosePayType isEqualToString:kEtisalat])
                  {
                      [self toEtisalat];
                  }
                  else if ([choosePayType isEqualToString:kWechatPay])
                  {
                      [self toWechatPay];
                  }
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

#pragma mark - wechat pay
- (void)toWechatPay
{
    float price = exchangeCnyRate*(sprice+deliveryFee);
    NSString* strPrict = [NSString stringWithFormat:@"%d",(int)(price*100)];//分
    
    [weixinAccountManage sharedInstance].delegate = self;
    [[weixinAccountManage sharedInstance] getPrepayWithOrderName:NSLocalizedString(@"Buy Coupon", @"购买优惠卷") price:strPrict withNo:order_id withUrl:[NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Order/weixin_callback"]];
}

- (void)wechatPayCompleted:(BOOL)success
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (success)
    {
        [self completePay];
    }
    else
    {
        [self orderOkAndDelProduct];
        order_id = @"";
        
        [UIAlertView showWithTitle:NSLocalizedString(@"Payment Failed", @"支付失败")
                           message:NSLocalizedString(@"You need to pay at me->orders!", @"下单成功, 您没有完成支付,可以在我的-待支付 继续完成支付!")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  [self.navigationController popViewControllerAnimated:YES];
                              }
                          }];
    }
}


- (void)toAlipay
{
    AlipayProduct *product = [[AlipayProduct alloc] init];
    
    NSString* body;
    NSMutableString *headerString = [NSMutableString string];
    
    for (NSDictionary* obj in self.productData)
    {
        int qty = [obj[@"order_qty"] intValue];
        NSString* every = [NSString stringWithFormat:@"%@,%d\n",obj[@"name"],qty];
        [headerString appendString:every];
    }
    body = [NSString stringWithString:headerString];
    
    product.subject = NSLocalizedString(@"Buy Coupon", @"购买优惠卷");
    product.body  = body;
    product.price = exchangeUsdRate*(sprice+chosseCodFee+deliveryFee);
    
    [AliPayment instance].delegate = self;
    [[AliPayment instance] callAli:product withNo:order_id withUrl:[NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/order/alipay_notify"]];
}


- (void)toEtisalat
{
    float price = sprice+chosseCodFee+deliveryFee;
    
    [[GDEtisalat instance] callEtisalat:order_id withName:NSLocalizedString(@"Buy Coupon", @"购买优惠卷") withPrice:price withType:@"live" withNav:self.navigationController withId:self];
}


- (void)toPaypal
{
    NSMutableArray* items = [self caluItemsPrice];
    
    float ex = 1;
    if ([choosePayType isEqualToString:kPaypal])
    {
        ex = exchangeUsdRate;
    }
    
    NSDecimalNumber *shipping=[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.3f",(deliveryFee+chosseCodFee)*ex]];
    
    GDPaypal* pay = [[GDPaypal alloc] init];
    
    if ([choosePayType isEqualToString:kPaypal])
    {
        [pay callPaypal:items withShipFee:shipping withSuper:self withCard:NO];
    }
}

#pragma mark Alipay methods
- (void)aliPayCompleted:(BOOL)success
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (success)
    {
        [self completePay];
    }
    else
    {
        [self orderOkAndDelProduct];
        order_id = @"";
        
        [UIAlertView showWithTitle:NSLocalizedString(@"Payment Failed", @"支付失败")
                           message:NSLocalizedString(@"You need to pay at me->orders!", @"下单成功, 您没有完成支付,可以在我的-待支付 继续完成支付!")
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
    
    [self orderOkAndDelProduct];
    order_id = @"";
    
    [UIAlertView showWithTitle:NSLocalizedString(@"Payment Failed", @"支付失败")
                       message:NSLocalizedString(@"You need to pay at me->orders!", @"下单成功, 您没有完成支付,可以在我的-待支付 继续完成支付!")
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
     
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Order/verify_payment"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    NSDictionary *parameters = @{@"order_id":order_id,@"token":[GDPublicManager instance].token,@"payment_code":choosePayType,@"verify_payment_id":paypemtID};
    
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
    
    //order_id = @"";
    
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
        if ([choosePayType isEqualToString:kCashPay]  || [choosePayType isEqualToString:kShopPay])
        {
            [confirmBut setTitle: NSLocalizedString(@"Confirm", @"确定") forState:UIControlStateNormal];
            chosseCodFee = codFee;
        }
        else
        {
            [confirmBut setTitle: NSLocalizedString(@"Continue to pay", @"确定并支付") forState:UIControlStateNormal];
            chosseCodFee = 0;
        }
    }
    [mainTableView reloadData];
}

- (void)setChooseDeliver:(int)nIndex
{
    chooseDeliver = nIndex;
    
    NSDictionary* obj = [deliverInfo objectAtIndex:chooseDeliver];
    
    deliveryFee = [obj [@"shipping_price"] floatValue];
    
    [mainTableView reloadData];
}

- (void)selectedBirth:(NSString *)value
{
    startDate = value;
    [mainTableView reloadData];
}

#pragma mark - Data
//- (void)getPaymentPrice
//{
//    NSString* url;
//    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"billing/get_payment_fee"];
//    NSDictionary *parameters=@{@"payment_code":kCashPay};
//        
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        
//    [manager POST:url
//           parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
//         {
//             int status = [responseObject[@"status"] intValue];
//             if (status==1)
//             {
//                 float price = [responseObject[@"data"][@"price"] floatValue];
//                 codFee = price;
//                 [mainTableView reloadData];
//             }
//             else
//             {
//                 NSString *errorInfo =@"";
//                 SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
//                 LOG(@"errorInfo: %@", errorInfo);
//                 [ProgressHUD showError:errorInfo];
//             }
//             
//             [self setChoosePay:0];
//            
//         }
//         failure:^(AFHTTPRequestOperation *operation, NSError *error)
//         {
//             LOG(@"%@",operation.responseObject);
//             [ProgressHUD showError:error.localizedDescription];
//         }];
//}

//- (void)getShippingPrice:(int)sel_address_id
//{
//    
//    NSString *jsonStr = [[GDOrderCheck instance] genJsonStr:self.productData];
//    
//    NSString* url;
//    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"billing/get_shipping_price_of_products"];
//        
//    __block int count = 0;
//    for (NSMutableDictionary *obj in deliverInfo)
//    {
//                 int courier_id = [obj[@"courier_id"] intValue];
//                
//                 NSDictionary *parameters=@{@"courier_id":@(courier_id),@"vendor_id":@(vendorId),@"product_list_json":jsonStr,@"address_id":@(sel_address_id)};
//                
//                 AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//                
//                [manager POST:url
//                   parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
//                 {
//                     int status = [responseObject[@"status"] intValue];
//                     if (status==1)
//                     {
//                         float price = [responseObject[@"data"][@"price"] floatValue];
//                         @synchronized(obj)
//                         {
//                            [obj setObject:@(price) forKey:@"shipping_price"];
//                         }
//                     }
//                     else
//                     {
//                         NSString *errorInfo =@"";
//                         SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
//                         LOG(@"errorInfo: %@", errorInfo);
//                         [ProgressHUD showError:errorInfo];
//                     }
//                     
//                     count++;
//                     if (count==1)
//                     {
//                         [self setChooseDeliver:0];
//                     }
//                     else  if (count == deliverInfo.count)
//                         [mainTableView reloadData];
//                     
//                 }
//                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
//                 {
//                     LOG(@"%@",operation.responseObject);
//                     [ProgressHUD showError:error.localizedDescription];
//                 }];
//
//            }
//}

- (void)getPrice:(id)sender
{
    NSDictionary *dict = sender;
    sprice = [dict[@"sprice"] floatValue];
    [mainTableView reloadData];
}

- (void)getPayWay
{
    if (isFree)
        return;
    
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
            //[self getPaymentPrice];
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

- (void)getShipWay:(int)sel_address_id
{
//     [ProgressHUD show:nil];
//    
//     NSString *jsonStr = [[GDOrderCheck instance] genJsonStr:self.productData];
//    
//     NSString* url;
//     url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"shipping/get_courier_list_of_vendor_with_shipping_price"];
//    
//     NSDictionary *parameters=@{@"vendor_id":@(self.vendorId),@"product_list_json":jsonStr,@"address_id":@(sel_address_id)};
//        
//     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//     manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
//    
//     [manager POST:url
//           parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//            [ProgressHUD dismiss];
//            int status = [responseObject[@"status"] intValue];
//            if (status==1)
//            {
//                @synchronized(deliverInfo)
//                {
//                    [deliverInfo removeAllObjects];
//                }
//            
//                if(responseObject[@"data"][@"courier_list"]!= [NSNull null] && responseObject[@"data"][@"courier_list"]!= nil)
//                {
//                    NSArray* temp = responseObject[@"data"][@"courier_list"];
//                    for (NSDictionary* obj in temp)
//                    {
//                        NSMutableDictionary *dictTemp = [obj mutableCopy];
//                        [deliverInfo addObject:dictTemp];
//                    }
//                }
//            
//                if (deliverInfo.count>0)
//                {
//                    [self setChooseDeliver:0];
//                }
//            
//             }
//             else
//             {
//                 NSString *errorInfo =@"";
//                 SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
//                 LOG(@"errorInfo: %@", errorInfo);
//                 [ProgressHUD showError:errorInfo];
//             }
//    }
//    failure:^(AFHTTPRequestOperation *operation, NSError *error)
//    {
//        LOG(@"%@",operation.responseObject);
//        [ProgressHUD showError:error.localizedDescription];
//    }];
//
}

- (void)getReceiveAddress
{
   
//    NSString* url;
//    NSDictionary *parameters;
//    
//    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"address/get_address_list_of_customer"];
//    parameters = @{@"token":[GDPublicManager instance].token};
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
//    
//    [manager POST:url
//       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         [ProgressHUD dismiss];
//         
//         int status = [responseObject[@"status"] intValue];
//         if (status==1)
//         {
//             if(responseObject[@"data"][@"address_list"] != [NSNull null] && responseObject[@"data"][@"address_list"] != nil)
//             {
//                 NSDictionary* obj;
//                 for (obj in responseObject[@"data"][@"address_list"])
//                 {
//                      receiveInfo = obj;
//                      int  selected = [obj[@"selected"] floatValue];
//                      if (selected==1)
//                      {
//                          receiveInfo = obj;
//                          break;
//                      }
//                 }
//             }
//            
//             [mainTableView reloadData];
//         }
//         else
//         {
//             NSString *errorInfo =@"";
//             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
//             LOG(@"errorInfo: %@", errorInfo);
//             [ProgressHUD showError:errorInfo];
//         }
//         
//         if (receiveInfo!=nil)
//         {
//             int sel_address_id = [receiveInfo[@"address_id"] intValue];
//             [self getShipWay:sel_address_id];
//         }
//
//         confirmBut.enabled = YES;
//     }
//     failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         [ProgressHUD showError:error.localizedDescription];
//     }];
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kAddressSection)
    {
        if (receiveInfo!=nil)
        {
            static NSString *CellIdentifier = @"cellUserAddress";
            GDReceiveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GDReceiveCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            
            NSString*  name = @"";
            NSString*  telephone_area_code=@"";
            NSString*  telephone= @"";
            NSString*  address=@"";
            NSString*  country=@"";
            NSString*  city=@"";
            NSString*  area=@"";
            
            SET_IF_NOT_NULL(name, receiveInfo[@"firstname"]);
            SET_IF_NOT_NULL(telephone_area_code, receiveInfo[@"telephone_area_code"]);
            SET_IF_NOT_NULL(telephone, receiveInfo[@"telephone"]);
            SET_IF_NOT_NULL(address, receiveInfo[@"address_1"]);
            SET_IF_NOT_NULL(country, receiveInfo[@"country_name"]);
            SET_IF_NOT_NULL(city, receiveInfo[@"zone_name"]);
            SET_IF_NOT_NULL(area, receiveInfo[@"zonearea_name"]);

            cell.name.text  = [NSString stringWithFormat:NSLocalizedString(@"Receiver: %@", @"收货人:%@"),name];
            cell.phone.text = [NSString stringWithFormat:@"%@%@",telephone_area_code,telephone];
            cell.address.text = [NSString stringWithFormat:@"%@,%@,%@,%@",address,area,city,country];
            
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more.png"]];
            
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"cellAddAddress";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                
            }
            CGRect r = self.view.frame;
            ACPButton* addBut = [ACPButton buttonWithType:UIButtonTypeCustom];
            addBut.frame = CGRectMake(50, 4, r.size.width-100, 32);
            [addBut setStyleRedButton];
            [addBut setTitle: NSLocalizedString(@"Add Receiving Address", @"添加收货地址") forState:UIControlStateNormal];
            [addBut addTarget:self action:@selector(tapAdd) forControlEvents:UIControlEventTouchUpInside];
            [addBut setLabelFont:MOLightFont(14)];
            
            [cell.contentView addSubview:addBut];
            return cell;
        }
        
    }
    else if (indexPath.section == kDeliverSection)
    {
        if (indexPath.row ==0)
        {
            static NSString *CellIdentifier = @"cellShip";
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
            cell.textLabel.text=  NSLocalizedString(@"Shipping", @"物流方式");
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"cellShipWay";
            
            GDShipsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GDShipsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                
            }
            
            NSDictionary* obj = [deliverInfo objectAtIndex:indexPath.row-1];
            NSString* imageUrl = obj[@"courier_image"];
            [cell.iconImage sd_setImageWithURL:[NSURL URLWithString:[imageUrl encodeUTF]] placeholderImage:[UIImage imageNamed:@"market_product_default.png"]];
            cell.iconImage.contentMode = UIViewContentModeScaleAspectFit;
            
            NSString* courier_name=@"";
            SET_IF_NOT_NULL(courier_name, obj[@"courier_name"]);
            float shipping_price = [obj[@"shipping_price"] floatValue];
            
            NSString* fees = [NSString stringWithFormat:NSLocalizedString(@"Freight(%@%0.1f)",@"运费(%@%0.1f)"),[GDPublicManager instance].currency,shipping_price];
            
            cell.title.text = courier_name;
            SET_IF_NOT_NULL(cell.details.text, obj[@"description"]);
            cell.details.textColor = [UIColor grayColor];
            
            cell.fees.text = fees;
            
            if (chooseDeliver==indexPath.row-1)
            {
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick.png"]];
            }
            else
            {
                cell.accessoryView = nil;
            }
            
            return cell;
        }
    }
    else if (indexPath.section == kPaymentSection)
    {
        if (indexPath.row ==0)
        {
            static NSString *CellIdentifier = @"cellPay";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
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
                else if ([codeId isEqualToString:kCashPay])
                {
                    if (codFee>0)
                    {
                        cell.fees.text = [NSString stringWithFormat:NSLocalizedString(@"Additional Fees(%@%0.1f)",@"附加费(%@%0.1f)"),[GDPublicManager instance].currency,codFee];
                        cell.fees.textColor = MOColorSaleFontColor();
                    }
                }
//              else if ([codeId isEqualToString:kVisaPay])
//              {
//                   cell.fees.text = NSLocalizedString(@"Pay with Card",@"信用卡支付");
//                   cell.fees.textColor = [UIColor grayColor];
//              }
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
    else if (indexPath.section == kCommentSection)
    {
        static NSString *CellIdentifier = @"CellComment";
        UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
             cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
             cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text= NSLocalizedString(@"Message to seller", @"给卖家留言");
        cell.detailTextLabel.text= comment;
        return cell;
    }
    else if (indexPath.section == kRequireID)
    {
        if (indexPath.row  == 0)
        {
            static NSString *CellIdentifier = @"CellRequireId";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.textLabel.text= NSLocalizedString(@"ID Or Passport", @"身份证 或 护照");
            if (IdPassport!=nil)
                cell.detailTextLabel.text= [IdPassport[@"id"] length]>0?IdPassport[@"id"]:IdPassport[@"passport"];
        
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"CellDate";
            UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }

            cell.textLabel.text = NSLocalizedString(@"Check-In Date",@"入住日期");
            cell.detailTextLabel.text = startDate;
            return cell;
        }

    }
    else if (indexPath.section == kOrdersSection)
    {
        if (indexPath.row ==0)
        {
            static NSString *CellIdentifier = @"CellPro";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsZero];
            }
            
            if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                [cell setLayoutMargins:UIEdgeInsetsZero];
            }
            
            cell.textLabel.text= NSLocalizedString(@"Items", @"订购商品");
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"CellProList";
            
            GDOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GDOrderListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            NSDictionary* obj = [self.productData objectAtIndex:indexPath.row-1];
            
            NSString* title_name;
            int option_value_id = [obj[@"option_value_id"] intValue];
            if (option_value_id>0)
            {
                title_name = [NSString stringWithFormat:@"%@ (%@)",obj[@"name"],obj[@"option_value_name"]];
            }
            else
            {
                title_name = obj[@"name"];
            }
            
            int price = [obj[@"sprice"] intValue];
            int oprice = [obj[@"oprice"] intValue];
            int setsale = [obj[@"setsale"] intValue];
            
            NSString*  imgUrl =    obj[@"image"];
            int order_qty = [obj[@"order_qty"] intValue];
            
            [cell.photoView sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                                  placeholderImage:[UIImage imageNamed:@"carts_default.png"]];
            
            [[GDSettingManager instance] setTitleAttr:cell.title withTitle:title_name withSale:setsale withOrigin:oprice];
            
            cell.total_qty.text = [NSString stringWithFormat:@"%@%d x %d",[GDPublicManager instance].currency,price,order_qty];
            
            cell.price.text =  [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, price*order_qty];
            
            return cell;
        }

    }
    else if (indexPath.section == kPriceSection)
    {
        static NSString *CellIdentifier = @"CellSum";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        float offsetY = 5;
        UILabel*  ordersPrice =  MOCreateLabelAutoRTL();
        ordersPrice.font = MOLightFont(13);
        ordersPrice.frame = CGRectMake(10, offsetY, [GDPublicManager instance].screenWidth-20, 20);
        ordersPrice.textColor = [UIColor whiteColor];
        ordersPrice.backgroundColor =  [UIColor clearColor];
        ordersPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Subtotal: %@%.1f",@"订单金额: %@%.1f"),[GDPublicManager instance].currency, sprice];
        [ordersPrice findCurrency:CurrencyFontSize];
        
        if (![order_type isEqualToString:@"live"])
        {
            offsetY+=20;
            UILabel* deliverPrice =  MOCreateLabelAutoRTL();
            deliverPrice.font = MOLightFont(13);
            deliverPrice.frame = CGRectMake(10, offsetY,[GDPublicManager instance].screenWidth-20, 20);
            deliverPrice.textColor = [UIColor whiteColor];
            deliverPrice.backgroundColor =  [UIColor clearColor];
            deliverPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Shipping: %@%.1f",@"运费金额: %@%.1f"),[GDPublicManager instance].currency, deliveryFee];
            [deliverPrice findCurrency:CurrencyFontSize];
            [cell.contentView addSubview:deliverPrice];
        }
        
        if (chosseCodFee>0)
        {
            offsetY+=20;
            UILabel* payPrice =  MOCreateLabelAutoRTL();
            payPrice.font = MOLightFont(13);
            payPrice.frame = CGRectMake(10, offsetY, [GDPublicManager instance].screenWidth-20, 20);
            payPrice.textColor = [UIColor whiteColor];
            payPrice.backgroundColor =  [UIColor clearColor];
            payPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Cash/Card On Delivery Charges: %@%.1f",@"货到付款手续费: %@%.1f"),[GDPublicManager instance].currency, chosseCodFee];
            [payPrice findCurrency:CurrencyFontSize];
            [cell.contentView addSubview:payPrice];
        }
        
        offsetY+=20;
        
        UILabel* sumPrice =  MOCreateLabelAutoRTL();
        sumPrice.textAlignment = [GDSettingManager instance].isRightToLeft?NSTextAlignmentLeft:NSTextAlignmentRight;
        
        sumPrice.font = MOLightFont(13);
        sumPrice.frame = CGRectMake(10, offsetY, [GDPublicManager instance].screenWidth-20, 20);
        sumPrice.textColor = [UIColor whiteColor];
        sumPrice.backgroundColor =  [UIColor clearColor];
        
        if (isFree && [[GDPublicManager instance] isMember])
        {
            sumPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Member Total: %@%.1f",@"会员总金额: %@%.1f"),[GDPublicManager instance].currency, sprice+chosseCodFee+deliveryFee];
        }
        else
        {
            sumPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Total: %@%.1f",@"总金额: %@%.1f"),[GDPublicManager instance].currency, sprice+chosseCodFee+deliveryFee];
        }
        
        [sumPrice findCurrency:CurrencyFontSize];
        
        if ([choosePayType isEqualToString:kPaypal] || [choosePayType isEqualToString:kAliPay])
        {
            offsetY+=20;
            
            NSMutableArray  *items = [self caluItemsPrice];
            NSDecimalNumber *subtotal = [PayPalItem totalPriceForItems:items];
            float ex = 1;
            
            ex = exchangeUsdRate;
            
            NSDecimalNumber *shipping=[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.1f",(deliveryFee+chosseCodFee)*ex]];
                                                      
            UILabel* exPrice =  MOCreateLabelAutoRTL();
            exPrice.textAlignment = [GDSettingManager instance].isRightToLeft?NSTextAlignmentLeft:NSTextAlignmentRight;
            
            exPrice.font = MOLightFont(13);
            exPrice.frame = CGRectMake(10, offsetY, [GDPublicManager instance].screenWidth-20, 20);
            exPrice.textColor = [UIColor whiteColor];
            exPrice.backgroundColor =  [UIColor clearColor];
            exPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Price after conversion: %@%.2f",@"价格被转换: %@%.2f"),PaypalCurrency, [subtotal floatValue]+[shipping floatValue]];
            
            [cell.contentView addSubview:exPrice];
        }
        else if ([choosePayType isEqualToString:kWechatPay])
        {
            offsetY+=20;
            
            UILabel* exPrice =  MOCreateLabelAutoRTL();
            exPrice.textAlignment = [GDSettingManager instance].isRightToLeft?NSTextAlignmentLeft:NSTextAlignmentRight;
            
            exPrice.font = MOLightFont(14);
            exPrice.frame = CGRectMake(10, offsetY, [GDPublicManager instance].screenWidth-20, 20);
            exPrice.textColor = [UIColor whiteColor];
            exPrice.backgroundColor =  [UIColor clearColor];
            
            NSDecimalNumber *shipping=[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",(sprice+deliveryFee)*exchangeCnyRate]];
                
            exPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Price after conversion: %@%.2f",@"价格被转换: %@%.2f"),AlipalCurrency, [shipping floatValue]];
            [cell.contentView addSubview:exPrice];
        }
        
        cell.backgroundColor = [UIColor colorWithRed:75/255.0 green:87/255.0 blue:114/255.0 alpha:1.0];
        [cell.contentView addSubview:ordersPrice];
        [cell.contentView addSubview:sumPrice];

        return cell;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int nIndex  = 0;
    
    kPriceSection   = nIndex++;
   
//    if (![order_type isEqualToString:@"live"])
//        kAddressSection = nIndex++;
//    else
    kAddressSection = 6;
//    
//    if (deliverInfo.count>0 && ![order_type isEqualToString:@"live"])
//    {
//        kDeliverSection = nIndex++;
//    }
//    else
    kDeliverSection = 6;
    
    if (require_passport_or_idcard)
        kRequireID = nIndex++;
    else
        kRequireID = 6;
    
    kOrdersSection  = nIndex++;

    if (!isFree)
        kPaymentSection = nIndex++;
    else
        kPaymentSection = 6;
    
    kCommentSection = 6;//kCommentSection = nIndex++;
    
    
    return nIndex;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kAddressSection)
    {
       return 1;
    }
    else if (section == kDeliverSection)
    {
         return 1+deliverInfo.count;
    }
    else if (section == kPaymentSection)
    {
        return 1+payWayInfo.count;
    }
    else if (section == kRequireID)
    {
        return 2;
    }
    else if (section == kOrdersSection)
    {
         return 1+self.productData.count;
    }
    else if (section == kPriceSection)
    {
        return 1;
    }
    else if (section == kCommentSection)
    {
        return 1;
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kAddressSection)
    {
        if (receiveInfo!=nil)
            return 110;
        return 40;
    }
    else if (indexPath.section == kDeliverSection)
    {
        if (indexPath.row == 0)
            return 40;
        else
            return 70;
    }
    else if (indexPath.section == kPaymentSection)
    {
        if (indexPath.row == 0)
            return 40;
        else
            return 60;
    }
    else if (indexPath.section == kRequireID)
    {
        return 40;
    }
    else if (indexPath.section == kOrdersSection)
    {
        if (indexPath.row == 0)
            return 40;
        else
            return 100;
    }
    else if (indexPath.section == kPriceSection)
    {
        float baseHeight = 50;
        
        if (![order_type isEqualToString:@"live"])
        {
            baseHeight+=20;
        }
        
        if (chosseCodFee>0)
            baseHeight+=20;
        
        if ([choosePayType isEqualToString:kPaypal] || [choosePayType isEqualToString:kAliPay] || [choosePayType isEqualToString:kWechatPay])
        {
            baseHeight+=20;
        }
        
        return baseHeight;
    }
    else if (indexPath.section == kCommentSection)
    {
        return 40;
    }
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==kCommentSection)
    {
        GDMessageViewController* nv = [[GDMessageViewController alloc] init:self action:@selector(getUserMessage:)];
        [self.navigationController pushViewController:nv animated:YES];
    }
    else if (indexPath.section==kAddressSection)
    {
        int sel_address_id = 0;
        if (receiveInfo!=nil)
        {
            sel_address_id = [receiveInfo[@"address_id"] intValue];
        }
        
        GDDeliveryAddressManageViewController* nv = [[GDDeliveryAddressManageViewController alloc] init];
        nv.sel_address_id = sel_address_id;
        nv.isChoose = YES;
        nv.target = self;
        nv.callback = @selector(choosed:);
        [self.navigationController pushViewController:nv animated:YES];
    }
    else if (indexPath.section == kDeliverSection)
    {
        if (indexPath.row>0)
        {
            [self setChooseDeliver:(int)indexPath.row-1];
        }
    }
    else if (indexPath.section == kPaymentSection)
    {
        if (indexPath.row>0)
        {
            [self setChoosePay:(int)indexPath.row-1];
        }
    }
    else if (indexPath.section == kRequireID)
    {
        if (indexPath.row == 0)
        {
            GDPassportViewController* vc =  [[GDPassportViewController alloc] initWithStyle:UITableViewStyleGrouped];
            vc.target = self;
            vc.callback = @selector(passportResult:);
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            
            MODayViewController* startChoose = [[MODayViewController alloc] init:self action:@selector(selectedBirth:) withUnavailable:date_unavailable withEnddate:endDate];
            [self.navigationController pushViewController:startChoose animated:YES];

        }
    }
}


@end
