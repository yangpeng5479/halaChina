//
//  GDDeliveryOrderViewController.m
//  Greadeal
//
//  Created by Elsa on 16/2/19.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDReservationDeliveryOrderViewController.h"

#import "RDVTabBarController.h"
#import "GDReceiveCell.h"
#import "GDDeliveryOrderCell.h"

#import "GDDeliveryEditAddressViewController.h"
#import "GDDeliveryAddressManageViewController.h"

#import "GDMarketVerificationCodeViewController.h"
#import "GDMessageViewController.h"

#import "GDShipsCell.h"
#import "GDPaymentCell.h"

#import "GDReservationDeliveryOrderDetailsViewController.h"

#import "GDReservationDeliveryListViewController.h"
#import "GDReservationDeliveryOrderListViewController.h"

#define  toolViewHeight 40


@interface GDReservationDeliveryOrderViewController ()

@end

@implementation GDReservationDeliveryOrderViewController
@synthesize  vendorId;

- (void)getExchange
{
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest/v1/currency/get_all_currency"];
    
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
             //[ProgressHUD showError:errorInfo];
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //[ProgressHUD showError:error.localizedDescription];
     }];
}


- (id)init:(NSArray*)aproductData withDeliveryFee:(int)delivery_Fee  withDiscount:(int)acount
{
    self = [super init];
    if (self)
    {
        self.title = NSLocalizedString(@"Order Details", @"订单详情");
        
        self.productData = aproductData;
        sprice = 0;
        choosePayType = @"";
        timeType = -1;
        selectDate = @"";
        
       
        deliveryFee = delivery_Fee;
        discount    = acount;
        
        if (self.productData.count>0)
        {
            int order_qty = 0;
            for (NSDictionary* obj in self.productData)
            {
                order_qty  = [obj[@"order_qty"] intValue];
                sprice += [obj[@"price"] floatValue]*order_qty;
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
    
    codFee = 0.0;
    chosseCodFee =0;
    
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
    
    payWayInfo  = [[NSMutableArray alloc] init];
    timeInfo    = [[NSMutableArray alloc] init];
    
    confirmBut.enabled = NO;
    
    exchangeCnyRate = exCnyRate;
    exchangeUsdRate = exUsdRate;
    
    [self getExchange];
   
    
    [self getReceiveAddress];
    
    [self getTimes];
    
    uuidstr = [self uuidString];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    [self getPayWay];
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
    viewController.canBeChangeArea = NO;
    [self.navigationController pushViewController: viewController animated:YES];
}

#pragma mark - Action

- (void)goCheckout:(id)sender
{
    [self checkPay];
}

- (void)checkQuantity
{
    if (receiveInfo==nil)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                               message:NSLocalizedString(@"No Receiving Address.", @"没有收货地址")
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
    
                                  }
                              }];
    
        return;
    }
    
    if (timeType<0)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"No Delivery Arrival", @"没有选择送到时间")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        
        return;
    }
    
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

    [self checkPay];
}


- (void)choosed:(id)sender
{
    //{"s":<string> sticker name, if applicable, "e":<string> emoji code, if applicable.}
    NSDictionary *dict = sender;
    LOG(@"dict=%@",dict);
    receiveInfo = dict;
    [mainTableView reloadData];
}

- (void)getUserMessage:(id)sender
{
    NSString *dict = sender;
    comment = dict;
    [mainTableView reloadData];
}

- (void)verificationResult:(id)sender
{
    //{"s":<string> sticker name, if applicable, "e":<string> emoji code, if
    [self tapMakeOrder];
}


- (void)completePay
{
    [UIAlertView showWithTitle:NSLocalizedString(@"Order Successful", @"购买成功")
                       message:NSLocalizedString(@"Please waiting for the delivery.", @"请等待餐厅送餐.")
             cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              //pop
                              
                              [CATransaction begin];
                              [CATransaction setCompletionBlock:^{
                                  GDReservationDeliveryOrderDetailsViewController* nv = [[GDReservationDeliveryOrderDetailsViewController alloc] initWithOrderId:order_id];
                                  
                                  [_superNav pushViewController:nv animated:YES];
                                  
                              }];
                              
                              for (UIViewController *temp in self.navigationController.viewControllers) {
                                  if ([temp isKindOfClass:[GDReservationDeliveryListViewController class]])
                                  {
                                      [self.navigationController popToViewController:temp animated:NO];
                                  }
                              }
                              
                              
                              [CATransaction commit];
                          }
                      }];
}

