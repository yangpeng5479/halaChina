//
//  GDCollectionViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/3.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDCollectionViewController.h"

#import "RDVTabBarController.h"

#import "GDProductDetailsViewController.h"
#import "GDProductListCell.h"

@interface GDCollectionViewController ()

@end

@implementation GDCollectionViewController

- (id)init:(int)cid  withTitle:(NSString*)sTitle
{
    self = [super init];
    if (self)
    {
        productData = [[NSMutableArray alloc] init];
        collection_id = cid;
        seekPage = 1;
        lastCountFromServer = 0;
        
        self.title = sTitle;
    }
    return self;
}

- (void)getProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    reloading = YES;
    
    NSString* url;
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/product/get_product_list_of_collection"];
    
    NSDictionary* parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"page":@(seekPage),@"limit":@(prePageNumber),@"collection_id":@(collection_id)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [ProgressHUD dismiss];
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             if (seekPage == 1)
             {
                 @synchronized(productData)
                 {
                     [productData removeAllObjects];
                 }
             }
             
             NSArray* temp = responseObject[@"data"][@"product_list"];
             
             lastCountFromServer = (int)temp.count;
             
             if (temp.count>0)
             {
                 [productData addObjectsFromArray:temp];
             }
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             [ProgressHUD showError:errorInfo];
         }
         
         netWorkError = NO;
         [self stopLoad];
         [self reLoadView];
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         netWorkError = YES;
         [self stopLoad];
         [self reLoadView];
         [ProgressHUD showError:error.localizedDescription];
     }];
}

- (void)refreshData
{
    LOG(@"refresh data");
    
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
}

#pragma mark UIView

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
        [self  getProductData];
        isLoadData = YES;
    }
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect r = self.view.bounds;
    float h = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    r.size.height-=h;
    
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    [self.view addSubview:mainTableView];
    mainTableView.backgroundColor = MOColorAppBackgroundColor();
    
    MODebugLayer(mainTableView, 1.f, [UIColor redColor].CGColor);
    
    [self addRefreshUI];
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"guessCell";
    
    GDProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GDProductListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* product = [productData objectAtIndex:indexPath.row];
    
    NSString*  imgUrl=@"";
    NSString*  productname=@"";
    NSString*  originprice=@"0";
    NSString*  saleprice=@"0";
    NSString*  setsale=@"0";
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return productData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 224;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* product = [productData objectAtIndex:indexPath.row];
    if (product!=nil)
    {
        int productId = [product[@"product_id"] intValue];
        NSString* type=@"";
        SET_IF_NOT_NULL(type, product[@"type"]);
        
        UIViewController *viewController = [[GDProductDetailsViewController alloc] init:productId withOrder:YES];
        [self.navigationController pushViewController:viewController animated:YES];
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
