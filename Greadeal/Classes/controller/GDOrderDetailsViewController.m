//
//  GDOrderDetailsViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/6.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDOrderDetailsViewController.h"
#import "RDVTabBarController.h"

#import "GDDeliverCell.h"
#import "GDReceiveCell.h"

#import "GDOrderListCell.h"

#import "GDDeliverViewController.h"
#import "GDQRCell.h"

#import "GDRatingViewController.h"
#import "GDPINViewController.h"

@interface GDOrderDetailsViewController ()

@end

@implementation GDOrderDetailsViewController

- (id)init:(NSDictionary*)aObj
{
    self = [super init];
    if (self)
    {
        orderData   = aObj;
        coupon_lists= [[NSMutableArray alloc] init];
        deliverData = [[NSMutableArray alloc] init];
        order_id    = orderData[@"order_id"];
        shareData   = [[NSMutableDictionary alloc] init];
           }
    return self;
}

- (id)initWithOrderId:(NSString*)orderId
{
    self = [super init];
    if (self)
    {
        order_id = orderId;
        deliverData = [[NSMutableArray alloc] init];
        coupon_lists= [[NSMutableArray alloc] init];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",@"返回") style:UIBarButtonItemStylePlain target:self action:@selector(Exit)];
    }
    return self;
}

