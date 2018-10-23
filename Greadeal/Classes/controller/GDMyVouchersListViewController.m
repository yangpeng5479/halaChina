//
//  GDVouchersListViewController.m
//  Greadeal
//
//  Created by Elsa on 15/10/17.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "GDMyVouchersListViewController.h"
#import "RDVTabBarController.h"

#import "GDOrderListCell.h"

#import "GDDeliverViewController.h"
#import "GDOrderDetailsViewController.h"

#import "GDLiveVendorViewController.h"
#import "GDQRCell.h"

#import "GDRatingViewController.h"
#import "GDProductDetailsViewController.h"

#import "GDPINViewController.h"

@interface GDMyVouchersListViewController ()

@end

@implementation GDMyVouchersListViewController

- (id)init:(vourchersSearchType)atype
{
    self = [super init];
    if (self)
    {
        vourchersType = atype;
        
        coupon_lists = [[NSMutableArray alloc] init];
        shareData    = [[NSMutableDictionary alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect r = self.view.bounds;
    
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    [self addRefreshUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getProductData) name:kNotificationSwitchLanagues object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action


- (void)tapRedeem:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    
    int selectedIndex = (int)button.tag;
             
    NSDictionary* obj = [coupon_lists objectAtIndex:selectedIndex];
    if (obj!=nil)
    {
        NSString* consume_code_qr = @"";
        SET_IF_NOT_NULL(consume_code_qr, obj[@"code"]);
        if (consume_code_qr.length>0)
        {
            GDPINViewController* nv = [[GDPINViewController alloc] init:consume_code_qr];
            [_superNav pushViewController:nv animated:YES];
        }
        
    }
}

- (void)tapGo
{
    if (self.navigationController!=nil)
    {
        [[self rdv_tabBarController] setSelectedIndex:[GDSettingManager instance].nTabLive];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [[_superNav rdv_tabBarController] setSelectedIndex:[GDSettingManager instance].nTabLive];
        [_superNav popToRootViewControllerAnimated:YES];
    }
}

- (void)tapRating:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    int selectedIndex = (int)button.tag;
    
    NSDictionary* obj = [coupon_lists objectAtIndex:selectedIndex];
    if (obj!=nil)
    {
        int product_id = [obj[@"product_id"] intValue];
        GDRatingViewController* vc = [[GDRatingViewController alloc] initWithProduct:product_id];
                
        UINavigationController *nc = [[UINavigationController alloc]
                                              initWithRootViewController:vc];
                
        [_superNav presentViewController:nc animated:YES completion:^(void) {}];
        
    }
    
}

- (void)shareAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    int selectedIndex = (int)button.tag;
    
    NSDictionary* obj = [coupon_lists objectAtIndex:selectedIndex];
    if (obj!=nil)
    {
        [shareData removeAllObjects];
        
        NSString* title = [NSString stringWithFormat:@"%@ %@",obj[@"vendor"][@"vendor_name"],obj[@"product_name"]];
        
        [shareData setValue:obj[@"qrcode"] forKey:@"codeimage"];
        [shareData setValue:title forKey:@"title"];
        
        NSString*  code = obj[@"code"];
        NSString*  key = [NSString stringWithFormat:@"%@%d",obj[@"code"],[GDPublicManager instance].cid];
        
        NSString*  sha1 = [[GDPublicManager instance] getSha1String:key];
        
        NSString*  url = [NSString stringWithFormat:@"%@index.php?route=coupon/share&code=%@&key=%@",MainWebPage,code,sha1];

        [shareData setValue:url forKey:@"url"];
        
        NSMutableArray *shareButtonTitleArray = [[NSMutableArray alloc] init];
        NSMutableArray *shareButtonImageNameArray = [[NSMutableArray alloc] init];
    
        [shareButtonTitleArray addObject:NSLocalizedString(@"E-Mail",@"邮件")];
        [shareButtonImageNameArray addObject:@"sns_icon_mail"];
    
        if ([[whatsappAccountManage sharedInstance] isInstalled])
        {
            [shareButtonTitleArray addObject:@"WhatsApp"];
            [shareButtonImageNameArray addObject:@"sns_icon_whatsapp"];
        }
    
        if ([[weixinAccountManage sharedInstance] isWXInstalled])
        {
            [shareButtonTitleArray addObject:NSLocalizedString(@"Wechat",@"微信好友")];
            [shareButtonImageNameArray addObject:@"sns_icon_wechat"];
        }
    
        LXActivity *lxActivity = [[LXActivity alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonImageNameArray];
        [lxActivity showInView:self.view];
    }
}

#pragma mark - Data
- (UIView *)noOrderView
{
    if (!_noOrderView) {
        
        CGRect r = self.view.frame;
        
        _noOrderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height)];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, r.size.height/2-40, r.size.width, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"You have no relevant coupon.", @"您没有相关优惠券");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = MOLightFont(16);
        [_noOrderView addSubview:label];
        
        
        ACPButton* goBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        goBut.frame = CGRectMake(10, r.size.height/2, r.size.width-20, 36);
        [goBut setStyleRedButton];
        [goBut setTitle: NSLocalizedString(@"Go Shopping", @"去购物") forState:UIControlStateNormal];
        [goBut addTarget:self action:@selector(tapGo) forControlEvents:UIControlEventTouchUpInside];
        [goBut setLabelFont:MOLightFont(18)];
        [_noOrderView addSubview:goBut];
        
    }
    return _noOrderView;
}


