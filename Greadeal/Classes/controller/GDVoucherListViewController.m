//
//  GDVoucherListViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/6.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDVoucherListViewController.h"
#import "RDVTabBarController.h"
#import "GDOrderListCell.h"

#import "GDDeliverViewController.h"
#import "GDOrderDetailsViewController.h"

#import "GDLiveVendorViewController.h"
#import "GDRatingViewController.h"

@interface GDVoucherListViewController ()

@end

@implementation GDVoucherListViewController

- (id)init:(vourcherOrderSearchType)atype;
{
    self = [super init];
    if (self)
    {
        orderFindType = atype;
        
        orderData = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
        
        order_id=@"";
        
        switch (orderFindType) {
            case VOUCHER_ORDER_ALL:
                self.title = NSLocalizedString(@"All", @"全部");
                break;
            case VOUCHER_ORDER_PAID:
                self.title = NSLocalizedString(@"Paid", @"已支付");
                break;
            case VOUCHER_ORDER_AWAITING_PAYMENT:
                self.title = NSLocalizedString(@"Awaiting Payment", @"待支付");
                break;
            case VOUCHER_ORDER_CANCELED:
                self.title = NSLocalizedString(@"Canceled", @"已取消");
                break;
            default:
                break;
        }
    }
    return self;
}

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect r = self.view.bounds;
    
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    [self addRefreshUI];
    
    exchangeCnyRate = exCnyRate;
    exchangeUsdRate = exUsdRate;
    [self getExchange];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Paypal
- (void)completePay
{
    [self refreshData];
    
    [UIAlertView showWithTitle:NSLocalizedString(@"Order Successful", @"购买成功")
                       message:NSLocalizedString(@"You are able to enjoy discounts after vendors scan your QR code.", @"请使用二维码去商家享受优惠，商家会对二维码进行扫描确认，您只需要付优惠后的金额.")
             cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              
                          }
                      }];
}

- (NSMutableArray*)caluItemsPaypalPrice:(NSArray*)product_list
{
    
    NSMutableArray* items = [[NSMutableArray alloc] init];
    // Optional: include multiple items
    for (NSDictionary* product in product_list)
    {
        NSString*    post_name=product[@"name"];
        
        float price = [product[@"price"] floatValue]*exchangeUsdRate;
        int qty = [product[@"quantity"] intValue];
        int product_id = [product[@"product_id"] intValue];
        
        NSString*  SKU;
        if(product[@"option_list"] != [NSNull null] && product[@"option_list"] != nil)
        {
            NSDictionary* option = product[@"option_list"];
            SKU = [NSString stringWithFormat:@"%@(%@)%d",product[@"name"],option[@"value"],product_id];
            
        }
        if (SKU.length<=0)
            SKU = [NSString stringWithFormat:@"SKU%d",product_id];
        
        
        PayPalItem *item = [PayPalItem itemWithName:post_name
                                       withQuantity:qty
                                          withPrice:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",price]]
                                       withCurrency:PaypalCurrency
                                            withSku:SKU];
        [items addObject:item];
    }
    return items;
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
        order_id = @"";
        paying_code = @"";
        
        [UIAlertView showWithTitle:NSLocalizedString(@"Payment Failed", @"支付失败")
                           message:NSLocalizedString(@"You need to pay at me->orders!", @"下单成功, 您没有完成支付,可以在我的-待支付 继续完成支付!")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                                  if (self.navigationController!=nil)
                                  {
                                      [self.navigationController popViewControllerAnimated:YES];
                                  }
                                  else
                                  {
                                      [_superNav popViewControllerAnimated:YES];
                                  }
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
    paying_code = @"";
    
    [UIAlertView showWithTitle:NSLocalizedString(@"Payment Failed", @"支付失败")
                       message:NSLocalizedString(@"You need to pay at me->orders!", @"您没有完成支付,可以在我的-待支付 继续完成支付!")
             cancelButtonTitle:NSLocalizedString(@"OK", nil)
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              
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
    
    NSDictionary *parameters = @{@"order_id":order_id,@"token":[GDPublicManager instance].token,@"payment_code":paying_code,@"verify_payment_id":paypemtID};
    
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
    paying_code = @"";
}

- (void)toBank:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    int selectedIndex = (int)button.tag;
    NSDictionary* obj = [orderData objectAtIndex:selectedIndex];
    if (obj!=nil)
    {

    }
}

- (void)toEtisalat:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    int selectedIndex = (int)button.tag;
    NSDictionary* obj = [orderData objectAtIndex:selectedIndex];
    if (obj!=nil)
    {

        order_id    = obj[@"order_id"];
        
        int  total = 0;
        if(obj[@"bill"]!= [NSNull null] && obj[@"bill"]!= nil)
        {
            total = [obj[@"bill"][@"total"][@"value"] intValue];
        }
        
        [[GDEtisalat instance] callEtisalat:order_id withName:NSLocalizedString(@"Buy Vouchers", @"购买优惠卷") withPrice:total withType:@"live" withNav:_superNav withId:self];
    }
}

