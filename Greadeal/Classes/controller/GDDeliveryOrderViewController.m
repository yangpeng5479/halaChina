//
//  GDDeliveryOrderViewController.m
//  Greadeal
//
//  Created by Elsa on 16/2/19.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDDeliveryOrderViewController.h"

#import "GDMakeOrderViewController.h"
#import "RDVTabBarController.h"
#import "GDReceiveCell.h"
#import "GDDeliveryOrderCell.h"

#import "GDDeliveryEditAddressViewController.h"
#import "GDDeliveryAddressManageViewController.h"

#import "GDMarketVerificationCodeViewController.h"
#import "GDMessageViewController.h"

#import "GDShipsCell.h"
#import "GDPaymentCell.h"

#import "GDDeliveryOrderDetailsViewController.h"

#import "GDDeliveryListViewController.h"

#define  toolViewHeight 40


@interface GDDeliveryOrderViewController ()

@end

@implementation GDDeliveryOrderViewController
@synthesize  vendorId;

- (id)init:(NSArray*)aproductData withDeliveryFee:(int)delivery_Fee  withDiscount:(int)acount
{
    self = [super init];
    if (self)
    {
        self.title = NSLocalizedString(@"Order Details", @"订单详情");
       
        
        self.productData = aproductData;
        sprice = 0;
        choosePayType = @"";
        
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
    
    confirmBut.enabled = NO;
    
    [self getReceiveAddress];
   
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
                       message:NSLocalizedString(@"Please waiting for the delivery.", @"请等待餐厅送餐.")
             cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              //pop
                              
                              [CATransaction begin];
                              [CATransaction setCompletionBlock:^{
                                  GDDeliveryOrderDetailsViewController* nv = [[GDDeliveryOrderDetailsViewController alloc] initWithOrderId:order_id];
                                  
                                  [_superNav pushViewController:nv animated:YES];
                                  
                              }];
                              
                              for (UIViewController *temp in self.navigationController.viewControllers) {
                                  if ([temp isKindOfClass:[GDDeliveryListViewController class]])
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
    
    [self tapMakeOrder];

}

- (void)tapMakeOrder
{
    int sel_address_id = 0;
    if (receiveInfo!=nil)
    {
        sel_address_id = [receiveInfo[@"address_id"] intValue];
    }
    
    NSString *jsonStr = [[GDOrderCheck instance] genJsonStr:self.productData];
    
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/Takeout/add_order"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    NSDictionary *parameters;
    
    parameters = @{@"product_list_json":jsonStr,@"token":[GDPublicManager instance].token,@"language_id":@([[GDSettingManager instance] language_id:NO]),@"comment":comment,@"vendor_id":@(vendorId),@"payment_code":choosePayType,@"address_id":@(sel_address_id),@"push_device":@"ios",@"push_token":[GDPublicManager instance].push_token};
  
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
             
             [self orderOkAndDelProduct];
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
        
        [confirmBut setTitle: NSLocalizedString(@"Confirm", @"确定") forState:UIControlStateNormal];
        
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
             [ProgressHUD showError:errorInfo];
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [ProgressHUD showError:error.localizedDescription];
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
                 [ProgressHUD showError:errorInfo];
             }
    
             confirmBut.enabled = YES;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [ProgressHUD showError:error.localizedDescription];
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
            SET_IF_NOT_NULL(area, receiveInfo[@"area_name"]);
            
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
        sumPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Total: %@%.1f",@"总金额: %@%.1f"),[GDPublicManager instance].currency, sprice+chosseCodFee+deliveryFee];
        [sumPrice findCurrency:CurrencyFontSize];
        
        if (discount>0)
        {
            offsetY+=20;
            
            UILabel* discountPrice =  MOCreateLabelAutoRTL();
            discountPrice.textAlignment = [GDSettingManager instance].isRightToLeft?NSTextAlignmentLeft:NSTextAlignmentRight;
            discountPrice.font = MOLightFont(14);
            discountPrice.frame = CGRectMake(10, offsetY, [GDPublicManager instance].screenWidth-20, 20);
            discountPrice.textColor = [UIColor whiteColor];
            discountPrice.backgroundColor =  [UIColor clearColor];
            discountPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Discounted Price: %@%.1f",@"折扣价: %@%.1f"),[GDPublicManager instance].currency, (sprice+chosseCodFee+deliveryFee)*(1-discount*1.0/100)];
            [discountPrice findCurrency:CurrencyFontSize];
            [cell.contentView addSubview:discountPrice];
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
    
    kAddressSection = nIndex++;
    
    kOrdersSection  = nIndex++;

    kPaymentSection = nIndex++;
   
    kCommentSection = nIndex++;
    
    
    return nIndex;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kAddressSection)
    {
        return 1;
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
            return 90;
    }
    else if (indexPath.section == kPriceSection)
    {
        float baseHeight = 50;
        
        baseHeight+=20;
        
        if (chosseCodFee>0)
            baseHeight+=20;
        if (discount>0)
            baseHeight+=20;
        
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
}



@end
