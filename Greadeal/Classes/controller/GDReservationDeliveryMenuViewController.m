//
//  GDReservationDeliveryMenuViewController.m
//  Greadeal
//
//  Created by Elsa on 16/2/18.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDReservationDeliveryMenuViewController.h"
#import "RDVTabBarController.h"

#import "GDDeliveryMenuCell.h"
#import "GDDeliveryMenuNoImageCell.h"

#import "GDReservationDeliveryOrderViewController.h"

#import "GDLoginViewController.h"
#import "GDRegsiterViewController.h"

#import "UIActionSheet+Blocks.h"

#import "MJPhoto.h"
#import "MJPhotoBrowser.h"


#define toolViewHeight  50

#define kLeftWidth     100
#define leftTag        101

#define kRightWidth [[UIScreen mainScreen] bounds].size.width-kLeftWidth
#define titleWidth  kRightWidth-6*2

@interface GDReservationDeliveryMenuViewController ()

@end

@implementation GDReservationDeliveryMenuViewController


- (id)init:(NSDictionary*)vender_info
{
    self = [super init];
    if (self)
    {
        selectIndex = 0;
        leftData  = [[NSMutableArray alloc] init];
        
        NSString*  sale_off=@"0";
        SET_IF_NOT_NULL(sale_off, vender_info[@"discount"]);
        discount = [sale_off intValue];
   
        NSString* delivery_fee = @"";
        NSString* min_charge = @"";
        
        int vendor_id = [vender_info[@"vendor_id"] intValue];
        SET_IF_NOT_NULL(delivery_fee, vender_info[@"delivery_fee"]);
        int n_delivery_fee  = [delivery_fee intValue];
        
        SET_IF_NOT_NULL(min_charge, vender_info[@"min_order_fee"]);
        int n_min_charge  = [min_charge intValue];
        
        NSString* has_image = @"";
        SET_IF_NOT_NULL(has_image, vender_info[@"has_image"]);
        BOOL b_image = NO;
        
        NSString* is_open= @"";
        SET_IF_NOT_NULL(is_open, vender_info[@"is_open"]);
        isopen = [is_open boolValue];
        
        //b_image = [has_image boolValue];
        
        if ([has_image isEqualToString:@"1"])
            b_image = YES;

        venderId  = vendor_id;
        deliverFee= n_delivery_fee;
        minCharge = n_min_charge;
        
        haveImageCell = b_image;
        
    }
    return self;
}