- (void)tapAlipay:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    int selectedIndex = (int)button.tag;
    NSDictionary* obj = [orderData objectAtIndex:selectedIndex];
    if (obj!=nil)
    {

        AlipayProduct *product = [[AlipayProduct alloc] init];
    
        NSString* body;
        NSMutableString *headerString = [NSMutableString string];
    
        order_id    = obj[@"order_id"];
        
        int  total = 0;
        if(obj[@"bill"]!= [NSNull null] && obj[@"bill"]!= nil)
        {
            total = [obj[@"bill"][@"total"][@"value"] intValue];
        }
        
        NSArray* product_list = obj[@"product_list"];
        
        for (NSDictionary* every in product_list)
        {
            int qty = [every[@"order_qty"] intValue];
            NSString* everystr = [NSString stringWithFormat:@"%@,%d\n",every[@"name"],qty];
            [headerString appendString:everystr];
        }
        body = [NSString stringWithString:headerString];
    
        product.subject = NSLocalizedString(@"Buy Vouchers", @"购买优惠卷");
        product.body  = body;
        product.price = exchangeUsdRate*total;
    
        [AliPayment instance].delegate = self;
        [[AliPayment instance] callAli:product withNo:order_id withUrl:@"http://api.greadeal.com/rest2/v1/order/alipay_notify"];
    }
}

- (void)tapPaypal:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    int selectedIndex = (int)button.tag;
    NSDictionary* obj = [orderData objectAtIndex:selectedIndex];
    if (obj!=nil)
    {
        order_id    = obj[@"order_id"];
        paying_code = obj[@"payment_code"];
        
        NSArray* product_list = obj[@"product_list"];
        NSMutableArray* items = [self caluItemsPaypalPrice:product_list];
        
        float  shipping_fee = 0;
        float  payment_fee  = 0;
        if(obj[@"bill"]!= [NSNull null] && obj[@"bill"]!= nil)
        {
            shipping_fee = [obj[@"bill"][@"shipping"][@"value"] floatValue];
            payment_fee = [obj[@"bill"][@"payment_fee"][@"value"] floatValue];
        }
        
        NSDecimalNumber *shipping=[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.1f",(shipping_fee+payment_fee)*exchangeUsdRate]];
        
        GDPaypal* pay = [[GDPaypal alloc] init];
        
        NSString* codeId = obj[@"payment_code"];
        if ([codeId isEqualToString:kPaypal])
        {
            [pay callPaypal:items withShipFee:shipping withSuper:self withCard:NO];
        }
    }
}

#pragma mark - Action
- (void)tapTracking:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    int selectedIndex = (int)button.tag;
    NSDictionary* obj = [orderData objectAtIndex:selectedIndex];
    if (obj!=nil)
    {
        GDDeliverViewController* nv = [[GDDeliverViewController alloc] init:obj];
        if (self.navigationController!=nil)
        {
            [self.navigationController pushViewController:nv animated:YES];
        }
        else
        {
            [_superNav pushViewController:nv animated:YES];
        }
    }
}

