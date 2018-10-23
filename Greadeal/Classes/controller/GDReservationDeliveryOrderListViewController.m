//
//  GDDeliveryOrderListViewController.m
//  Greadeal
//
//  Created by Elsa on 16/2/21.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDReservationDeliveryOrderListViewController.h"
#import "RDVTabBarController.h"
#import "GDDeliveryOrderCell.h"

#import "GDReservationDeliveryOrderDetailsViewController.h"

#import "GDRatingViewController.h"


@interface GDReservationDeliveryOrderListViewController ()

@end

@implementation GDReservationDeliveryOrderListViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        isLoadData = NO;
        
        orderData = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
        
        self.title = NSLocalizedString(@"Delivery Orders", @"外卖订单");
    }
    return self;
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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)noOrderView
{
    if (!_noOrderView) {
        
        CGRect r = self.view.frame;
        
        _noOrderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height)];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, r.size.height/2-40, r.size.width, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"You have no relevant coupon.", @"您没有相关优惠券");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = MOLightFont(16);
        [_noOrderView addSubview:label];
        
    }
    return _noOrderView;
}


#pragma mark - Data
- (void)getProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    reloading = YES;
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/Takeout/get_order_list"];
    
    parameters = @{@"page":@(seekPage),@"limit":@(prePageNumber),@"token":[GDPublicManager instance].token,@"language_id":@([[GDSettingManager instance] language_id:NO])};
    
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