- (void)getProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    reloading = YES;
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Coupon/get_coupon_list"];
    
    NSString* voucher_status_type;
    switch (vourchersType) {
        case VOUCHERS_ALL:
            voucher_status_type = @"all";
            break;
        case VOUCHERS_AWAITING_USE:
            voucher_status_type = @"unconsume";
            break;
        case VOUCHERS_USED:
            voucher_status_type = @"consumed";
            break;
        case VOUCHERS_RETURNS:
            voucher_status_type = @"after_sale";
            break;
        default:
            break;
    }
    
    parameters = @{@"page":@(seekPage),@"limit":@(prePageNumber),@"token":[GDPublicManager instance].token,@"status":voucher_status_type,@"language_id":@([GDSettingManager instance].switchLanguage)};
    
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
                 @synchronized(coupon_lists)
                 {
                     [coupon_lists removeAllObjects];
                 }
             }
             
             if(responseObject[@"data"][@"coupon_list"] != [NSNull null] && responseObject[@"data"][@"coupon_list"] != nil)
             {
                 NSArray* temp = responseObject[@"data"][@"coupon_list"];
                 lastCountFromServer = (int)temp.count;
                 
                 if (temp.count>0)
                 {
                     [coupon_lists addObjectsFromArray:temp];
                 }
             }
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             [ProgressHUD showError:errorInfo];
         }
         [ProgressHUD dismiss];
         [self stopLoad];
         [self reLoadView];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self stopLoad];
         [self reLoadView];
         [ProgressHUD showError:error.localizedDescription];
     }];
}

#pragma mark UIView
- (void)reLoadView
{
    [mainTableView reloadData];
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    isLoadData = NO;
    [self  getProductData];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [ProgressHUD dismiss];
}