- (void)tapRetrun:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    
    [UIAlertView showWithTitle:nil
                       message:NSLocalizedString(@"are you sure to apply for return?", @"您确定要申请退货?")
             cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
             otherButtonTitles:@[NSLocalizedString(@"OK", @"确定")]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
        if (buttonIndex ==1) {
            int selectedIndex = (int)button.tag;
            
            NSDictionary* obj = [orderData objectAtIndex:selectedIndex];
            if (obj!=nil)
            {
                NSString* orderId = obj[@"order_id"];
                NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/order/apply_return"];
                
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
                
                NSDictionary *parameters = @{@"order_id":orderId,@"token":[GDPublicManager instance].token};
                
                [ProgressHUD show:NSLocalizedString(@"Processing...",@"处理中...")];
                
                [manager POST:url
                   parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     [ProgressHUD dismiss];
                     LOG(@"JSON: %@", responseObject);
                     int status = [responseObject[@"status"] intValue];
                     if (status==1)
                     {
                         [UIAlertView showWithTitle:nil
                                            message:NSLocalizedString(@"Apply for return successful", @"申请退货成功")
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                                  otherButtonTitles:nil
                                           tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                               if (buttonIndex == [alertView cancelButtonIndex])
                                               {
                                                   [self refreshData];
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
                     [ProgressHUD showError:error.localizedDescription];
                 }];
            }
        }
     }];
}

- (void)tapCancel:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    
    [UIAlertView showWithTitle:nil
                       message:NSLocalizedString(@"Are you sure to cancel this order?", @"您确定取消这个订单?")
             cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
             otherButtonTitles:@[NSLocalizedString(@"OK", @"确定")]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex ==1) {
            
             int selectedIndex = (int)button.tag;
             NSDictionary* obj = [orderData objectAtIndex:selectedIndex];
             if (obj!=nil)
             {
                 NSString* orderId = obj[@"order_id"];
                 NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Order/cancel_live_order"];
                 
                 AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                 manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
                 
                 NSDictionary *parameters = @{@"order_id":orderId,@"token":[GDPublicManager instance].token};
                 
                 [ProgressHUD show:NSLocalizedString(@"Processing...",@"处理中...")];
                 
                 [manager POST:url
                    parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
                  {
                      [ProgressHUD dismiss];
                      LOG(@"JSON: %@", responseObject);
                      int status = [responseObject[@"status"] intValue];
                      if (status==1)
                      {
                          [UIAlertView showWithTitle:nil
                                             message:NSLocalizedString(@"Order canceled", @"取消订单成功")
                                   cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                                   otherButtonTitles:nil
                                            tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                if (buttonIndex == [alertView cancelButtonIndex])
                                                {
                                                    [self refreshData];
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
                      [ProgressHUD showError:error.localizedDescription];
                  }];
             }

         }
     }];
    
}