- (void)checkPay
{
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
//        if (sel_address_id!=0)
//        {
//            GDMarketVerificationCodeViewController* vc =  [[GDMarketVerificationCodeViewController alloc] initWithStyle:UITableViewStylePlain];
//            vc.userPhone = [NSString stringWithFormat:@"%@%@",telephone_area_code,telephone];
//            vc.address_id = sel_address_id;
//            vc.target = self;
//            vc.callback = @selector(verificationResult:);
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//    }
//    else
//    {
//        [self tapMakeOrder];
//    }
    
    NSString* message = @"";
    NSString* order_end_time = @"";
    NSString* dTime = @"";
    
    NSMutableDictionary* obj = [timeInfo objectAtIndex:chooseTime];
    
    if (![obj isKindOfClass:[NSNull class]] && obj!= nil)
    {
        NSString*  date=@"";
        NSString*  arrive_start_time=@"";
        NSString*  arrive_end_time=@"";
        
        SET_IF_NOT_NULL(date, obj[@"name"]);
        SET_IF_NOT_NULL(arrive_start_time, obj[@"arrive_start_time"]);
        SET_IF_NOT_NULL(arrive_end_time, obj[@"arrive_end_time"]);
       
        order_end_time = obj[@"order_end_time"];
        
        dTime = [NSString stringWithFormat:@"%@   %@-%@",date,[arrive_start_time substringToIndex:5],[arrive_end_time substringToIndex:5]];
        
        order_end_time = [order_end_time substringToIndex:5];
    }
    
    if ([choosePayType isEqualToString:kWechatPay] || [choosePayType isEqualToString:kAliPay])
    {
        message = [NSString stringWithFormat:NSLocalizedString(@"You have booked the meal from %@, and it cannot be canceled after successful payment.", @"您预定了 %@ 的工作餐. 支付后就不可以再取消."), dTime];
    }
    else
    {
        message = [NSString stringWithFormat:NSLocalizedString(@"You have booked the meal from %@, if you want to cancel your order, please do it before %@", @"您预定了 %@ 的工作餐, 如果您想取消订单, 请在 %@ 之前."), dTime,order_end_time];
    }
    
    [UIAlertView showWithTitle:NSLocalizedString(@"Note", @"提示")
                       message:message
             cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
             otherButtonTitles:@[NSLocalizedString(@"OK", @"确定")]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex ==1) {
                              [self tapMakeOrder];
                          }
                      }];
    

}

