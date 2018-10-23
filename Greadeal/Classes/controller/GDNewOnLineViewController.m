//
//  WCPageHomeViewController.m
//  JUMPSTAR
//
//  Created by tao tao on 3/4/15.
//  Copyright (c) 2015 tao tao. All rights reserved.
//

#import "GDNewOnLineViewController.h"
#import "GDSaleNewCell.h"

#import "TMQuiltView.h"
#import "GDSaleProductListViewController.h"
#import "GDProductDetailsViewController.h"

#define bannerHeight            180
#define titleHeight             35

@interface GDNewOnLineViewController ()

@end

@implementation GDNewOnLineViewController

- (id)init:(BOOL)haveRefreshView withBanner:(BOOL)haveBanner
{
    self = [super init:haveRefreshView];
    if (self)
    {
        bannerData  = [[NSMutableArray alloc] init];
        productData = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
      
        needBanner =  haveBanner;
    }
    return self;
}


#pragma mark Data
- (void)initPageTitle
{
  

}
- (void)setPageTitle:(NSString*)str
{
    CGRect r = self.view.frame;
    
    if (backTitle==nil)
    {
        backTitle = [[UIImageView alloc] initWithFrame:CGRectMake(r.origin.x, bannerHeight+titleHeight/2+2.5,
                                                                           r.size.width, 1)];
        backTitle.image = [[UIImage imageNamed:@"cutOff.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    }
    
    if (titleLabel == nil)
    {
        titleLabel = MOCreateLabelAutoRTL();
        titleLabel.frame=CGRectMake(r.origin.x, bannerHeight+10, r.size.width, 20);
        titleLabel.backgroundColor = MOColorAppBackgroundColor();
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    titleLabel.text = str;
    CGSize titleSize = [titleLabel.text moSizeWithFont:titleLabel.font withWidth:r.size.width];
    CGRect tr = titleLabel.frame;
    tr.origin.x = (r.size.width-titleSize.width)/2;
    tr.size.width = titleSize.width;
    titleLabel.frame = tr;
    
    [backTitle removeFromSuperview];
    [titleLabel removeFromSuperview];
    
    [self.quiltView addSubview:backTitle];
    [self.quiltView addSubview:titleLabel];
   
}

- (void)getBannerData
{
    if (needBanner)
    {
        reloading = YES;
        
        CGRect r = self.view.frame;
        
        NSString* url;
        NSDictionary *parameters;
        
        url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"sale/get_banner_list"];
        parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES])};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
        
        [manager POST:url
           parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             
             if (bannerView==nil)
             {
                 bannerView = [[JCTopic alloc]initWithFrame:CGRectMake(0, 0, r.size.width, bannerHeight) ];
                 bannerView.JCdelegate = self;
                 [self.quiltView addSubview:bannerView];
                 [self.quiltView setHeaderViewHeight:bannerHeight+titleHeight];
             }
             
             int status = [responseObject[@"status"] intValue];
             if (status==1)
             {
                 @synchronized(bannerData)
                 {
                     [bannerData removeAllObjects];
                 }
                 
                 if(responseObject[@"data"][@"banner_list"] != [NSNull null] && responseObject[@"data"][@"banner_list"] != nil)
                 {
                     [bannerData addObjectsFromArray:responseObject[@"data"][@"banner_list"]];
                     
                     NSMutableArray *pictureArrar = [[NSMutableArray alloc] init];
                     for (NSDictionary* dict in bannerData) {
                         NSString* image = @"";
                         SET_IF_NOT_NULL( image , dict[@"image"]);
                         [pictureArrar addObject:image];
                     }
                     
                     bannerView.pics = pictureArrar;
                     [bannerView upDate:@"sale_banner_default.png"];
                     
                     NSString* title = @"";
                     SET_IF_NOT_NULL( title , responseObject[@"data"][@"activity_info"]);
                     [self setPageTitle:title];
                     
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
}

- (void)getProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    reloading = YES;
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"sale/get_new_activity_list"];
    
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
    [self getBannerData];
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
        LOG(@"stop refrsh");
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
        [self  getBannerData];
    
        isLoadData = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect r = self.view.frame;
    [self  loadMainView:r];
    [self  initPageTitle];
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
    
    if (!reloading && !bannerData.count)
    {
        if (netWorkError)
            [self.quiltView insertSubview:[self noNetworkView] atIndex:0];
        else
            [self.quiltView insertSubview:[self noDataView] atIndex:0];
       
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getProductData)];
        [[self noNetworkView] addGestureRecognizer:tapGesture];
    }
    
    if (bannerData.count>0)
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
        //NSInteger iHours = (lTime / 3600);
        NSInteger iDays = lTime/60/60/24+1;
       
        if (iDays>1)
            countTime = [NSString stringWithFormat:NSLocalizedString(@"%ld days left", @"剩%ld天"),iDays];
        else
            countTime = [NSString stringWithFormat:NSLocalizedString(@"%ld day left", @"剩%ld天"),iDays];
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
    
    int category_id = 0;
    category_id = [dict[@"category_id"] intValue];
    NSString* endtime = @"";
    SET_IF_NOT_NULL(endtime, dict[@"date_end"]);
    if (category_id>0)
    {
        GDSaleProductListViewController *viewController = [[GDSaleProductListViewController alloc] init:YES withId:category_id];
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

#pragma mark bannerDelegate

-(void)didClick:(int)nIndex
{
    if (nIndex<bannerData.count) {
        NSDictionary* dict = [bannerData objectAtIndex:nIndex];
        if (dict!=nil)
        {
            NSString* type=@"";
            SET_IF_NOT_NULL(type, dict[@"type"]);
            int proId = [dict[@"id"] intValue];
            
            if ([type isEqualToString:@"product"])
            {
                GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:proId withtype:@"sale"];
                [_superNav pushViewController:viewController animated:YES];
            }
            else if ([type isEqualToString:@"category"])
            {
                NSString* endtime = @"";
                SET_IF_NOT_NULL(endtime, dict[@"date_end"]);
                GDSaleProductListViewController *viewController = [[GDSaleProductListViewController alloc] init:YES withId:proId];
                viewController.endTime = endtime;
                SET_IF_NOT_NULL(viewController.title, dict[@"title"]);
                [_superNav pushViewController:viewController animated:YES];

            }
        }
    }
}


@end
