//
//  GDLiveVendorViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/25.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDLiveVendorViewController.h"
#import "GDProductDetailsViewController.h"
#import "GDVoucherListCell.h"
#import "GDVendorCell.h"

#import "RDVTabBarController.h"

#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

#import "GDGridLayoutViewController.h"

#import "GDRateListCell.h"
#import "DJQRateView.h"

#import "GDRateViewController.h"
#import "GDOpenHourListCell.h"
#import "GDTagListCell.h"

#import "GDLoginViewController.h"
#import "GDRegsiterViewController.h"

#import "UIActionSheet+Blocks.h"

#import "GDRatingViewController.h"
#import "ALCustomColoredAccessory.h"

#import "GDProductListCell.h"
#import "GDWholeMapViewController.h"

#define  numberOfLine 4
#define  photosHeight (([[UIScreen mainScreen] bounds].size.width-20.0)/numberOfLine)

#define  smallImageWidth  ([[UIScreen mainScreen] bounds].size.width)
#define  smallImageHeight ([[UIScreen mainScreen] bounds].size.width/320.0*180)

@interface GDLiveVendorViewController ()

@end

@implementation GDLiveVendorViewController

#pragma mark - init

- (id)init:(int)vendor_id withName:(NSString*)vendor_name withUrl:(NSString*)vendor_url withImage:(NSString*)vendor_image;
{
    self = [super init];
    if (self)
    {
        vendorData = nil;
        fee_per_person = 0;
        is_wish_vendor = 0;
        
        _imageList  = [[NSMutableArray alloc] init];
        _menuList   = [[NSMutableArray alloc] init];
        _productData= [[NSMutableArray alloc] init];
        _rateList   = [[NSMutableArray alloc] init];
        _tagArrays  = [[NSMutableArray alloc] init];
        _openHours  = [[NSMutableArray alloc] init];
        
        vendorId  = vendor_id;
        vendorUrl = vendor_url;
        vendorName =vendor_name;
        vendorImage=vendor_image;
        
        self.title = NSLocalizedString(@"Intro", @"介绍");
       
        
        sCuisines  = @"";
        
        expandedSections = [[NSMutableIndexSet alloc] init];
    }
    return self;
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
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    UIBarButtonItem*  shareButItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share.png"] style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(shareAction)];
    
    self.navigationItem.rightBarButtonItem = shareButItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)addHeaderView
{
    CGRect r =  self.view.bounds;
    
    PScrollView = [[OTPageView alloc] initWithFrame:CGRectMake(0, 0,r.size.width,smallImageHeight)];
    PScrollView.pageScrollView.dataSource = self;
    PScrollView.pageScrollView.delegate = self;
    PScrollView.pageScrollView.padding  = 0;
    PScrollView.pageScrollView.leftRightOffset = 0;
    
    PScrollView.pageScrollView.frame = CGRectMake(0, 0,smallImageWidth, smallImageHeight);
    MODebugLayer(PScrollView.pageScrollView, 1.f, [UIColor redColor].CGColor);
    PScrollView.backgroundColor = [UIColor colorWithRed:236/255.0 green:234/255.0 blue:245/255.0 alpha:1.0];
    
    [PScrollView.pageScrollView reloadData];
    
    PScrollView.pageControl.numberOfPages = _imageList.count;
    PScrollView.pageControl.currentPage = 0;
    PScrollView.pageControl.hidesForSinglePage = YES;
    PScrollView.pageLabel.text = [NSString stringWithFormat:@"%u / %ld",1,_imageList.count];
    
    if (_imageList.count<10)
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

#pragma mark - Data

- (void)getRateData
{
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/vendor/get_vendor_review_list"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"vendor_id":@(vendorId),@"page":@(1),@"limit":@(3)};
    
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

- (void)getVendorData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    reloading = YES;
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/vendor/get_detail_info"];
    
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"vendor_id":@(vendorId),@"longitude":@([[GDSettingManager instance] getCityLongitude]),@"latitude":@([[GDSettingManager instance] getCityLatitude])};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             
             vendorData = responseObject[@"data"][@"vendor_info"];
             
             NSString*  address=@"";
             NSString*  city=@"";
             NSString*  area=@"";
             
             SET_IF_NOT_NULL(vendor_phone, vendorData[@"telephone"]);
             SET_IF_NOT_NULL(vendorName, vendorData[@"vendor_name"]);
             SET_IF_NOT_NULL(vendorImage, vendorData[@"vendor_image"]);
             SET_IF_NOT_NULL(vendorUrl, vendorData[@"store_url"]);
             
             SET_IF_NOT_NULL(address, vendorData[@"address"]);
             SET_IF_NOT_NULL(city, vendorData[@"zone_name"]);
             SET_IF_NOT_NULL(area, vendorData[@"area_name"]);
             
             SET_IF_NOT_NULL(sDescription, vendorData[@"description"]);
             
             if (area.length>0)
                 vendor_address = [NSString stringWithFormat:@"%@,%@,%@",address,area,city];
             else
                 vendor_address = [NSString stringWithFormat:@"%@,%@",address,city];
             
             fee_per_person = [vendorData[@"fee_per_person"] intValue];
             is_wish_vendor = [vendorData[@"is_wish_vendor"] intValue];
             
             NSArray* timeArray = nil;
             SET_IF_NOT_NULL(timeArray,vendorData[@"open_time"]);
             if (timeArray.count>0)
             {
                 [_openHours addObjectsFromArray:timeArray];
             }
             
             NSArray* tArray = nil;
             SET_IF_NOT_NULL(tArray,vendorData[@"tags"]);
             if (tArray.count>0)
             {
                 [_tagArrays addObjectsFromArray:tArray];
             }
             
             SET_IF_NOT_NULL(sCuisines, vendorData[@"entree"]);
             
             NSArray* imageArray = nil;
             SET_IF_NOT_NULL(imageArray,vendorData[@"image_list"]);
             if (imageArray.count>0)
             {
                 [_imageList addObjectsFromArray:imageArray];
             }

             NSString* imgUrl = @"";
             SET_IF_NOT_NULL(imgUrl, vendorData[@"vendor_image"])
             if (imgUrl.length>0)
             {
                 [_imageList addObject:imgUrl];
             }

             if (_imageList.count>0)
                 [self addHeaderView];
             
             NSArray* menuArray = nil;
             SET_IF_NOT_NULL(menuArray,vendorData[@"menu_list"]);
             if (menuArray.count>0)
             {
                 [_menuList addObjectsFromArray:menuArray];
             }
             
             NSArray* productArray = nil;
             SET_IF_NOT_NULL(productArray,vendorData[@"product_list"]);
             if (productArray.count>0)
             {
                 [_productData addObjectsFromArray:productArray];
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
         
         [self getRateData];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self stopLoad];
         [self reLoadView];
         
         [ProgressHUD showError:error.localizedDescription];
     }];
}

