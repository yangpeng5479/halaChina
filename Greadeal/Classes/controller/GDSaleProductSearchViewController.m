//
//  GDSaleProductSearchViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/15.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDSaleProductSearchViewController.h"
#import "RDVTabBarController.h"

#import "TMQuiltView.h"

#import "GDSaleProductListCell.h"
#import "GDProductDetailsViewController.h"

@interface GDSaleProductSearchViewController ()

@end

@implementation GDSaleProductSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    insearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20.0, 4.0, 200.0, 34.0)];
    insearchBar.delegate = self;
    insearchBar.placeholder =  NSLocalizedString(@"Search Sale Product", @"搜索特卖产品");
    insearchBar.showsCancelButton=YES;
    self.navigationItem.titleView = insearchBar;
    
    [insearchBar becomeFirstResponder];
    
    productData = [[NSMutableArray alloc] init];
    searchStr = @"";
    
    seekPage = 1;
    lastCountFromServer = 0;
    
    reloading = YES;
    CGRect r = self.view.frame;
    [self  loadMainView:r];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    self.quiltView.backgroundColor = MOColorSaleProductBackgroundColor();
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [ProgressHUD dismiss];
    [insearchBar resignFirstResponder];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}


- (void)searchProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"search/search_product"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"page":@(seekPage),@"limit":@(prePageNumber),@"type":@"sale",@"keyword":searchStr};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (seekPage == 1)
         {
             @synchronized(productData)
             {
                 [productData removeAllObjects];
             }
         }
         
         lastCountFromServer = [responseObject[@"data"][@"count"] intValue];
         if (lastCountFromServer>0)
         {
             [productData addObjectsFromArray:responseObject[@"data"][@"list"]];
         }
         [self stopLoad];
         [self reLoadView];
         [ProgressHUD dismiss];
         isLoadData = YES;
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self stopLoad];
         [ProgressHUD showError:error.localizedDescription];
     }];
}


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

- (void)stopLoad
{
    if (reloading)
    {
        //stop refrsh
        reloading = NO;
        [refreshHeaderView  flipImageAnimated:NO];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        [self.quiltView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [UIView commitAnimations];
        [refreshHeaderView setStatus:kMOPullToReloadStatus];
        [refreshHeaderView toggleActivityView:NO];
        [refreshHeaderView setLastUpdatedDate:[NSDate date]];
    }
    
    //stop next page
    [getMoreview setUserInteractionEnabled:YES];
    [indicator stopAnimating];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [self.quiltView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [UIView commitAnimations];
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

#pragma mark - QuiltViewControllerDataSource

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    if (!reloading && !productData.count)
    {
        [self.quiltView insertSubview:[self noDataView] atIndex:0];
    }
    
    if (productData.count>0)
    {
        [_noDataView removeFromSuperview];
    }
    
    return [productData count];
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath
{
    GDSaleProductListCell *cell = (GDSaleProductListCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"WaterCell"];
    if (!cell) {
        cell = [[GDSaleProductListCell alloc] initWithReuseIdentifier:@"WaterCell"];
    }
    
    NSDictionary   *product = [productData objectAtIndex:indexPath.row];
    
    NSString*  imgUrl=@"";
    NSString*  proname=@"";
    NSString*  originprice=@"0";
    NSString*  saleprice=@"0";
    int        rating=0;
    int        quantity=0;
    
    SET_IF_NOT_NULL(imgUrl, product[@"image"]);
    SET_IF_NOT_NULL(proname, product[@"name"]);
    SET_IF_NOT_NULL(originprice, product[@"price"]);
    
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
    
    int  oprice = [originprice floatValue];
    int  sprice = [saleprice floatValue];
    
    NSString* opricestr = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, oprice];
    NSString* spricestr = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, sprice];
    
    
    if ([imgUrl isKindOfClass:[NSString class]])
        [cell.photoView sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                          placeholderImage:[UIImage imageNamed:@"category_product_default.png"]];
    
    
    cell.titleLabel.text = proname;
    
    cell.salePrice.text = spricestr;
    
    cell.originPrice.text = opricestr;
    
    cell.discount.text = [NSString stringWithFormat:@"%d%% OFF",(int)(100-sprice*1.0/oprice*100)];
    
    [cell adjustFont];
    
    return cell;
}

#pragma mark - TMQuiltViewDelegate

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    LOG(@"did select %ld",(long)indexPath.row);
    NSDictionary   *product = [productData objectAtIndex:indexPath.row];
    
    int productId = [product[@"product_id"] intValue];
    NSString* type=@"";
    SET_IF_NOT_NULL(type, product[@"type"]);
    
    GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:productId withtype:type];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView
{
    return 2;
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return 260*[GDPublicManager instance].screenScale;
}


@end