- (void)Exit
{
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showHeaderInfo
{
    NSArray* temp = orderData[@"product_list"];
    if (temp!=nil)
    {
        for (NSDictionary *product in temp)
        {
            NSArray* tempList = product[@"coupon_list"];
            if (tempList.count>0)
            {
                [coupon_lists addObjectsFromArray:tempList];
            }
        }
    }
    
    CGRect r = self.view.bounds;

    int order_status_id = [orderData[@"order_status_id"] intValue];
    //目前超市才显示消费二维码和消费码
    BOOL hasQR = NO;
    
    r.size.height = hasQR?150:120;
    float  offsexX = hasQR?120:10;
    float  offwidth = hasQR?190:[GDPublicManager instance].screenWidth-20;
    
    UIView *footer = [[UIView alloc] initWithFrame:r];
    footer.backgroundColor = [UIColor colorWithRed:75/255.0 green:87/255.0 blue:114/255.0 alpha:1.0];
    
    if (hasQR)
    {
        NSString* consume_code_qr = @"";
        SET_IF_NOT_NULL(consume_code_qr, orderData[@"consume_code_qr"]);
        
        UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
        icon.backgroundColor = [UIColor clearColor];
        icon.contentMode = UIViewContentModeScaleAspectFill;
        icon.clipsToBounds = YES;
        if (consume_code_qr.length>0)
            [icon sd_setImageWithURL:[NSURL URLWithString:[consume_code_qr encodeUTF]]];
        [footer addSubview:icon];
    }
    
    float  offsexY = 5;
    
    UILabel* title =  MOCreateLabelAutoRTL();
    title.frame = CGRectMake(offsexX, offsexY, offwidth, 20);
    title.font = MOLightFont(13);
    title.textColor = MOColorSaleFontColor();
    title.backgroundColor = [UIColor clearColor];
    
    switch (order_status_id) {
        case VOUCHER_ORDER_AWAITING_PAYMENT:
            title.text = NSLocalizedString(@"Awaiting Payment", @"待支付");
            break;
        case VOUCHER_ORDER_PAID:
            title.text = NSLocalizedString(@"Paid", @"已支付");
            break;
        case VOUCHER_ORDER_CANCELED:
            title.text = NSLocalizedString(@"Canceled", @"已取消");
            break;
    }
    
    [footer addSubview:title];
    
    int  sub_total = 0;
    if(orderData[@"bill"]!= [NSNull null] && orderData[@"bill"]!= nil)
    {
        sub_total = [orderData[@"bill"][@"sub_total"][@"value"] intValue];
    }
    
    offsexY+=20;
    UILabel* deliverId =  MOCreateLabelAutoRTL();
    deliverId.font = MOLightFont(13);
    deliverId.frame = CGRectMake(offsexX, offsexY, offwidth, 20);
    deliverId.textColor = [UIColor whiteColor];
    deliverId.backgroundColor =  [UIColor clearColor];
    [footer addSubview:deliverId];
    [deliverId findCurrency:CurrencyFontSize];
    
    int  shipping_fee = 0;
    if(orderData[@"bill"]!= [NSNull null] && orderData[@"bill"]!= nil)
    {
        shipping_fee = [orderData[@"bill"][@"shipping"][@"value"] intValue];
    }
    
    NSString* type = @"";
    SET_IF_NOT_NULL(type, orderData[@"order_type"]);
    if (![type isEqualToString:@"live"])
    {
        offsexY+=20;
        UILabel* deliverStatus =  MOCreateLabelAutoRTL();
        deliverStatus.font = MOLightFont(13);
        deliverStatus.frame = CGRectMake(offsexX, offsexY, offwidth, 20);
        deliverStatus.textColor = [UIColor whiteColor];
        deliverStatus.backgroundColor =  [UIColor clearColor];
        deliverStatus.text = [NSString stringWithFormat:NSLocalizedString(@"Shipping: %@%d",@"运费金额: %@%d"),[GDPublicManager instance].currency, shipping_fee];
        [deliverStatus findCurrency:CurrencyFontSize];
        
        [footer addSubview:deliverStatus];
    }
    
    int  payment_fee = 0;
    if(orderData[@"bill"]!= [NSNull null] && orderData[@"bill"]!= nil)
    {
        payment_fee = [orderData[@"bill"][@"payment_fee"][@"value"] intValue];
    }
    
    if (payment_fee>0)
    {
        offsexY+=20;
        UILabel* payment =  MOCreateLabelAutoRTL();
        payment.font = MOLightFont(13);
        payment.frame = CGRectMake(offsexX, offsexY, offwidth, hasQR?40:20);
        payment.textColor = [UIColor whiteColor];
        payment.numberOfLines = 0;
        payment.backgroundColor =  [UIColor clearColor];
        payment.text = [NSString stringWithFormat:NSLocalizedString(@"Cash/Card On Delivery: %@%d",@"货到付款手续费: %@%d"),[GDPublicManager instance].currency, payment_fee];
        [footer addSubview:payment];
        [payment findCurrency:CurrencyFontSize];
        offsexY+=hasQR?40:20;
    }
    
    offsexY+=20;
    
    int membership_level = [orderData[@"vendor"][@"membership_level"] intValue];
    BOOL isFree = [[GDPublicManager instance] isVaildFreeBuy:membership_level withNote:NO];
  
    int total =payment_fee+shipping_fee+sub_total;
    UILabel* totalLable =  MOCreateLabelAutoRTL();
    totalLable.font = MOLightFont(13);
    totalLable.frame = CGRectMake(offsexX, offsexY, offwidth, 20);
    totalLable.textColor = [UIColor whiteColor];
    totalLable.backgroundColor =  [UIColor clearColor];
    
    if (isFree)
    {
        totalLable.text =  [NSString stringWithFormat:NSLocalizedString(@"Member Total: %@%d", @"会员总金额:%@%d"),[GDPublicManager instance].currency, 0];
        deliverId.text = [NSString stringWithFormat:NSLocalizedString(@"Subtotal: %@%d",@"订单金额: %@%d"),[GDPublicManager instance].currency, 0];
    }
    else
    {
        totalLable.text =  [NSString stringWithFormat:NSLocalizedString(@"Total: %@%d", @"总金额:%@%d"),[GDPublicManager instance].currency, total];
        deliverId.text = [NSString stringWithFormat:NSLocalizedString(@"Subtotal: %@%d",@"订单金额: %@%d"),[GDPublicManager instance].currency, sub_total];
    }
    [footer addSubview:totalLable];
    [totalLable findCurrency:CurrencyFontSize];
    [deliverId findCurrency:CurrencyFontSize];

    offsexY+=20;
    order_id = orderData[@"order_id"];
    
    UILabel* orderId =  MOCreateLabelAutoRTL();
    orderId.font = MOLightFont(13);
    orderId.frame = CGRectMake(offsexX, offsexY, offwidth, 20);
    orderId.textColor = [UIColor whiteColor];
    orderId.backgroundColor =  [UIColor clearColor];
    orderId.text = [NSString stringWithFormat:NSLocalizedString(@"Order ID: %@",@"订单号: %%@"), order_id];
    [footer addSubview:orderId];
    
    NSString*  PayId = @"";
    SET_IF_NOT_NULL(PayId, orderData[@"payment_return_id"]);
  
    if (PayId.length>0)
    {
        offsexY+=20;
        
        UILabel* payLabel =  MOCreateLabelAutoRTL();
        payLabel.font = MOLightFont(13);
        payLabel.frame = CGRectMake(offsexX, offsexY, offwidth, 20);
        payLabel.textColor = [UIColor whiteColor];
        payLabel.backgroundColor =  [UIColor clearColor];
        payLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Pay ID: %@",@"支付号: %%@"), PayId];
        [footer addSubview:payLabel];
    }
    
    CGRect rf = footer.frame;
    rf.size.height = offsexY+30;
    footer.frame = rf;
    
    mainTableView.tableHeaderView = footer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Order Details", @"订单详情");
    
    // Do any additional setup after loading the view.
    CGRect r = self.view.bounds;
    
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    if (orderData!=nil)
    {
        [self showHeaderInfo];
        [self reLoadView];
    }
    else
    {
        [self getOrderData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapRedeem:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    
    int selectedIndex = (int)button.tag;
    
    NSDictionary* obj = [coupon_lists objectAtIndex:selectedIndex];
    if (obj!=nil)
    {
        NSString* consume_code_qr = @"";
        SET_IF_NOT_NULL(consume_code_qr, obj[@"code"]);
        if (consume_code_qr.length>0)
        {
            GDPINViewController* nv = [[GDPINViewController alloc] init:consume_code_qr];
            [self.navigationController pushViewController:nv animated:YES];
        }
        
    }
}

- (void)tapRating:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    int selectedIndex = (int)button.tag;
    
    NSDictionary* obj = [coupon_lists objectAtIndex:selectedIndex];
    if (obj!=nil)
    {
        int product_id = [obj[@"product_id"] intValue];
        GDRatingViewController* vc = [[GDRatingViewController alloc] initWithProduct:product_id];
        
        UINavigationController *nc = [[UINavigationController alloc]
                                      initWithRootViewController:vc];
        
        [self.navigationController presentViewController:nc animated:YES completion:^(void) {}];
        
    }
    
}

- (void)shareAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
        
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
        
    int selectedIndex = (int)button.tag;
        
    NSDictionary* obj = [coupon_lists objectAtIndex:selectedIndex];
    if (obj!=nil)
    {

        [shareData removeAllObjects];
        
        NSString* title = [NSString stringWithFormat:@"%@ %@",obj[@"vendor"][@"vendor_name"],obj[@"product_name"]];
        
        [shareData setValue:obj[@"qrcode"] forKey:@"codeimage"];
        [shareData setValue:title forKey:@"title"];
        [shareData setValue:obj[@"title"] forKey:@"url"];
        
        
        NSMutableArray *shareButtonTitleArray = [[NSMutableArray alloc] init];
        NSMutableArray *shareButtonImageNameArray = [[NSMutableArray alloc] init];
    
        [shareButtonTitleArray addObject:NSLocalizedString(@"E-Mail",@"邮件")];
        [shareButtonImageNameArray addObject:@"sns_icon_mail"];
    
        if ([[whatsappAccountManage sharedInstance] isInstalled])
        {
            [shareButtonTitleArray addObject:@"WhatsApp"];
            [shareButtonImageNameArray addObject:@"sns_icon_whatsapp"];
        }
    
        if ([[weixinAccountManage sharedInstance] isWXInstalled])
        {
            [shareButtonTitleArray addObject:NSLocalizedString(@"Wechat",@"微信好友")];
            [shareButtonImageNameArray addObject:@"sns_icon_wechat"];
        }
    
        LXActivity *lxActivity = [[LXActivity alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonImageNameArray];
        [lxActivity showInView:self.view];
    }
}

#pragma mark - Data
- (void)getOrderData
{
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/order/get_order"];
    parameters = @{@"order_id":order_id,@"token":[GDPublicManager instance].token,@"language_id":@([[GDSettingManager instance] language_id:NO])};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             if(responseObject[@"data"][@"order"] != [NSNull null] && responseObject[@"data"][@"order"] != nil)
             {
                 orderData = responseObject[@"data"][@"order"];
             }
             
             [self showHeaderInfo];
             [self reLoadView];

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

- (void)getProductData
{
//    reloading = YES;
//    
//    if (order_id.length<=0)
//        order_id    = orderData[@"order_id"];
//    
//    NSString* url;
//    NSDictionary *parameters;
//    
//    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"shippinglog/get_shipping_logs"];
//    parameters = @{@"order_id":order_id};
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
//             @synchronized(deliverData)
//             {
//                 [deliverData removeAllObjects];
//             }
//             
//             if(responseObject[@"data"][@"shipping_logs"] != [NSNull null] && responseObject[@"data"][@"shipping_logs"] != nil)
//             {
//                 [deliverData addObjectsFromArray:responseObject[@"data"][@"shipping_logs"]];
//             }
//         }
//         
//         [self stopLoad];
//         [self performSelectorOnMainThread:@selector(reLoadView) withObject:nil waitUntilDone:NO];
//         
//         
//     }
//     failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         [self stopLoad];
//         [ProgressHUD showError:error.localizedDescription];
//     }];
}

#pragma mark UIView
- (void)reLoadView
{
    [mainTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}


#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            static NSString *CellIdentifier = @"cellPeo";
        
            GDReceiveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
            cell = [[GDReceiveCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            NSString* type = @"";
            SET_IF_NOT_NULL(type, orderData[@"order_type"]);
            if ([type isEqualToString:@"live"])
            {
                NSString* vendor_phone = @"";
                NSString* vendor_country = @"";
                NSString* vendor_city = @"";
                NSString* vendor_area = @"";
                NSString* vendor_address = @"";
                NSString* vendor_name = @"";
                
                SET_IF_NOT_NULL(vendor_name, orderData[@"vendor"][@"vendor_name"]);
                SET_IF_NOT_NULL(vendor_address, orderData[@"vendor"][@"address"]);
                SET_IF_NOT_NULL(vendor_area, orderData[@"vendor"][@"area_name"]);
                SET_IF_NOT_NULL(vendor_city, orderData[@"vendor"][@"zone_name"]);
                SET_IF_NOT_NULL(vendor_country, orderData[@"vendor"][@"country_name"]);
                SET_IF_NOT_NULL(vendor_phone, orderData[@"vendor"][@"telephone"]);
                
                cell.name.text  = vendor_name;
                cell.phone.text = [NSString stringWithFormat:@"%@",vendor_phone];
                if (vendor_area.length>0)
                    cell.address.text = [NSString stringWithFormat:@"%@,%@,%@",vendor_address,vendor_area,vendor_city];
                else
                    cell.address.text = [NSString stringWithFormat:@"%@,%@",vendor_address,vendor_city];
            }
            else
            {
                NSString*  name = @"";
                NSString*  telephone_area_code=@"";
                NSString*  telephone= @"";
                NSString*  address=@"";
                NSString*  city=@"";
                NSString*  area=@"";
                
                SET_IF_NOT_NULL(name, orderData[@"shipping_firstname"]);
                SET_IF_NOT_NULL(telephone_area_code, orderData[@"telephone_area_code"]);
                SET_IF_NOT_NULL(telephone, orderData[@"telephone"]);
                SET_IF_NOT_NULL(address, orderData[@"shipping_address_1"]);
                //SET_IF_NOT_NULL(country, orderData[@"shipping_country"]);
                SET_IF_NOT_NULL(city, orderData[@"shipping_zone"]);
                SET_IF_NOT_NULL(area, orderData[@"shipping_zone_area"]);
                
                cell.name.text  = [NSString stringWithFormat:NSLocalizedString(@"Receiver: %@", @"收货人:%@"),name];
                cell.phone.text = [NSString stringWithFormat:@"%@%@",telephone_area_code,telephone];
                
                if (area.length>0)
                    cell.address.text = [NSString stringWithFormat:@"%@,%@,%@",address,area,city];
                else
                   cell.address.text = [NSString stringWithFormat:@"%@,%@",address,city];
                
            }
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"code";
            GDQRCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                    cell = [[GDQRCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                    cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            NSDictionary* dict =  [coupon_lists objectAtIndex:indexPath.row-1];
            if (dict!=nil)
            {
                cell.numberLabel.text = dict[@"code"];
                
                NSString* consume_code_qr = @"";
                SET_IF_NOT_NULL(consume_code_qr, dict[@"qrcode"]);
                if (consume_code_qr.length>0)
                    [cell.QRView sd_setImageWithURL:[NSURL URLWithString:[consume_code_qr encodeUTF]]];
        
                int  oprice = [dict[@"original_price"] intValue];
               // int  sprice = [dict[@"price"] intValue];
                
                NSString* opricestr = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, oprice];
                //NSString* spricestr = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, sprice];
                
                cell.originPriceLabel.text  = opricestr;
                //cell.priceLabel.text = spricestr;
                
                NSString* vendor_name = @"";
                SET_IF_NOT_NULL(vendor_name, dict[@"vendor"][@"vendor_name"]);
                cell.vendorLabel.text = vendor_name;
                
                //cell.usedLabel.text = dict[@"status"];
                
                int setprice = 0;
                if(dict[@"set_price"] != [NSNull null] && dict[@"set_price"] != nil)
                    setprice = [dict[@"set_price"] intValue];
                
                [[GDSettingManager instance] setTitleAttr:cell.titleLabel withTitle:dict[@"product_name"] withSale:setprice withOrigin:oprice];
        
                NSString* expireDate = dict[@"available_date_end"];
                expireDate = [expireDate substringToIndex:10];
                NSString* earlier = [[GDPublicManager instance] minExpiredDate:expireDate];
                
                if ([dict[@"status"] isEqualToString:@"consumed"])
                {
                    cell.isExpire = 1;
                    
                    [cell.actionBut setStyleYellowButton];
                    cell.actionBut.tag = indexPath.row;
                    [cell.actionBut setTitle:NSLocalizedString(@"RATING", @"评分")  forState:UIControlStateNormal];
                    [cell.actionBut addTarget:self action:@selector(tapRating:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [cell.shareBut setStyleYellowButton];
                    cell.shareBut.enabled = NO;
                    [cell.shareBut addShareImage];
                }
                else if ([dict[@"status"] isEqualToString:@"unconsume"])
                {
                    if ([[GDPublicManager instance] isExpiredDate:earlier])
                    {
                        cell.isExpire = 2 ;
                        
                        [cell.actionBut setStyleRedButton];
                        [cell.actionBut setTitle:NSLocalizedString(@"REDEEM", @"使用") forState:UIControlStateNormal];
                        cell.actionBut.enabled = NO;
                        
                        [cell.shareBut setStyleYellowButton];
                        cell.shareBut.enabled = NO;
                        [cell.shareBut addShareImage];
                    }
                    else
                    {
                        cell.isExpire = 0 ;
                        
                        [cell.actionBut setStyleRedButton];
                        cell.actionBut.tag = indexPath.row;
                        [cell.actionBut setTitle:NSLocalizedString(@"REDEEM", @"使用") forState:UIControlStateNormal];
                        [cell.actionBut addTarget:self action:@selector(tapRedeem:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [cell.shareBut setStyleYellowButton];
                        cell.shareBut.tag = indexPath.section;
                        [cell.shareBut addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.shareBut addShareImage];
                    }
                }

                cell.actionBut.hidden = YES;
                cell.shareBut.hidden = YES;
                
                cell.expireLabel.text = cell.expireLabel.text =  [NSString stringWithFormat:NSLocalizedString(@"Expired Date: %@", @"过期日期:  %@"),earlier];
            }
            return cell;
        }
    }
    else if (indexPath.section == 1)
    {
//        if (indexPath.row ==0)
//        {
//            static NSString *CellIdentifier = @"Cell";
//            UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            if (!cell) {
//                cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
//            
//            }
//            
//            NSString* vendor_name = @"";
//            SET_IF_NOT_NULL(vendor_name, orderData[@"vendor"][@"vendor_name"]);
//            
//            cell.textLabel.font = MOLightFont(14);
//            cell.textLabel.text= vendor_name;
//            
//            return cell;
//        }
//        else
        {
            static NSString *CellIdentifier = @"listCell";
        
            GDOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GDOrderListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
        
            NSArray* temp = orderData[@"product_list"];
           
            if (temp!=nil && temp.count>0)
            {
                NSDictionary   *product = [temp objectAtIndex:indexPath.row];
                
                NSString*  imgUrl=@"";
                NSString*  proname=@"";
            
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

                
                SET_IF_NOT_NULL(imgUrl, product[@"image"]);

                int price = [product[@"price"] intValue];
                int oprice = [product[@"original_price"] intValue];
                int order_qty = [product[@"quantity"] intValue];
                
                [cell.photoView sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                              placeholderImage:[UIImage imageNamed:@"order_default.png"]];
            
                int setprice = 0;
                if(product[@"set_price"] != [NSNull null] && product[@"set_price"] != nil)
                    setprice = [product[@"set_price"] intValue];
                
                [[GDSettingManager instance] setTitleAttr:cell.title withTitle:proname withSale:setprice withOrigin:oprice];
        
                
                cell.total_qty.text = [NSString stringWithFormat:@"%@%d x %d",[GDPublicManager instance].currency,price,order_qty];
                
                cell.price.text =  [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, price*order_qty];
                
                return cell;
            }
        }
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        NSString* type = @"";
        SET_IF_NOT_NULL(type, orderData[@"order_type"]);
        
        if (coupon_lists.count>0)
        {
            return 1+coupon_lists.count;
        }
        else
        {
            return 1;
        }
    }
    
    NSArray* temp = orderData[@"product_list"];
    return temp.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
            return 120;
        return 150; //non 115 member 135
    }
    else if (indexPath.section == 1)
    {
        return 100;
    }
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
//        if (indexPath.row == 1)
//        {
//            NSString* type = @"";
//            SET_IF_NOT_NULL(type, orderData[@"order_type"]);
//            if (![type isEqualToString:@"live"])
//            {
//                GDDeliverViewController* nv = [[GDDeliverViewController alloc] init:orderData];
//                [self.navigationController pushViewController:nv animated:YES];
//            }
//        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate method

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultSaved:
        case MFMailComposeResultCancelled:
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case MFMailComposeResultSent:
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Done",@"完成")
                               message:nil
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }
                              }];
            break;
        }
        case MFMailComposeResultFailed:
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"错误")
                               message:NSLocalizedString(@"Failed to send E-Mail.", @"发送邮件失败")
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      
                                  }
                              }];
            break;
        }
        default:
            break;
    }
}