- (void)addFooterView
{
    if (cartsView==nil)
    {
        CGRect r =  self.view.bounds;
        r.origin.y= r.size.height- toolViewHeight - 62 - 45;
        r.size.height=toolViewHeight;
        
        cartsView = [[UIView alloc] initWithFrame:r];
        cartsView.backgroundColor = MOColorAppBackgroundColor();
        [self.view addSubview:cartsView];
        
        UIImageView* backgroundView = [[UIImageView alloc] init];
        backgroundView.image = [[UIImage imageNamed:@"productLline.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        backgroundView.frame= CGRectMake(r.origin.x, 0,
                                         r.size.width, 0.5);
        [cartsView addSubview:backgroundView];
        
        buyNowBut=[UIButton buttonWithType:UIButtonTypeCustom];
        buyNowBut.frame = CGRectMake([GDPublicManager instance].screenWidth-120, 0, 120, toolViewHeight+2);
        [buyNowBut setBackgroundColor:[UIColor colorWithRed:221/255.0 green:0 blue:56/255.0 alpha:1.0]];
        buyNowBut.titleLabel.textAlignment = NSTextAlignmentCenter;
        [buyNowBut addTarget:self action:@selector(tapBuy:) forControlEvents:UIControlEventTouchUpInside];
        buyNowBut.titleLabel.font = MOBlodFont(16);
        [cartsView addSubview:buyNowBut];
        
        [buyNowBut setTitle:NSLocalizedString(@"BUY NOW",@"结算") forState:UIControlStateNormal];
        buyNowBut.hidden = YES;
        
        cartsBut = [UIButton buttonWithType:UIButtonTypeCustom];
        cartsBut.frame = CGRectMake(0, 2, 54, 44);
        [cartsBut setImage:[UIImage imageNamed:@"cart_normal.png"]  forState:UIControlStateNormal];
        [cartsBut addTarget:self action:@selector(tapBuy:) forControlEvents:UIControlEventTouchUpInside];
        cartsBut.enabled = NO;
        [cartsView addSubview:cartsBut];
        
        totalSingular =[[UILabel alloc]initWithFrame:CGRectMake(32, 0, 20, 20)];
        totalSingular.layer.masksToBounds=YES;
        totalSingular.layer.cornerRadius=10;
        totalSingular.textAlignment=NSTextAlignmentCenter;
        totalSingular.backgroundColor=[UIColor redColor];
        totalSingular.textColor=[UIColor whiteColor];
        totalSingular.font=MOLightFont(12);
        [cartsBut addSubview:totalSingular];
        totalSingular.hidden = YES;
        
        subTotalLabel=[[UILabel alloc]initWithFrame:CGRectMake(60, 3, [GDPublicManager instance].screenWidth-150, 20)];
        subTotalLabel.textAlignment=NSTextAlignmentLeft;
        subTotalLabel.backgroundColor=[UIColor clearColor];
        subTotalLabel.textColor=MOColor66Color();
        subTotalLabel.font=MOLightFont(12);
        [cartsView addSubview:subTotalLabel];
        
        deliveryChargeLabel=[[UILabel alloc]initWithFrame:CGRectMake(60, 23, [GDPublicManager instance].screenWidth-150, 20)];
        deliveryChargeLabel.textAlignment=NSTextAlignmentLeft;
        deliveryChargeLabel.backgroundColor=[UIColor clearColor];
        deliveryChargeLabel.textColor=MOColor66Color();
        deliveryChargeLabel.font=MOLightFont(12);
        [cartsView addSubview:deliveryChargeLabel];
        subTotalLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Sub Total: %@%d",@"小计: %@%d"),[GDPublicManager instance].currency, 0];
        [subTotalLabel findCurrency:10];
        
        deliveryChargeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Delivery Chagres: %@%d",@"配送费: %@%d"),[GDPublicManager instance].currency,deliverFee];
        [deliveryChargeLabel findCurrency:10];
        
    }
}


- (void)tapBuy:(id)sender
{
//     if (!isopen){
//        [UIAlertView showWithTitle:nil
//                           message:NSLocalizedString(@"The store has stopped taking reservations today, you can try again tomorrow.", @"亲,今天商家已停止预约,请明天在预约!")
//                 cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
//                 otherButtonTitles:nil
//                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                          }];
//        return;
//
//    }

    if ([GDPublicManager instance].cid>0)
    {
//        if (order_sum_price<minCharge)
//        {
//            [UIAlertView showWithTitle:nil
//                               message:[NSString stringWithFormat:NSLocalizedString(@"Sorry, your order total does not reach\n the minimum order (%@%d)",@"您的订单总价没有达到最少起送价格%@%d"),[GDPublicManager instance].currency,minCharge]
//                     cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
//                     otherButtonTitles:nil
//                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                              }];
//            return;
//        }
//        
        NSMutableArray   *orderArrar = [[NSMutableArray alloc] init];
    
        for (int line = 0; line <leftData.count; line++)
        {
            NSArray* temp = [rightData objectAtIndex:line];
            if (temp.count>0)
            {
                for (NSDictionary* obj in temp)
                {
                    int order_qty  = [obj[@"order_qty"] intValue];
                    if (order_qty>0)
                    {
                        [orderArrar addObject:obj];
                    }
                }
            }
        }
    
        GDReservationDeliveryOrderViewController* vc = [[GDReservationDeliveryOrderViewController alloc] init:orderArrar withDeliveryFee:deliverFee withDiscount:discount];
        vc.superNav = _superNav;
        vc.vendorId = venderId;
        [_superNav pushViewController:vc animated:YES];
    }
    else
    {
        [UIActionSheet showInView:self.view
                        withTitle:NSLocalizedString(@"Please login first and check out", @"您还没有登录,请先登录再购买")
                cancelButtonTitle:NSLocalizedString(@"Cancel",@"取消")
           destructiveButtonTitle:nil
                otherButtonTitles:@[NSLocalizedString(@"Login", @"登录"), NSLocalizedString(@"Sign Up", @"注册")]
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                             if (buttonIndex==0)
                             {
                                 GDLoginViewController* vc = [[GDLoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
                                 
                                 UINavigationController *nc = [[UINavigationController alloc]
                                                               initWithRootViewController:vc];
                                 
                                 [self presentViewController:nc animated:YES completion:^(void) {}];
                             }
                             else if (buttonIndex==1)
                             {
                                 GDRegsiterViewController* vc = [[GDRegsiterViewController alloc] initWithStyle:UITableViewStyleGrouped];
                                 UINavigationController *nc = [[UINavigationController alloc]
                                                               initWithRootViewController:vc];
                                 
                                 [self presentViewController:nc animated:YES completion:^(void) {}];
                             }
                         }];

    }
    
}

- (void)reCaluPrice
{
    float sprice = 0;
    int   sum_order_qty = 0;
    
    for (int line = 0; line <leftData.count; line++)
    {
        NSArray* temp = [rightData objectAtIndex:line];
        if (temp.count>0)
        {
            for (NSDictionary* obj in temp)
            {
                int order_qty  = [obj[@"order_qty"] floatValue];
                sum_order_qty+=order_qty;
                sprice += [obj[@"price"] floatValue]*order_qty;
            }
        }
    }
   
    
    if (sum_order_qty>0)
    {
        totalSingular.hidden = NO;
        buyNowBut.hidden = NO;
        cartsBut.enabled = YES;
    }
    else
    {
        totalSingular.hidden = YES;
        buyNowBut.hidden = YES;
        cartsBut.enabled = NO;
    }
    
    totalSingular.text = [NSString stringWithFormat:@"%d",sum_order_qty];
   
    subTotalLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Sub Total: %@%.1f",@"小计: %@%.1f"),[GDPublicManager instance].currency, sprice];
    [subTotalLabel findCurrency:10];
    
    order_sum_price=sprice+deliverFee;
}


-(void)subtractionItem:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:rightTableView];
    NSIndexPath *indexPath = [rightTableView indexPathForRowAtPoint:buttonPosition];
    
    int qty = 0;
    if (haveImageCell)
    {
        GDDeliveryMenuCell *cell = (GDDeliveryMenuCell*)[rightTableView cellForRowAtIndexPath:indexPath];
        qty = [cell.qtyLabel.text intValue];
        if (qty>=1)
        {
            qty--;
            cell.qtyLabel.text = [NSString stringWithFormat:@"%d",qty];
        }
    }
    else
    {
        GDDeliveryMenuNoImageCell *cell = (GDDeliveryMenuNoImageCell*)[rightTableView cellForRowAtIndexPath:indexPath];
        qty = [cell.qtyLabel.text intValue];
        if (qty>=1)
        {
            qty--;
            cell.qtyLabel.text = [NSString stringWithFormat:@"%d",qty];
        }
    }
    
    
    NSMutableDictionary* dict = rightData[selectIndex][indexPath.row];
    if (dict!=nil)
    {
        @synchronized(rightData) {
                [dict setObject:@(qty) forKey:@"order_qty"];
        }
    }
      
    [self reCaluPrice];
    [self reLoadView];

}

