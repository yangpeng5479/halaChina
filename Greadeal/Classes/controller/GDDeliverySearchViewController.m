//
//  GDDeliverySearchViewController.m
//  Greadeal
//
//  Created by Elsa on 16/5/5.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDDeliverySearchViewController.h"
#import "RDVTabBarController.h"

#import "GDLiveVendorListCell.h"
#import "GDLiveVendorViewController.h"

#import "GDLiveProductListCell.h"
#import "GDProductDetailsViewController.h"

#import "GDLiveProductListCell.h"
#import "GDDeliverListCell.h"
#import "GDDeliveryVendorViewController.h"

@interface GDDeliverySearchViewController ()

@end

@implementation GDDeliverySearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    insearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20.0, 4.0, 200.0, 34.0)];
    insearchBar.delegate = self;
    insearchBar.placeholder =  NSLocalizedString(@"Search by restaurant or a dish", @"搜索餐厅或者菜品");
    insearchBar.showsCancelButton=YES;
    self.navigationItem.titleView = insearchBar;
    [insearchBar becomeFirstResponder];
    
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.hidesWhenStopped = YES;
    activityIndicatorView.frame = CGRectMake([GDPublicManager instance].screenWidth-175, 10, 25,25);
    [insearchBar addSubview:activityIndicatorView];
    
    products    = [[NSMutableArray alloc] init];
    searchIndex = [[NSMutableArray alloc] init];
    searchStr = @"";
    
    isloadSearch = NO;
    
    seekPage = 1;
    lastCountFromServer = 0;
    
    CGRect r = self.view.bounds;
    
    mainTableView = MOCreateTableView( r , UITableViewStylePlain, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    [self addRefreshUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - search bar delegate

- (void) searchBarTextDidBeginEditing: (UISearchBar*) searchBar
{
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    isSearchActive = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    LOG(@"searchText=%@",searchText);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchIndexData) object:nil];
    
    if (searchText.length>0)
    {
        isSearchActive = YES;
        strIndex = searchText;
        [self performSelector:@selector(searchIndexData) withObject:nil afterDelay:1.0f];
    }
    else
    {
        isSearchActive = NO;
        [self reLoadView];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    LOG(@"%@",searchBar.text);
    searchStr = searchBar.text;
    
    [self startSearch];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [insearchBar resignFirstResponder];
}

#pragma mark - Data

- (void)startSearch
{
    [insearchBar resignFirstResponder];
    
    if (searchStr.length>0)
    {
        seekPage   = 1;
        isLoadData = NO;
        reloading = YES;
        [self searchProductData];
    }
}

- (void)searchIndexData
{
    if (!isloadSearch)
    {
        NSNumber* areaNumber = [GDSettingManager instance].userDeliveryInfo[@"selAreaId"];
        int areaId = [areaNumber intValue];
        if (areaId<0)
            return;
        
        isloadSearch = YES;
        [activityIndicatorView startAnimating];
        
        NSString* url;
        NSDictionary *parameters;
        
        url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/Search/associate"];
        parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"page":@(1),@"limit":@(7),@"keyword":strIndex,@"area_id":@(areaId)};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
        
        [manager POST:url
           parameters:parameters success:^(AFHTTPRequestOperation *operation, id    responseObject)
         {
             isloadSearch = NO;
             [activityIndicatorView stopAnimating];
             
             int status = [responseObject[@"status"] intValue];
             if (status==1)
             {
                 
                 @synchronized(searchIndex)
                 {
                     [searchIndex removeAllObjects];
                 }
                 
                 NSArray* temp = responseObject[@"data"][@"result"];
                 
                 if (temp.count>0)
                 {
                     [searchIndex addObjectsFromArray:temp];
                 }
                 
             }
             [self reLoadView];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             isloadSearch = NO;
             [activityIndicatorView stopAnimating];
         }];
    }
    
}

