//
//  GDDeliveryOrderListViewController.m
//  Greadeal
//
//  Created by Elsa on 16/2/21.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDDeliveryOrderListViewController.h"
#import "RDVTabBarController.h"
#import "GDDeliveryOrderCell.h"

#import "GDDeliverViewController.h"
#import "GDDeliveryOrderDetailsViewController.h"

#import "GDLiveVendorViewController.h"
#import "GDRatingViewController.h"


@interface GDDeliveryOrderListViewController ()

@end

@implementation GDDeliveryOrderListViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        isLoadData = NO;
        
        orderData = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
        
        order_id=@"";
        
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
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;;
        }
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        UILabel *timeLable = MOCreateLabelAutoRTL();
        timeLable.frame = CGRectMake(12,0, [GDPublicManager instance].screenWidth-24, 30);
        timeLable.backgroundColor = [UIColor clearColor];
        timeLable.font = MOLightFont(14);
        timeLable.textColor = MOColor33Color();
        timeLable.text = [NSString stringWithFormat:NSLocalizedString(@"Order Time: %@", @"下单时间: %@"),obj[@"date_added"]];
        [cell.contentView addSubview:timeLable];
        
        NSString* orderStatus = @"";
        SET_IF_NOT_NULL(orderStatus, obj[@"order_status_id"]);
        
        UILabel *statusLable = MOCreateLabelAutoRTL();
        statusLable.frame = CGRectMake(12,30, [GDPublicManager instance].screenWidth-24, 30);
        statusLable.backgroundColor = [UIColor clearColor];
        statusLable.font = MOLightFont(14);
        statusLable.textColor = MOColor33Color();
        [cell.contentView addSubview:statusLable];
        
        if ([orderStatus isEqualToString:@"1"])
        {
            statusLable.text = [NSString stringWithFormat:@"%@ %@",
                                NSLocalizedString(@"Order Status:", @"订单状态:"),NSLocalizedString(@"Waiting for confirmation", @"等待商家确认")];
            
            statusLable.textColor = [UIColor magentaColor];
        }
        else if ([orderStatus isEqualToString:@"2"])
        {
            statusLable.text = [NSString stringWithFormat:@"%@ %@",
                                NSLocalizedString(@"Order Status:", @"订单状态:"),NSLocalizedString(@"Accepted", @"已接受")];
            
            statusLable.textColor = [UIColor redColor];
        }
        else
        {
            statusLable.text = [NSString stringWithFormat:@"%@ %@",
                                NSLocalizedString(@"Order Status:", @"订单状态:"),NSLocalizedString(@"Declined", @"已拒绝")];
            
            statusLable.textColor = [UIColor blueColor];
        }
        
        return cell;
    }
    else if (indexPath.row == 1)
    {
        static NSString *CellIdentifier = @"items";
        
        GDDeliveryOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GDDeliveryOrderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSArray* temp = obj[@"product_list"];
        if (temp!=nil && temp.count>0)
        {
            NSDictionary *product;
         
            product = [temp objectAtIndex:0];
            
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
            return 60;
        }
        case 1:
            return 90;
        default:
            break;
    }
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* obj = [orderData objectAtIndex:indexPath.section];
    
    GDDeliveryOrderDetailsViewController* nv = [[GDDeliveryOrderDetailsViewController alloc] init:obj];
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
