
//  GDShopProductDetailsViewController.m
//  GDShopProductDetailsViewController
//
//  Created by Robert Dimitrov on 11/8/14.
//  Copyright (c) 2014 Robert Dimitrov. All rights reserved.
//

#import "GDShopProductDetailsViewController.h"
#import "RDVTabBarController.h"

#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

#import "GDShopDetailsTableViewCell.h"

#import "GDLiveVendorViewController.h"

#import "GDVendorCell.h"
#import "GDRateListCell.h"
#import "GDRateViewController.h"

#import "GDPackageListCell.h"

#import "GDLoginViewController.h"
#import "GDRegsiterViewController.h"

#import "GDShopDeliveryOrderViewController.h"
#import "UIActionSheet+Blocks.h"

#import "GDOpenHourListCell.h"
#import "GDTagListCell.h"

#import "ALCustomColoredAccessory.h"

#import "GDWholeMapViewController.h"

#define  smallImageWidth  ([[UIScreen mainScreen] bounds].size.width)
#define  smallImageHeight ([[UIScreen mainScreen] bounds].size.width/320.0*180)

#define  smallPadding       8

@interface GDShopProductDetailsViewController ()

@end

@implementation GDShopProductDetailsViewController

#pragma mark - init

- (id)init:(int)product_id withOrder:(BOOL)isView
{
    self = [super init];
    if (self)
    {
        if (isView)
            toolViewHeight = 45;
        else
            toolViewHeight = 0;
        
        productId = product_id;
        
        _packageList   = [[NSMutableArray alloc] init];
        _imageArray    = [[NSMutableArray alloc] init];
        _tagArrays     = [[NSMutableArray alloc] init];
        _openHours     = [[NSMutableArray alloc] init];
        _rateList      = [[NSMutableArray alloc] init];
        
        expandedSections = [[NSMutableIndexSet alloc] init];
        
        option_quantity = -1;
        option_value_id = -1;
        option_value_name = @"";
        
        dictData = nil;
        
        order_maximum = 1;
        sprice = 1.0;
        oprice = 1.0;
        setsale =1.0;
        name   = NSLocalizedString(@"Product Name",@"产品名");
        
        highlightHeight = 20;
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)shareAction
{
    NSMutableArray *shareButtonTitleArray = [[NSMutableArray alloc] init];
    NSMutableArray *shareButtonImageNameArray = [[NSMutableArray alloc] init];
    
    [shareButtonTitleArray addObject:@"Facebook"];
    [shareButtonTitleArray addObject:@"Twitter"];
    [shareButtonTitleArray addObject:@"QQ"];

    [shareButtonImageNameArray addObject:@"sns_icon_facebook"];
    [shareButtonImageNameArray addObject:@"sns_icon_twitter"];
    [shareButtonImageNameArray addObject:@"sns_icon_qq"];
    
    if ([[whatsappAccountManage sharedInstance] isInstalled])
    {
        [shareButtonTitleArray addObject:@"WhatsApp"];
        [shareButtonImageNameArray addObject:@"sns_icon_whatsapp"];
    }
    
    if ([[weixinAccountManage sharedInstance] isWXInstalled])
    {
        [shareButtonTitleArray addObject:NSLocalizedString(@"Wechat",@"微信好友")];
        [shareButtonTitleArray addObject:NSLocalizedString(@"Moments",@"微信朋友圈")];
        
        [shareButtonImageNameArray addObject:@"sns_icon_wechat"];
        [shareButtonImageNameArray addObject:@"sns_icon_moments"];
    }
    
    LXActivity *lxActivity = [[LXActivity alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonImageNameArray];
    [lxActivity showInView:self.view];
}

- (void)addHeaderView
{
    CGRect r =  self.view.bounds;
    
    PScrollView = [[OTPageView alloc] initWithFrame:CGRectMake(0, 0,r.size.width,smallImageHeight)];
    PScrollView.pageScrollView.dataSource = self;
    PScrollView.pageScrollView.delegate = self;
    PScrollView.pageScrollView.padding  = 0;
    PScrollView.pageScrollView.leftRightOffset = 0;
    
    PScrollView.pageScrollView.frame = CGRectMake(0, 0, smallImageWidth, smallImageHeight);
    MODebugLayer(PScrollView.pageScrollView, 1.f, [UIColor redColor].CGColor);
    PScrollView.backgroundColor = [UIColor colorWithRed:236/255.0 green:234/255.0 blue:245/255.0 alpha:1.0];
    
    [PScrollView.pageScrollView reloadData];
    
    PScrollView.pageControl.numberOfPages = _imageArray.count;
    PScrollView.pageControl.currentPage = 0;
    PScrollView.pageControl.hidesForSinglePage = YES;
    
    PScrollView.pageLabel.text = [NSString stringWithFormat:@"%u / %ld",1,_imageArray.count];
    
    if (_imageArray.count<10)
    {
        PScrollView.pageControl.hidden = NO;
        PScrollView.pageLabel.hidden = YES;
    }
    else
    {
        PScrollView.pageControl.hidden = YES;
        PScrollView.pageLabel.hidden = NO;
    }
    
    mainTableView.tableHeaderView = PScrollView;
}

#pragma mark - Action
- (void)clearCountdown
{
    [self showCartCountdown:NO];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if (flag) {
        [imageViewForAnimation removeFromSuperview];
        
        [self showCartCountdown:YES];
    }
}

- (void)makeAnimation:(CGPoint)buttonPosition withImage:(NSString*)imgUrl
{
    //buttonPosition.x +=80;
    
    LOG(@"%f,%f",buttonPosition.x,buttonPosition.y);
    if (imageViewForAnimation==nil)
    {
        imageViewForAnimation = [[UIImageView alloc] init];
    }
    imageViewForAnimation.frame = CGRectMake(buttonPosition.x, buttonPosition.y,smallImageWidth, smallImageHeight);
    
    [imageViewForAnimation sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                             placeholderImage:[UIImage imageNamed:@"product_detail_default.png"]];
    
    imageViewForAnimation.alpha = 1.0f;
    CGRect imageFrame = imageViewForAnimation.frame;
    //Your image frame.origin from where the animation need to get start
    CGPoint viewOrigin = imageViewForAnimation.frame.origin;
    viewOrigin.y = viewOrigin.y + imageFrame.size.height / 4.0f;
    viewOrigin.x = viewOrigin.x + imageFrame.size.width / 4.0f;
    
    imageViewForAnimation.frame = imageFrame;
    imageViewForAnimation.layer.position = viewOrigin;
    [self.view addSubview:imageViewForAnimation];
    
    // Set up fade out effect
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeOutAnimation setToValue:[NSNumber numberWithFloat:0.3]];
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.removedOnCompletion = NO;
    
    // Set up scaling
    CABasicAnimation *resizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    [resizeAnimation setToValue:[NSValue valueWithCGSize:CGSizeMake(10.0f, 10.0f)]];
    resizeAnimation.fillMode = kCAFillModeForwards;
    resizeAnimation.removedOnCompletion = NO;
    
    // Set up path movement
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    //Setting Endpoint of the animation
    CGRect r = self.view.frame;
    CGPoint endPoint = CGPointMake(70, r.size.height - 40);
    //to end animation in last tab use
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, viewOrigin.x, viewOrigin.y);
    CGPathAddCurveToPoint(curvedPath, NULL, endPoint.x, viewOrigin.y, endPoint.x, viewOrigin.y, endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    pathAnimation.delegate = self;
    CGPathRelease(curvedPath);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setAnimations:[NSArray arrayWithObjects:fadeOutAnimation, pathAnimation, resizeAnimation, nil]];
    group.duration = 1.5f;
    group.delegate = self;
    [group setValue:imageViewForAnimation forKey:@"imageViewBeingAnimated"];
    
    [imageViewForAnimation.layer addAnimation:group forKey:@"savingAnimation"];
}