#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* obj = [coupon_lists objectAtIndex:indexPath.section];
    int  membership_level = [obj[@"vendor"][@"membership_level"] intValue];

    if (indexPath.row ==0)
    {
        static NSString *CellIdentifier = @"code";
        GDQRCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GDQRCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if (obj!=nil)
        {
            cell.numberLabel.text = obj[@"code"];
            
            NSString* consume_code_qr = @"";
            SET_IF_NOT_NULL(consume_code_qr, obj[@"qrcode"]);
            if (consume_code_qr.length>0)
                [cell.QRView sd_setImageWithURL:[NSURL URLWithString:[consume_code_qr encodeUTF]]];
            
            float  oprice = [obj[@"original_price"] floatValue];
            //float  sprice = [obj[@"price"] floatValue];
            
            NSString* opricestr = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, (int)oprice];
            //NSString* spricestr = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, (int)sprice];
            
            cell.originPriceLabel.text  = opricestr;
           // cell.priceLabel.text = spricestr;
            
            NSString* expireDate = obj[@"available_date_end"];
            expireDate = [expireDate substringToIndex:10];
            
            NSString* earlier = [[GDPublicManager instance] minExpiredDate:expireDate];
            
            [cell.actionBut removeTarget:nil
                               action:NULL
                     forControlEvents:UIControlEventAllEvents];
            
            if ([obj[@"status"] isEqualToString:@"consumed"])
            {
                cell.isExpire = 1;
                
                [cell.actionBut setStyleYellowButton];
                cell.actionBut.tag = indexPath.section;
                [cell.actionBut setTitle:[[GDSettingManager instance] isSwitchChinese]?@"评分":@"RATING" forState:UIControlStateNormal];
                [cell.actionBut addTarget:self action:@selector(tapRating:) forControlEvents:UIControlEventTouchUpInside];
                cell.actionBut.enabled = YES;
                
                [cell.shareBut setStyleYellowButton];
                cell.shareBut.enabled = NO;
                [cell.shareBut addShareImage];
            }
            else if ([obj[@"status"] isEqualToString:@"unconsume"])
            {
                if ([[GDPublicManager instance] isExpiredDate:earlier])
                {
                    cell.isExpire = 2 ;
                    
                    [cell.actionBut setStyleRedButton];
                    [cell.actionBut setTitle:[[GDSettingManager instance] isSwitchChinese]?@"使用":@"REDEEM" forState:UIControlStateNormal];
                    cell.actionBut.enabled = NO;
                    [cell.actionBut addTarget:self action:@selector(tapRedeem:) forControlEvents:UIControlEventTouchUpInside];
                    

                    [cell.shareBut setStyleYellowButton];
                    cell.shareBut.enabled = NO;
                    [cell.shareBut addShareImage];
                }
                else
                {
                    cell.isExpire = 0 ;
                    
                    [cell.actionBut setStyleRedButton];
                    cell.actionBut.tag = indexPath.section;
                    [cell.actionBut setTitle:[[GDSettingManager instance] isSwitchChinese]?@"使用":@"REDEEM" forState:UIControlStateNormal];
                    [cell.actionBut addTarget:self action:@selector(tapRedeem:) forControlEvents:UIControlEventTouchUpInside];
                    cell.actionBut.enabled = YES;
                    
                    [cell.shareBut setStyleYellowButton];
                    cell.shareBut.tag = indexPath.section;
                    [cell.shareBut addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.shareBut addShareImage];
                    cell.shareBut.enabled = YES;
                }
            }
            
            if (membership_level == needPayType)
            {
                cell.actionBut.hidden = YES;
            }
            else
            {
                cell.actionBut.hidden = NO;
            }
            
            NSString* vendor_name = @"";
            SET_IF_NOT_NULL(vendor_name, obj[@"vendor"][@"vendor_name"]);
            cell.vendorLabel.text = vendor_name;
            
            int setprice = 0;
            if(obj[@"set_price"] != [NSNull null] && obj[@"set_price"] != nil)
                setprice = [obj[@"set_price"] intValue];
            
            NSString* title_name = obj[@"product_name"];
            
            NSArray* optionArray = nil;
            if(obj[@"options"] != [NSNull null] && obj[@"options"] != nil)
            {
                SET_IF_NOT_NULL(optionArray,obj[@"options"]);
                if (optionArray.count>0)
                {
                    NSDictionary* dict = [optionArray objectAtIndex:0];
                    title_name = [NSString stringWithFormat:@"%@ (%@)",obj[@"product_name"],dict[@"value"]];
                }
            }
            
            [[GDSettingManager instance] setTitleAttr:cell.titleLabel withTitle:title_name withSale:setprice withOrigin:oprice];
            
            cell.expireLabel.text= [NSString stringWithFormat:[[GDSettingManager instance] isSwitchChinese]?@"过期日期: %@":@"Expired Date: %@",earlier];
        }

        return cell;

    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!reloading && !coupon_lists.count)
    {
        [mainTableView addSubview:[self noOrderView]];
        
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    
    if (coupon_lists.count>0)
    {
        [_noOrderView removeFromSuperview];
        
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    
    return coupon_lists.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary* obj = [coupon_lists objectAtIndex:section];
    if (obj!=nil)
    {
//        NSString* order_status = obj[@"status"];
//        if ([order_status isEqualToString:@"unconsume"] || [order_status isEqualToString:@"consumed"])
//        if ([order_status isEqualToString:@"consumed"])
//        {
//            return 2;
//        }
    }
    
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return 155; //non 115 member 135
//        case 1:
//        {
//            return 40;
//        }
        default:
            break;
    }
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0)
    {
        NSDictionary* obj = [coupon_lists objectAtIndex:indexPath.section];
        if (obj!=nil)
        {
            int product_id = [obj[@"order_product_id"] intValue];
    
        GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:product_id withOrder:NO];
        [_superNav pushViewController:viewController animated:YES];
        }
    }
}


