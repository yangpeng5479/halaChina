//
//  GDSaleProductListViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/30.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDSaleProductListViewController.h"
#import "GDSaleProductListCell.h"

#import "TMQuiltView.h"
#import "GDProductDetailsViewController.h"

#import "RDVTabBarController.h"

#define titleHeight   40

@interface GDSaleProductListViewController ()

@end

@implementation GDSaleProductListViewController
@synthesize endTime;

- (id)init:(BOOL)haveRefreshView withId:(int)category_id
{
    self = [super init:haveRefreshView];
    if (self)
    {
        productData = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
        
        categoryId = category_id;
        endTime = @"";
    }
    return self;
}

- (void)dealloc {
   [proCountDown pause];
}
- (void)didReceiveMemoryWarning {
    
    // Dispose of any resources that can be recreated.
}

- (void)tapSort
{
    if (priceBut.tag==0)
    {
        priceBut.tag = 1;
        [priceBut setBackgroundImage:[UIImage imageNamed:@"sort_desc.png"] forState:UIControlStateNormal];
    }
    else
    {
        priceBut.tag = 0;
        [priceBut setBackgroundImage:[UIImage imageNamed:@"sort_asc.png"] forState:UIControlStateNormal];
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
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"sale/get_discount_product_list_by_category_id"];
    
    NSString* sortChoose=@"asc";
    if (priceBut.tag==1)
        sortChoose=@"desc";
        
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"category_id":@(categoryId),@"page":@(seekPage),@"limit":@(prePageNumber),@"discount_price_order":sortChoose};

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
        [productData addObjectsFromArray:responseObject[@"data"]];
         NSArray* temp = responseObject[@"data"];
         lastCountFromServer = (int)temp.count;
         
         [ProgressHUD dismiss];
         
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
        priceBut.frame = CGRectMake(20, 12, 12, 15);
        [priceBut addTarget:self action:@selector(tapSort) forControlEvents:UIControlEventTouchUpInside];
        priceBut.tag = 0; //0 asc 1 desc
        [priceBut setBackgroundImage:[UIImage imageNamed:@"sort_asc.png"] forState:UIControlStateNormal];
        
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
        
        UIImageView* backgroundView = [[UIImageView alloc] init];
        backgroundView.image = [[UIImage imageNamed:@"productLline.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        backgroundView.frame= CGRectMake(r.origin.x, titleHeight-0.5,
                                         r.size.width, 0.5);
        [headView addSubview:backgroundView];

        
        proCountDown = [[MZTimerLabel alloc] init];
        proCountDown.timerType = MZTimerLabelTypeTimer;
        proCountDown.textAlignment = NSTextAlignmentRight;
        proCountDown.timeFormat = @"mm:ss";
        proCountDown.timeLabel.backgroundColor = [UIColor clearColor];
        proCountDown.timeLabel.font = [UIFont systemFontOfSize:14.0f];
        proCountDown.timeLabel.textColor = [UIColor grayColor];
        proCountDown.frame = CGRectMake(150*[GDPublicManager instance].screenScale, 0, 150*[GDPublicManager instance].screenScale, titleHeight);
        proCountDown.delegate = self;
        [headView addSubview:proCountDown];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* date_end = [formatter dateFromString:endTime];
        if (date_end==nil)
        {
            [formatter setDateFormat:@"yyyy-MM-dd"];
            date_end = [formatter dateFromString:endTime];
        }
        
        NSTimeInterval sub = [date_end timeIntervalSinceNow];
        if (sub>0)
        {
            [proCountDown setCountDownTime:sub];
            [proCountDown start];
        }
        else
        {
            proCountDown.hidden = YES;
        }
        
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
    
    UIBarButtonItem*  searchButItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share.png"] style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(shareAction)];
    
    self.navigationItem.rightBarButtonItem = searchButItem;
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

#pragma mark - countdown Delegate

- (NSString*)timerLabel:(MZTimerLabel *)timerLabel customTextToDisplayAtTime:(NSTimeInterval)time
{
    if([timerLabel isEqual:proCountDown]){
        
        int days  = time/86400;
        
        NSTimeInterval atime = (int)time%86400;
        int second = (int)atime  % 60;
        int minute = ((int)atime / 60) % 60;
        int hours = atime / 3600;
        
        if (days>1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"%02d days %02d:%02d:%02d left", @"还剩%02d天 %02d时%02d分%02d秒"),days,hours,minute,second];
        }
        else if (days==1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"%02d day %02d:%02d:%02d left", @"还剩%02d天 %02d时%02d分%02d秒"),days,hours,minute,second];
        }
        return [NSString stringWithFormat:NSLocalizedString(@"%02d:%02d:%02d left",@"还剩%02d时%02d分%02d秒"),hours,minute,second];
    }
    else
        return nil;
}


-(void)timerLabel:(MZTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime
{
    LOG(@"finshedCountDownTimerWithTime");
    proCountDown.hidden = YES;
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
    NSString* cagegoryUrl = @"";
    NSString* text = [NSString stringWithFormat:NSLocalizedString(@"Hurry up, Big Sale",@"赶紧去抢购! 大促销")];
    NSURL*     url = [NSURL URLWithString:[cagegoryUrl encodeUTF]];
    
    __block UIImage* imageData = nil;
    
    NSString* vendorImage = DefaultSysImage;
    
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
            
            [mailComposeViewController setSubject:NSLocalizedString(@"Big Sale", @"活动 大促销")];
            
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
        
        if (cagegoryUrl.length>0)
            [parameters setObject:[cagegoryUrl encodeUTF] forKey:@"paramUrl"];
        
        [parameters setObject:@"Greadeal" forKey:@"paramSummary"];
        
        [[qqAccountManage sharedInstance] clickAddShare:parameters];

        if (text.length>0)
            [UIPasteboard generalPasteboard].string = text;
        if (url!=nil)
            [UIPasteboard generalPasteboard].URL = url;
        
        if (vendorImage.length>0)
        {
            [parameters setObject:vendorImage forKey:@"paramImages"];
        }
        
        [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
        
    }
    else if  ((int)imageIndex==4)
    {
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:text forKey:@"title"];
        [parameters setObject:[url absoluteString] forKey:@"url"];
        [parameters setObject:NSLocalizedString(@"Hurry up, Big Sale",@"赶紧去抢购! 大促销") forKey:@"description"];
        if (imageData!=nil)
            [parameters setObject:imageData forKey:@"image"];

        [[weixinAccountManage sharedInstance] sendMessageToFriend:parameters];
    }
    else if  ((int)imageIndex==5)
    {
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:text forKey:@"title"];
        [parameters setObject:[url absoluteString] forKey:@"url"];
        [parameters setObject:NSLocalizedString(@"Hurry up, Big Sale",@"赶紧去抢购! 大促销") forKey:@"description"];
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