#pragma mark - LXActivityDelegate

- (void)didClickOnImageIndex:(NSString *)imageIndex
{
    NSString*  text = shareData[@"title"];
    NSString*  url = [shareData[@"url"] encodeUTF];
    
    NSString* codeimage = shareData[@"codeimage"];
    
    __block UIImage* imageData = nil;
    
    [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:[codeimage encodeUTF]]  options:SDWebImageLowPriority|SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        imageData = image;
        
        //大小不能超过32K
        float imageRatio = image.size.height / image.size.width;
        CGFloat newWidth = image.size.width;
        if (newWidth > 160) {
            newWidth = 160;
        }
        
        imageData= [UIImage scaleImage:image ToSize:CGSizeMake(newWidth, newWidth*imageRatio)];
        
        if ([imageIndex isEqualToString:@"sns_icon_mail"])
        {
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
                
                mailComposeViewController.mailComposeDelegate = self;
                
                NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Your friend share a coupon for you ",@"您的朋友赠送了一张优惠券 ")];
                [mailComposeViewController setSubject:title];
                
                [mailComposeViewController setMessageBody:text isHTML:NO];
                
                
                [self presentViewController:mailComposeViewController animated:YES completion:nil];
            }
            else
            {
                [UIAlertView showWithTitle:NSLocalizedString(@"Unable to send E-Mail", @"不能发送邮件")
                                   message:NSLocalizedString(@"Please configure your E-Mail in this phone first.", @"您的手机没有配置发送邮件账号")
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      if (buttonIndex == [alertView cancelButtonIndex]) {
                                          
                                      }
                                  }];
                
            }
        }
        else if  ([imageIndex isEqualToString:@"sns_icon_whatsapp"])
        {
            [[whatsappAccountManage sharedInstance] sendMessageToFriend:text withUrl:url];
        }
        else if  ([imageIndex isEqualToString:@"sns_icon_wechat"])
        {
            NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
            [parameters setObject:text forKey:@"title"];
            if (url!=nil)
                [parameters setObject:[[NSURL URLWithString:url] absoluteString] forKey:@"url"];
            if (imageData!=nil)
                [parameters setObject:imageData forKey:@"image"];
            [[weixinAccountManage sharedInstance] sendMessageToFriend:parameters];
        }
    }];
}

- (void)didClickOnCancelButton
{
    LOG(@"didClickOnCancelButton");
}

@end
