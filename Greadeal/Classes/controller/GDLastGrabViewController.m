//
//  UILastGrabViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/11.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDLastGrabViewController.h"
#import "GDSaleNewCell.h"

#import "TMQuiltView.h"
#import "GDSaleProductListViewController.h"

#define bannerHeight            100

@interface GDLastGrabViewController ()

@end

@implementation GDLastGrabViewController

- (id)init:(BOOL)haveRefreshView withBanner:(BOOL)haveBanner
{
    self = [super init:haveRefreshView];
    if (self)
    {
        productData = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
        
        needBanner =  haveBanner;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    reloading = YES;
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"sale/get_before_end_activity_list"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"page":@(seekPage),@"limit":@(prePageNumber)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"%d getProductList: JSON: %@",seekPage,responseObject);
         
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
             [productData addObjectsFromArray:temp];
             
             lastCountFromServer = (int)temp.count;
             
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             [ProgressHUD showError:errorInfo];
         }
         netWorkError = NO;
         [ProgressHUD dismiss];
         
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

#pragma mark UIView
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!isLoadData)
    {
        [self  getProductData];
        isLoadData = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect r = self.view.frame;
    [self  loadMainView:r];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - QuiltViewControllerDataSource

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    
    if (!reloading && !productData.count)
    {
        if (netWorkError)
            [self.quiltView insertSubview:[self noNetworkView] atIndex:0];
        else
            [self.quiltView insertSubview:[self noDataView] atIndex:0];
    }
    
    if (productData.count>0)
    {
        [_noNetworkView removeFromSuperview];
        [_noDataView removeFromSuperview];
    }

    
    return [productData count];
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* obj = [productData objectAtIndex:indexPath.row];
    
    NSString*  imgUrl =     @"";
    NSString*  title_name = @"";
    NSString*  meta_title = @"";
    NSString*  time = @"";
    NSString*  countTime = @"";
    
    SET_IF_NOT_NULL( imgUrl , obj[@"desc_image"]);
    SET_IF_NOT_NULL( title_name , obj[@"name"]);
    SET_IF_NOT_NULL( meta_title , obj[@"meta_title"]);
    SET_IF_NOT_NULL( time , obj[@"date_end"]);
    
    if (time.length>0)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date_end = [formatter dateFromString:time];
        //LOG(@"%@",date_end);
        
        NSTimeInterval intervalTime = [date_end timeIntervalSinceNow];
        
        long lTime = (long)intervalTime;
        NSInteger iHours = (lTime / 3600);
        //NSInteger iDays = lTime/60/60/24+1;
        
//        if (iHours>1)
//            countTime = [NSString stringWithFormat:NSLocalizedString(@"%ldhr left", @"剩%ld小时"),iHours];
//        else
            countTime = [NSString stringWithFormat:NSLocalizedString(@"%ldhr left", @"剩%ld小时"),iHours];
    }
    
    GDSaleNewCell *cell = (GDSaleNewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"WaterCell"];
    if (!cell) {
        cell = [[GDSaleNewCell alloc] initWithReuseIdentifier:@"WaterCell"];
    }
    
    
    [cell.photoView sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                      placeholderImage:[UIImage imageNamed:@"activity_default.png"]];
    
    cell.titleLabel.text = title_name;
    cell.saleLabel.text = meta_title;
    cell.countLabel.text = countTime;
    
    return cell;

}

#pragma mark - TMQuiltViewDelegate

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    LOG(@"did select %ld",(long)indexPath.row);
    NSDictionary* dict = [productData objectAtIndex:indexPath.row];
    
    int proId = 0;
    proId = [dict[@"category_id"] intValue];
    NSString* endtime = @"";
    SET_IF_NOT_NULL(endtime, dict[@"date_end"]);
    if (proId>0)
    {
        GDSaleProductListViewController *viewController = [[GDSaleProductListViewController alloc] init:YES withId:proId];
        viewController.endTime = endtime;
        SET_IF_NOT_NULL( viewController.title , dict[@"name"]);
        [_superNav pushViewController:viewController animated:YES];
    }
}

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView
{
    return 1;
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return 185;
}

@end