- (void)tapBuy:(id)sender
{
    //check login infomation
    if ([GDPublicManager instance].cid>0)
    {
        int  vendor_id = 0;
        NSString* vendor_name=@"";
        
        if(dictData[@"vendor_info"] != [NSNull null] && dictData[@"vendor_info"] != nil)
        {
            vendor_id = [dictData[@"vendor_info"][@"vendor_id"] intValue];
            SET_IF_NOT_NULL(vendor_name, dictData[@"vendor_info"][@"vendor_name"]);
        }
        
        NSMutableDictionary *dict = [[GDPublicManager instance] getVendorOfCart:vendor_id];
        
        if (dict!=nil)
        {
            int vendor_id = [dict[@"vendor_id"] intValue];
            NSArray* orderArrar = dict[@"Items"];
            
            int  membership_level = 0;
            if (orderArrar.count>0)
            {
                NSMutableDictionary* obj = [orderArrar objectAtIndex:0];
                membership_level  = [obj[@"membership_level"] intValue];
            }
            
            GDShopDeliveryOrderViewController* vc = [[GDShopDeliveryOrderViewController alloc] init:orderArrar withDeliveryFee:0];
            vc.superNav = self.navigationController;
            vc.vendorId = vendor_id;
            [self.navigationController pushViewController:vc animated:YES];
          
        }
    }
    else
    {
        [UIActionSheet showInView:self.view
                        withTitle:NSLocalizedString(@"Please login first and check out", @"您还没有登录,请先登录再购买")
                cancelButtonTitle:NSLocalizedString(@"Cancel",@"取消")
           destructiveButtonTitle:nil
                otherButtonTitles:@[NSLocalizedString(@"Login", @"登录"), NSLocalizedString(@"Sign Up", @"注册")]
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                             if (buttonIndex==0)
                             {
                                 GDLoginViewController* vc = [[GDLoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
                                 
                                 UINavigationController *nc = [[UINavigationController alloc]
                                                               initWithRootViewController:vc];
                                 
                                 [self presentViewController:nc animated:YES completion:^(void) {}];
                             }
                             else if (buttonIndex==1)
                             {
                                 GDRegsiterViewController* vc = [[GDRegsiterViewController alloc] initWithStyle:UITableViewStyleGrouped];
                                 UINavigationController *nc = [[UINavigationController alloc]
                                                               initWithRootViewController:vc];
                                 
                                 [self presentViewController:nc animated:YES completion:^(void) {}];
                             }
                         }];
        
    }

}

- (void)tapSubCarts:(id)sender
{
    if (orderQty>0)
    {
        int  vendor_id = 0;
        NSString* vendor_name=@"";
    
        if(dictData[@"vendor_info"] != [NSNull null] && dictData[@"vendor_info"] != nil)
        {
            vendor_id = [dictData[@"vendor_info"][@"vendor_id"] intValue];
            SET_IF_NOT_NULL(vendor_name, dictData[@"vendor_info"][@"vendor_name"]);
        }
    
        NSDictionary* parameters;
        parameters = @{@"order_qty":@(1),@"product_id":@([dictData[@"product_id"] intValue]),
                   @"option_value_id":@(option_value_id),@"vendor_id":@(vendor_id)};
    
        [[GDPublicManager instance] deleteProduct:vendor_id withproduct:[dictData[@"product_id"] intValue] withoption:option_value_id];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidSubToCart object:nil userInfo:nil];
    
        [self setBadge];
    }
}

- (void)finishedAdd:(NSString*)imgUrl withPara:(NSDictionary*)parameters
{
//    if (orderQty>0 && [[GDPublicManager instance] isMember])
//    {
//        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
//                           message:NSLocalizedString(@"The Member only buy one coupon at one time, you can continue to buy After used", @"会员一次只能购买一张券, 使用完后可以继续购买!")
//                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                 otherButtonTitles:nil
//                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                              if (buttonIndex == [alertView cancelButtonIndex]) {
//                                  
//                              }
//                          }];
//    }
//    else
//    {
//        if (orderQty<order_maximum)
 //       {
            [self makeAnimation:CGPointMake(self.view.frame.size.width/2,  self.navigationController.navigationBar.frame.size.height) withImage:imgUrl];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidAddToCart object:parameters userInfo:nil];
 //       }
//        else
//        {
//            
//            [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
//                               message:[NSString stringWithFormat:NSLocalizedString(@"Oops, Every one only buy %d pieces", @"每人最多购买 %d 张!"),order_maximum]
//                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                     otherButtonTitles:nil
//                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                                  if (buttonIndex == [alertView cancelButtonIndex]) {
//                                      
//                                  }
//                              }];
//            
//        }
    //}
}

- (void)tapAddCarts:(id)sender
{
if ([GDPublicManager instance].cid>0)
{
    int  vendor_id = 0;
    NSString* vendor_name=@"";
    int  membership_level = 0;
    
    NSString* imgUrl=@"";
    
    if (_imageArray.count>0)
    {
        imgUrl = [_imageArray objectAtIndex:0];
    }
    else
    {
        SET_IF_NOT_NULL(imgUrl, dictData[@"image"])
    }
    
    if(dictData[@"vendor_info"] != [NSNull null] && dictData[@"vendor_info"] != nil)
    {
        membership_level = [dictData[@"vendor_info"][@"membership_level"] intValue];
        vendor_id = [dictData[@"vendor_info"][@"vendor_id"] intValue];
        SET_IF_NOT_NULL(vendor_name, dictData[@"vendor_info"][@"vendor_name"]);
    }
    
    NSDictionary* parameters;
    parameters = @{@"image":imgUrl,@"name":name,@"setsale":@(setsale),@"sprice":@(sprice),@"oprice":@(oprice),@"order_qty":@(1),@"product_id":@([dictData[@"product_id"] intValue]),@"product_qty":@([dictData[@"quantity"] intValue]),@"option_value_id":@(option_value_id),@"option_quantity":@(option_quantity),@"vendor_id":@(vendor_id),@"vendor_name":vendor_name,@"option_value_name":option_value_name,@"maximum":@(order_maximum),@"type":dictData[@"type"],@"membership_level":@(membership_level)};
    
    BOOL isFree = [[GDPublicManager instance] isVaildFreeBuy:membership_level withNote:NO];
    
    if (isFree)
    {
        NSArray *orderArrar = [[NSArray alloc] initWithObjects:parameters,nil];
        [[GDOrderCheck instance] checkRepeatVoucher:vendor_id withProuct:orderArrar success:^(BOOL noRepeat) {
            if (noRepeat)
            {
                [self finishedAdd:imgUrl withPara:parameters];
            }
        }];
    }
    else
    {
         [self finishedAdd:imgUrl withPara:parameters];
    }
}
    else
    {
        [UIActionSheet showInView:self.view
                        withTitle:NSLocalizedString(@"Please login first and check out", @"您还没有登录,请先登录再购买")
                cancelButtonTitle:NSLocalizedString(@"Cancel",@"取消")
           destructiveButtonTitle:nil
                otherButtonTitles:@[NSLocalizedString(@"Login", @"登录"), NSLocalizedString(@"Sign Up", @"注册")]
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                             if (buttonIndex==0)
                             {
                                 GDLoginViewController* vc = [[GDLoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
                                 
                                 UINavigationController *nc = [[UINavigationController alloc]
                                                               initWithRootViewController:vc];
                                 
                                 [self presentViewController:nc animated:YES completion:^(void) {}];
                             }
                             else if (buttonIndex==1)
                             {
                                 GDRegsiterViewController* vc = [[GDRegsiterViewController alloc] initWithStyle:UITableViewStyleGrouped];
                                 UINavigationController *nc = [[UINavigationController alloc]
                                                               initWithRootViewController:vc];
                                 
                                 [self presentViewController:nc animated:YES completion:^(void) {}];
                             }
                         }];
        

    }
}

- (void)tapCarts
{
    if ([totalSingular.text intValue]>0)
    {
        if ([self rdv_tabBarController].selectedIndex!=[GDSettingManager instance].nTabCarts)
        {
            [[self rdv_tabBarController] setSelectedIndex:[GDSettingManager instance].nTabCarts];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"错误")
                           message:NSLocalizedString(@"Your shopping cart is empty!", @"亲,您的购物车还是空的!")
                 cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];

        
    }
}