- (NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

- (void)tapMakeOrder
{
    int sel_address_id = 0;
    if (receiveInfo!=nil)
    {
        sel_address_id = [receiveInfo[@"address_id"] intValue];
    }
    
    NSString *jsonStr = [[GDOrderCheck instance] genJsonStr:self.productData];
    
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/Takeout/add_order2"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    NSDictionary *parameters;
    
    parameters = @{@"product_list_json":jsonStr,@"token":[GDPublicManager instance].token,@"language_id":@([[GDSettingManager instance] language_id:NO]),@"comment":comment,@"vendor_id":@(vendorId),@"payment_code":choosePayType,@"address_id":@(sel_address_id),@"push_device":@"ios",@"push_token":[GDPublicManager instance].push_token,@"bat_takeout_time_id":@(timeType),@"date":selectDate,@"timestamp":uuidstr};
  
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
             
             if ([choosePayType isEqualToString:kCashPay])
             {
                 [self completePay];
             }
             else if ([choosePayType isEqualToString:kWechatPay])
             {
                 [self toWechatPay];
             }
             else if ([choosePayType isEqualToString:kAliPay])
             {
                 [self toAlipay];
             }
         }
         else if (status == 40006)
         {
              [UIAlertView showWithTitle:NSLocalizedString(@"Note", @"提示")
                                message:NSLocalizedString(@"Order has been submitted successfully, please do not resubmit", @"订单已经生成, 请不要重复提交申请.")
                      cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                      otherButtonTitles:nil
                               tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                   if (buttonIndex == [alertView cancelButtonIndex]) {
                                       //pop
                                       
                                       [CATransaction begin];
                                       [CATransaction setCompletionBlock:^{
                                        
                                           GDReservationDeliveryOrderListViewController* nvCollection = [[GDReservationDeliveryOrderListViewController alloc] init];
                                           
                                           [_superNav pushViewController:nvCollection animated:YES];
                                           
                                       }];
                                       
                                       for (UIViewController *temp in self.navigationController.viewControllers) {
                                           if ([temp isKindOfClass:[GDReservationDeliveryListViewController class]])
                                           {
                                               [self.navigationController popToViewController:temp animated:NO];
                                           }
                                       }
                                       
                                       
                                       [CATransaction commit];
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

#pragma mark - wechat pay
- (void)toWechatPay
{
    float price = exchangeCnyRate*(sprice+deliveryFee);
    NSString* strPrict = [NSString stringWithFormat:@"%d",(int)(price*100)];//分
    
    [weixinAccountManage sharedInstance].delegate = self;
    [[weixinAccountManage sharedInstance] getPrepayWithOrderName:NSLocalizedString(@"Scheduled Ordering", @"工作餐") price:strPrict withNo:order_id withUrl:[NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"Takeout/v1/TakeoutCallback/weixin_callback"]];
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
        order_id = @"";
        
        [UIAlertView showWithTitle:NSLocalizedString(@"Payment Failed", @"支付失败")
                           message:NSLocalizedString(@"Payment is not completed, please try it again!", @"支付没有完成, 请重新下单支付!")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  [self.navigationController popViewControllerAnimated:YES];
                              }
                          }];
    }
}

#pragma mark - ali pay
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
    
    product.subject = NSLocalizedString(@"Scheduled Ordering", @"工作餐");
    product.body  = body;
    product.price = exchangeUsdRate*(sprice+deliveryFee);
    
    [AliPayment instance].delegate = self;
    [[AliPayment instance] callAli:product withNo:order_id withUrl:[NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"Takeout/v1/TakeoutCallback/alipay_callback"]];
}

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
        
        [UIAlertView showWithTitle:NSLocalizedString(@"Payment Failed", @"支付失败")
                           message:NSLocalizedString(@"Payment is not completed, please try it again!", @"支付没有完成, 请重新下单支付!")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  [self.navigationController popViewControllerAnimated:YES];
                              }
                          }];
    }
}

#pragma mark - Choose

- (void)setChooseTime:(int)nIndex
{
    if (nIndex>=timeInfo.count)
        return;
    
    chooseTime = nIndex;
    
    NSMutableDictionary* obj = [timeInfo objectAtIndex:chooseTime];
    
    if (![obj isKindOfClass:[NSNull class]] && obj!= nil)
    {
        selectDate = obj[@"date"];
        timeType = [obj[@"bat_takeout_time_id"] intValue];
        
        [mainTableView reloadData];
    }
}

- (void)setChoosePay:(int)nIndex
{
    if (nIndex>=payWayInfo.count)
        return;
    
    choosePay = nIndex;
    
    NSMutableDictionary* obj = [payWayInfo objectAtIndex:choosePay];
    
    if (![obj isKindOfClass:[NSNull class]] && obj!= nil)
    {
        
        [confirmBut setTitle: NSLocalizedString(@"Confirm Order", @"点击去下单") forState:UIControlStateNormal];
        
        choosePayType = obj[@"payment_code"];
        
        chosseCodFee = codFee;
    
        [mainTableView reloadData];
    }
}

#pragma mark - Data

- (void)getPrice:(id)sender
{
    NSDictionary *dict = sender;
    sprice = [dict[@"sprice"] floatValue];
    [mainTableView reloadData];
}

- (void)getPayWay
{
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/Payment/get_payment_list"];
    
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO])};
    
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
             //[ProgressHUD showError:errorInfo];
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //[ProgressHUD showError:error.localizedDescription];
     }];
}