- (void)tapConfirm:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    int selectedIndex = (int)button.tag;
    NSDictionary* obj = [orderData objectAtIndex:selectedIndex];
    if (obj!=nil)
    {
        NSString* orderId = obj[@"order_id"];
        NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/order/confirm"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
        
        NSDictionary *parameters = @{@"order_id":orderId,@"token":[GDPublicManager instance].token};
        
        [ProgressHUD show:NSLocalizedString(@"Processing...",@"处理中...")];
        
        [manager POST:url
           parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [ProgressHUD dismiss];
             LOG(@"JSON: %@", responseObject);
             int status = [responseObject[@"status"] intValue];
             if (status==1)
             {
                 [UIAlertView showWithTitle:nil
                                    message:NSLocalizedString(@"Successful confirmation", @"确认收货成功")
                          cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                          otherButtonTitles:nil
                                   tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if (buttonIndex == [alertView cancelButtonIndex])
                                       {
                                           [self refreshData];
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
             [ProgressHUD showError:error.localizedDescription];
         }];
    }
}

//- (void)tapRating:(id)sender
//{
//    UIButton *button = (UIButton *)sender;
//    
//    if (![button isKindOfClass:UIButton.class]) {
//        return;
//    }
//    int selectedIndex = (int)button.tag;
//    
//    NSDictionary* obj = [orderData objectAtIndex:selectedIndex];
//    if (obj!=nil)
//    {
//        NSArray* temp = obj[@"product_list"];
//        if (temp!=nil && temp.count>0)
//        {
//            NSDictionary *product;
//            product = [temp objectAtIndex:0];
//            if (product!=nil)
//            {
//                int product_id = [product[@"product_id"] intValue];
//                GDRatingViewController* vc = [[GDRatingViewController alloc] initWithProduct:product_id];
//                
//                UINavigationController *nc = [[UINavigationController alloc]
//                                              initWithRootViewController:vc];
//                
//                [_superNav presentViewController:nc animated:YES completion:^(void) {}];
//            }
//        }
//    }
//
//}

- (void)tapGo
{
    if (self.navigationController!=nil)
    {
        [[self rdv_tabBarController] setSelectedIndex:[GDSettingManager instance].nTabLive];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [[_superNav rdv_tabBarController] setSelectedIndex:[GDSettingManager instance].nTabLive];
        [_superNav popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Data
- (BOOL)showCancel:(NSDictionary*)obj
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date_end = [formatter dateFromString:obj[@"date_added"]];
    if (date_end==nil)
    {
        return NO;
    }
    
    NSTimeInterval sub = -[date_end timeIntervalSinceNow];
    if (sub<3600) //1 hour
    {
        return YES;
    }
    return NO;
}
- (UIView *)noOrderView
{
    if (!_noOrderView) {
        
        CGRect r = self.view.frame;
        
        _noOrderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height)];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, r.size.height/2-40, r.size.width, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"You have no relevant orders.", @"您没有相关订单");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = MOLightFont(16);
        [_noOrderView addSubview:label];
        
        
        ACPButton* goBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        goBut.frame = CGRectMake(10, r.size.height/2, r.size.width-20, 36);
        [goBut setStyleRedButton];
        [goBut setTitle: NSLocalizedString(@"Go Shopping", @"去购物") forState:UIControlStateNormal];
        [goBut addTarget:self action:@selector(tapGo) forControlEvents:UIControlEventTouchUpInside];
        [goBut setLabelFont:MOLightFont(18)];
        [_noOrderView addSubview:goBut];
        
    }
    return _noOrderView;
}


- (void)getProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    reloading = YES;
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Order/get_live_order_list"];
    
    NSString* order_status_type;
    switch (orderFindType) {
        case VOUCHER_ORDER_ALL:
            order_status_type = @"all";
            break;
        case VOUCHER_ORDER_PAID:
            order_status_type = @"paid";
            break;
        case VOUCHER_ORDER_AWAITING_PAYMENT:
            order_status_type = @"to_paid";
            break;
        case VOUCHER_ORDER_CANCELED:
            order_status_type = @"canceled";
            break;
        default:
            break;
    }

    parameters = @{@"page":@(seekPage),@"limit":@(prePageNumber),@"token":[GDPublicManager instance].token,@"order_status_type":order_status_type,@"language_id":@([[GDSettingManager instance] language_id:NO])};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
     manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             if (seekPage == 1)
             {
                 @synchronized(orderData)
                 {
                     [orderData removeAllObjects];
                 }
             }
             
              if(responseObject[@"data"][@"order_list"] != [NSNull null] && responseObject[@"data"][@"order_list"] != nil)
              {
                  NSArray* temp = responseObject[@"data"][@"order_list"];
                  lastCountFromServer = (int)temp.count;
    
                  if (temp.count > 0)
                  {
                      [orderData addObjectsFromArray:temp];
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
         [ProgressHUD dismiss];
         [self stopLoad];
         [self reLoadView];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self stopLoad];
         [self reLoadView];
         [ProgressHUD showError:error.localizedDescription];
     }];
}

#pragma mark UIView
- (void)reLoadView
{
    [mainTableView reloadData];
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!isLoadData)
    {
        isLoadData = NO;
        [self  getProductData];
        isLoadData = YES;
    }
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [ProgressHUD dismiss];
}


