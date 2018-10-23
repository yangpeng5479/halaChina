//
//  GDSaleFindVendorProductViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/25.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDSaleFindVendorProductViewController.h"
#import "GDSaleProductListCell.h"

#import "TMQuiltView.h"
#import "GDProductDetailsViewController.h"

#import "RDVTabBarController.h"

#define titleHeight   40

@interface GDSaleFindVendorProductViewController ()

@end

@implementation GDSaleFindVendorProductViewController

- (id)init:(BOOL)haveRefreshView withId:(int)vendor_id withName:(NSString*)vendor_name withUrl:(NSString*)vendor_url withImage:(NSString*)vendor_image
{
    self = [super init:haveRefreshView];
    if (self)
    {
        productData = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
        
        vendorId = vendor_id;
        vendorUrl =vendor_url;
        vendorName =vendor_name;
        vendorImage =vendor_image;
    }
    return self;
}

- (void)dealloc {
  
}
- (void)didReceiveMemoryWarning {
    
    // Dispose of any resources that can be recreated.
}

- (void)tapSort
{
    if (priceBut.tag==0)
    {
        priceBut.tag = 1;
        [priceBut setImage:[UIImage imageNamed:@"sort_desc.png"] forState:UIControlStateNormal];
    }
    else
    {
        priceBut.tag = 0;
        [priceBut setImage:[UIImage imageNamed:@"sort_asc.png"] forState:UIControlStateNormal];
    }
    isLoadData = NO;
    [self getProductData];
}

- (void)getProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    reloading = YES;
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"vendor/get_product_list_by_vendor_id"];
    
    NSString* sortChoose=@"asc";
    if (priceBut.tag==1)
        sortChoose=@"desc";
    
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"vendor_id":@(vendorId),@"page":@(seekPage),@"limit":@(prePageNumber),@"order_price":sortChoose};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"WCPageHomeViewController: getProductList: JSON: %@", responseObject);
         
         if (seekPage == 1)
         {
             @synchronized(productData)
             {
                 [productData removeAllObjects];
             }
         }
         NSArray* temp = responseObject[@"data"][@"vendor"][@"product_list"];
         lastCountFromServer = (int)temp.count;
         [productData addObjectsFromArray:temp];
         
         SET_IF_NOT_NULL(vendorName, responseObject[@"data"][@"vendor"][@"vendor_name"]);
         SET_IF_NOT_NULL(vendorUrl, responseObject[@"data"][@"vendor"][@"store_url"]);
         SET_IF_NOT_NULL(vendorImage, responseObject[@"data"][@"vendor"][@"vendor_image"]);
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
        
        CGRect r = self.view.bounds;
        
        priceBut = [UIButton buttonWithType:UIButtonTypeCustom];
        priceBut.frame = CGRectMake(20, 10, 10, 20);
        [priceBut addTarget:self action:@selector(tapSort) forControlEvents:UIControlEventTouchUpInside];
        priceBut.tag = 0; //0 asc 1 desc
        [priceBut setImage:[UIImage imageNamed:@"sort_asc.png"] forState:UIControlStateNormal];
        
        titleLabel = MOCreateLabelAutoRTL();
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.text = NSLocalizedString(@"Price",@"价格");
        CGSize  titleSize = [titleLabel.text moSizeWithFont:titleLabel.font withWidth:100];
        
        titleLabel.frame=CGRectMake(priceBut.frame.origin.x+priceBut.frame.size.width+5, 0, titleSize.width, titleHeight);
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];//colorFromHexString(@"666666");
        
        UIView* headView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, r.origin.y, r.size.width, titleHeight)];
        headView.backgroundColor = [UIColor whiteColor];
        headView.userInteractionEnabled = YES;
        [headView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSort)]];
        
        [headView addSubview:priceBut];
        [headView addSubview:titleLabel];
        

        [self.quiltView addSubview:headView];
        [self.quiltView setHeaderViewHeight:titleHeight];
        
    }
    self.quiltView.backgroundColor = MOColorSaleProductBackgroundColor();
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect r = self.view.frame;
    [self  loadMainView:r];
    
    UIBarButtonItem*  shareButItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share.png"] style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(shareAction)];
    
    self.navigationItem.rightBarButtonItem = shareButItem;
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