- (void)getTimes
{
    
    NSNumber* areaNumber = [GDSettingManager instance].userDeliveryInfo[@"selAreaId"];
    int areaId = [areaNumber intValue];
    if (areaId<0)
        return;
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"Takeout/v1/Takeout/get_opt_arrive_times2"];
    
    parameters = @{@"area_id":@(areaId)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             @synchronized(timeInfo)
             {
                 [timeInfo removeAllObjects];
             }
             
             if(responseObject[@"data"]!= [NSNull null] && responseObject[@"data"]!= nil)
             {
                 NSArray* tempInfo = responseObject[@"data"];
                 for (NSDictionary* dict in tempInfo)
                 {
                     NSString* date = @"";
                     SET_IF_NOT_NULL(date, dict[@"date"]);
                     
                     NSString* name = @"";
                     SET_IF_NOT_NULL(name, dict[@"name"]);
                     if ([[GDSettingManager instance] isChinese])
                     {
                         if ([name isEqualToString:@"today"])
                         {
                             name = @"今天";
                         }
                         else if ([name isEqualToString:@"tomorrow"])
                         {
                             name = @"明天";
                         }
                     }
                     
                     NSArray* times = dict[@"times"];
                     
                     for (NSDictionary* arriveTime in times)
                     {
                         NSDictionary *para = @{@"date":date,@"bat_takeout_time_id":@([arriveTime[@"bat_takeout_time_id"] intValue]),@"arrive_start_time":arriveTime[@"arrive_start_time"],@"arrive_end_time":arriveTime[@"arrive_end_time"],@"name":name,@"order_end_time":arriveTime[@"order_end_time"]};
                         
                         [timeInfo addObject:para];
                     }
                 }
                 
             }
             
             if (timeInfo.count>0)
             {
                 [self setChooseTime:0];
             }
             
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
            // [ProgressHUD showError:errorInfo];
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //[ProgressHUD showError:error.localizedDescription];
     }];
}