#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* obj = [orderData objectAtIndex:indexPath.section];
    
    if (indexPath.row == 0)
    {
        UITableViewCell *cell ;
        static NSString *ID = @"ordertime";
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.accessoryType = UITableViewCellSelectionStyleNone;
        }
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        UILabel *timeLable = MOCreateLabelAutoRTL();
        timeLable.frame = CGRectMake(12,0, [GDPublicManager instance].screenWidth-24, 40);
        timeLable.backgroundColor = [UIColor clearColor];
        timeLable.font = MOLightFont(12);
        timeLable.textColor = MOColor33Color();
        timeLable.text = cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Order Time: %@", @"下单时间: %@"),obj[@"date_added"]];
        [cell.contentView addSubview:timeLable];
        
        return cell;
    }
    else if (indexPath.row == 1)
    {
        static NSString *CellIdentifier = @"vendor";
        UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        NSString* vendor_name = @"";
        NSString* vendor_phone = @"";
        NSString* type=@"";
        SET_IF_NOT_NULL(type, obj[@"order_type"]);
        if(obj[@"vendor"] != [NSNull null] && obj[@"vendor"] != nil)
        {
            SET_IF_NOT_NULL(vendor_name, obj[@"vendor"][@"vendor_name"]);
            SET_IF_NOT_NULL(vendor_phone, obj[@"vendor"][@"telephone"]);
        }
        
        UILabel *vendorLable = MOCreateLabelAutoRTL();
        vendorLable.frame = CGRectMake(12,0, [GDPublicManager instance].screenWidth-55, 22);
        vendorLable.backgroundColor = [UIColor clearColor];
        vendorLable.font = MOLightFont(14);
        vendorLable.textColor = MOColor33Color();
        vendorLable.text = vendor_name;
        [cell.contentView addSubview:vendorLable];
        
        float offsetY = 22;
        if (![type isEqualToString:@"sale"])
        {
            UILabel *phoneLable = MOCreateLabelAutoRTL();
            phoneLable.frame = CGRectMake(12,offsetY, [GDPublicManager instance].screenWidth-55, 22);
            phoneLable.backgroundColor = [UIColor clearColor];
            phoneLable.font = MOLightFont(14);
            phoneLable.textColor = MOColor33Color();
            phoneLable.text = [NSString stringWithFormat:NSLocalizedString(@"Tel:%@", @"电话:%@"),vendor_phone];
            [cell.contentView addSubview:phoneLable];
            
            offsetY+=22;
        }
        
        int order_status_id = [obj[@"order_status_id"] intValue];
        NSString* payment_method;
        SET_IF_NOT_NULL(payment_method, obj[@"payment_method"]);
        
        UILabel *pmLable = MOCreateLabelAutoRTL();
        pmLable.frame = CGRectMake(12,offsetY, 160*[GDPublicManager instance].screenScale, 22);
        pmLable.backgroundColor = [UIColor clearColor];
        pmLable.font = MOLightFont(12);
        pmLable.textColor = MOColor33Color();
        pmLable.text = payment_method;
        [cell.contentView addSubview:pmLable];
        
        UILabel *psLable = MOCreateLabelAutoRTL();
        psLable.frame = CGRectMake(180*[GDPublicManager instance].screenScale,offsetY, 100*[GDPublicManager instance].screenScale, 22);
        psLable.backgroundColor = [UIColor clearColor];
        psLable.font = MOLightFont(12);
        psLable.textColor = colorFromHexString(@"f80e3a");
        [cell.contentView addSubview:psLable];
        
        switch (order_status_id) {
            case VOUCHER_ORDER_AWAITING_PAYMENT:
                psLable.text = NSLocalizedString(@"Awaiting Payment", @"待支付");
                break;
            case VOUCHER_ORDER_PAID:
                psLable.text = NSLocalizedString(@"Paid", @"已支付");
                break;
            case VOUCHER_ORDER_CANCELED:
                psLable.text = NSLocalizedString(@"Canceled", @"已取消");
                break;
        }
        
        return cell;
    }
    else if (indexPath.row == 2)
    {
        static NSString *CellIdentifier = @"items";
        
        GDOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GDOrderListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
     
        NSArray* temp = obj[@"product_list"];
        if (temp!=nil && temp.count>0)
        {
            NSDictionary *product;
            int order_qty = 0;
            for (product in temp)
            {
                order_qty+=[product[@"quantity"] intValue];
            }
                
            product = [temp objectAtIndex:0];
            
            NSString*  imgUrl=@"";
            NSString*  proname=@"";
        
            SET_IF_NOT_NULL(imgUrl, product[@"image"]);
            
            if(product[@"options"] != [NSNull null] && product[@"options"] != nil)
            {
                NSArray* tempArrar = product[@"options"];
                if (tempArrar.count>0)
                {
                    NSDictionary* option = [tempArrar objectAtIndex:0];
                    proname = [NSString stringWithFormat:@"%@ (%@)",product[@"name"],option[@"value"]];
                }
            }
            
            if (proname.length<=0)
                proname = product[@"name"];
           
            [cell.photoView sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                              placeholderImage:[UIImage imageNamed:@"order_default.png"]];
            
            //int price  = [product[@"price"] intValue];
            int oprice = [product[@"original_price"] intValue];
            int setprice = 0;
            if(product[@"set_price"] != [NSNull null] && product[@"set_price"] != nil)
                 setprice = [product[@"set_price"] intValue];
        
            [[GDSettingManager instance] setTitleAttr:cell.title withTitle:proname withSale:setprice withOrigin:oprice];
            
            cell.total_qty.text = [NSString stringWithFormat:NSLocalizedString(@"%ld Vouchers", @"%ld优惠券"),order_qty];
            
            int  total = 0;
            if(obj[@"bill"]!= [NSNull null] && obj[@"bill"]!= nil)
            {
                total = [obj[@"bill"][@"total"][@"value"] intValue];
            }
            
            int membership_level = [obj[@"vendor"][@"membership_level"] intValue];
            BOOL isFree = [[GDPublicManager instance] isVaildFreeBuy:membership_level withNote:NO];
            
            if (isFree)
            {
                cell.price.text =  [NSString stringWithFormat:NSLocalizedString(@"Member Total: %@%d", @"会员总金额:%@%d"),[GDPublicManager instance].currency, 0];
            }
            else
            {
                 cell.price.text =  [NSString stringWithFormat:NSLocalizedString(@"Total: %@%d", @"总金额:%@%d"),[GDPublicManager instance].currency, total];
            }
        }
         return cell;
    }
    else if (indexPath.row == 3)
    {
        UITableViewCell *cell ;
        static NSString *ID = @"button";
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.accessoryType = UITableViewCellSelectionStyleNone;
        }
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        UILabel *statusLable = MOCreateLabelAutoRTL();
        statusLable.frame = CGRectMake(220*[GDPublicManager instance].screenScale,0, 90*[GDPublicManager instance].screenScale, 30);
        statusLable.backgroundColor = [UIColor clearColor];
        statusLable.font = MOLightFont(12);
        statusLable.textColor = colorFromHexString(@"f80e3a");
        [cell.contentView addSubview:statusLable];

        if ([GDSettingManager instance].isRightToLeft)
        {
            CGRect tempRect = statusLable.frame;
            tempRect.origin.x = 12;
            statusLable.frame = tempRect;
        }
        int order_status_id    = [obj[@"order_status_id"] intValue];
        NSString *payment_code = obj[@"payment_code"];
        NSString* type = @"";
        SET_IF_NOT_NULL(type, obj[@"order_type"]);
        
        ACPButton* tapBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        tapBut.frame = CGRectMake(170*[GDPublicManager instance].screenScale,4, 140*[GDPublicManager instance].screenScale, 32);
        [tapBut setStyleWithImage:@"button_normal.png" highlightedImage:@"button_pressed.png" disableImage:@"button_normal.png" andInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
        [tapBut setLabelTextColor:[UIColor whiteColor] highlightedColor:[UIColor greenColor] disableColor:nil];
        [tapBut setLabelFont:MOLightFont(14)];
        tapBut.tag = indexPath.section;
        [tapBut setCornerRadius:2];
        [cell.contentView addSubview:tapBut];
       
        ACPButton* tempBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        tempBut.frame = CGRectMake(10,4, 140*[GDPublicManager instance].screenScale, 32);
        [tempBut setStyleRedButton];
        [tempBut setLabelFont:MOLightFont(14)];
        tempBut.tag = indexPath.section;
        [tempBut setCornerRadius:2];
        [cell.contentView addSubview:tempBut];
       
        switch (order_status_id) {
            case VOUCHER_ORDER_AWAITING_PAYMENT:
            {
                if ([payment_code isEqualToString:kPaypal])
                {
                    tapBut.hidden = NO;
                    [tapBut setTitle:@"PayPal" forState:UIControlStateNormal];
                    
                    [tapBut addTarget:self action:@selector(tapPaypal:) forControlEvents:UIControlEventTouchUpInside];
                }
                else if ([payment_code isEqualToString:kAliPay])
                {
                    tapBut.hidden = NO;
                    [tapBut setTitle:NSLocalizedString(@"AliPay", @"支付宝") forState:UIControlStateNormal];
                    
                    [tapBut addTarget:self action:@selector(tapAlipay:) forControlEvents:UIControlEventTouchUpInside];
                }
                else if ([payment_code isEqualToString:kEtisalat])
                {
                    tapBut.hidden = NO;
                    [tapBut setTitle:@"Visa / Mastercard" forState:UIControlStateNormal];
                    
                    [tapBut addTarget:self action:@selector(toEtisalat:) forControlEvents:UIControlEventTouchUpInside];
                }
//                else if ([payment_code isEqualToString:kMashreqbank])
//                {
//                    tapBut.hidden  = NO;
//                    
//                    [tapBut setTitle:@"Bank Account" forState:UIControlStateNormal];
//                    
//                    [tapBut addTarget:self action:@selector(toBank:) forControlEvents:UIControlEventTouchUpInside];
//                }

                else{
                    tapBut.hidden = YES;
                }
                
                //member not show cancel order
                tempBut.hidden = NO;
                [tempBut setTitle:NSLocalizedString(@"Cancel Order", @"取消订单") forState:UIControlStateNormal];
                [tempBut addTarget:self action:@selector(tapCancel:) forControlEvents:UIControlEventTouchUpInside];
            }
            break;
            case VOUCHER_ORDER_PAID:
            {
                tempBut.hidden = YES;
                tapBut.hidden  = YES;
            }
                break;
            case VOUCHER_ORDER_CANCELED:
                //提醒发货, 暂定为取消订单
                tapBut.hidden = YES;
                tempBut.hidden = YES;
                break;
            default:
                tapBut.hidden = YES;
                tempBut.hidden = YES;
                break;
        }
        return cell;
    }

    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!reloading && !orderData.count)
    {
        [mainTableView addSubview:[self noOrderView]];
        
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    
    if (orderData.count>0)
    {
        [_noOrderView removeFromSuperview];
        
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    
    return orderData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary* obj = [orderData objectAtIndex:section];
    int order_status_id = [obj[@"order_status_id"] intValue];
  
    if (order_status_id != VOUCHER_ORDER_CANCELED)
    {
        return 4;
    }
    
    return 3;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            return 40;
        }
        case 1:
        {
            NSDictionary* obj = [orderData objectAtIndex:indexPath.section];
            
            NSString* type=@"";
            SET_IF_NOT_NULL(type, obj[@"order_type"]);
            
            if (![type isEqualToString:@"sale"])
            {
                return 65;
            }
            return 45;
        }
            break;
        case 2:
            return 100;
        case 3:
        {
            NSDictionary* obj = [orderData objectAtIndex:indexPath.section];
            
            int order_status_id = [obj[@"order_status_id"] intValue];
            if  (order_status_id == VOUCHER_ORDER_AWAITING_PAYMENT)
            {
                return 40;
            }
            return 0;
        }
        default:
            break;
    }
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* obj = [orderData objectAtIndex:indexPath.section];
   
    if (indexPath.row == 1)
    {
        NSString* vendor_name = @"vendor name";
        NSString* vendor_image = @"";
        NSString* vendor_url = @"";
      
        NSString* type = @"";
        SET_IF_NOT_NULL(type, obj[@"order_type"]);
        
        int vendor_id = 0;
        if(obj[@"vendor"] != [NSNull null] && obj[@"vendor"] != nil)
        {
            vendor_id = [obj[@"vendor"][@"vendor_id"] intValue];
            SET_IF_NOT_NULL(vendor_name,  obj[@"vendor"][@"vendor_name"]);
            SET_IF_NOT_NULL(vendor_url,  obj[@"vendor"][@"store_url"]);
            SET_IF_NOT_NULL(vendor_image, obj[@"vendor"][@"vendor_image"]);
        }
            
//        if (vendor_id>0)
//        {
//            if ([type isEqualToString:@"sale"])
//                {
//                   
//                }
//                else if ([type isEqualToString:@"live"])
//                {
//                    GDLiveVendorViewController * vc = [[GDLiveVendorViewController alloc] init:vendor_id withName:vendor_name withUrl:vendor_url withImage:vendor_image];
//                    if (self.navigationController!=nil)
//                        [self.navigationController pushViewController:vc animated:YES];
//                    else
//                        [_superNav pushViewController:vc animated:YES];
//                }
//            }

    }
    else if (indexPath.row == 2)
    {
        GDOrderDetailsViewController* nv = [[GDOrderDetailsViewController alloc] init:obj];
        if (self.navigationController!=nil)
            [self.navigationController pushViewController:nv animated:YES];
        else
            [_superNav pushViewController:nv animated:YES];
    }
}