-(void)addItem:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:rightTableView];
    NSIndexPath *indexPath = [rightTableView indexPathForRowAtPoint:buttonPosition];
    
    int qty = 0;
    if (haveImageCell)
    {
        GDDeliveryMenuCell *cell = (GDDeliveryMenuCell*)[rightTableView cellForRowAtIndexPath:indexPath];
       
        qty = [cell.qtyLabel.text intValue];
        
        qty++;
        cell.qtyLabel.text = [NSString stringWithFormat:@"%d",qty];
    }
    else
    {
        GDDeliveryMenuNoImageCell *cell = (GDDeliveryMenuNoImageCell*)[rightTableView cellForRowAtIndexPath:indexPath];
       
        qty = [cell.qtyLabel.text intValue];
        
        qty++;
        cell.qtyLabel.text = [NSString stringWithFormat:@"%d",qty];
    }
    
        
    NSMutableDictionary* dict = rightData[selectIndex][indexPath.row];
    if (dict!=nil)
    {
        @synchronized(rightData) {
            [dict setObject:@(qty) forKey:@"order_qty"];
        }
    }
    
    [self reCaluPrice];
    [self reLoadView];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Menus",@"菜单");
    
    CGRect r = self.view.bounds;

    self.leftSelectColor=MOColorSaleFontColor();
    self.leftUnSelectColor=[UIColor blackColor];
    self.leftSelectBgColor=[UIColor whiteColor];
    self.leftBgColor=colorFromHexString(@"F3F4F6");
    self.leftSeparatorColor=colorFromHexString(@"E5E5E5");
    self.leftUnSelectBgColor=colorFromHexString(@"F3F4F6");
   
    r.size.height -= toolViewHeight;

    leftTablew = MOCreateTableView(CGRectMake(0, r.origin.y, kLeftWidth, r.size.height), UITableViewStylePlain, [UITableView class]);
    leftTablew.dataSource = self;
    leftTablew.delegate = self;
    leftTablew.tableFooterView=[[UIView alloc] init];
    leftTablew.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:leftTablew];
    leftTablew.backgroundColor=self.leftBgColor;
    leftTablew.showsVerticalScrollIndicator = NO;
    if ([leftTablew respondsToSelector:@selector(setLayoutMargins:)]) {
        leftTablew.layoutMargins=UIEdgeInsetsZero;
    }
    if ([leftTablew respondsToSelector:@selector(setSeparatorInset:)]) {
        leftTablew.separatorInset=UIEdgeInsetsZero;
    }
    leftTablew.separatorColor=self.leftSeparatorColor;
    
    MODebugLayer(leftTablew, 1.f, [UIColor redColor].CGColor);
    
    rightTableView = MOCreateTableView( CGRectMake(kLeftWidth, r.origin.y, r.size.width-kLeftWidth, r.size.height) , UITableViewStylePlain, [UITableView class]);
    rightTableView.dataSource = self;
    rightTableView.delegate = self;
    rightTableView.tableFooterView=[[UIView alloc] init];
    rightTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:rightTableView];
    rightTableView.backgroundColor = MOColorAppBackgroundColor();
    
   // MODebugLayer(rightTableView, 1.f, [UIColor redColor].CGColor);
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = leftTablew.frame;
        tempRect.origin.x = r.size.width - kLeftWidth;
        leftTablew.frame = tempRect;
        
        tempRect = rightTableView.frame;
        tempRect.origin.x = 0;
        rightTableView.frame = tempRect;
    }
    
    [self addFooterView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [ProgressHUD dismiss];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!isLoadData)
    {
        [self getLeftData];
        isLoadData = YES;
    }
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)reLoadView
{
    [rightTableView reloadData];
}