#pragma mark Refresh
- (void)refreshData
{
    LOG(@"refresh data");
    isLoadData = NO;
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
    else
    {
        [self stopLoad];
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

#pragma mark - MFMailComposeViewControllerDelegate method

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultSaved:
        case MFMailComposeResultCancelled:
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case MFMailComposeResultSent:
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Done",@"完成")
                               message:nil
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }
                              }];
            break;
        }
        case MFMailComposeResultFailed:
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"错误")
                               message:NSLocalizedString(@"Failed to send E-Mail.", @"发送邮件失败")
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
}

#pragma mark - LXActivityDelegate

- (void)didClickOnImageIndex:(NSString *)imageIndex
{
    NSString*  text = shareData[@"title"];
    NSString*  url = [shareData[@"url"] encodeUTF];
    
    NSString* codeimage = shareData[@"codeimage"];
    
    __block UIImage* imageData = nil;
    
    [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:[codeimage encodeUTF]]  options:SDWebImageLowPriority|SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        imageData = image;
        
        //大小不能超过32K
        float imageRatio = image.size.height / image.size.width;
        CGFloat newWidth = image.size.width;
        if (newWidth > 160) {
            newWidth = 160;
        }
        
        imageData= [UIImage scaleImage:image ToSize:CGSizeMake(newWidth, newWidth*imageRatio)];
        
        if ([imageIndex isEqualToString:@"sns_icon_mail"])
        {
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
                
                mailComposeViewController.mailComposeDelegate = self;
                
                NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Your friend share a coupon for you ",@"您的朋友赠送了一张优惠券 ")];
                [mailComposeViewController setSubject:title];
                
                [mailComposeViewController setMessageBody:text isHTML:NO];
                
                
                [self presentViewController:mailComposeViewController animated:YES completion:nil];
            }
            else
            {
                [UIAlertView showWithTitle:NSLocalizedString(@"Unable to send E-Mail", @"不能发送邮件")
                                   message:NSLocalizedString(@"Please configure your E-Mail in this phone first.", @"您的手机没有配置发送邮件账号")
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      if (buttonIndex == [alertView cancelButtonIndex]) {
                                          
                                      }
                                  }];
                
            }
        }
        else if  ([imageIndex isEqualToString:@"sns_icon_whatsapp"])
        {
            [[whatsappAccountManage sharedInstance] sendMessageToFriend:text withUrl:url];
        }
        else if  ([imageIndex isEqualToString:@"sns_icon_wechat"])
        {
            NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
            [parameters setObject:text forKey:@"title"];
            if (url!=nil)
                [parameters setObject:[[NSURL URLWithString:url] absoluteString] forKey:@"url"];
            if (imageData!=nil)
                [parameters setObject:imageData forKey:@"image"];
            [[weixinAccountManage sharedInstance] sendMessageToFriend:parameters];
        }
    }];
}

- (void)didClickOnCancelButton
{
    LOG(@"didClickOnCancelButton");
}

@end