- (void)searchProductData
{
    NSNumber* areaNumber = [GDSettingManager instance].userDeliveryInfo[@"selAreaId"];
    int areaId = [areaNumber intValue];
    if (areaId<0)
        return;

    if (!isLoadData)
        [ProgressHUD show:nil];
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/Search/search_vendor_list_nearby"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"page":@(seekPage),@"limit":@(prePageNumber),@"word":searchStr,@"area_id":@(areaId),@"longitude":@([[GDSettingManager instance] getCityLongitude]),@"latitude":@([[GDSettingManager instance] getCityLatitude])};
    
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
                 @synchronized(products)
                 {
                     [products removeAllObjects];
                 }
             }
             
             NSArray* temp = responseObject[@"data"][@"vendor_list"];
             lastCountFromServer = (int)temp.count;
             
             if (temp.count>0)
             {
                 [products addObjectsFromArray:temp];
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
         
         isLoadData = YES;
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

#pragma mark Refresh
- (void)refreshData
{
    LOG(@"refresh data");
    
    if (searchStr.length>0)
    {
        seekPage   = 1;
        isLoadData = NO;
        reloading = YES;
        [self searchProductData];
    }
}

- (void)nextPage
{
    if (lastCountFromServer>=prePageNumber)
    {
        LOG(@"get next page");
        [self loadMoreView];
        seekPage++;
        
        [self searchProductData];
    }
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

- (void)viewWillDisappear:(BOOL)animated
{
    [ProgressHUD dismiss];
    [insearchBar resignFirstResponder];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (BOOL)checkStoreOpenTime:(NSString*)sTime withEtime:(NSString*)eTime
{
    NSDate * senddate=[NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH"];
    NSString * locationString=[dateformatter stringFromDate:senddate];
    int currentTime = [locationString intValue];
    
    int nStime = [sTime intValue];
    int nEtime = [eTime intValue];
    
    if (currentTime>=nStime && currentTime<=nEtime)
    {
        return YES;
    }
    else
        return NO;
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isSearchActive)
    {
        static NSString *CellIdentifier = @"associateCell";
        UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        NSString* product = [searchIndex objectAtIndex:indexPath.section];
        LOG(@"search=%@",product);
        
        cell.textLabel.font= MOLightFont(14);
        cell.textLabel.text= product;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    else
    {
    static NSString *CellIdentifier = @"guessCell";
    GDDeliverListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GDDeliverListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* product = [products objectAtIndex:indexPath.section];
    
    NSString*  imgUrl=@"";
    NSString*  delivery_fee=@"";
    NSString*  productname=@"";
    NSString*  min_order_fee=@"0";
    NSString*  delivery_time_min=@"0";
    NSString*  delivery_time_max=@"0";
    float      rating = [product[@"rating"] floatValue];
    
    SET_IF_NOT_NULL(imgUrl, product[@"vendor_image"]);
    SET_IF_NOT_NULL(delivery_fee, product[@"delivery_fee"]);
    SET_IF_NOT_NULL(productname, product[@"vendor_name"]);
    SET_IF_NOT_NULL(min_order_fee, product[@"min_order_fee"]);
    SET_IF_NOT_NULL(delivery_time_min, product[@"delivery_time_min"]);
    SET_IF_NOT_NULL(delivery_time_max, product[@"delivery_time_max"]);
    
    cell.vendorLabel.text = productname;
    if(product[@"distance"] != [NSNull null] && product[@"distance"] != nil)
        cell.nDist =  [product[@"distance"] intValue];
    
    cell.deliveryChargeLabel.text  = [NSString stringWithFormat:NSLocalizedString(@"Delivery Chagres: %@%d",@"配送费: %@%d"),[GDPublicManager instance].currency,[delivery_fee intValue]];
    [cell.deliveryChargeLabel findCurrency:10];
  
        
    cell.starRateView.scorePercent = rating*1.0/5;
    
    cell.minorderLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Min.Order: %@%@",@"起送价: %@%@"),[GDPublicManager instance].currency,min_order_fee];
    [cell.minorderLabel findCurrency:10];

    cell.deliverytimeLabel.text =  [NSString stringWithFormat:NSLocalizedString(@"%@Mins",@"%@分钟"),delivery_time_min];
    
    [cell.productImage sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                         placeholderImage:[UIImage imageNamed:@"live_product_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                         }];
    
    BOOL isopen = NO;
    NSArray* openTimeArray = nil;
    SET_IF_NOT_NULL(openTimeArray,product[@"open_time"]);
    if (openTimeArray.count>0)
    {
        NSDictionary* dict = [openTimeArray objectAtIndex:0];
        if (dict!=nil)
        {
            NSString* open_time_start = dict[@"open_time_start"];
            NSString* open_time_end = dict[@"open_time_end"];
            
            NSString* sTime = [NSString stringWithFormat:@"%@",[open_time_start substringToIndex:5]];
            NSString* eTime = [NSString stringWithFormat:@"%@",[open_time_end substringToIndex:5]];
            
            cell.openhoursLabel.text = [NSString stringWithFormat:@"%@ - %@",sTime,eTime];
            
            isopen = [self checkStoreOpenTime:sTime withEtime:eTime];
            if (isopen){
                cell.closeImage.image = [UIImage imageNamed:@"open_store.png"];
            }
            else
            {
                cell.closeImage.image = [UIImage imageNamed:@"close_store.png"];
            }
            
        }
        
    }
    
        NSString*  sale_off=@"0";
        SET_IF_NOT_NULL(sale_off, product[@"discount"]);
        
        int  n_sale_off = [sale_off intValue];
        if (n_sale_off>0)
        {
            cell.saleImage.hidden = NO;
            if (isopen){
                cell.saleImage.image = [UIImage imageNamed:@"list_sale_open.png"];
            }
            else
            {
                cell.saleImage.image = [UIImage imageNamed:@"list_sale_close.png"];
            }
            cell.saleLabel.text = [NSString stringWithFormat:@"%d%% OFF",n_sale_off];
        }
        else
        {
            cell.saleImage.hidden = YES;
        }

    return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isSearchActive)
    {
        [_noDataView removeFromSuperview];
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        
        return searchIndex.count;
    }
    else
    {
    if (!reloading && !products.count)
    {
        [mainTableView addSubview:[self noDataView]];
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    
    if (products.count>0)
    {
        [_noDataView removeFromSuperview];
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    
    return products.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSearchActive)
        return 40;
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (isSearchActive)
    {
        searchStr = [searchIndex objectAtIndex:indexPath.section];
        
        insearchBar.text = @"";
        
        [self startSearch];
    }
    else
    {
        isSearchActive = NO;

    NSDictionary* vendor = [products objectAtIndex:indexPath.section];
    if (vendor!=nil)
    {
        
        GDDeliveryVendorViewController *viewController = [[GDDeliveryVendorViewController alloc] init:vendor];
        [self.navigationController pushViewController:viewController animated:YES];
        }
    }
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