- (void)setBadge
{
    int order_qty = [[GDPublicManager instance] getOrderQtyOfAll];
   
    totalSingular.text = [NSString stringWithFormat:@"%d",order_qty];
    
    CGSize titleSize = [totalSingular.text moSizeWithFont:totalSingular.font withWidth:80];
    CGRect size = totalSingular.frame;
    size.size.width = titleSize.width+15;
    totalSingular.frame = size;
    
    [self getProductOrderQty];
}

- (void)showCartCountdown:(BOOL)reset
{
    if ([GDPublicManager instance].countDownPay.superview!=nil)
        [[GDPublicManager instance].countDownPay removeFromSuperview];
    
    if ([GDPublicManager instance].cartsItem.count>0 )
    {
        [self setBadge];
    
        [GDPublicManager instance].countDownPay.frame = CGRectMake(50, 5, 60, 25);
        [cartsBut addSubview:[GDPublicManager instance].countDownPay];
        
        [GDPublicManager instance].countDownPay.timeLabel.textColor = [UIColor redColor];
        
        if (reset && [GDPublicManager instance].defaultCount>0)
        {
            [[GDPublicManager instance].countDownPay reset];
            
            [[GDPublicManager instance].countDownPay setCountDownTime:[GDPublicManager instance].defaultCount*60];
            
            [[GDPublicManager instance].countDownPay start];
        }
        totalSingular.hidden = NO;
    }
}

- (void)phoneCall
{
    [[GDPublicManager instance] makeHelp];
}

#pragma mark - view
- (void)getRateData
{
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Product/get_product_review_list"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"product_id":@(productId),@"page":@(1),@"limit":@(3)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
            
             @synchronized(_rateList)
             {
                [_rateList removeAllObjects];
             }
             
             NSArray* temp = responseObject[@"data"][@"review_list"];
             if (temp.count>0)
             {
                 for (NSDictionary* newDict in  temp)
                 {
                     NSMutableDictionary *muNewDict=[newDict mutableCopy];
                     [muNewDict setObject:@"" forKey:ExText];
                     [muNewDict setObject:@(0) forKey:isCN];//0 no 1 yes
                    [_rateList addObject:muNewDict];
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
         
        [self reLoadView];
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self reLoadView];
         [ProgressHUD showError:error.localizedDescription];
     }];
}

- (void)getProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    isLoadData = YES;
    reloading = YES;
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/product/get_detail_info"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"product_id":@(productId),@"token":[GDPublicManager instance].token,@"longitude":@([[GDSettingManager instance] getCityLongitude]),@"latitude":@([[GDSettingManager instance] getCityLatitude])};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             name=@"";
             NSString* stroPrice=@"";
             NSString* strsPrice=@"";
             NSString* strsetsale=@"0";
             
             dictData = responseObject[@"data"][@"product_info"];
             
             SET_IF_NOT_NULL(name, dictData[@"name"]);
             SET_IF_NOT_NULL(stroPrice, dictData[@"original_price"]);
             SET_IF_NOT_NULL(strsPrice, dictData[@"price"]);
             SET_IF_NOT_NULL(productUrl, dictData[@"url"]);
             SET_IF_NOT_NULL(strsetsale, dictData[@"set_price"]);
             SET_IF_NOT_NULL(payment_info, dictData[@"payment_info"]);
             
             if(dictData[@"vendor_info"] != [NSNull null] && dictData[@"vendor_info"] != nil)
             {
                 SET_IF_NOT_NULL(self.title, dictData[@"vendor_info"][@"vendor_name"]);
             }
             else
             {
                 self.title = NSLocalizedString(@"Product", @"产品");
             }
             oprice = [stroPrice intValue];
             sprice = [strsPrice intValue];
             setsale= [strsetsale intValue];
             
             order_maximum = [dictData[@"maximum"] intValue];
             
             NSArray* tempArray = nil;
             SET_IF_NOT_NULL(tempArray,dictData[@"image_list"]);
             
             NSString* imgUrl = @"";
             SET_IF_NOT_NULL(imgUrl, dictData[@"image"])
             if (imgUrl.length>0)
             {
                 [_imageArray addObject:imgUrl];
             }
             for (NSString* images in tempArray)
             {
                 [_imageArray addObject:images];
             }
             
             if (_imageArray.count>0)
                 [self addHeaderView];
             
             [self addFooterView];
             
             if(dictData[@"product_set"] != [NSNull null] && dictData[@"product_set"] != nil)
             {
                 SET_IF_NOT_NULL(tempArray,dictData[@"product_set"]);
                 if (tempArray.count>0)
                 {
                     [_packageList addObjectsFromArray:tempArray];
                 }
             }
             
             SET_IF_NOT_NULL(sHowtouse, dictData[@"sale_notice"]);
             SET_IF_NOT_NULL(sHighlights, dictData[@"highlights"]);
             SET_IF_NOT_NULL(sMoreinfo, dictData[@"more_info"]);
             
             NSArray* timeArray = nil;
             SET_IF_NOT_NULL(timeArray,dictData[@"vendor_info"][@"open_time"]);
             if (timeArray.count>0)
             {
                 [_openHours addObjectsFromArray:timeArray];
             }
             
             NSArray* tArray = nil;
             SET_IF_NOT_NULL(tArray,dictData[@"vendor_info"][@"tags"]);
             if (tArray.count>0)
             {
                 [_tagArrays addObjectsFromArray:tArray];
             }
             
             SET_IF_NOT_NULL(sCuisines, dictData[@"vendor_info"][@"entree"]);
             
             quantity = [dictData[@"quantity"] intValue];
             if (quantity<=0)
             {
                 soldoutLabel.hidden = NO;
                 addBut.hidden = YES;
                 qtyLabel.hidden = YES;
                 subtractionBut.hidden = YES;
             }
             else
             {
                 soldoutLabel.hidden = YES;
                 addBut.hidden = NO;
                 qtyLabel.hidden = NO;
                 subtractionBut.hidden = NO;
             }

             [self showCartCountdown:NO];
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             [ProgressHUD showError:errorInfo];
         }
         
         [ProgressHUD dismiss];
         netWorkError = NO;
         reloading = NO;
         [self reLoadView];
         
         [self getRateData];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         reloading = NO;
         netWorkError = YES;
         [self reLoadView];
         [ProgressHUD showError:error.localizedDescription];
     }];
}

- (void)getProductOrderQty
{
    orderQty = [[GDPublicManager instance] getOrderQtyOfProudct:productId withoption:option_value_id];
    qtyLabel.text = [NSString stringWithFormat:@"%d",orderQty];
    
    if (orderQty>0)
    {
        buyNowBut.hidden = NO;
        
        NSString* showTitle = NSLocalizedString(@"Buy Now",@"购买");
        
       // NSString* showTitle = [NSString stringWithFormat:@"%@%.1f\nBuy Now",[GDPublicManager instance].currency, sprice*orderQty];
        [buyNowBut setTitle:showTitle forState:UIControlStateNormal];
        
    }
    else
    {
        buyNowBut.hidden = YES;
    }
}