#pragma mark Refresh
- (void)refreshData
{
    LOG(@"refresh data");
    [self getVendorData];
}

- (void)nextPage
{
}

#pragma mark Action
- (void)requestLogin
{
    [UIActionSheet showInView:self.view
                    withTitle:NSLocalizedString(@"Please login first", @"您还没有登录,请先登录")
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

- (void)tapCall
{
    [[GDPublicManager instance] makeCall:vendor_phone  withView:self.view];
}

- (void)tapWishlist
{
    if ([GDPublicManager instance].cid>0)
    {
        [ProgressHUD show:nil];
    
        NSString* url;
        NSDictionary *parameters;
    
        parameters = @{@"vendor_id":@(vendorId),@"token":[GDPublicManager instance].token};
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
        if (is_wish_vendor==1)
        {
            url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Customer/remove_vendor_wishlist"];
        }
        else
        {
            url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Customer/add_vendor_wishlist"];
        }
    
        [manager POST:url
        parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [ProgressHUD dismiss];
             
             int status = [responseObject[@"status"] intValue];
             if (status==1)
             {
                 if (is_wish_vendor==1) is_wish_vendor = 0; else is_wish_vendor = 1;
                 [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
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
    else
    {
        [self requestLogin];
    }
}

- (void)tapRate
{
    if ([GDPublicManager instance].cid>0)
    {
        GDRatingViewController* vc = [[GDRatingViewController alloc] initWithVendor:vendorId];
        
        UINavigationController *nc = [[UINavigationController alloc]
                                      initWithRootViewController:vc];
        
        [self.navigationController presentViewController:nc animated:YES completion:^(void) {}];

    }
    else
    {
        [self requestLogin];
    }
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

#pragma mark UIView

- (void)reLoadView
{
    [mainTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    if (!isLoadData)
    {
        [self  getVendorData];
        isLoadData = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [ProgressHUD dismiss];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)tapImageView:(UIGestureRecognizer *)tapGesture
{
    UIImageView *button = (UIImageView *)tapGesture.view;
    int index = (int)button.tag;
    
    if (index>=0)
    {
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity: [_imageList count]];
        for (int i = 0; i < [_menuList count]; i++) {
            NSString* getImageStrUrl = [_menuList objectAtIndex:i];
           
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString: [getImageStrUrl encodeUTF] ];
            [photos addObject:photo];
        }
        
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init:NO];
        browser.currentPhotoIndex = index;
        browser.photos = photos;
        [browser show];
    }
    
}

- (UIView*)makeOrderView:(NSString*)imageUrl withIndex:(int)nIndex
{
    float offsetY = 5;
    float pHeight = photosHeight-offsetY*2;
    float InteritemSpacing  = (self.view.frame.size.width-pHeight*numberOfLine)/(numberOfLine+1);
    
    float offsetX = nIndex*photosHeight+InteritemSpacing;
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        offsetX = [GDPublicManager instance].screenWidth - offsetX - photosHeight;
    }
    
    UIImageView * iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX,offsetY, pHeight, pHeight)];
    iconImage.tag = nIndex;
    iconImage.image = [UIImage imageNamed:imageUrl];
    iconImage.userInteractionEnabled = YES;
    [iconImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)]];
    [iconImage sd_setImageWithURL:[NSURL URLWithString:[imageUrl encodeUTF]]
                 placeholderImage:[UIImage imageNamed:@"live_store_default.png"]];
    
    MODebugLayer(iconImage, 1.f, [UIColor redColor].CGColor);
    
    return iconImage;
}

- (UIView*)makeOrderView:(NSString*)text withImage:(NSString*)imageUrl withSel:(SEL) callback withX:(float)startX withVLine:(BOOL)isV
{
    float butWidth  = self.view.frame.size.width/3;
    float butHeight = 60;
    float offsetY   = 10;
    
    UIView*  button = [[UIView alloc] initWithFrame:CGRectMake(startX, 0, butWidth, butHeight)];
    button.backgroundColor = [UIColor whiteColor];
    button.userInteractionEnabled = YES;
    [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:callback]];
    
    UIImageView* iconImage = [[UIImageView alloc]initWithFrame:CGRectMake((butWidth-26)/2, offsetY, 20, 20)];
    
    iconImage.image = [UIImage imageNamed:imageUrl];
    [button addSubview:iconImage];
    
    offsetY+=20;
    
    UILabel* titleLabel =  MOCreateLabelAutoRTL();
    titleLabel.frame=CGRectMake(0, offsetY, butWidth, 25);
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.font = MOLightFont(12.0);
    titleLabel.textColor = MOColorBlueBlack();
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = text;
    [button addSubview:titleLabel];
    
    if (isV)
    {
        UIImageView* iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(butWidth-0.5, 10, 1, 40)];
        iconImage.image = [UIImage imageNamed:@"line_v.png"];
        [button addSubview:iconImage];
    }
    return button;
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
    
    if(vendorData[@"latitude"] != [NSNull null] && vendorData[@"latitude"] != nil)
    {
        latitude = [vendorData[@"latitude"] floatValue];
    }
    
    if(vendorData[@"longitude"] != [NSNull null] && vendorData[@"longitude"] != nil)
    {
        longitude = [vendorData[@"longitude"] floatValue];
    }
    
    NSString*  vendor_name=@"";
    if(vendorData[@"vendor_name"] != [NSNull null] && vendorData[@"vendor_name"] != nil)
    {
        SET_IF_NOT_NULL(vendorData, vendorData[@"vendor_name"]);
    }
    
    GDWholeMapViewController* nv =  [[GDWholeMapViewController alloc] init:latitude withLong:longitude withName:vendor_name];
    [self.navigationController pushViewController:nv animated:YES];
}