- (void)shareAction
{
    NSMutableArray *shareButtonTitleArray = [[NSMutableArray alloc] init];
    NSMutableArray *shareButtonImageNameArray = [[NSMutableArray alloc] init];
    
    [shareButtonTitleArray addObject:@"Facebook"];
    [shareButtonTitleArray addObject:@"Twitter"];
    [shareButtonTitleArray addObject:NSLocalizedString(@"Mail","邮件")];
    [shareButtonTitleArray addObject:NSLocalizedString(@"Qzone",@"QQ空间")];
    
    [shareButtonImageNameArray addObject:@"sns_icon_facebook"];
    [shareButtonImageNameArray addObject:@"sns_icon_twitter"];
    [shareButtonImageNameArray addObject:@"sns_icon_mail"];
    [shareButtonImageNameArray addObject:@"sns_share_qzone"];
    
    if ([[weixinAccountManage sharedInstance] isWXInstalled])
    {
        [shareButtonTitleArray addObject:NSLocalizedString(@"Wechat",@"微信好友")];
        [shareButtonTitleArray addObject:NSLocalizedString(@"Moments",@"朋友圈")];
        
        [shareButtonImageNameArray addObject:@"sns_icon_wechat"];
        [shareButtonImageNameArray addObject:@"sns_icon_moments"];
    }
    
    LXActivity *lxActivity = [[LXActivity alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonImageNameArray];
    [lxActivity showInView:self.view];
}


#pragma mark - MFMailComposeViewControllerDelegate method

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultSent:
        {
            [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
        }
        case MFMailComposeResultFailed:
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"错误")
                               message:NSLocalizedString(@"Failed to send Email.", @"发送邮件失败")
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      
                                  }
                              }];
            break;
        }
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LXActivityDelegate

- (void)didClickOnImageIndex:(NSInteger *)imageIndex
{
    NSString* text = [NSString stringWithFormat:NSLocalizedString(@"Quickly Go Shopping! Store: %@",@"赶紧去抢购! 商家 %@"),vendorName];
    NSURL*     url = [NSURL URLWithString:[vendorUrl encodeUTF]];
    
    __block UIImage* imageData = nil;
    
    if (vendorImage.length<=0) {
        vendorImage = DefaultSysImage;
    }
    
    [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:[vendorImage encodeUTF]]  options:SDWebImageLowPriority|SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        imageData = image;
    }];
    
    if (imageIndex==0) //facebook
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultDone)
            {
                [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
            }
            [controller dismissViewControllerAnimated:YES completion:nil];
        };
        controller.completionHandler =myBlock;
        
        [controller setInitialText:text];
        [controller addURL:url];
        [controller addImage:imageData];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    else if  ((int)imageIndex==1)
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultDone)
            {
                [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
            }
            [controller dismissViewControllerAnimated:YES completion:nil];
        };
        controller.completionHandler =myBlock;
        
        [controller setInitialText:text];
        [controller addURL:url];
        [controller addImage:imageData];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    else if  ((int)imageIndex==2)
    {
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
            
            mailComposeViewController.mailComposeDelegate = self;
            
            if (text.length>0 && !url)
                [mailComposeViewController setMessageBody:text isHTML:YES];
            
            if (text.length>0 && url)
                [mailComposeViewController setMessageBody:url.absoluteString isHTML:YES];
            
            if (text && url)
                [mailComposeViewController setMessageBody:[NSString stringWithFormat:@"%@ %@", text, url.absoluteString] isHTML:YES];
            
            if (imageData!=nil)
                [mailComposeViewController addAttachmentData:UIImageJPEGRepresentation(imageData, 1.0f) mimeType:@"image/jpeg" fileName:@"photo.jpg"];
            
            [mailComposeViewController setSubject:[NSString stringWithFormat:NSLocalizedString(@"Big Sale, Store: %@",@"大促销 商家 %@"),vendorName]];
            
            [self presentViewController:mailComposeViewController animated:YES completion:nil];
        }
        else
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Unable to send e-mail", @"不能发送邮件")
                               message:NSLocalizedString(@"Please configure your E-mail first in this phone.", @"您的手机没有配置发送邮件账号")
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      
                                  }
                              }];
            
        }
        
    }
    else if  ((int)imageIndex==3)
    {
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:text forKey:@"paramTitle"];
        
        if(vendorName .length>0)
        {
            [parameters setObject:vendorName forKey:@"paramSummary"];
        }
        else
        {
            [parameters setObject:@"Greadeal" forKey:@"paramSummary"];
        }
        
        if (vendorUrl.length>0)
            [parameters setObject:[vendorUrl encodeUTF] forKey:@"paramUrl"];
        
        if (vendorImage.length>0)
        {
            [parameters setObject:vendorImage forKey:@"paramImages"];
        }
        [[qqAccountManage sharedInstance] clickAddShare:parameters];

    }
    else if  ((int)imageIndex==4)
    {
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:text forKey:@"title"];
        if (url!=nil)
            [parameters setObject:[url absoluteString] forKey:@"url"];
        if (imageData!=nil)
            [parameters setObject:imageData forKey:@"image"];

        [[weixinAccountManage sharedInstance] sendMessageToFriend:parameters];
    }
    else if  ((int)imageIndex==5)
    {
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:text forKey:@"title"];
        if (url!=nil)
            [parameters setObject:[url absoluteString] forKey:@"url"];
        if (imageData!=nil)
            [parameters setObject:imageData forKey:@"image"];

        [[weixinAccountManage sharedInstance] sendMessageToCycle:parameters];
    }

}

- (void)didClickOnCancelButton
{
    LOG(@"didClickOnCancelButton");
}

@end