- (void)addFooterView
{
    if (cartsView==nil)
    {
        CGRect r =  self.view.bounds;
        r.origin.y= self.view.bounds.size.height- toolViewHeight;
        r.size.height=toolViewHeight;
    
        cartsView = [[UIView alloc] initWithFrame:r];
        cartsView.backgroundColor = MOColorAppBackgroundColor();
        [self.view addSubview:cartsView];
    
        UIImageView* backgroundView = [[UIImageView alloc] init];
        backgroundView.image = [[UIImage imageNamed:@"productLline.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        backgroundView.frame= CGRectMake(r.origin.x, 0,
                                     r.size.width, 0.5);
        [cartsView addSubview:backgroundView];
    
        //////////////////////////////////////////////////////////////////////////////
        UIImageView* _modiImage = [[UIImageView alloc] init];
        _modiImage.image = [UIImage imageNamed:@"qty_normal.png"];
        [cartsView addSubview:_modiImage];

        
        subtractionBut=[UIButton buttonWithType:UIButtonTypeCustom];
        [subtractionBut setImage:[UIImage imageNamed:@"redu_normal.png"] forState:UIControlStateNormal];
        [subtractionBut addTarget:self action:@selector(tapSubCarts:) forControlEvents:UIControlEventTouchUpInside];
        [cartsView addSubview:subtractionBut];
        
        addBut=[UIButton buttonWithType:UIButtonTypeCustom];
        [addBut setImage:[UIImage imageNamed:@"plus_normal.png"]  forState:UIControlStateNormal];
        [addBut addTarget:self action:@selector(tapAddCarts:) forControlEvents:UIControlEventTouchUpInside];
        [cartsView addSubview:addBut];
        
        qtyLabel = MOCreateLabelAutoRTL();
        qtyLabel.textAlignment = NSTextAlignmentCenter;
        qtyLabel.backgroundColor = [UIColor clearColor];
        qtyLabel.textColor = MOColorSaleFontColor();
        qtyLabel.font = MOLightFont(14);
        [cartsView addSubview:qtyLabel];
        [self getProductOrderQty];
        
//        MODebugLayer(subtractionBut, 1.f, [UIColor redColor].CGColor);
//        MODebugLayer(qtyLabel, 1.f, [UIColor redColor].CGColor);
//        
        float offsetX = 70;
        _modiImage.frame = CGRectMake(offsetX, 5.5,
                                      102, 34);
        
        offsetX-=10;
        subtractionBut.frame = CGRectMake(offsetX, 0,
                                    50, toolViewHeight);
        
        offsetX += 50;
        qtyLabel.frame = CGRectMake(offsetX, 0,
                                         20, toolViewHeight);
        
        offsetX += 20;
        addBut.frame = CGRectMake(offsetX, 0,
                                       50, toolViewHeight);
        //////////////////////////////////////////////////////////////////////////////
    
        buyNowBut=[ACPButton buttonWithType:UIButtonTypeCustom];
        buyNowBut.frame = CGRectMake(r.size.width-130, 0, 130, toolViewHeight);
        [buyNowBut setStyleRedButton];
        buyNowBut.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        buyNowBut.titleLabel.textAlignment = NSTextAlignmentCenter;
        [buyNowBut addTarget:self action:@selector(tapBuy:) forControlEvents:UIControlEventTouchUpInside];
        [buyNowBut setLabelFont:MOLightFont(16)];
        [cartsView addSubview:buyNowBut];
        buyNowBut.hidden = YES;
        
        soldoutLabel =[[UILabel alloc]initWithFrame:CGRectMake(r.size.width-(110*[GDPublicManager instance].screenScale), 3, 100*[GDPublicManager instance].screenScale, 39)];
        soldoutLabel.textAlignment=NSTextAlignmentCenter;
        soldoutLabel.backgroundColor=[UIColor clearColor];
        soldoutLabel.textColor=MOColorSaleFontColor();
        soldoutLabel.font=MOLightFont(16);
        soldoutLabel.text = NSLocalizedString(@"Sold Out", @"已售完");
        [cartsView addSubview:soldoutLabel];
        soldoutLabel.hidden = YES;
    
        cartsBut = [UIButton buttonWithType:UIButtonTypeCustom];
        cartsBut.frame = CGRectMake(0, 0, 60, 45);
        [cartsBut setImage:[UIImage imageNamed:@"cart_normal.png"]  forState:UIControlStateNormal];
        [cartsBut addTarget:self action:@selector(tapCarts) forControlEvents:UIControlEventTouchUpInside];
        [cartsView addSubview:cartsBut];
    
        totalSingular =[[UILabel alloc]initWithFrame:CGRectMake(35, 4, 16, 20)];
        totalSingular.layer.masksToBounds=YES;
        totalSingular.layer.cornerRadius=6;
        totalSingular.textAlignment=NSTextAlignmentCenter;
        totalSingular.backgroundColor=[UIColor redColor];
        totalSingular.textColor=[UIColor whiteColor];
        totalSingular.font=MOLightFont(12);
        [cartsBut addSubview:totalSingular];
        totalSingular.hidden = YES;
        
        //MODebugLayer(cartsBut, 1.f, [UIColor redColor].CGColor);
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect r =  self.view.bounds;
    
    r.size.height-=toolViewHeight;
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    if (self.rdv_tabBarController.tabBar.translucent) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0,
                                               0,
                                               CGRectGetHeight(self.rdv_tabBarController.tabBar.frame),
                                               0);
        
        mainTableView.contentInset = insets;
        mainTableView.scrollIndicatorInsets = insets;
    }
    
    UIBarButtonItem*  shareButItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share.png"] style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(shareAction)];
    
    self.navigationItem.rightBarButtonItem = shareButItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCountdown) name:kNotificationDidClearCart object:nil];
}

