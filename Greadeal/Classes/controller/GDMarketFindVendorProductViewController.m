//
//  GDMarketFindVendorProductViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/25.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDMarketFindVendorProductViewController.h"
#import "GDProductDetailsViewController.h"
#import "GDProductListCell.h"

#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"

@interface GDMarketFindVendorProductViewController ()

@end

@implementation GDMarketFindVendorProductViewController

- (id)init:(int)vendor_id withName:(NSString*)vendor_name withUrl:(NSString*)vendor_url withImage:(NSString*)vendor_image
{
    self = [super init];
    if (self)
    {
        productList = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
        
        vendorId = vendor_id;
        vendorUrl =vendor_url;
        vendorName =vendor_name;
        vendorImage =vendor_image;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect r = self.view.bounds;
    
    mainTableView = MOCreateTableView( r , UITableViewStylePlain, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
     
    [self addRefreshUI];
    
    UIBarButtonItem*  shareButItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share.png"] style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(shareAction)];
    
    self.navigationItem.rightBarButtonItem = shareButItem;
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
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"vendor/get_product_list_by_vendor_id"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"vendor_id":@(vendorId),@"page":@(seekPage),@"limit":@(prePageNumber)};
    
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
                 @synchronized(productList)
                 {
                     [productList removeAllObjects];
                 }
             }
             
             NSArray* temp = responseObject[@"data"][@"vendor"][@"product_list"];
             lastCountFromServer = (int)temp.count;
             [productList addObjectsFromArray:temp];
             
             SET_IF_NOT_NULL(vendorName, responseObject[@"data"][@"vendor"][@"vendor_name"]);
             SET_IF_NOT_NULL(vendorUrl, responseObject[@"data"][@"vendor"][@"store_url"]);
             SET_IF_NOT_NULL(vendorImage, responseObject[@"data"][@"vendor"][@"vendor_image"])
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             [ProgressHUD showError:errorInfo];
         }
         
         [self stopLoad];
         [self reLoadView];
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
- (void)reLoadView
{
    [mainTableView reloadData];
}

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
    
    [ProgressHUD dismiss];
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
    
    if (!reloading && [[GDPublicManager instance]._reachability currentReachabilityStatus] == NotReachable && !productList.count)
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