- (void)dirctionMap:(UIGestureRecognizer*)gestureRecognizer
{
    float latitude=0.0;
    float longitude=0.0;
    
    if(vendorData[@"latitude"] != [NSNull null] && vendorData[@"latitude"] != nil)
    {
        latitude = [vendorData[@"latitude"] floatValue];
    }
    
    if(vendorData[@"longitude"] != [NSNull null] && vendorData[@"longitude"] != nil)
    {
        longitude = [vendorData[@"longitude"] floatValue];
    }
    
    NSString*  vendor_name=@"";
    if(vendorData[@"vendor_name"] != [NSNull null] && vendorData[@"vendor_name"] != nil)
    {
        SET_IF_NOT_NULL(vendorData, vendorData[@"vendor_name"]);
    }
    
    CLLocationCoordinate2D endCoor = CLLocationCoordinate2DMake(latitude,longitude);
                 
    [[GDPublicManager instance] mapDiredection:endCoor withEnd:endCoor withToName:vendor_name withView:self.view];
    
}

#pragma mark - map view
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[SVAnnotation class]]) {
        NSString *identifier = NSLocalizedString(@"Vendor Location",@"商家位置");
        SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[vmapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if(pulsingView == nil) {
            pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pulsingView.annotationColor = MOColorSaleFontColor();
            pulsingView.canShowCallout = YES;
        }
        
        return pulsingView;
    }
    
    return nil;
}


