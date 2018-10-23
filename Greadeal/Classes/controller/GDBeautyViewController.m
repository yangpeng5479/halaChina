//
//  GDBeautyViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/28.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBeautyViewController.h"
#import "GDProductDetailsViewController.h"
#import "GDSaleProductListCell.h"
#import "TMQuiltView.h"
#import "RDVTabBarController.h"

@interface GDBeautyViewController ()

@end

@implementation GDBeautyViewController

- (id)init
{
    self = [super init:YES];
    if (self)
    {
        productData = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
    }
    return self;
}

-(void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect r = self.view.bounds;
    [self  loadMainView:r];
    self.quiltView.backgroundColor = MOColorSaleProductBackgroundColor();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data

- (void)getProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    reloading = YES;
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"sale/get_beauty_makeup_activity_list"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"page":@(seekPage),@"limit":@(prePageNumber)};
    
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
                 @synchronized(productData)
                 {
                     [productData removeAllObjects];
                 }
             }
             NSArray* temp = responseObject[@"data"];
             lastCountFromServer = (int)temp.count;
             [productData addObjectsFromArray:temp];
        
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
         [ProgressHUD dismiss];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         netWorkError = YES;
         [self stopLoad];
         [self reLoadView];
         [ProgressHUD showError:error.localizedDescription];

     }];
}


#pragma mark UIView

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
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

#pragma mark - QuiltViewControllerDataSource

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    if (!reloading && !productData.count)
    {
        if (netWorkError)
            [self.quiltView insertSubview:[self noNetworkView] atIndex:0];
        else
            [self.quiltView insertSubview:[self noDataView] atIndex:0];
        
        self.quiltView.backgroundColor = MOColorAppBackgroundColor();
    }
    
    if (productData.count>0)
    {
        [_noNetworkView removeFromSuperview];
        [_noDataView removeFromSuperview];
        self.quiltView.backgroundColor = MOColorSaleProductBackgroundColor();
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
    
    int  oprice = [originprice intValue];
    int  sprice = [saleprice intValue];
    
    NSString* opricestr = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, oprice];
    
    NSString* spricestr = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, sprice];
  
    
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
    NSDictionary* obj = [productData objectAtIndex:indexPath.row];
    int proId = [obj[@"product_id"] intValue];
    NSString* type=@"";
    SET_IF_NOT_NULL(type, obj[@"type"]);
    
    UIViewController *viewController = [[GDProductDetailsViewController alloc] init:proId withtype:type];
    [_superNav pushViewController:viewController animated:YES];

}

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView
{
    return 2;
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return 260*[GDPublicManager instance].screenScale;
}

#pragma mark Refresh

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
@end