- (void)getLeftData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    isLoadData= YES;
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/TakeoutVendor/get_category_list"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"vendor_id":@(venderId)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             @synchronized(leftData)
             {
                 [leftData removeAllObjects];
             }
             
             [leftData addObjectsFromArray:responseObject[@"data"][@"category_list"]];
             
             rightData = [[NSMutableArray alloc] initWithCapacity:leftData.count];
             for (NSUInteger idx = 0; idx < leftData.count; idx++) {
                 [rightData addObject:[NSMutableArray array]];
             }
             
             [leftTablew reloadData];
             
             //get one
             if (selectIndex<leftData.count)
                 [self getRightData:selectIndex];
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             [ProgressHUD showError:errorInfo];
         }
         [ProgressHUD dismiss];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [ProgressHUD showError:error.localizedDescription];
     }];
}

- (void)selectedSection:(int)nRow
{
    selectIndex = nRow;
    [leftTablew reloadData];
}

- (void)getRightData:(int)nRow
{
    NSArray* temp = [rightData objectAtIndex:nRow];
    if (temp.count>0)
    {
        [self selectedSection:nRow];
        [rightTableView reloadData];
        [rightTableView setContentOffset:CGPointZero animated:NO];
        return;
    }
    
    [ProgressHUD show:nil];
    
    NSString* url;
    NSDictionary *parameters;
    
    NSDictionary* obj = [leftData objectAtIndex:nRow];
    int categoryId = [obj[@"vendor_category_id"] intValue];
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/TakeoutVendor/get_product_list_by_category_id"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"vendor_id":@(venderId),@"vendor_category_id":@(categoryId),@"page":@(0),@"limit":@(100)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [ProgressHUD dismiss];
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             NSArray* tempArr = responseObject[@"data"][@"product_list"];
             
             NSMutableArray* changedArr= [[NSMutableArray alloc] initWithCapacity:tempArr.count];
             
             for (NSDictionary* ecth in tempArr)
             {
                 NSMutableDictionary *product = [ecth mutableCopy];
                 [product setObject:@(0) forKey:@"order_qty"];
                 [changedArr addObject:product];
             }
             
             @synchronized(rightData)
             {
                 [rightData replaceObjectAtIndex:nRow withObject:changedArr];
             }
             
             [self selectedSection:nRow];
             
             [rightTableView reloadData];
             [rightTableView setContentOffset:CGPointZero animated:NO];
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

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (leftTablew == tableView)
    {
        static NSString *ID = @"left";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }

        NSDictionary* obj = [leftData objectAtIndex:indexPath.row];
        
        NSString*  categoryName=@"";
        SET_IF_NOT_NULL(categoryName, obj[@"name"]);
        
        UILabel* Ltext = MOCreateLabelAutoRTL();
        Ltext.frame = CGRectMake(5, 0, kLeftWidth-10, 60);
        Ltext.font = MOLightFont(14);
        Ltext.tag=leftTag;
        Ltext.text=categoryName;
        Ltext.numberOfLines = 0;
        [cell.contentView addSubview:Ltext];
        MODebugLayer(Ltext, 1.f, [UIColor redColor].CGColor);
        
        if (indexPath.row==selectIndex) {
            Ltext.textColor=self.leftSelectColor;
            cell.backgroundColor=self.leftSelectBgColor;
        }
        else{
            Ltext.textColor=self.leftUnSelectColor;
            cell.backgroundColor=self.leftUnSelectBgColor;
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            cell.layoutMargins=UIEdgeInsetsZero;
        }
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset=UIEdgeInsetsZero;
        }
        return cell;
    }
    else if (rightTableView == tableView)
    {
        static NSString *CellIdentifier = @"menuCell";
        
        if (haveImageCell)
        {
        GDDeliveryMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GDDeliveryMenuCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        NSDictionary* product = rightData[selectIndex][indexPath.row];
        
        NSString*  imgUrl=@"";
        NSString*  productname=@"";
        NSString*  saleprice=@"0";
       
        SET_IF_NOT_NULL(imgUrl, product[@"image"]);
        SET_IF_NOT_NULL(productname, product[@"name"]);
        SET_IF_NOT_NULL(saleprice, product[@"price"]);
        
        [cell.productImage sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                             placeholderImage:[UIImage imageNamed:@"menudefault.png"]];
        
        
        cell.menuLabel.text = productname;
        
        float sprice = [saleprice floatValue];
        NSString* spricestr = [NSString stringWithFormat:@"%@%.1f",[GDPublicManager instance].currency, sprice];
        cell.saleLabel.text = spricestr;
        
        int order_qty = [product[@"order_qty"] intValue];
        cell.qtyLabel.text = [NSString stringWithFormat:@"%d",order_qty];
        
        [cell.subtractionBut addTarget:self action:@selector(subtractionItem:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.addBut addTarget:self action:@selector(addItem:) forControlEvents:UIControlEventTouchUpInside];
            
        return cell;
        }
        else
        {
        GDDeliveryMenuNoImageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GDDeliveryMenuNoImageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        NSDictionary* product = rightData[selectIndex][indexPath.row];
        
        NSString*  imgUrl=@"";
        NSString*  productname=@"";
        NSString*  saleprice=@"0";
        NSString*  details=@"";
            
        SET_IF_NOT_NULL(details, product[@"description"]);
        SET_IF_NOT_NULL(imgUrl, product[@"image"]);
        SET_IF_NOT_NULL(productname, product[@"name"]);
        SET_IF_NOT_NULL(saleprice, product[@"price"]);
 
        cell.menuLabel.text = productname;
        cell.detailsLabel.text = details;
            
        float  sprice = [saleprice floatValue];
        NSString* spricestr = [NSString stringWithFormat:@"%@%.1f",[GDPublicManager instance].currency, sprice];
        cell.saleLabel.text = spricestr;
        
        int order_qty = [product[@"order_qty"] intValue];
        cell.qtyLabel.text = [NSString stringWithFormat:@"%d",order_qty];
        
        [cell.subtractionBut addTarget:self action:@selector(subtractionItem:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.addBut addTarget:self action:@selector(addItem:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        }
    }

    return nil;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (leftTablew == tableView)
    {
        return 1;
    }
    else if (rightTableView == tableView)
    {
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (leftTablew == tableView)
    {
        return leftData.count;
    }
    else if (rightTableView == tableView)
    {
        if (section<rightData.count)
        {
            NSArray* temp = [rightData objectAtIndex:selectIndex];
            return temp.count;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (leftTablew == tableView)
    {
        return 60;
    }
    else if (rightTableView == tableView)
    {
        if (haveImageCell)
        {
            return 110;
        }
        else
        {
            NSDictionary* product = rightData[selectIndex][indexPath.row];
            
            NSString*  details=@"";
            SET_IF_NOT_NULL(details, product[@"description"]);
        
            UIFont* Font = MOLightFont(12);
            CGSize titleSize = [details moSizeWithFont:Font withWidth:titleWidth];
            if (titleSize.height>18)
                titleSize.height += 8;
            return 65+titleSize.height;
        }
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (leftTablew == tableView)
    {
        UITableViewCell * cell=(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor=self.leftSelectColor;
        cell.backgroundColor=self.leftSelectBgColor;
        
        [leftTablew scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        if (indexPath.row<leftData.count)
            [self getRightData:(int)indexPath.row];
    }
    else if  (rightTableView == tableView)
    {
        if (haveImageCell)
        {
            NSDictionary* product = rightData[selectIndex][indexPath.row];
            
            NSString*  imgUrl=@"";
            imgUrl = product[@"image"];
            
            NSMutableArray *photos = [[NSMutableArray alloc] init];
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString: [imgUrl encodeUTF] ];
            [photos addObject:photo];
            
            MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init:NO];
            browser.currentPhotoIndex = 0;
            browser.photos = photos;
            [browser show];
            
        }
    }

}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (leftTablew == tableView)
    {
        UITableViewCell * cell=(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor=self.leftUnSelectColor;
        cell.backgroundColor=self.leftUnSelectBgColor;
    }
}

@end