#pragma mark - Table view
- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    if (kOpenhoursSection==section) return YES;
    
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kAddressSection)
    {
        if (indexPath.row == 0)
        {
            static NSString *CellIdentifier = @"vendorname";
            UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            cell.textLabel.font = MOLightFont(14);
            cell.textLabel.text= vendorName;
            return cell;
        }
        else if (indexPath.row==1 && fee_per_person>0)
        {
            static NSString *CellIdentifier = @"vendorname1";
            UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            cell.textLabel.font = MOLightFont(14);
            cell.textLabel.text= [NSString stringWithFormat:NSLocalizedString(@"Cost:",@"消费:")];
            
            cell.detailTextLabel.font = MOLightFont(14);
            cell.detailTextLabel.textColor = MOColorSaleFontColor();
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@%d per person",@"%@%d /人"),[GDPublicManager instance].currency,fee_per_person];
           
            return cell;

        }
        else
        {
            GDVendorCell *cell;
            static NSString *ID = @"vendorname2";
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[GDVendorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            }
       
            cell.iconImage.image = [UIImage imageNamed:@"Coordinate.png"];
            cell.titleLabel.text = vendor_address;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.iconImage.frame = CGRectMake(15, 15,
                                              15, 19);
            
            if (vmapView==nil)
            {
                vmapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 100)];
                vmapView.delegate = self;
                [cell.contentView addSubview:vmapView];
                UITapGestureRecognizer *mTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
                [vmapView addGestureRecognizer:mTap];
                
                if ([[GDPublicManager instance] showDiredection])
                {
                UIImageView* dirctionImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-100, 15, 89, 69)];
                dirctionImage.image = [UIImage imageNamed:@"dirctions.png"];
                [vmapView addSubview:dirctionImage];
                dirctionImage.userInteractionEnabled = YES;
                UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dirctionMap:)];
                [dirctionImage addGestureRecognizer:singleTap1];
                
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, 89, 20)];
                label.backgroundColor = [UIColor clearColor];
                label.text = NSLocalizedString(@"Directions", @"导航");
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = [UIColor blackColor];
                label.font = MOLightFont(14);
                [dirctionImage addSubview:label];
                }
                
                float latitude=0.0;
                float longitude=0.0;
                
                if(vendorData[@"latitude"] != [NSNull null] && vendorData[@"latitude"] != nil)
                {
                    latitude = [vendorData[@"latitude"] floatValue];
                }
                
                if(vendorData[@"longitude"] != [NSNull null] && vendorData[@"longitude"] != nil)
                {
                    longitude = [vendorData[@"longitude"] floatValue];
                }
                
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                
                MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.03, 0.03));
                [vmapView setRegion:region animated:NO];
                
                SVAnnotation *annotation = [[SVAnnotation alloc] initWithCoordinate:coordinate];
                annotation.title = NSLocalizedString(@"Vendor Location",@"商家位置");
                [vmapView addAnnotation:annotation];
            }

            return cell;
        }
    }
    else if (indexPath.section == kFavoriteSection)
    {
        static NSString *CellIdentifier = @"kFavoriteSection";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            
        }
    
        float lineWidth = self.view.frame.size.width;
        
        UIView*  favoritePage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lineWidth, 60)];
        favoritePage.backgroundColor = [UIColor whiteColor];
        
        [favoritePage addSubview:[self makeOrderView:NSLocalizedString(@"CALL & BOOK", @"电话订座") withImage:@"helpcallphone.png" withSel:@selector(tapCall) withX:0 withVLine:YES]];
        
        [favoritePage addSubview:[self makeOrderView:NSLocalizedString(@"WISHLIST",@"收藏") withImage:is_wish_vendor==1?@"wishlist_selected.png":@"wishlist_normal.png" withSel:@selector(tapWishlist)
                                               withX:lineWidth/3 withVLine:YES] ];
        [favoritePage addSubview:[self makeOrderView:NSLocalizedString(@"RATE",@"评价") withImage:@"reate.png" withSel:@selector(tapRate)
                                               withX:lineWidth/3*2 withVLine:NO]];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.contentView addSubview:favoritePage];
        
        return cell;
    }
    else if (indexPath.section == kMenuSection)
    {
        if (indexPath.row == 0)
        {
            static NSString *CellIdentifier = @"menuSection";
            UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            cell.textLabel.font = MOLightFont(14);
            cell.textLabel.text= NSLocalizedString(@"Menus", @"菜单");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"menuSection1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width)];
                }
                
                if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                    [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width)];
                }
            }
            
            UIView*  photosPage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, photosHeight)];
            photosPage.backgroundColor = [UIColor whiteColor];
            
            for (int nIndex = 0;nIndex<_menuList.count && nIndex<numberOfLine;nIndex++)
            {
                NSString* imageUrl = [_menuList objectAtIndex:nIndex];
                
                [photosPage addSubview:[self makeOrderView:imageUrl withIndex:nIndex]];
                
                if (nIndex>=3)
                    break;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            [cell.contentView addSubview:photosPage];
           
            return cell;
        }
    }
    else if (indexPath.section == kProductSection)
    {
        if (indexPath.row == 0)
        {
            static NSString *CellIdentifier = @"listName";
            UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.font = MOLightFont(14);
            cell.textLabel.text= NSLocalizedString(@"Coupons", @"优惠券");
            return cell;
        }
        else
        {

            static NSString *CellIdentifier = @"listCell";
    
          
            NSDictionary   *product = [_productData objectAtIndex:indexPath.row-1];
    
            GDProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GDProductListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            
            NSString*  imgUrl=@"";
            NSString*  productname=@"";
            NSString*  originprice=@"0";
            NSString*  saleprice=@"0";
            NSString*  setsale=@"0";
            
            SET_IF_NOT_NULL(imgUrl, product[@"image"]);
            SET_IF_NOT_NULL(productname, product[@"name"]);
            SET_IF_NOT_NULL(originprice, product[@"original_price"]);
            SET_IF_NOT_NULL(saleprice, product[@"price"]);
            SET_IF_NOT_NULL(setsale, product[@"set_price"]);
            
            [cell.productImage sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                                 placeholderImage:[UIImage imageNamed:@"live_product_default.png"]];
            
            
            cell.vendorLabel.text = product[@"vendor_info"][@"vendor_name"];
            
            int  oprice   = [originprice intValue];
            int  sprice   = [saleprice intValue];
            int  setprice = [setsale intValue];
            
            NSString* opricestr = [NSString stringWithFormat:@"%d", oprice];
            NSString* spricestr = [NSString stringWithFormat:@"%d", sprice];
            
            cell.membership_level = [product[@"vendor_info"][@"membership_level"] intValue];
            
            if (cell.membership_level!=needPayType)
                [[GDSettingManager instance] setTitleAttr:cell.productLabel withTitle:productname withSale:setprice withOrigin:oprice];
            else
                [[GDSettingManager instance] setTitleAttr:cell.productLabel withTitle:productname withSale:0 withOrigin:0];
            
            cell.originLabel.text = opricestr;
            cell.saleLabel.text = spricestr;
            
            cell.cityLabel.text = product[@"vendor_info"][@"zone_name"];
            
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
    else if (indexPath.section == kDescSection)
    {
        if (indexPath.row == 0)
        {
            static NSString *CellIdentifier = @"sDesc";
            UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.font = MOLightFont(14);
            cell.textLabel.text= NSLocalizedString(@"Description", @"商家描述");
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"sDesc1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            [cell.contentView addSubview:_descView];
            
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
    else if (indexPath.section == kOpenhoursSection)
    {
        if ([self tableView:tableView canCollapseSection:indexPath.section])
        {
            if (indexPath.row==0)
            {
                static NSString *CellIdentifier = @"sOpenHours";
                UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                }
                
                cell.textLabel.font = MOLightFont(14);
                cell.textLabel.text= NSLocalizedString(@"Opening Hours", @"营业时间");
                
                if ([expandedSections containsIndex:indexPath.section])
                {
                    cell.accessoryView = [ALCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:ALCustomColoredAccessoryTypeUp];
                }
                else
                {
                    cell.accessoryView = [ALCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:ALCustomColoredAccessoryTypeDown];
                }
                
                return cell;
            }
        else
        {
            static NSString *CellIdentifier = @"sOpenHours1";
            GDOpenHourListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GDOpenHourListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            NSDictionary* dict = [_openHours objectAtIndex:indexPath.row-1];
            if (dict!=nil)
            {
                NSString* open_time_start = dict[@"open_time_start"];
                NSString* open_time_end = dict[@"open_time_end"];
                int tag = [dict[@"tag"] intValue];
                
                NSDictionary* temp = [[GDPublicManager instance] getDateFormat:open_time_start withEnd:open_time_end withDay:tag];
                
                cell.dayLabel.text = temp[@"days"];
                cell.timeLabel.text = temp[@"time"];
            }
            
            return cell;
        }
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
            rateView.rate = [vendorData[@"rating"] floatValue];
            [cell.contentView addSubview:rateView];
            
            UILabel* rateLable = MOCreateLabelAutoRTL();
            rateLable.backgroundColor = [UIColor clearColor];
            rateLable.textColor = MOColorSaleFontColor();
            rateLable.font = MOLightFont(14);
            rateLable.text = [NSString stringWithFormat:@"%.1f",[vendorData[@"rating"] floatValue]];
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
            cell.contentLabel.text = dict[@"text"];
        
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
    int nIndex  = 0;
    if (vendor_address.length>0)
        kAddressSection = nIndex++;
    else
        kAddressSection = 10;
    
    kFavoriteSection = nIndex++;
    
    if (_productData.count>0)
        kProductSection = nIndex++;
    else
        kProductSection = 10;

    if (_menuList.count>0)
    {
        kMenuSection = nIndex++;
    }
    else
        kMenuSection = 10;
    
    if (_openHours.count>0)
    {
        kOpenhoursSection = nIndex++;
    }
    else
        kOpenhoursSection = 10;
    
    if (sCuisines.length>0)
    {
        kCuisinesSection = nIndex++;
    }
    else
        kCuisinesSection = 10;
    
    if (_tagArrays.count>0)
    {
        kTagSection = nIndex++;
    }
    else
        kTagSection = 10;
    
    if (_rateList.count>0)
    {
        kRateSection = nIndex++;
    }
    else
        kRateSection = 10;
    
    if (sDescription.length>0)
    {
        kDescSection = nIndex++;
    }
    else
        kDescSection = 10;
    
    return nIndex;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == kAddressSection)
    {
        if (fee_per_person>0)
            return 3;
        else
            return 2;
    }
    else if (section == kFavoriteSection)
        return 1;
    else if (section == kMenuSection)
    {
        return 2;
    }
    else if (section == kProductSection)
        return _productData.count+1;
    else if (section == kOpenhoursSection)
    {
        if ([self tableView:tableView canCollapseSection:section])
        {
            if ([expandedSections containsIndex:section])
            {
                return _openHours.count+1; // return rows when expanded
            }
            
            return 1; // only top row showing
        }
    }
    else if (section == kCuisinesSection)
    {
        return 2;
    }
    else if (section == kDescSection)
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
    if (indexPath.section == kAddressSection)
    {
        if (indexPath.row==0)
            return 40;
        
        if (fee_per_person>0 && indexPath.row==1)
            return 40;
        
        return 150;
    }
    else if (indexPath.section  == kFavoriteSection)
    {
        return 60;
    }
    else if (indexPath.section  == kMenuSection)
    {
        if (indexPath.row == 0)
            return 40;
        else if (indexPath.row == 1)
        {
            return photosHeight;
        }
    }
    else if (indexPath.section  == kProductSection)
    {
        if (indexPath.row == 0)
            return 40;
        return 224;
    }
    else if (indexPath.section == kOpenhoursSection)
    {
        if (indexPath.row==0)
            return 40;
        else
            return 30;
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
            cuisinesLabel.font = MOLightFont(13);
            CGSize fittingSize = [cuisinesLabel sizeThatFits:CGSizeMake([GDPublicManager instance].screenWidth-30, 20)];
            
            cuisinesLabel.frame = CGRectMake(15, 10, [GDPublicManager instance].screenWidth-30, fittingSize.height);
            
            return fittingSize.height+20;
        }
    }
    else if (indexPath.section == kDescSection)
    {
        if (indexPath.row == 0)
            return 40;
        else
        {
            if (_descView==nil)
            {
                _descView = MOCreateLabelAutoRTL();
                _descView.backgroundColor = [UIColor clearColor];
                _descView.numberOfLines = 0;
            }
            _descView.textColor = MOColor66Color();
        
            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[sDescription dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
            _descView.attributedText = attrStr;

            _descView.font = MOLightFont(12);
            CGSize fittingSize = [_descView sizeThatFits:CGSizeMake([GDPublicManager instance].screenWidth-30, 20)];
            
            _descView.frame = CGRectMake(15, 10, [GDPublicManager instance].screenWidth-30, fittingSize.height);
            
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
    else if (indexPath.section == kRateSection)
    {
        if (indexPath.row == 0)
            return 40;
        
        NSDictionary* dict = [_rateList objectAtIndex:indexPath.row-1];
        NSString* content = dict[@"text"];
        
        CGSize titleSize = [content moSizeWithFont:MOLightFont(12) withWidth:[GDPublicManager instance].screenWidth-60];
        
        float  photosWidth = 0;
        if(dict[@"imagelist_list"] != [NSNull null] && dict[@"imagelist_list"]!= nil)
        {
            NSArray* imagelist_list = dict[@"imagelist_list"];
            if (imagelist_list.count>0)
            {
                photosWidth = (([[UIScreen mainScreen] bounds].size.width-70.0)/numberOfLine);
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
    
    if (indexPath.section == kMenuSection)
    {
        if (indexPath.row == 0)
        {
            GDGridLayoutViewController* viewController = [[GDGridLayoutViewController alloc] init:_menuList];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
    else if (indexPath.section == kProductSection)
    {
        if (indexPath.row!=0)
        {
            NSDictionary   *product = [_productData objectAtIndex:indexPath.row-1];
            int productId = [product[@"product_id"] intValue];
            NSString* type=@"";
            SET_IF_NOT_NULL(type, product[@"type"]);
    
            GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:productId withOrder:YES];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
    else if (indexPath.section == kRateSection)
    {
        if (indexPath.row == 0)
        {
            GDRateViewController* viewController  = [[GDRateViewController alloc] initWithVendor:vendorId];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
    else if (indexPath.section == kOpenhoursSection)
    {
        if (indexPath.row == 0)
        {
            NSInteger section = indexPath.section;
            BOOL currentlyExpanded = [expandedSections containsIndex:section];
            NSInteger rows;
            
            NSMutableArray *tmpArray = [NSMutableArray array];
            
            if (currentlyExpanded)
            {
                rows = [self tableView:tableView numberOfRowsInSection:section];
                [expandedSections removeIndex:section];
                
            }
            else
            {
                [expandedSections addIndex:section];
                rows = [self tableView:tableView numberOfRowsInSection:section];
            }
            
            for (int i=1; i<rows; i++)
            {
                NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:i
                                                               inSection:section];
                [tmpArray addObject:tmpIndexPath];
            }
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (currentlyExpanded)
            {
                [tableView deleteRowsAtIndexPaths:tmpArray
                                 withRowAnimation:UITableViewRowAnimationTop];
                
                cell.accessoryView = [ALCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:ALCustomColoredAccessoryTypeDown];
                
            }
            else
            {
                [tableView insertRowsAtIndexPaths:tmpArray
                                 withRowAnimation:UITableViewRowAnimationTop];
                cell.accessoryView =  [ALCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:ALCustomColoredAccessoryTypeUp];
                
            }
        }
    }
    
}

#pragma mark - scroll Delegate

- (NSInteger)numberOfPageInPageScrollView:(OTPageScrollView*)pageScrollView{
    return [_imageList count];
}

- (UIView*)pageScrollView:(OTPageScrollView*)pageScrollView viewForRowAtIndex:(int)index
{
    UIImageView * iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 200)];
    iconImage.contentMode = UIViewContentModeScaleAspectFill;
    [iconImage setClipsToBounds:YES];
    
    NSString* getImageStrUrl = [_imageList objectAtIndex:index];
     
    [iconImage sd_setImageWithURL:[NSURL URLWithString:[getImageStrUrl encodeUTF]] placeholderImage:[UIImage imageNamed:@"product_detail_default.png"]];
    return iconImage;
}

- (CGSize)sizeCellForPageScrollView:(OTPageScrollView*)pageScrollView
{
    return CGSizeMake(smallImageWidth, smallImageHeight);
}

- (void)pageScrollView:(OTPageScrollView *)pageScrollView didTapPageAtIndex:(NSInteger)index{
    
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity: [_imageList count]];
    for (int i = 0; i < [_imageList count]; i++) {
        NSString * getImageStrUrl = [NSString stringWithFormat:@"%@", [_imageList objectAtIndex:i] ];
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
    
    PScrollView.pageLabel.text = [NSString stringWithFormat:@"%u / %ld",currentPage+1,_imageList.count];
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
    NSString* text = [NSString stringWithFormat:NSLocalizedString(@"Hurry Up:%@",@"赶紧去抢购:%@"),vendorName];
    
    NSURL*     url = [NSURL URLWithString:[vendorUrl encodeUTF]];
    
    __block UIImage* imageData = nil;
    
    if (vendorImage.length<=0) {
        vendorImage = DefaultSysImage;
    }
    
    [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:[vendorImage encodeUTF]]  options:SDWebImageLowPriority|SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
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
            
            if(vendorName.length>0)
            {
                [parameters setObject:vendorName forKey:@"paramSummary"];
            }
            else
            {
                [parameters setObject:@"Greadeal" forKey:@"paramSummary"];
            }
            
            if (vendorUrl.length>0)
                [parameters setObject:[vendorUrl encodeUTF] forKey:@"paramUrl"];
            else if (vendorImage.length>0)
            {
                [parameters setObject:vendorImage forKey:@"paramImages"];
            }
            
            [[qqAccountManage sharedInstance] clickAddShare:parameters];
        }
        else if  ([imageIndex isEqualToString:@"sns_icon_whatsapp"])
        {
            [[whatsappAccountManage sharedInstance] sendMessageToFriend:text withUrl:vendorUrl];
        }
        else if  ([imageIndex isEqualToString:@"sns_icon_wechat"])
        {
            NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
            [parameters setObject:text forKey:@"title"];
            if (url!=nil)
                [parameters setObject:[url absoluteString] forKey:@"url"];
            if (imageData!=nil)
                [parameters setObject:imageData forKey:@"image"];
            [[weixinAccountManage sharedInstance] sendMessageToFriend:parameters];
        }
        else if  ([imageIndex isEqualToString:@"sns_icon_moments"])
        {
            NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
            [parameters setObject:text forKey:@"title"];
            if (url!=nil)
                [parameters setObject:[url absoluteString] forKey:@"url"];
            if (imageData!=nil)
                [parameters setObject:imageData forKey:@"image"];
            
            [[weixinAccountManage sharedInstance] sendMessageToCycle:parameters];
        }
    }];
}

- (void)didClickOnCancelButton
{
    LOG(@"didClickOnCancelButton");
}

@end
