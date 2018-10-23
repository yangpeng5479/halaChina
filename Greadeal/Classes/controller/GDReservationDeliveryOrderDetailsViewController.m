//
//  GDReservationDeliveryOrderDetailsViewController.m
//  Greadeal
//
//  Created by Elsa on 16/2/21.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDReservationDeliveryOrderDetailsViewController.h"
#import "RDVTabBarController.h"

#import "GDDeliverCell.h"
#import "GDReceiveCell.h"

#import "GDDeliveryOrderCell.h"

#define  toolViewHeight 40

@interface GDReservationDeliveryOrderDetailsViewController ()

@end

@implementation GDReservationDeliveryOrderDetailsViewController

- (id)init:(NSDictionary*)aObj
{
    self = [super init];
    if (self)
    {
        orderData   = aObj;
        deliverData = [[NSMutableArray alloc] init];
        order_id    = orderData[@"order_id"];
        isReminder = NO;
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
        isReminder = NO;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",@"返回") style:UIBarButtonItemStylePlain target:self action:@selector(Exit)];
    }
    return self;
}

- (void)Exit
{
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showHeaderInfo
{
    CGRect r = self.view.bounds;
    
    //目前超市才显示消费二维码和消费码
    r.size.height = 120;
    float  offsetX = 10;
    float  offwidth = [GDPublicManager instance].screenWidth-20;
    
    UIView *footer = [[UIView alloc] initWithFrame:r];
    footer.backgroundColor = [UIColor colorWithRed:75/255.0 green:87/255.0 blue:114/255.0 alpha:1.0];
    
    float  offsetY = 5;
    
    float  sub_total = 0;
    if(orderData[@"bill"]!= [NSNull null] && orderData[@"bill"]!= nil)
    {
        sub_total = [orderData[@"bill"][@"sub_total"][@"value"] floatValue];
    }
    
    int  deliveryFee = 0;
    if(orderData[@"bill"]!= [NSNull null] && orderData[@"bill"]!= nil)
    {
        deliveryFee = [orderData[@"bill"][@"shipping"][@"value"] intValue];
    }
   
    UILabel* subTotal =  MOCreateLabelAutoRTL();
    subTotal.font = MOLightFont(14);
    subTotal.frame = CGRectMake(offsetX, offsetY, offwidth, 20);
    subTotal.textColor = [UIColor whiteColor];
    subTotal.backgroundColor =  [UIColor clearColor];
    [footer addSubview:subTotal];
    [subTotal findCurrency:CurrencyFontSize];
    subTotal.text = [NSString stringWithFormat:NSLocalizedString(@"Subtotal: %@%.1f",@"订单金额: %@%.1f"),[GDPublicManager instance].currency, sub_total];
  
    offsetY+=20;
    UILabel* deliveryLabel =  MOCreateLabelAutoRTL();
    deliveryLabel.font = MOLightFont(13);
    deliveryLabel.frame = CGRectMake(offsetX, offsetY, offwidth, 20);
    deliveryLabel.textColor = [UIColor whiteColor];
    deliveryLabel.backgroundColor =  [UIColor clearColor];
    deliveryLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Delivery Chagres: %@%d",@"配送费: %@%d"),[GDPublicManager instance].currency, deliveryFee];
    [footer addSubview:deliveryLabel];
    [deliveryLabel findCurrency:CurrencyFontSize];
 
    int  discount = 0;
    if(orderData[@"bill"]!= [NSNull null] && orderData[@"bill"]!= nil)
    {
        discount = [orderData[@"bill"][@"discount"][@"value"] intValue];
    }
    
    offsetY+=20;
    
    float total =0;
    if(orderData[@"bill"]!= [NSNull null] && orderData[@"bill"]!= nil)
    {
        total = [orderData[@"bill"][@"total"][@"value"] floatValue];
    }
    
    UILabel* totalLable =  MOCreateLabelAutoRTL();
    totalLable.font = MOLightFont(14);
    totalLable.frame = CGRectMake(offsetX, offsetY, offwidth, 20);
    totalLable.textColor = [UIColor whiteColor];
    totalLable.backgroundColor =  [UIColor clearColor];
    
    if (discount>0)
    {
         totalLable.text =  [NSString stringWithFormat:NSLocalizedString(@"Total: %@%.1f              Discounted: -%d%%", @"总金额:%@%.1f           折扣:-%d%%"),[GDPublicManager instance].currency, total, discount];
    }
    else
    {
        totalLable.text =  [NSString stringWithFormat:NSLocalizedString(@"Total: %@%.1f", @"总金额:%@%.1f"),[GDPublicManager instance].currency, total];
    }
    
    [footer addSubview:totalLable];
    [totalLable findCurrency:CurrencyFontSize];
     
    offsetY+=20;
    order_id = orderData[@"order_id"];
    
    UILabel* orderId =  MOCreateLabelAutoRTL();
    orderId.font = MOLightFont(14);
    orderId.frame = CGRectMake(offsetX, offsetY, offwidth, 20);
    orderId.textColor = [UIColor whiteColor];
    orderId.backgroundColor =  [UIColor clearColor];
    orderId.text = [NSString stringWithFormat:NSLocalizedString(@"Order ID: %@",@"订单号: %%@"), order_id];
    [footer addSubview:orderId];
    
    NSString* payment_method;
    SET_IF_NOT_NULL(payment_method, orderData[@"payment_method"]);
    NSString* payment_code;
    SET_IF_NOT_NULL(payment_code, orderData[@"payment_code"]);

    offsetY+=20;
    UILabel *pmLable = MOCreateLabelAutoRTL();
    pmLable.frame = CGRectMake(offsetX,offsetY, offwidth, 20);
    pmLable.backgroundColor = [UIColor clearColor];
    pmLable.font = MOLightFont(14);
    pmLable.textColor = [UIColor whiteColor];
    pmLable.text = [NSString stringWithFormat:NSLocalizedString(@"Payment Method: %@", @"支付方式: %@"),payment_method];
    [footer addSubview:pmLable];

    offsetY+=20;
    NSString* orderStatus = @"";
    SET_IF_NOT_NULL(orderStatus, orderData[@"order_status_id"]);
    
    UILabel *statusLable = MOCreateLabelAutoRTL();
    statusLable.frame = CGRectMake(offsetX, offsetY, offwidth, 20);
    statusLable.backgroundColor = [UIColor clearColor];
    statusLable.font = MOLightFont(14);
    statusLable.textColor = MOColor33Color();
    [footer addSubview:statusLable];
    statusLable.textColor = [UIColor whiteColor];
    
    if ([orderStatus isEqualToString:@"1"])
    {
        if ([payment_code isEqualToString:kCashPay])
        {
            statusLable.text = [NSString stringWithFormat:@"%@ %@",
                                NSLocalizedString(@"Order Status:", @"订单状态:"),NSLocalizedString(@"Accepted", @"已接受")];
        }
        else
        {
            statusLable.text = [NSString stringWithFormat:@"%@ %@",
                                NSLocalizedString(@"Order Status:", @"订单状态:"),NSLocalizedString(@"Unpaid", @"没有支付")];
        }
        statusLable.textColor = [UIColor redColor];
    }
    else if ([orderStatus isEqualToString:@"2"])
    {
        if ([payment_code isEqualToString:kCashPay])
        {
            statusLable.text = [NSString stringWithFormat:@"%@ %@",
                                NSLocalizedString(@"Order Status:", @"订单状态:"),NSLocalizedString(@"Accepted", @"已接受")];
        }
        else
        {
        statusLable.text = [NSString stringWithFormat:@"%@ %@",
                            NSLocalizedString(@"Order Status:", @"订单状态:"),NSLocalizedString(@"Paid", @"已支付")];
        }
        statusLable.textColor = [UIColor magentaColor];
    }
    else
    {
        statusLable.text = [NSString stringWithFormat:@"%@ %@",
                            NSLocalizedString(@"Order Status:", @"订单状态:"),NSLocalizedString(@"Declined", @"已拒绝")];
    }

    NSString*  arrive_start_time=@"";
    NSString*  arrive_end_time=@"";
    
    SET_IF_NOT_NULL(arrive_start_time, orderData[@"arrive_start_time"]);
    SET_IF_NOT_NULL(arrive_end_time, orderData[@"arrive_end_time"]);
    NSString* dTime = @"";
    
    if (arrive_start_time.length>16 && arrive_end_time.length>0)
        dTime = [NSString stringWithFormat:@"%@-%@",[arrive_start_time substringToIndex:16],[[arrive_end_time substringFromIndex:11] substringToIndex:5]];
    
    
    offsetY+=20;
    UILabel *dtimeLable = MOCreateLabelAutoRTL();
    dtimeLable.frame = CGRectMake(offsetX,offsetY, [GDPublicManager instance].screenWidth-10, 25);
    dtimeLable.backgroundColor = [UIColor clearColor];
    dtimeLable.font = MOLightFont(14);
    dtimeLable.textColor = [UIColor whiteColor];
    dtimeLable.text = [NSString stringWithFormat:NSLocalizedString(@"Delivery Arrival: %@", @"送达时间: %@"),dTime];
    [footer addSubview:dtimeLable];
    
    CGRect rf = footer.frame;
    rf.size.height = offsetY+30;
    footer.frame = rf;
    
    mainTableView.tableHeaderView = footer;
}

- (void)checkReminder
{
    if (orderData!=nil)
    {
        NSString* order_status_id = orderData[@"order_status_id"];
        int reminder = [orderData[@"reminder"] intValue];

        if (reminder==0 && [order_status_id isEqualToString:@"2"])
        {
            isReminder = YES;
        }
    }
}

- (void)tapReminder
{
    [UIAlertView showWithTitle:nil
                       message:NSLocalizedString(@"Are you sure to send a reminder?", @"您确定要催单吗?")
             cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
             otherButtonTitles:@[NSLocalizedString(@"OK", @"确定")]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == 1){
                              NSString* url;
                              NSDictionary *parameters;
                              
                              url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/customer/reminder_order"];
                              parameters = @{@"order_id":order_id,@"token":[GDPublicManager instance].token};
                              
                              AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                              manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
                              
                              [manager POST:url
                                 parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
                               {
                                   int status = [responseObject[@"status"] intValue];
                                   if (status==1)
                                   {
                                       
                                       [UIAlertView showWithTitle:nil
                                                          message:NSLocalizedString(@"Done", @"完成")
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@[NSLocalizedString(@"OK", @"确定")]
                                                         tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
                                        {
                                            [self.navigationController popViewControllerAnimated:YES];
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

                      }];
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Order Details", @"订单详情");
    
    [self checkReminder];
    // Do any additional setup after loading the view.
    CGRect r = self.view.bounds;
    if (isReminder)
    {
        r.size.height-=toolViewHeight;
    }
    
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    if (orderData!=nil)
    {
        
        if (isReminder)
        {
            r.origin.y= self.view.bounds.size.height-toolViewHeight-64;
            r.size.height=toolViewHeight;
            
            paymentView = [[UIView alloc] initWithFrame:r];
            [self.view addSubview:paymentView];
           
            reminderBut = [ACPButton buttonWithType:UIButtonTypeCustom];
            reminderBut.frame = CGRectMake(10, 4, [GDPublicManager instance].screenWidth-20, 34);
            [reminderBut setStyleRedButton];
            [reminderBut setTitle: NSLocalizedString(@"Reminder", @"催单") forState:UIControlStateNormal];
            [reminderBut addTarget:self action:@selector(tapReminder) forControlEvents:UIControlEventTouchUpInside];
            [reminderBut setLabelFont:MOLightFont(18)];
            [paymentView addSubview:reminderBut];

        }
        
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


#pragma mark - Data
- (void)getOrderData
{
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/Takeout/get_order"];
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
            static NSString *CellIdentifier = @"CellPerson1";
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
                
                cell.textLabel.text= NSLocalizedString(@"Personal Information", @"个人信息");
                return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"CellPerson2";
            
            GDReceiveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GDReceiveCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
          
                NSString*  name = @"";
                NSString*  telephone= @"";
                NSString*  address=@"";
                NSString*  city=@"";
                NSString*  area=@"";
                NSString*  country=@"";
                
                SET_IF_NOT_NULL(name, orderData[@"firstname"]);
                SET_IF_NOT_NULL(telephone, orderData[@"telephone"]);
                SET_IF_NOT_NULL(address, orderData[@"shipping_address_1"]);
                SET_IF_NOT_NULL(country, orderData[@"shipping_country"]);
                SET_IF_NOT_NULL(city, orderData[@"shipping_zone"]);
                SET_IF_NOT_NULL(area, orderData[@"shipping_area"]);
                
                cell.name.text  = [NSString stringWithFormat:NSLocalizedString(@"Receiver: %@", @"收货人:%@"),name];
                cell.phone.text = telephone;
                
                if (area.length>0)
                    cell.address.text = [NSString stringWithFormat:@"%@,%@,%@,%@",address,area,city,country];
                else
                    cell.address.text = [NSString stringWithFormat:@"%@,%@",address,city];
                
            
            return cell;
        }
    }
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            static NSString *CellIdentifier = @"CellVendor1";
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
            
            cell.textLabel.text= NSLocalizedString(@"Vendor Information", @"商家信息");
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"CellVendor2";
            
            GDReceiveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GDReceiveCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            NSString* vendor_phone = @"";
            NSString* vendor_country = @"";
            NSString* vendor_city = @"";
            NSString* vendor_area = @"";
            NSString* vendor_address = @"";
            NSString* vendor_name = @"";
            
            if(orderData[@"vendor"]!= [NSNull null] && orderData[@"vendor"]!= nil)
            {
            SET_IF_NOT_NULL(vendor_name, orderData[@"vendor"][@"vendor_name"]);
            SET_IF_NOT_NULL(vendor_address, orderData[@"vendor"][@"address"]);
            SET_IF_NOT_NULL(vendor_area, orderData[@"vendor"][@"area"]);
            SET_IF_NOT_NULL(vendor_city, orderData[@"vendor"][@"zone_name"]);
            SET_IF_NOT_NULL(vendor_country, orderData[@"vendor"][@"country_name"]);
            SET_IF_NOT_NULL(vendor_phone, orderData[@"vendor"][@"telephone"]);
            }
            
            cell.name.text  = vendor_name;
            cell.phone.text = [NSString stringWithFormat:@"%@",vendor_phone];
            cell.address.text = vendor_address;
            
//            if (vendor_area.length>0)
//                cell.address.text = [NSString stringWithFormat:@"%@,%@,%@,%@",vendor_address,vendor_area,vendor_city,vendor_country];
//            else
//                cell.address.text = [NSString stringWithFormat:@"%@,%@",vendor_address,vendor_city];
            
            cell.nameImage.image = [UIImage imageNamed:@"verdor_name.png"];
            return cell;
        }
    }
    else if (indexPath.section == 2)
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
        static NSString *CellIdentifier = @"listCell";
            
        GDDeliveryOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GDDeliveryOrderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            
        NSArray* temp = orderData[@"product_list"];
        
        if (temp!=nil && temp.count>0)
        {
            NSDictionary *product;
            
            product = [temp objectAtIndex:indexPath.row-1];
            
            NSString*  imgUrl=@"";
            NSString*  proname=@"";
            
            SET_IF_NOT_NULL(imgUrl, product[@"image"]);
            float price = [product[@"price"] floatValue];
            
            int order_qty = [product[@"quantity"] intValue];
            
            if(product[@"option"] != [NSNull null] && product[@"option"] != nil)
            {
                NSDictionary* option = product[@"option"];
                proname = [NSString stringWithFormat:@"%@ (%@)",product[@"name"],option[@"value"]];
            }
            
            if (proname.length<=0)
                proname = product[@"name"];
            
            [cell.photoView sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                              placeholderImage:[UIImage imageNamed:@"delivery_default.png"]];
            
            
            cell.title.text = proname;
            
            cell.total_qty.text = [NSString stringWithFormat:@"%@%.1f x %d",[GDPublicManager instance].currency,price,order_qty];
            
            cell.price.text =  [NSString stringWithFormat:@"%@%.1f",[GDPublicManager instance].currency, price*order_qty];
        }
        return cell;
        }
    }
    else if (indexPath.section == 3)
    {
        if (indexPath.row == 0)
        {
        static NSString *CellIdentifier = @"CellMessage1";
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
        
        cell.textLabel.text= NSLocalizedString(@"Message", @"留言");
        return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"CellMessage2";
            
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
            
            NSString* message=@"";
            SET_IF_NOT_NULL(message, orderData[@"comment"]);
            
            cell.textLabel.text= message;
            return cell;

        }
    }
  
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSString* message=@"";
    SET_IF_NOT_NULL(message, orderData[@"comment"]);
    
    if (message.length>0)
        return 4;
    else
        return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else if (section == 1)
    {
        return 2;
    }
    else if (section == 2)
    {
        NSArray* temp = orderData[@"product_list"];
        return 1+temp.count;
    }
    else
    {
        return 2;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 )
    {
        if (indexPath.row == 0)
            return 40;
        return 115;
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
            return 40;
        return 115;
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
            return 40;
        return 60;
    }
    else
    {
        if (indexPath.row == 0)
            return 40;
        return 60;
    }
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section ==1 && indexPath.row == 1)
    {
         NSString* vendor_phone=@"";
         SET_IF_NOT_NULL(vendor_phone, orderData[@"vendor"][@"telephone"]);
        
         [[GDPublicManager instance] makeCall:vendor_phone  withView:self.view];
    }
}

@end