- (void)getReceiveAddress
{
    NSString* url;
    NSDictionary *parameters;
    
    NSNumber* areaNumber = [GDSettingManager instance].userDeliveryInfo[@"selAreaId"];
    int areaId = [areaNumber intValue];
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/TakeoutAddress/get_address_list_of_customer"];
    parameters = @{@"token":[GDPublicManager instance].token,@"area_id":@(areaId)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
           parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        [ProgressHUD dismiss];
    
        int status = [responseObject[@"status"] intValue];
        if (status==1)
        {
            if(responseObject[@"data"][@"address_list"] != [NSNull null] && responseObject[@"data"][@"address_list"] != nil)
                 {
                     NSDictionary* obj;
                     for (obj in responseObject[@"data"][@"address_list"])
                     {
                          receiveInfo = obj;
                          int  selected = [obj[@"selected"] floatValue];
                          if (selected==1)
                          {
                              receiveInfo = obj;
                              break;
                          }
                     }
                 }
    
                 [mainTableView reloadData];
             }
             else
             {
                 NSString *errorInfo =@"";
                 SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
                 LOG(@"errorInfo: %@", errorInfo);
                // [ProgressHUD showError:errorInfo];
             }
    
             confirmBut.enabled = YES;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             //[ProgressHUD showError:error.localizedDescription];
         }];
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
            NSString*  telephone= @"";
            NSString*  address=@"";
            NSString*  country=@"";
            NSString*  city=@"";
            NSString*  area=@"";
            
            SET_IF_NOT_NULL(name, receiveInfo[@"firstname"]);
            SET_IF_NOT_NULL(telephone, receiveInfo[@"telephone"]);
            SET_IF_NOT_NULL(address, receiveInfo[@"address_1"]);
            SET_IF_NOT_NULL(country, receiveInfo[@"country_name"]);
            SET_IF_NOT_NULL(city, receiveInfo[@"zone_name"]);
            SET_IF_NOT_NULL(area, receiveInfo[@"area_name"]);
            
            cell.name.text  = [NSString stringWithFormat:NSLocalizedString(@"Receiver: %@", @"收货人:%@"),name];
            cell.phone.text = telephone;
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
    else if (indexPath.section == kTimeSection)
    {
        if (indexPath.row ==0)
        {
            static NSString *CellIdentifier = @"cellTime";
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
            
            cell.textLabel.text= NSLocalizedString(@"Delivery Arrival", @"送到时间");
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"cellTimeWay";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            NSDictionary* obj = [timeInfo objectAtIndex:indexPath.row-1];
            if (![obj isKindOfClass:[NSNull class]] && obj!= nil)
            {
                NSString*  date=@"";
                NSString*  arrive_start_time=@"";
                NSString*  arrive_end_time=@"";
            
                SET_IF_NOT_NULL(date, obj[@"name"]);
                SET_IF_NOT_NULL(arrive_start_time, obj[@"arrive_start_time"]);
                SET_IF_NOT_NULL(arrive_end_time, obj[@"arrive_end_time"]);
                
                NSString* dTime = [NSString stringWithFormat:@"%@   %@-%@",date,[arrive_start_time substringToIndex:5],[arrive_end_time substringToIndex:5]];
                
                cell.textLabel.text = dTime;
                
                if (chooseTime==indexPath.row-1)
                {
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick.png"]];
                }
                else
                {
                    cell.accessoryView = nil;
                }
            }
            cell.textLabel.font = MOLightFont(14);
            return cell;
        }
        
    }
    else if (indexPath.section == kPaymentSection)
    {
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
                if ([codeId isEqualToString:kCashPay])
                {
                    if (codFee>0)
                    {
                        cell.fees.text = [NSString stringWithFormat:NSLocalizedString(@"Additional Fees(%@%0.1f)",@"附加费(%@%0.1f)"),[GDPublicManager instance].currency,codFee];
                        cell.fees.textColor = MOColorSaleFontColor();
                    }
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
    else if (indexPath.section == kCommentSection)
    {
        static NSString *CellIdentifier = @"CellComment";
        UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text= NSLocalizedString(@"Special Cooking Instructions", @"特殊烹调方式");
        cell.detailTextLabel.text= comment;
        return cell;
    }
    else if (indexPath.section == kOrdersSection)
    {
        if (indexPath.row ==0)
        {
            static NSString *CellIdentifier = @"CellPro";
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
            
            cell.textLabel.text= NSLocalizedString(@"Items", @"订购商品");
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"CellProList";
            
            GDDeliveryOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GDDeliveryOrderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            NSDictionary* obj = [self.productData objectAtIndex:indexPath.row-1];
            
            NSString* title_name;
            title_name = obj[@"name"];
            float price = [obj[@"price"] floatValue];
            
            NSString* imgUrl = @"";
            SET_IF_NOT_NULL(imgUrl, obj[@"image"]);
       
            int order_qty = [obj[@"order_qty"] intValue];
            
            [cell.photoView sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                              placeholderImage:[UIImage imageNamed:@"delivery_default.png"]];
            
            cell.title.text = title_name;

            cell.total_qty.text = [NSString stringWithFormat:@"%@%.1f x %d",[GDPublicManager instance].currency,price,order_qty];
            
            cell.price.text =  [NSString stringWithFormat:@"%@%.1f",[GDPublicManager instance].currency, price*order_qty];
            
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
        ordersPrice.font = MOLightFont(14);
        ordersPrice.frame = CGRectMake(10, offsetY, [GDPublicManager instance].screenWidth-20, 20);
        ordersPrice.textColor = [UIColor whiteColor];
        ordersPrice.backgroundColor =  [UIColor clearColor];
        ordersPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Sub Total: %@%.1f",@"小计: %@%.1f"),[GDPublicManager instance].currency, sprice];
        [ordersPrice findCurrency:CurrencyFontSize];
        [cell.contentView addSubview:ordersPrice];
        
        offsetY+=20;
        UILabel* deliverPrice =  MOCreateLabelAutoRTL();
        deliverPrice.font = MOLightFont(14);
        deliverPrice.frame = CGRectMake(10, offsetY,[GDPublicManager instance].screenWidth-20, 20);
        deliverPrice.textColor = [UIColor whiteColor];
        deliverPrice.backgroundColor =  [UIColor clearColor];
        deliverPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Delivery Chagres: %@%d",@"配送费: %@%d"),[GDPublicManager instance].currency, deliveryFee];
        [deliverPrice findCurrency:CurrencyFontSize];
        [cell.contentView addSubview:deliverPrice];
        
        offsetY+=20;
        
        UILabel* sumPrice =  MOCreateLabelAutoRTL();
        sumPrice.textAlignment = [GDSettingManager instance].isRightToLeft?NSTextAlignmentLeft:NSTextAlignmentRight;
        sumPrice.font = MOLightFont(14);
        sumPrice.frame = CGRectMake(10, offsetY, [GDPublicManager instance].screenWidth-20, 20);
        sumPrice.textColor = [UIColor whiteColor];
        sumPrice.backgroundColor =  [UIColor clearColor];
        sumPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Total: %@%.1f",@"总金额: %@%.1f"),[GDPublicManager instance].currency, sprice+deliveryFee];
        [sumPrice findCurrency:CurrencyFontSize];
//        
//        if (discount>0)
//        {
//            offsetY+=20;
//            
//            UILabel* discountPrice =  MOCreateLabelAutoRTL();
//            discountPrice.textAlignment = [GDSettingManager instance].isRightToLeft?NSTextAlignmentLeft:NSTextAlignmentRight;
//            discountPrice.font = MOLightFont(14);
//            discountPrice.frame = CGRectMake(10, offsetY, [GDPublicManager instance].screenWidth-20, 20);
//            discountPrice.textColor = [UIColor whiteColor];
//            discountPrice.backgroundColor =  [UIColor clearColor];
//            discountPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Discounted Price: %@%.1f",@"折扣价: %@%.1f"),[GDPublicManager instance].currency, (sprice+chosseCodFee+deliveryFee)*(1-discount*1.0/100)];
//            [discountPrice findCurrency:CurrencyFontSize];
//            [cell.contentView addSubview:discountPrice];
//        }
        
        cell.backgroundColor = [UIColor colorWithRed:75/255.0 green:87/255.0 blue:114/255.0 alpha:1.0];
//      [cell.contentView addSubview:ordersPrice];
        [cell.contentView addSubview:sumPrice];
        
        if ([choosePayType isEqualToString:kWechatPay] || [choosePayType isEqualToString:kAliPay])
        {
            offsetY+=20;
            
            UILabel* exPrice =  MOCreateLabelAutoRTL();
            exPrice.textAlignment = [GDSettingManager instance].isRightToLeft?NSTextAlignmentLeft:NSTextAlignmentRight;
            
            exPrice.font = MOLightFont(14);
            exPrice.frame = CGRectMake(10, offsetY, [GDPublicManager instance].screenWidth-20, 20);
            exPrice.textColor = [UIColor whiteColor];
            exPrice.backgroundColor =  [UIColor clearColor];
            
            if ([choosePayType isEqualToString:kAliPay])
            {
                NSDecimalNumber *shipping=[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",(sprice+deliveryFee)*exchangeUsdRate]];
                
                exPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Price after conversion: %@%.2f",@"价格被转换: %@%.2f"),PaypalCurrency, [shipping floatValue]];
            }
            else
            {
                NSDecimalNumber *shipping=[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",(sprice+deliveryFee)*exchangeCnyRate]];
                
                exPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Price after conversion: %@%.2f",@"价格被转换: %@%.2f"),AlipalCurrency, [shipping floatValue]];
            }
            
            [cell.contentView addSubview:exPrice];
        }

        
        return cell;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int nIndex  = 0;
    
    kPriceSection   = nIndex++;
    
    kAddressSection = nIndex++;
    
    kTimeSection  = nIndex++;
    
    kPaymentSection = nIndex++;
    kOrdersSection  = nIndex++;

    kCommentSection = nIndex++;
    
    
    return nIndex;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kAddressSection)
    {
        return 1;
    }
    else if (section == kTimeSection)
    {
        return 1+timeInfo.count;
    }
    else if (section == kPaymentSection)
    {
        return 1+payWayInfo.count;
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
    else if (indexPath.section == kTimeSection)
    {
        if (indexPath.row == 0)
            return 40;
        else
            return 36;
    }
    else if (indexPath.section == kPaymentSection)
    {
        if (indexPath.row == 0)
            return 40;
        else
            return 60;
    }
    else if (indexPath.section == kOrdersSection)
    {
        if (indexPath.row == 0)
            return 40;
        else
            return 60;
    }
    else if (indexPath.section == kPriceSection)
    {
        float baseHeight = 70;

        if ([choosePayType isEqualToString:kWechatPay] || [choosePayType isEqualToString:kAliPay])
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
  
    else if (indexPath.section == kPaymentSection)
    {
        if (indexPath.row>0)
        {
            [self setChoosePay:(int)indexPath.row-1];
        }
    }
    else if (indexPath.section == kTimeSection)
    {
        if (indexPath.row>0)
        {
            [self setChooseTime:(int)indexPath.row-1];
        }
    }
}



@end