#pragma mark Refresh
- (void)refreshData
{
    LOG(@"refresh data");
    isLoadData = NO;
    seekPage = 1;
    
    [self getProductData];
   
}

- (void)nextPage
{
    if (lastCountFromServer>=prePageNumber)
    {
        LOG(@"get next page");
        [self loadMoreView];
        seekPage++;
        
        [self getProductData];
       
    }
    else
        [self stopLoad];
}

#pragma mark scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (scrollView == mainTableView)
    {
        NSInteger currentOffset = scrollView.contentOffset.y;
        NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if (reloading) return;
        
        if (checkForRefresh)
        {
            if (refreshHeaderView.isFlipped
                && scrollView.contentOffset.y > -kRefreshkShowAll-5
                && scrollView.contentOffset.y < 0.0f
                && !reloading) {
                [refreshHeaderView flipImageAnimated:YES];
                [refreshHeaderView setStatus:kMOPullToReloadStatus];
                
            } else if (!refreshHeaderView.isFlipped
                       && scrollView.contentOffset.y < -kRefreshkShowAll-5) {
                [refreshHeaderView flipImageAnimated:YES];
                [refreshHeaderView setStatus:kMOReleaseToReloadStatus];
                
            }
        }
        
        // Change 20.0 to adjust the distance from bottom
        if (currentOffset>0 && currentOffset - maximumOffset >= kThumbsViewMoreHeight)
        {
            [self nextPage];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == mainTableView)
    {
        if (!reloading)
        {
            checkForRefresh = YES;  //only check offset when dragging
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == mainTableView)
    {
        if (!reloading)
        {
            if (scrollView.contentOffset.y <= -kRefreshkShowAll + 10)
            {
                reloading = YES;
                [refreshHeaderView toggleActivityView:YES];
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.2];
                mainTableView.contentInset = UIEdgeInsetsMake(kRefreshkShowAll, 0.0f, 0.0f,0.0f);
                [UIView commitAnimations];
                
                mainTableView.contentOffset=scrollView.contentOffset;
                
                [self refreshData];
                
            }
            checkForRefresh = NO;
        }
    }
}

@end
