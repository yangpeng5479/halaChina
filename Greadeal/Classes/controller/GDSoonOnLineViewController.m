//
//  UISoonOnLineViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/11.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDSoonOnLineViewController.h"

#import "GDSaleNewCell.h"

#import "TMQuiltView.h"
#import "GDProductDetailsViewController.h"

#define bannerHeight           100
#define titleHeight            30

@interface GDSoonOnLineViewController ()

@end

@implementation GDSoonOnLineViewController

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
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"sale/get_to_start_activity_list"];
    //parameters = @{@"page":@(seekPage),@"limit":@(prePageNumber)};
    
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
             
             if(responseObject[@"data"][@"list"] != [NSNull null] && responseObject[@"data"][@"list"] != nil)
             {
                 NSArray* temp = responseObject[@"data"][@"list"];
                 
                 [productData addObjectsFromArray:temp];
                 
                 lastCountFromServer = (int)temp.count;
                 
             }
           
             SET_IF_NOT_NULL( titleLabel.text , responseObject[@"data"][@"to_start_activity_info"]);
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
        
        CGRect r = self.view.bounds;
        titleLabel = MOCreateLabelAutoRTL();
        titleLabel.frame=CGRectMake(r.origin.x,r.origin.y, r.size.width, titleHeight);
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        UIImageView* backgroundView = [[UIImageView alloc] init];
        backgroundView.image = [[UIImage imageNamed:@"productLline.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        backgroundView.frame= CGRectMake(r.origin.x, titleHeight-0.5,
                                              r.size.width, 0.5);
        
        
        [self.quiltView addSubview:titleLabel];
        [self.quiltView addSubview:backgroundView];
        [self.quiltView setHeaderViewHeight:titleHeight];
        
        self.quiltView.backgroundColor = MOColorAppBackgroundColor();
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
    GDSaleNewCell *cell = (GDSaleNewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"WaterCell"];
    if (!cell) {
        cell = [[GDSaleNewCell alloc] initWithReuseIdentifier:@"WaterCell"];
    }
    
    NSDictionary* obj = [productData objectAtIndex:indexPath.row];
    NSString*  imgUrl =     @"";
    NSString*  title_name = @"";
    NSString*  meta_title = @"";
    NSString*  time = @"";
    
    SET_IF_NOT_NULL( imgUrl , obj[@"desc_image"]);
    SET_IF_NOT_NULL( title_name , obj[@"name"]);
    SET_IF_NOT_NULL( meta_title , obj[@"meta_title"]);
    SET_IF_NOT_NULL( time , obj[@"date_end"]);
    
    if (time.length>0)
    {
        NSRange findrange = [time rangeOfString:@" "];
        if (findrange.location != NSNotFound)
        {
            cell.countLabel.text = [time substringToIndex:findrange.location];
        }
       
    }
    [cell.photoView sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                      placeholderImage:[UIImage imageNamed:@"activity_default.png"]];
    
    cell.titleLabel.text = title_name;
    cell.saleLabel.text = meta_title;
     return cell;
}

#pragma mark - TMQuiltViewDelegate

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    LOG(@"did select %ld",(long)indexPath.row);
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