- (void)reLoadView
{
    [mainTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    if (!isLoadData)
    {
        [self  getProductData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [ProgressHUD dismiss];
}

- (void)tapTrans:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    int selectedIndex = (int)button.tag;
    
    __block NSMutableDictionary* dict = [_rateList objectAtIndex:selectedIndex];
    NSString* cnText = dict[ExText];
    NSString* enText = dict[@"text"];
    
    if (cnText.length<=0)
    {
        [[GDPublicManager instance] toChinese:enText success:^(NSString *translated) {
            if (translated.length>0)
            {
                [dict setObject:translated forKey:ExText];
                LOG(@"%@",translated);
                [self reLoadView];
            }
        }];
    }
}

- (void)tapPress:(UIGestureRecognizer*)gestureRecognizer
{
    float latitude=0.0;
    float longitude=0.0;
    
    if(dictData[@"vendor_info"][@"latitude"] != [NSNull null] && dictData[@"vendor_info"][@"latitude"] != nil)
    {
        latitude = [dictData[@"vendor_info"][@"latitude"] floatValue];
    }
    
    if(dictData[@"vendor_info"][@"longitude"] != [NSNull null] && dictData[@"vendor_info"][@"longitude"] != nil)
    {
        longitude = [dictData[@"vendor_info"][@"longitude"] floatValue];
    }
    
    NSString*  vendor_name=@"";
    if(dictData[@"vendor_info"][@"vendor_name"] != [NSNull null] && dictData[@"vendor_info"][@"vendor_name"] != nil)
    {
        SET_IF_NOT_NULL(vendor_name, dictData[@"vendor_info"][@"vendor_name"]);
    }
    
    GDWholeMapViewController* nv =  [[GDWholeMapViewController alloc] init:latitude withLong:longitude withName:vendor_name];
    [self.navigationController pushViewController:nv animated:YES];
}

- (void)dirctionMap:(UIGestureRecognizer*)gestureRecognizer
{
    float latitude=0.0;
    float longitude=0.0;
    
    if(dictData[@"vendor_info"][@"latitude"] != [NSNull null] && dictData[@"vendor_info"][@"latitude"] != nil)
    {
        latitude = [dictData[@"vendor_info"][@"latitude"] floatValue];
    }
    
    if(dictData[@"vendor_info"][@"longitude"] != [NSNull null] && dictData[@"vendor_info"][@"longitude"] != nil)
    {
        longitude = [dictData[@"vendor_info"][@"longitude"] floatValue];
    }
    
    NSString*  vendor_name=@"";
    if(dictData[@"vendor_info"][@"vendor_name"] != [NSNull null] && dictData[@"vendor_info"][@"vendor_name"] != nil)
    {
        SET_IF_NOT_NULL(vendor_name, dictData[@"vendor_info"][@"vendor_name"]);
    }
    
    CLLocationCoordinate2D endCoor = CLLocationCoordinate2DMake(latitude,longitude);
    
    [[GDPublicManager instance] mapDiredection:endCoor withEnd:endCoor withToName:vendor_name withView:self.view];
    
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section ==kNameSection)
    {
        if (indexPath.row == 0)
        {
            static NSString *CellIdentifier = @"titlecell";
          
            GDShopDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
            cell = [[GDShopDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }

            cell.titleLabel.text = name;
            
            cell.originLabel.text =  [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, oprice];
            
            cell.saleLabel.text =  [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, sprice];
            
            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsZero];
            }
                
            if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                [cell setLayoutMargins:UIEdgeInsetsZero];
            }
                
                return cell;
            }
            if (indexPath.row == 1)
            {
                UIArabicTableViewCell *cell ;
                static NSString *ID = @"titlecell1";
                cell = [tableView dequeueReusableCellWithIdentifier:ID];
                if (cell == nil) {
                    cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
                cell.textLabel.font = MOLightFont(14);
                cell.textLabel.text = NSLocalizedString(@"Vaild Date:",@"有效期");
                
                NSString* startDate = dictData[@"available_date_start"];
                startDate = [startDate substringToIndex:10];
                NSString* endDate = dictData[@"available_date_end"];
                endDate = [endDate substringToIndex:10];
                
                NSString* showDate = [NSString stringWithFormat:NSLocalizedString(@"%@ to %@",@"%@ to %@"),startDate,endDate];
                cell.detailTextLabel.font = MOLightFont(13);
                cell.detailTextLabel.text = showDate;
                
                
                
                return cell;
            }
            else
            {
                float offsetY = 10.0;
                
                static NSString *CellIdentifier = @"titlecell2";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                }
                
                UIImageView* _stockImage = [[UIImageView alloc] init];
                _stockImage.backgroundColor = [UIColor clearColor];
                _stockImage.frame = CGRectMake(15, 15, 12, 12);
                _stockImage.image = [UIImage imageNamed:@"stock.png"];
                [cell.contentView addSubview:_stockImage];
                
                UILabel* stockLabel = [[UILabel alloc] init];
                stockLabel.backgroundColor = [UIColor clearColor];
                stockLabel.numberOfLines = 0;
                stockLabel.font = MOLightFont(14);
                stockLabel.textColor = MOColorSaleFontColor();
                stockLabel.text =  [NSString stringWithFormat:NSLocalizedString(@"Stock:% d", @"库存:%d"),quantity];
                stockLabel.frame = CGRectMake(30, offsetY, 150, 20);
                [cell.contentView addSubview:stockLabel];
                
                int soldCount = [dictData[@"sold_count"] intValue];
                if (soldCount>0)
                {
                    UILabel* soldLabel = MOCreateLabelAutoRTL();
                    soldLabel.backgroundColor = [UIColor clearColor];
                    soldLabel.textColor = MOColor66Color();
                    soldLabel.font = MOLightFont(14);
                    soldLabel.textAlignment = NSTextAlignmentRight;
                    soldLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Sold:%d","已售:%d"),[dictData[@"sold_count"] intValue]];
                      [cell.contentView addSubview:soldLabel];
                    
                    CGSize titleSize = [soldLabel.text moSizeWithFont:soldLabel.font withWidth:100];
                    soldLabel.frame = CGRectMake([GDPublicManager instance].screenWidth-titleSize.width-15, offsetY,
                                                       titleSize.width, 20);
                    
                 }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
        else if (indexPath.section == kVendorSection)
        {
            if (indexPath.row == 0)
            {
                UIArabicTableViewCell *cell ;
                static NSString *ID = @"vendorname";
                cell = [tableView dequeueReusableCellWithIdentifier:ID];
                if (cell == nil) {
                    cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            }
            
                NSString*  vendor_name=@"";
                if(dictData[@"vendor_info"][@"vendor_name"] != [NSNull null] && dictData[@"vendor_info"][@"vendor_name"] != nil)
                {
                    SET_IF_NOT_NULL(vendor_name, dictData[@"vendor_info"][@"vendor_name"]);
                }
            
                cell.textLabel.font =MOLightFont(14);
                cell.textLabel.text = vendor_name;
                
                return cell;
            }
            else
            {
                if (indexPath.row == 1)
                {
                    static NSString *CellIdentifier = @"vendor1";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (!cell) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    }

                    NSString*  address=@"";
                    NSString*  city=@"";
                    NSString*  area=@"";
                    
                    SET_IF_NOT_NULL(address, dictData[@"vendor_info"][@"address"]);
                    SET_IF_NOT_NULL(city, dictData[@"vendor_info"][@"zone_name"]);
                    SET_IF_NOT_NULL(area, dictData[@"vendor_info"][@"area_name"]);
                    
                    NSString *vendor_address;
                    if (area.length>0)
                        vendor_address=[NSString stringWithFormat:@"%@,%@,%@",address,area,city];
                    else
                        vendor_address=[NSString stringWithFormat:@"%@,%@",address,city];
                    
                    UILabel* addressLabel = MOCreateLabelAutoRTL();
                    addressLabel.backgroundColor = [UIColor clearColor];
                    addressLabel.numberOfLines = 0;
                    addressLabel.textColor = MOColor66Color();
                    addressLabel.text = vendor_address;
                    addressLabel.font = MOLightFont(12);
                    addressLabel.frame = CGRectMake(10, 0, [GDPublicManager instance].screenWidth-40, 50);
                    
                    [cell.contentView addSubview:addressLabel];
                    
                    vendor_phone = @"";
                    SET_IF_NOT_NULL(vendor_phone, dictData[@"vendor_info"][@"telephone"]);
                 
                    UIButton* callBut = [UIButton buttonWithType:UIButtonTypeCustom];
                    callBut.frame = CGRectMake([GDPublicManager instance].screenWidth-50, 0, 45, 50);
                    [callBut addTarget:self action: @selector(phoneCall) forControlEvents:UIControlEventTouchUpInside];
                    [callBut setImage:[UIImage imageNamed:@"helpcallphone.png"] forState:UIControlStateNormal];
                    [cell.contentView addSubview:callBut];
                    
                    MODebugLayer(addressLabel, 1.f, [UIColor redColor].CGColor);
                    MODebugLayer(callBut, 1.f, [UIColor redColor].CGColor);

                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    return cell;
                }
//                else if (indexPath.row == 2)
//                {
//                    GDVendorCell *cell ;
//                    static NSString *ID = @"vendor2";
//                    cell = [tableView dequeueReusableCellWithIdentifier:ID];
//                    if (cell == nil) {
//                        cell = [[GDVendorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
//                    }
//                    int distance = 0;
//                    if(dictData[@"distance"] != [NSNull null] && dictData[@"distance"] != nil)
//                        distance =  [dictData[@"distance"] intValue];
//                    if (distance < 1000)
//                    {
//                        cell.titleLabel.text = [NSString stringWithFormat:@"%dm",distance];
//                    }
//                    else
//                    {
//                        cell.titleLabel.text = [NSString stringWithFormat:@"%.1fkm",distance*1.0/1000];
//                    }
//                    
//                    cell.iconImage.image = [UIImage imageNamed:@"location.png"];
//                    cell.iconImage.frame = CGRectMake(13, 15,
//                                                      15, 19);
//                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                    return cell;
//                }
                
            }
        }
        else if (indexPath.section == kPackageSection)
        {
            if (indexPath.row == 0)
            {
                static NSString *CellIdentifier = @"Package";
                UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                }
                cell.textLabel.font = MOLightFont(14);
                cell.textLabel.text= NSLocalizedString(@"Package", @"套餐");
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [cell setSeparatorInset:UIEdgeInsetsZero];
                }
                
                if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                    [cell setLayoutMargins:UIEdgeInsetsZero];
                }
                
                return cell;
            }
            else
            {
                static NSString *ID = @"Package1";
                GDPackageListCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
                if (cell == nil) {
                cell = [[GDPackageListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
                    
                cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
               
            }
    
                NSDictionary* dict = [_packageList objectAtIndex:indexPath.row-1];
                cell.nameLabel.text   = dict[@"name"];
                cell.numberLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d Dish", @"%d 份"),[dict[@"quantity"] intValue]];
                cell.priceLabel.text  = [NSString stringWithFormat:@"%@%d", [GDPublicManager instance].currency,[dict[@"sprice"] intValue]];
                return cell;
            }
        }
        else if (indexPath.section == kHighlightsSection)
        {
            if (indexPath.row == 0)
            {
                static NSString *CellIdentifier = @"kHighlightsSection1";
                UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                }
                
                cell.textLabel.font = MOLightFont(14);
                cell.textLabel.text= NSLocalizedString(@"Highlights", @"特色");
                return cell;
            }
            else
            {
                static NSString *CellIdentifier = @"kHighlightsSection2";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                for (UIView *view in cell.contentView.subviews)
                {
                    [view removeFromSuperview];
                }
                
                if (highlightsLabel==nil)
                {
                    highlightsLabel = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [GDPublicManager instance].screenWidth,highlightHeight)];
                    highlightsLabel.backgroundColor = MOColorAppBackgroundColor();
                    highlightsLabel.delegate = self;
                    highlightsLabel.scrollView.scrollEnabled=NO;
                    
                    [highlightsLabel loadHTMLString:sHighlights baseURL:nil];
                }
                
                [cell.contentView addSubview:highlightsLabel];
                return cell;
            }
            
        }
        else if (indexPath.section == kHowtouseSection)
        {
            if (indexPath.row == 0)
            {
                static NSString *CellIdentifier = @"kHowtouseSection";
                UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                }
                
                cell.textLabel.font = MOLightFont(14);
                cell.textLabel.text= NSLocalizedString(@"Terms and Conditions", @"使用规则");
                return cell;
            }
            else
            {
                static NSString *CellIdentifier = @"kHowtouseSection2";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                [cell.contentView addSubview:howtouseLabel];
                return cell;
            }
            
        }
        else if (indexPath.section == kMoreinfoSection)
        {
            if (indexPath.row == 0)
            {
                static NSString *CellIdentifier = @"kMoreinfoSection";
                UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                }
                
                cell.textLabel.font = MOLightFont(14);
                cell.textLabel.text= NSLocalizedString(@"More Information", @"使用规则");
                return cell;
            }
            else
            {
                static NSString *CellIdentifier = @"kMoreinfoSection2";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                [cell.contentView addSubview:moreinfoLabel];
                return cell;
            }

        }
        else if (indexPath.section == kCuisinesSection)
        {
            if (indexPath.row == 0)
            {
                static NSString *CellIdentifier = @"sSpecialty";
                UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                }
                
                cell.textLabel.font = MOLightFont(14);
                cell.textLabel.text= NSLocalizedString(@"Specialty", @"招牌菜");
                return cell;
            }
            else
            {
                static NSString *CellIdentifier = @"sCuisines1";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                [cell.contentView addSubview:cuisinesLabel];
                return cell;
            }
        }
        else if (indexPath.section == kTagSection)
        {
            if (indexPath.row == 0)
            {
                static NSString *CellIdentifier = @"sTag";
                UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                }
                
                cell.textLabel.font = MOLightFont(14);
                cell.textLabel.text= NSLocalizedString(@"Tags", @"提供服务");
                return cell;

            }
            else
            {
                static NSString *CellIdentifier = @"sTag1";
                GDTagListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[GDTagListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.tickImage.image = [UIImage imageNamed:@"tick_normal.png"];
                cell.serveiceLabel.text = [_tagArrays objectAtIndex:indexPath.row-1];
                
                return cell;
            }
        }
        else if (indexPath.section == kPaymentInfo)
        {
            if (indexPath.row == 0)
            {
                static NSString *CellIdentifier = @"kPaymentSection1";
                UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                }
                
                cell.textLabel.font = MOLightFont(14);
                cell.textLabel.text= NSLocalizedString(@"Payment Instruction", @"支付说明");
                return cell;
            }
            else
            {
                static NSString *CellIdentifier = @"kPaymentSection2";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                [cell.contentView addSubview:paymentLabel];
                return cell;
            }

        }
        else if (indexPath.section == kRateSection)
        {
            if (indexPath.row == 0)
            {
                static NSString *CellIdentifier = @"rateList";
                UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                }
                
                for (UIView *view in cell.contentView.subviews)
                {
                    [view removeFromSuperview];
                }

                if (rateView==nil)
                {
                    rateView = [[DJQRateView alloc] init];
                    rateView.frame = CGRectMake(15, 0, 100, 40);
                }
                
                rateView.maxRate = 5;
                rateView.rate = [dictData[@"rating"] floatValue];
                [cell.contentView addSubview:rateView];
                
                UILabel* rateLable = MOCreateLabelAutoRTL();
                rateLable.backgroundColor = [UIColor clearColor];
                rateLable.textColor = colorFromHexString(@"999999");
                rateLable.font = MOLightFont(14);
                rateLable.text = [NSString stringWithFormat:@"%.1f",[dictData[@"rating"] floatValue]];
                rateLable.frame = CGRectMake(125, 0, 30, 40);
                [cell.contentView addSubview:rateLable];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                return cell;
            }
            else
            {
                GDRateListCell *cell;
                static NSString *ID = @"rateList1";
                cell = [tableView dequeueReusableCellWithIdentifier:ID];
                if (cell == nil) {
                    cell = [[GDRateListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
                }
                
                NSDictionary* dict = [_rateList objectAtIndex:indexPath.row-1];
                
                cell.userLabel.text  = dict[@"author"];
                cell.rateLabel.text  = [NSString stringWithFormat:NSLocalizedString(@"Rated %.1f", @"评分 %.1f"),[dict[@"rating"] floatValue]];
                cell.dateLabel.text  = dict[@"date_added"];
                
                NSString* strChinese = dict[ExText];
                if (strChinese.length>0)
                    cell.contentLabel.text = strChinese;
                else
                    cell.contentLabel.text = dict[@"text"];
                
                if(dict[@"imagelist_list"] != [NSNull null] && dict[@"imagelist_list"]!= nil)
                {
                    NSArray* imagelist_list = dict[@"imagelist_list"];
                    if (imagelist_list.count>0)
                    {
                        cell.imageArrar = imagelist_list;
                    }
                }
                
                if ([[GDSettingManager instance] isChinese])
                {
                    cell.translationBut.hidden = NO;
                    cell.translationBut.tag = indexPath.row-1;
                    [cell.translationBut addTarget:self action:@selector(tapTrans:) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    cell.translationBut.hidden = YES;
                }
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                return cell;
            }
        }

    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!reloading && dictData==nil)
    {
        if (netWorkError)
        {
             isLoadData = NO;
            [mainTableView insertSubview:[self noNetworkView] atIndex:0];
         
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getProductData)];
            [[self noNetworkView] addGestureRecognizer:tapGesture];
        }
    }
    
    if (dictData!=nil)
    {
        [_noNetworkView removeFromSuperview];
    }
    
    int nIndex  = 0;
    if (dictData!=nil)
        kNameSection = nIndex++;
    else
        kNameSection = 20;
    
    if (payment_info.length>0)
        kPaymentInfo = nIndex++;
    else
        kPaymentInfo = 20;
    
    if (dictData!=nil)
        kVendorSection = nIndex++;
    else
        kVendorSection = 20;
    
    if (_packageList.count>0)
    {
        kPackageSection = nIndex++;
    }
    else
        kPackageSection = 20;
    
    if (sHighlights.length>0)
    {
        kHighlightsSection = nIndex++;
    }
    else
        kHighlightsSection = 20;
    
    if (sHowtouse.length>0)
    {
        kHowtouseSection = nIndex++;
    }
    else
        kHowtouseSection = 20;

    if (sMoreinfo.length>0)
    {
        kMoreinfoSection = nIndex++;
    }
    else
        kMoreinfoSection = 20;
    
    if (sCuisines.length>0)
    {
        kCuisinesSection = nIndex++;
    }
    else
        kCuisinesSection = 20;
    
    if (_tagArrays.count>0)
    {
        kTagSection = nIndex++;
    }
    else
        kTagSection = 20;
    
    if (_rateList.count>0)
    {
        kRateSection = nIndex++;
    }
    else
        kRateSection = 20;
    
    return nIndex;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
       if (section == kNameSection)
       {
            return 3;
       }
       else if (section == kVendorSection)
       {
            return 2;
       }
       else if (section == kPackageSection)
       {
            return _packageList.count+1;
       }
       else if (section == kHighlightsSection)
       {
           return 2;
       }
       else if (section == kHowtouseSection)
       {
           return 2;
       }
       else if (section == kMoreinfoSection)
       {
           return 2;
       }
       else if (section == kPaymentInfo)
       {
           return 2;
       }
    
       else if (section == kCuisinesSection)
       {
           return 2;
       }
       else if (section == kTagSection)
       {
           return _tagArrays.count+1;
       }
       else if (section == kRateSection)
       {
           return _rateList.count+1;
       }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if  (indexPath.section==kNameSection)
    {
        if (indexPath.row == 0)
        {
            return 75;
        }
        else if (indexPath.row == 1)
        {
            return 40;
        }
        else
        {
            return 40;
        }
    }
    else if  (indexPath.section==kVendorSection)
    {
        if (indexPath.row == 0)
            return 40;
        return 60;
    }
    else if  (indexPath.section==kPackageSection)
    {
        if (indexPath.row==0)
            return 40;
        else
            return 35;
    }
    else if (indexPath.section == kPaymentInfo)
    {
        if (indexPath.row==0)
            return 40;
        else
        {
            if (paymentLabel==nil)
            {
                paymentLabel = MOCreateLabelAutoRTL();
                paymentLabel.backgroundColor = [UIColor clearColor];
                paymentLabel.numberOfLines = 0;
            }
            
            paymentLabel.textColor = MOColor66Color();
            paymentLabel.text = payment_info;
            paymentLabel.font = MOLightFont(12);
            CGSize fittingSize = [paymentLabel sizeThatFits:CGSizeMake([GDPublicManager instance].screenWidth-30, 20)];
            
            paymentLabel.frame = CGRectMake(15, 10, [GDPublicManager instance].screenWidth-30, fittingSize.height);
            
            return fittingSize.height+20;

        }
    }
    else if (indexPath.section == kCuisinesSection)
    {
        if (indexPath.row == 0)
            return 40;
        else
        {
            if (cuisinesLabel==nil)
            {
                cuisinesLabel = MOCreateLabelAutoRTL();
                cuisinesLabel.backgroundColor = [UIColor clearColor];
                cuisinesLabel.numberOfLines = 0;
            }
            cuisinesLabel.textColor = MOColor66Color();
            cuisinesLabel.text = sCuisines;
            cuisinesLabel.font = MOLightFont(12);
            CGSize fittingSize = [cuisinesLabel sizeThatFits:CGSizeMake([GDPublicManager instance].screenWidth-30, 20)];
        
            cuisinesLabel.frame = CGRectMake(15, 10, [GDPublicManager instance].screenWidth-30, fittingSize.height);
        
            return fittingSize.height+20;
        }
    }
    else if (indexPath.section == kTagSection)
    {
        if (indexPath.row==0)
            return 40;
        else
            return 30;
    }
    else if (indexPath.section == kHighlightsSection)
    {
        if (indexPath.row==0)
        {
            return 40;
        }
        else
        {
            return highlightHeight;
        }
    }
    else if (indexPath.section == kHowtouseSection)
    {
        if (indexPath.row==0)
        {
            return 40;
        }
        else
        {
            if (howtouseLabel==nil)
            {
                howtouseLabel = MOCreateLabelAutoRTL();
                howtouseLabel.backgroundColor = [UIColor clearColor];
                howtouseLabel.numberOfLines = 0;
            }
            
            howtouseLabel.textColor = MOColor66Color();
            howtouseLabel.text = sHowtouse;
            howtouseLabel.font = MOLightFont(12);
            CGSize fittingSize = [howtouseLabel sizeThatFits:CGSizeMake([GDPublicManager instance].screenWidth-30, 20)];
                
            howtouseLabel.frame = CGRectMake(15, 10, [GDPublicManager instance].screenWidth-30, fittingSize.height);
                
            return fittingSize.height+20;
        }
    }
    else if (indexPath.section == kMoreinfoSection)
    {
        if (indexPath.row==0)
        {
            return 40;
        }
        else
        {
            if (moreinfoLabel==nil)
            {
                moreinfoLabel = MOCreateLabelAutoRTL();
                moreinfoLabel.backgroundColor = [UIColor clearColor];
                moreinfoLabel.numberOfLines = 0;
            }
            
            moreinfoLabel.textColor = MOColor66Color();
            moreinfoLabel.text = sMoreinfo;
            moreinfoLabel.font = MOLightFont(12);
            CGSize fittingSize = [moreinfoLabel sizeThatFits:CGSizeMake([GDPublicManager instance].screenWidth-30, 20)];
            
            moreinfoLabel.frame = CGRectMake(15, 10, [GDPublicManager instance].screenWidth-30, fittingSize.height);
            
            return fittingSize.height+20;
        }
    }
    else if (indexPath.section == kRateSection)
    {
        if (indexPath.row == 0)
            return 40;
            
        NSDictionary* dict = [_rateList objectAtIndex:indexPath.row-1];
        
        NSString* strChinese = dict[ExText];
        if (strChinese.length<=0)
            strChinese = dict[@"text"];
        
        CGSize titleSize = [strChinese moSizeWithFont:MOLightFont(12) withWidth:[GDPublicManager instance].screenWidth-60];
            
        float  photosWidth = 0;
        if(dict[@"imagelist_list"] != [NSNull null] && dict[@"imagelist_list"]!= nil)
        {
            NSArray* imagelist_list = dict[@"imagelist_list"];
            if (imagelist_list.count>0)
            {
                photosWidth = (([[UIScreen mainScreen] bounds].size.width-70.0)/4);
            }
        }
        
        float translationBut = 0;
        if ([[GDSettingManager instance] isChinese])
            translationBut = 0;
        
        return 56+titleSize.height+8+photosWidth+translationBut;

    }

    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == kVendorSection)
    {
        if (indexPath.row == 0)
        {
            int vendor_id = 0;
            NSString* vendor_name = @"vendor name";
            NSString* vendor_image = @"";
            NSString* vendor_url = @"";
        
            NSString* type = @"";
            SET_IF_NOT_NULL(type, dictData[@"type"]);
            if(dictData[@"vendor_info"] != [NSNull null] && dictData[@"vendor_info"] != nil)
            {
                vendor_id = [dictData[@"vendor_info"][@"vendor_id"] intValue];
                SET_IF_NOT_NULL(vendor_name, dictData[@"vendor_info"][@"vendor_name"]);
                SET_IF_NOT_NULL(vendor_url, dictData[@"vendor_info"][@"store_url"]);
                SET_IF_NOT_NULL(vendor_image, dictData[@"vendor_info"][@"vendor_image"]);
            }
        
            if (vendor_id>0)
            {
              
                GDLiveVendorViewController * vc = [[GDLiveVendorViewController alloc] init:vendor_id withName:vendor_name withUrl:vendor_url withImage:vendor_image];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else if (indexPath.row ==2)
        {
            
        }
    }
    else if (indexPath.section == kRateSection)
    {
        if (indexPath.row == 0)
        {
            GDRateViewController* viewController  = [[GDRateViewController alloc] initWithProduct:productId];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
   
}

#pragma mark - scroll Delegate

- (NSInteger)numberOfPageInPageScrollView:(OTPageScrollView*)pageScrollView{
    return [_imageArray count];
}

- (UIView*)pageScrollView:(OTPageScrollView*)pageScrollView viewForRowAtIndex:(int)index
{
    UIImageView * iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 200)];
    iconImage.contentMode = UIViewContentModeScaleAspectFill;
    [iconImage setClipsToBounds:YES];
    
    [iconImage sd_setImageWithURL:[NSURL URLWithString:[_imageArray[index] encodeUTF]] placeholderImage:[UIImage imageNamed:@"product_detail_default.png"]];
    return iconImage;
}

- (CGSize)sizeCellForPageScrollView:(OTPageScrollView*)pageScrollView
{
    return CGSizeMake(smallImageWidth,smallImageHeight);
}

- (void)pageScrollView:(OTPageScrollView *)pageScrollView didTapPageAtIndex:(NSInteger)index{
   
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity: [_imageArray count]];
    for (int i = 0; i < [_imageArray count]; i++) {
        NSString * getImageStrUrl = [NSString stringWithFormat:@"%@", [_imageArray objectAtIndex:i] ];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString: [getImageStrUrl encodeUTF] ];
        [photos addObject:photo];
    }
    
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init:NO];
    browser.currentPhotoIndex = index;
    browser.photos = photos;
    [browser show];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int currentPage = scrollView.contentOffset.x/scrollView.frame.size.width;
    PScrollView.pageControl.currentPage = currentPage;
    
    PScrollView.pageLabel.text = [NSString stringWithFormat:@"%u / %ld",currentPage+1,_imageArray.count];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect frame = webView.frame;
    //CGSize fittingSize = [webView  sizeThatFits:CGSizeMake([GDPublicManager instance].screenWidth, 20)];
    CGSize fittingSize = [webView  sizeThatFits:CGSizeMake(0,0)];
    frame.size = fittingSize;
    webView.frame = frame;
    
    highlightHeight = frame.size.height;
    
    [self performSelectorOnMainThread:@selector(reLoadView) withObject:nil waitUntilDone:NO];
    
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
            [self dismissViewControllerAnimated:NO completion:nil];
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
                                      [self dismissViewControllerAnimated:NO completion:nil];
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
    NSString* text = [NSString stringWithFormat:NSLocalizedString(@"Hurry Up:%@",@"赶紧去抢购:%@"),name];
    
    NSURL*     url = [NSURL URLWithString:[productUrl encodeUTF]];
    
    __block UIImage* imageData = nil;
    
    if (_imageArray.count>0)
    {
        NSString* imgUrl = [_imageArray objectAtIndex:0];
        [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]  options:SDWebImageLowPriority|SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            imageData = image;
            
            //大小不能超过32K
            float imageRatio = image.size.height / image.size.width;
            CGFloat newWidth = image.size.width;
            if (newWidth > 160) {
                newWidth = 160;
            }
            
            imageData= [UIImage scaleImage:image ToSize:CGSizeMake(newWidth, newWidth*imageRatio)];
            
            if ([imageIndex isEqualToString:@"sns_icon_facebook"])
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
            else if  ([imageIndex isEqualToString:@"sns_icon_twitter"])
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
            else if  ([imageIndex isEqualToString:@"sns_icon_qq"])
            {
                NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
                [parameters setObject:text forKey:@"paramTitle"];
                
                if (productUrl.length>0)
                    [parameters setObject:[productUrl encodeUTF] forKey:@"paramUrl"];
                
                if(dictData[@"vendor_info"] != [NSNull null] && dictData[@"vendor_info"] != nil)
                {
                    [parameters setObject:dictData[@"vendor_info"][@"vendor_name"] forKey:@"paramSummary"];
                }
                else
                {
                    [parameters setObject:@"Greadeal" forKey:@"paramSummary"];
                }
                
                if (_imageArray.count>0)
                {
                    NSString* imgUrl = [_imageArray objectAtIndex:0];
                    [parameters setObject:imgUrl forKey:@"paramImages"];
                }
                
                [[qqAccountManage sharedInstance] clickAddShare:parameters];

            }
            else if  ([imageIndex isEqualToString:@"sns_icon_whatsapp"])
            {
                [[whatsappAccountManage sharedInstance] sendMessageToFriend:text withUrl:productUrl];
            }
            else if  ([imageIndex isEqualToString:@"sns_icon_wechat"])
            {
                NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
                [parameters setObject:text forKey:@"title"];
                [parameters setObject:@"Greadeal" forKey:@"description"];
                if (productUrl!=nil)
                    [parameters setObject:[productUrl encodeUTF] forKey:@"url"];
                if (imageData!=nil)
                    [parameters setObject:imageData forKey:@"image"];
                [[weixinAccountManage sharedInstance] sendMessageToFriend:parameters];
            }
            else if  ([imageIndex isEqualToString:@"sns_icon_moments"])
            {
                NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
                [parameters setObject:text forKey:@"title"];
                if (productUrl!=nil)
                    [parameters setObject:[productUrl encodeUTF] forKey:@"url"];
                
                [parameters setObject:@"Greadeal" forKey:@"description"];
                if (imageData!=nil)
                    [parameters setObject:imageData forKey:@"image"];
                
                [[weixinAccountManage sharedInstance] sendMessageToCycle:parameters];
            }
           
        }];
    }
    
}

- (void)didClickOnCancelButton
{
    LOG(@"didClickOnCancelButton");
}

@end