- (void)tapCancel:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    
    int selectedIndex = (int)button.tag;
    
    NSDictionary* obj = [orderData objectAtIndex:selectedIndex];
    if (obj!=nil)
    {
      
        NSString* url;
        NSDictionary *parameters;
        
        url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"Takeout/v1/Takeout/cancel_order"];
        
        NSString* order_id = obj[@"order_id"];
        
        parameters = @{@"order_id":order_id,@"token":[GDPublicManager instance].token};
        
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
                                    message:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil
                                   tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if (buttonIndex == [alertView cancelButtonIndex]) {
                                           [self getProductData];
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
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        float offsetY = 15;
        float offsetX = 4;
      
        UIImageView* _productImage = [[UIImageView alloc] init];
        _productImage.backgroundColor = [UIColor clearColor];
        _productImage.contentMode = UIViewContentModeScaleAspectFill;
        _productImage.clipsToBounds = YES;
        [cell.contentView addSubview:_productImage];
        
        NSString* vendor_image = @"";
        NSString* vendor_name = @"";
        
        if(obj[@"vendor"]!= [NSNull null] && obj[@"vendor"]!= nil)
        {
            SET_IF_NOT_NULL(vendor_image, obj[@"vendor"][@"vendor_image"]);
            SET_IF_NOT_NULL(vendor_name,obj[@"vendor"][@"vendor_name"]);
        }
        
        [_productImage sd_setImageWithURL:[NSURL URLWithString:[vendor_image encodeUTF]]
                             placeholderImage:[UIImage imageNamed:@"delivery_vendor_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             }];
        _productImage.frame =  CGRectMake(offsetX,offsetY, 85, 85);
        
        offsetX+=90;
        
        UILabel *name = MOCreateLabelAutoRTL();
        name.frame = CGRectMake(offsetX,offsetY, [GDPublicManager instance].screenWidth-10, 25);
        name.backgroundColor = [UIColor clearColor];
        name.font = MOLightFont(16);
        name.textColor = MOColor33Color();
        name.text = vendor_name;
        [cell.contentView addSubview:name];
        
        offsetY+=25;
        UILabel *timeLable = MOCreateLabelAutoRTL();
        timeLable.frame = CGRectMake(offsetX,offsetY, [GDPublicManager instance].screenWidth-10, 25);
        timeLable.backgroundColor = [UIColor clearColor];
        timeLable.font = MOLightFont(13);
        timeLable.textColor = MOColor66Color();
        timeLable.text = [NSString stringWithFormat:NSLocalizedString(@"Booking Time: %@", @"预约时间: %@"),obj[@"date_added"]];
        [cell.contentView addSubview:timeLable];
        
        NSString*  arrive_start_time=@"";
        NSString*  arrive_end_time=@"";
        
        SET_IF_NOT_NULL(arrive_start_time, obj[@"arrive_start_time"]);
        SET_IF_NOT_NULL(arrive_end_time, obj[@"arrive_end_time"]);
        
        NSString* payment_method;
        SET_IF_NOT_NULL(payment_method, obj[@"payment_method"]);
        NSString* payment_code;
        SET_IF_NOT_NULL(payment_code, obj[@"payment_code"]);
        
        NSString* dTime = @"";
        
        if (arrive_start_time.length>16 && arrive_end_time.length>0)
            dTime = [NSString stringWithFormat:@"%@-%@",[arrive_start_time substringToIndex:16],[[arrive_end_time substringFromIndex:11] substringToIndex:5]];
        
        offsetY+=25;
        UILabel *dtimeLable = MOCreateLabelAutoRTL();
        dtimeLable.frame = CGRectMake(offsetX,offsetY, [GDPublicManager instance].screenWidth-10, 25);
        dtimeLable.backgroundColor = [UIColor clearColor];
        dtimeLable.font = MOLightFont(13);
        dtimeLable.textColor = MOColor66Color();
        dtimeLable.text = [NSString stringWithFormat:NSLocalizedString(@"Delivery Arrival: %@", @"送达时间: %@"),dTime];
        [cell.contentView addSubview:dtimeLable];
        
        offsetY+=25;
        UILabel *pmLable = MOCreateLabelAutoRTL();
        pmLable.frame = CGRectMake(offsetX,offsetY, [GDPublicManager instance].screenWidth-10, 25);
        pmLable.backgroundColor = [UIColor clearColor];
        pmLable.font = MOLightFont(13);
        pmLable.textColor = MOColor66Color();
        pmLable.text = [NSString stringWithFormat:NSLocalizedString(@"Payment Method: %@", @"支付方式: %@"),payment_method];
        [cell.contentView addSubview:pmLable];

        offsetY+=25;
        NSString* orderStatus = @"";
        SET_IF_NOT_NULL(orderStatus, obj[@"order_status_id"]);
        
        UILabel *statusLable = MOCreateLabelAutoRTL();
        statusLable.frame = CGRectMake(offsetX,offsetY, [GDPublicManager instance].screenWidth-10, 25);
        statusLable.backgroundColor = [UIColor clearColor];
        statusLable.font = MOLightFont(13);
        statusLable.textColor = MOColor66Color();
        [cell.contentView addSubview:statusLable];
        
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
        else if ([orderStatus isEqualToString:@"6"])
        {
            statusLable.text = [NSString stringWithFormat:@"%@ %@",
                                NSLocalizedString(@"Order Status:", @"订单状态:"),NSLocalizedString(@"Canceled", @"已取消")];
            
            statusLable.textColor = [UIColor magentaColor];
        }
        else
        {
            statusLable.text = [NSString stringWithFormat:@"%@ %@",
                                NSLocalizedString(@"Order Status:", @"订单状态:"),NSLocalizedString(@"Declined", @"已拒绝")];
            
            statusLable.textColor = [UIColor blueColor];
        }
        
        return cell;
    }
    else
    {
        UITableViewCell *cell ;
        static NSString *ID = @"totalcell";
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        float total =0;
        if(obj[@"bill"]!= [NSNull null] && obj[@"bill"]!= nil)
        {
            total = [obj[@"bill"][@"total"][@"value"] floatValue];
        }
        
        UILabel* totalLable =  MOCreateLabelAutoRTL();
        totalLable.font = MOLightFont(14);
        totalLable.frame = CGRectMake(10, 0, 150, 44);
        totalLable.backgroundColor =  [UIColor clearColor];
        totalLable.textColor = MOColor33Color();
        totalLable.text =  [NSString stringWithFormat:NSLocalizedString(@"Total: %@%.1f", @"总金额:%@%.1f"),[GDPublicManager instance].currency, total];
        [cell.contentView addSubview:totalLable];
        
        BOOL  can_cancel_order = NO;
        if(obj[@"can_cancel_order"]!= [NSNull null] && obj[@"can_cancel_order"]!= nil)
        {
            can_cancel_order = [obj[@"can_cancel_order"] boolValue];
        }
        
        NSString* orderStatus = @"";
        SET_IF_NOT_NULL(orderStatus, obj[@"order_status_id"]);
        
        NSString* payment_code;
        SET_IF_NOT_NULL(payment_code, obj[@"payment_code"]);
       
        if (can_cancel_order  && [payment_code isEqualToString:kCashPay])
        {
            ACPButton* _actionBut = [ACPButton buttonWithType:UIButtonTypeCustom];
            [_actionBut setLabelTextColor:[UIColor whiteColor] highlightedColor:[UIColor whiteColor] disableColor:nil];
            [_actionBut setLabelFont:MOLightFont(14)];
            [_actionBut setCornerRadius:1];
            [cell.contentView addSubview:_actionBut];
            [_actionBut setStyleRedButton];
            [_actionBut setTitle:NSLocalizedString(@"Cancel", @"取消") forState:UIControlStateNormal];
            [_actionBut addTarget:self action:@selector(tapCancel:) forControlEvents:UIControlEventTouchUpInside];
            _actionBut.tag = indexPath.section;
            [cell.contentView addSubview:_actionBut];
            _actionBut.frame = CGRectMake([GDPublicManager instance].screenWidth-120, 4, 110, 36);
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
    return 2;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            return 140;
        }
        case 1:
            return 44;
        default:
            break;
    }
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* obj = [orderData objectAtIndex:indexPath.section];
    
    GDReservationDeliveryOrderDetailsViewController* nv = [[GDReservationDeliveryOrderDetailsViewController alloc] init:obj];
    [self.navigationController pushViewController:nv animated:YES];
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
