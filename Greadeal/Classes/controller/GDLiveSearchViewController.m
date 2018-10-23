//
//  GDLiveSearchViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/25.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDLiveSearchViewController.h"
#import "RDVTabBarController.h"

#import "GDLiveVendorListCell.h"
#import "GDLiveVendorViewController.h"

#import "GDLiveProductListCell.h"
#import "GDProductDetailsViewController.h"

#import "GDProductListCell.h"

@interface GDLiveSearchViewController ()

@end

@implementation GDLiveSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    insearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 4.0, 200.0, 34.0)];
    insearchBar.delegate = self;
    insearchBar.placeholder =  NSLocalizedString(@"Search by stores or offers", @"搜索商店或产品");
    insearchBar.showsCancelButton=YES;
    self.navigationItem.titleView = insearchBar;
    insearchBar.tintColor=[UIColor blueColor];
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
    
    mainTableView = MOCreateTableView(r, UITableViewStyleGrouped, [UITableView class]);
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
        isloadSearch = YES;
        [activityIndicatorView startAnimating];
        
        NSString* url;
        NSDictionary *parameters;
        
        url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Search/associate_product"];
        parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"page":@(1),@"limit":@(7),@"keyword":strIndex,@"country_id":@([GDSettingManager instance].currentCountryId)};
        
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
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Search/search_product"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"page":@(seekPage),@"limit":@(prePageNumber),@"keyword":searchStr,@"country_id":@([GDSettingManager instance].currentCountryId),@"longitude":@([[GDSettingManager instance] getCityLongitude]),@"latitude":@([[GDSettingManager instance] getCityLatitude])};
    
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
             
             NSArray* temp = responseObject[@"data"][@"result"][@"list"];
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
        NSDictionary* product = [products objectAtIndex:indexPath.section];
    
        static NSString *CellIdentifier = @"listCell";
        
        GDProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
             cell = [[GDProductListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        NSString*  imgUrl=@"";
        NSString*  productname=@"";
        NSString*  originprice=@"0"; //商家原价
        NSString*  saleprice=@"0";   //平台销售价
        NSString*  setsale=@"0";     //商家优惠价
        
        SET_IF_NOT_NULL(imgUrl, product[@"image"]);
        SET_IF_NOT_NULL(productname, product[@"name"]);
        SET_IF_NOT_NULL(originprice, product[@"original_price"]);
        SET_IF_NOT_NULL(saleprice, product[@"price"]);
        SET_IF_NOT_NULL(setsale, product[@"set_price"]);
        
        [cell.productImage sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                                 placeholderImage:[UIImage imageNamed:@"live_product_default.png"]];
            
            
        cell.vendorLabel.text = product[@"vendor_info"][@"vendor_name"];
            
        int  oprice   = [originprice intValue];
        int  sprice   = [saleprice intValue];
        int  setprice = [setsale intValue];
            
        NSString* opricestr = [NSString stringWithFormat:@"%d", oprice];
        NSString* spricestr = [NSString stringWithFormat:@"%d", sprice];
            
        cell.membership_level = [product[@"vendor_info"][@"membership_level"] intValue];
            
        if (cell.membership_level!=needPayType)
            [[GDSettingManager instance] setTitleAttr:cell.productLabel withTitle:productname withSale:setprice withOrigin:oprice];
        else
            [[GDSettingManager instance] setTitleAttr:cell.productLabel withTitle:productname withSale:0 withOrigin:0];
            
        cell.originLabel.text = opricestr;
        cell.saleLabel.text = spricestr;
        
        
        cell.cityLabel.text = product[@"vendor_info"][@"zone_name"];
            
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
    else
        return 224;
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
        
    NSDictionary* product = [products objectAtIndex:indexPath.section];
    
    if (product!=nil)
    {
        int productId = [product[@"product_id"] intValue];
        NSString* type=@"";
        SET_IF_NOT_NULL(type, product[@"type"]);
        
        GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:productId withOrder:YES];
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
