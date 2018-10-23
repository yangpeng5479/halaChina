//
//  GDMarketSearchViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/25.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDMarketSearchViewController.h"
#import "RDVTabBarController.h"
#import "GDProductListCell.h"

#import "GDProductDetailsViewController.h"

@interface GDMarketSearchViewController ()

@end

@implementation GDMarketSearchViewController

- (id)init:(int)vendor_id
{
    self = [super init];
    if (self)
    {
        productList = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
        
        vendorId = vendor_id;
        searchStr = @"";
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    insearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20.0, 4.0, 200.0, 34.0)];
    insearchBar.delegate = self;
    insearchBar.placeholder =  NSLocalizedString(@"Search Product", @"搜索产品");
    insearchBar.showsCancelButton=YES;
    self.navigationItem.titleView = insearchBar;
    
    [insearchBar becomeFirstResponder];
    
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

#pragma mark - Data

- (void)searchProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"search/search_product"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"page":@(seekPage),@"limit":@(prePageNumber),@"type":@"market",@"keyword":searchStr,@"vendor_id":@(vendorId)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (seekPage == 1)
         {
             @synchronized(productList)
             {
                 [productList removeAllObjects];
             }
         }
         
         lastCountFromServer = [responseObject[@"data"][@"count"] intValue];
         if (lastCountFromServer>0)
         {
             [productList addObjectsFromArray:responseObject[@"data"][@"list"]];
         }
         
         isLoadData = YES;
         [self stopLoad];
         
         [self performSelectorOnMainThread:@selector(reLoadView) withObject:nil waitUntilDone:NO];
         [ProgressHUD dismiss];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self stopLoad];
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

#pragma mark - search bar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    LOG(@"%@",searchBar.text);
    searchStr = searchBar.text;
    [insearchBar resignFirstResponder];
    
    if (searchStr.length>0)
    {
        seekPage   = 1;
        isLoadData = NO;
        reloading = YES;
        [self searchProductData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [insearchBar resignFirstResponder];
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
    static NSString *CellIdentifier = @"listCell";
    
    GDProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GDProductListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary   *product = [productList objectAtIndex:indexPath.row];
    
    NSString*  imgUrl=@"";
    NSString*  proname=@"";
    NSString*  originprice=@"0";
    NSString*  saleprice=@"0";
    int        rating=0;
    int        quantity=0;
    NSString*  meta_description=@"";
    
    SET_IF_NOT_NULL(imgUrl, product[@"image"]);
    SET_IF_NOT_NULL(proname, product[@"name"]);
    SET_IF_NOT_NULL(originprice, product[@"price"]);
    SET_IF_NOT_NULL(meta_description, product[@"meta_description"]);
    int viewed = [product [@"viewed"] intValue];
    
    if(product[@"special_price_info"] != [NSNull null] && product[@"special_price_info"] != nil)
    {
        SET_IF_NOT_NULL(saleprice, product[@"special_price_info"][@"price"]);
    }
    else
    {
        saleprice = originprice;
    }
    
    rating =   [product[@"rating"] intValue];
    quantity = [product[@"quantity"] intValue];
    
    float  oprice = [originprice floatValue];
    float  sprice = [saleprice floatValue];
    
    NSString* opricestr = [NSString stringWithFormat:@"%@%.1f",[GDPublicManager instance].currency, oprice];
    NSString* spricestr = [NSString stringWithFormat:@"%@%.1f",[GDPublicManager instance].currency, sprice];
    
    [cell.productImage sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                         placeholderImage:[UIImage imageNamed:@"live_product_default.png"]];
    
    cell.titleLabel.text = proname;
    
    cell.originPrice.text = opricestr;
    cell.salePrice.text   = spricestr;
    
    cell.detailLabel.text = meta_description;
    
    cell.viewed.text = [NSString stringWithFormat:NSLocalizedString(@"Viewed: %d", @"查看: %d"),viewed];
    cell.rateView.hidden = YES;
    
    if (sprice!=oprice)
        cell.discount.text = [NSString stringWithFormat:@"%d%% OFF",(int)(100-sprice*1.0/oprice*100)];
    else
        cell.discount.text = @"";

    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!reloading && !productList.count)
    {
        [mainTableView insertSubview:[self noDataView] atIndex:0];
          
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    
    if (productList.count>0)
    {
        [_noDataView removeFromSuperview];
        
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    
    return productList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    NSDictionary* obj = [productList objectAtIndex:indexPath.row];
//    NSString*  title_name = obj[@"title"];
//    
//    UIFont* titleFont =   [UIFont systemFontOfSize:titleFontSize];
//    CGSize titleSize = [title_name moSizeWithFont:titleFont withWidth:titleWidth];
//    
//    int line = titleSize.height/titleHeight+1;
//    
//    float height = photoHeigth + kMargin * 2;
//    if (line > 2)
//        return height+(line-2)*titleHeight;
    
    return 90*[GDPublicManager instance].screenScale;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary   *product = [productList objectAtIndex:indexPath.row];
    int productId = [product[@"product_id"] intValue];
    NSString* type=@"";
    SET_IF_NOT_NULL(type, product[@"type"]);
    
    GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:productId withtype:type];
    [self.navigationController pushViewController:viewController animated:YES];

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
