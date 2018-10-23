// GDLiveViewController.m
// RDVTabBarController
//
// Copyright (c) 2013 Robert Dimitrov

#import "GDLiveViewController.h"
#import "RDVTabBarController.h"
#import "GDProductDetailsViewController.h"

#import "GDProductListCell.h"
#import "GDLiveClassPanelView.h"

#import "GDLiveSearchViewController.h"
#import "GDDiscountAndStoreViewController.h"

#import "GDLiveAllCategoryViewController.h"
#import "GDSelectCityViewController.h"

#import "GDNewDealsViewController.h"
#import "GDShoppingViewController.h"
#import "GDDeliveryListViewController.h"

#import "GDLiveDiscountViewController.h"
#import "GDBuyGetFreeViewController.h"

#import "GDReturnsViewController.h"

#import "GDJoinViewController.h"

#import "GDReservationAreaListViewController.h"

#import "GDCollectionViewController.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#define bannerHeight          180

#define hotCagetoryHeight     90
#define hotCagetoryItemOfPage 5

#define AdHeight             ([[UIScreen mainScreen] bounds].size.width/320.0*180)
#define AdItemOfPage          2

#define xMargin               0
#define yMargin               10

#define allcategories         100000

@implementation GDLiveViewController


- (id)init
{
    self = [super init];
    if (self)
    {
        self.title = NSLocalizedString(@"Home", @"首页");
        
        
        bannerData  = [[NSMutableArray alloc] init];
        hotCategoryData = [[NSMutableArray alloc] init];
        event_banners = [[NSMutableArray alloc] init];
        
        alsoLikeData = [[NSMutableArray alloc] init];
        newDealsData = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCountry) name:kNotificationGetCountryID object:nil];
       
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect r = self.view.bounds;
    float h = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height+TABBARHEIGHT;
    r.size.height-=h;
    
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    [self.view addSubview:mainTableView];
    mainTableView.backgroundColor = MOColorAppBackgroundColor();
   
    
    if (self.rdv_tabBarController.tabBar.translucent) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0,
                                               0,
                                               CGRectGetHeight(self.rdv_tabBarController.tabBar.frame),
                                               0);
        
        mainTableView.contentInset = insets;
        mainTableView.scrollIndicatorInsets = insets;
    }
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 2, 100, 40)];
    
    countryBut  = [UIButton buttonWithType:UIButtonTypeCustom];
    countryBut.frame = CGRectMake(0, 0, 100, 40);
    [countryBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [countryBut addTarget:self action:@selector(resetCity) forControlEvents:UIControlEventTouchUpInside];
    [countryBut setTitle:[[GDSettingManager instance] getCountryShort] forState:UIControlStateNormal];
    [countryBut setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    countryBut.titleLabel.font = MOLightFont(16);
    [buttonView addSubview:countryBut];
    [self reCaluCityWidth];

    
    MODebugLayer(buttonView, 1.f, [UIColor redColor].CGColor);
    
    UIBarButtonItem*  selectButItem = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    self.navigationItem.leftBarButtonItem = selectButItem;
    
    UIBarButtonItem*  searchButItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(tapSearch)];
    self.navigationItem.rightBarButtonItem = searchButItem;
   
    
    [self addRefreshUI];
    
    [[GAI sharedInstance].defaultTracker send:
     [[GAIDictionaryBuilder createEventWithCategory:@"app"
                                             action:@"start"
                                              label:@"homepage"
                                              value:nil] build]];
}

//#pragma mark - Event
//- (void)getEventData
//{
//
//    NSString* url;
//    NSDictionary *parameters;
//    
//    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Banner/get_event_list"];
//    parameters = @{@"country_id":@([GDSettingManager instance].currentCountryId),@"language_id":@([[GDSettingManager instance] language_id:NO])};
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
//    
//    [manager POST:url
//       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         
//         int status = [responseObject[@"status"] intValue];
//         if (status==1)
//         {
//             @synchronized(event_banners)
//             {
//                 [event_banners removeAllObjects];
//             }
//             
//             if(responseObject[@"data"][@"event_banners"] != [NSNull null] && responseObject[@"data"][@"event_banners"] != nil)
//             {
//                 NSArray* temp = responseObject[@"data"][@"event_banners"];
//                 
//                 [event_banners addObjectsFromArray:temp];
//             }
//             
//         }
//         else
//         {
//             NSString *errorInfo =@"";
//             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
//             LOG(@"errorInfo: %@", errorInfo);
//             [ProgressHUD showError:errorInfo];
//         }
//        
//         [self reLoadView];
//         
//     }
//     failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         netWorkError = YES;
//         [self stopLoad];
//         [self reLoadView];
//         [ProgressHUD showError:error.localizedDescription];
//     }];
//}

#pragma mark - Data List
- (void)getDataList
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    reloading = YES;
    
    CGRect r = self.view.frame;
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Banner/get_list"];
    parameters = @{@"country_id":@([GDSettingManager instance].currentCountryId),@"language_id":@([[GDSettingManager instance] language_id:NO])};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         if (bannerView==nil)
         {
             bannerView = [[JCTopic alloc]initWithFrame:CGRectMake(0, 0, r.size.width, bannerHeight) ];
             bannerView.JCdelegate = self;
         }
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             @synchronized(bannerData)
             {
                 [bannerData removeAllObjects];
                 
             }
             
             if(responseObject[@"data"][@"app_home_top_banner"] != [NSNull null] && responseObject[@"data"][@"app_home_top_banner"] != nil)
             {
                 [bannerData addObjectsFromArray:responseObject[@"data"][@"app_home_top_banner"]];
                 
                 NSMutableArray *pictureArrar = [[NSMutableArray alloc] init];
                 for (NSDictionary* dict in bannerData)
                 {
                     NSString* image = @"";
                     SET_IF_NOT_NULL( image , dict[@"image"]);
                     [pictureArrar addObject:image];
                 }
                 
                 bannerView.pics = pictureArrar;
                 [bannerView upDate:@"sale_banner_default.png"];
                 
                 mainTableView.tableHeaderView = bannerView;
             }
             
             
             @synchronized(hotCategoryData)
             {
                 [hotCategoryData removeAllObjects];
             }
             NSArray* temp = responseObject[@"data"][@"app_home_category_banner"];
             if (temp.count>0)
             {
                 [hotCategoryData addObjectsFromArray:temp];
             }
             
             @synchronized(event_banners)
             {
                 [event_banners removeAllObjects];
             }
             
             if(responseObject[@"data"][@"app_home_sence_banner"] != [NSNull null] && responseObject[@"data"][@"app_home_sence_banner"] != nil)
             {
                 NSArray* temp = responseObject[@"data"][@"app_home_sence_banner"];
                 
                 [event_banners addObjectsFromArray:temp];
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

//#pragma mark - Banner
//- (void)getBannerData
//{
//    reloading = YES;
//    
//    CGRect r = self.view.frame;
//    
//    NSString* url;
//    NSDictionary *parameters;
//    
//    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Banner/get_top_banner_list"];
//    parameters = @{@"country_id":@([GDSettingManager instance].currentCountryId),@"language_id":@([[GDSettingManager instance] language_id:NO])};
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
//    
//    [manager POST:url
//       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         
//         if (bannerView==nil)
//         {
//             bannerView = [[JCTopic alloc]initWithFrame:CGRectMake(0, 0, r.size.width, bannerHeight) ];
//             bannerView.JCdelegate = self;
//         }
//         
//         int status = [responseObject[@"status"] intValue];
//         if (status==1)
//         {
//             @synchronized(bannerData)
//             {
//                 [bannerData removeAllObjects];
//             }
//             
//             if(responseObject[@"data"][@"top_banners"] != [NSNull null] && responseObject[@"data"][@"top_banners"] != nil)
//             {
//                 [bannerData addObjectsFromArray:responseObject[@"data"][@"top_banners"]];
//                 
//                 NSMutableArray *pictureArrar = [[NSMutableArray alloc] init];
//                 for (NSDictionary* dict in bannerData)
//                 {
//                     NSString* image = @"";
//                     SET_IF_NOT_NULL( image , dict[@"image"]);
//                     [pictureArrar addObject:image];
//                 }
//                 
//                 bannerView.pics = pictureArrar;
//                 [bannerView upDate:@"sale_banner_default.png"];
//                 
//                 mainTableView.tableHeaderView = bannerView;
//             }
//         }
//         else
//         {
//             NSString *errorInfo =@"";
//             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
//             LOG(@"errorInfo: %@", errorInfo);
//             [ProgressHUD showError:errorInfo];
//         }
//         
//         netWorkError = NO;
//         [ProgressHUD dismiss];
//         [self stopLoad];
//         [self reLoadView];
//         
//     }
//     failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         netWorkError = YES;
//         [self stopLoad];
//         [self reLoadView];
//         [ProgressHUD showError:error.localizedDescription];
//     }];
//}

#pragma mark - hotCategory
- (int)numberOfPages:(int)numberOfPage withCount:(int)recentCount
{
    int pageSize = numberOfPage;
    int numOfPages = ceil((double)recentCount / (double)pageSize);
    return numOfPages;
}

- (void)didSelectHotCagetoryViewItem:(id)sender
{
    //{"s":<string> sticker name, if applicable, "e":<string> emoji code, if applicable.}
    NSDictionary *dict = sender;
    NSString* url=@"";
    SET_IF_NOT_NULL(url, dict[@"link"]);
    
    NSString* type=@"";
    SET_IF_NOT_NULL(type, dict[@"type"]);
    
    if ([type isEqualToString:@"weburl"])
    {
        NSString* web_url = [NSString stringWithFormat:@"%@&longitude=%f&latitude=%f&language_id=%@",url,[[GDSettingManager instance] getCityLongitude],[[GDSettingManager instance] getCityLatitude],@([[GDSettingManager instance] language_id:NO])];
        GDBuyGetFreeViewController* nv = [[GDBuyGetFreeViewController alloc] init:web_url];
        [self.navigationController pushViewController:nv animated:YES];
    }
    else if ([type isEqualToString:@"collection"])
    {
        NSString* title=@"";
        SET_IF_NOT_NULL(title, dict[@"title"]);
        
        GDCollectionViewController* nv = [[GDCollectionViewController alloc] init:[url intValue] withTitle:title];
        [self.navigationController pushViewController:nv animated:YES];
    }
    else if ([type isEqualToString:@"delivery"])
    {
        GDReservationAreaListViewController* nv = [[GDReservationAreaListViewController alloc] init];
        [self.navigationController pushViewController:nv animated:YES];
    }
}

//- (void)getHotCategoryData
//{
//    NSString* url;
//    NSDictionary *parameters;
//    
//    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Category/get_recommend_category_list"];
//    
//    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO])};
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
//    
//    [manager POST:url
//       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         
//         int status = [responseObject[@"status"] intValue];
//         if (status==1)
//         {
//             @synchronized(hotCategoryData)
//             {
//                 [hotCategoryData removeAllObjects];
//             }
//             
//             NSArray* temp = responseObject[@"data"][@"category_list"];
//             if (temp.count>0)
//             {
//                 [hotCategoryData addObjectsFromArray:temp];
//             }
//             
//         }
//         else
//         {
//             NSString *errorInfo =@"";
//             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
//             LOG(@"errorInfo: %@", errorInfo);
//             [ProgressHUD showError:errorInfo];
//         }
//         
//         [ProgressHUD dismiss];
//         
//         [self reLoadView];
//
//     }
//     failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         [ProgressHUD showError:error.localizedDescription];
//     }];
//}

#pragma mark - NewDeal list

- (void)getNewDealData
{
    NSString* url;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/product/get_product_list_of_collection"];
    
    NSDictionary* parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"page":@(1),@"limit":@(3),@"collection_id":@(29)};
    
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
                 @synchronized(newDealsData)
                 {
                     [newDealsData removeAllObjects];
                 }
             }
             
             NSArray* temp = responseObject[@"data"][@"product_list"];
             if (temp.count>0)
             {
                 [newDealsData addObjectsFromArray:temp];
             }
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
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [ProgressHUD showError:error.localizedDescription];
     }];

}

#pragma mark - relation product
- (void)getLikeData
{
  
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/product/get_guess_your_like_product_list"];
   
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"country_id":@([GDSettingManager instance].currentCountryId),@"longitude":@([[GDSettingManager instance] getCityLongitude]),@"latitude":@([[GDSettingManager instance] getCityLatitude])};
    //目前是没有分页，服务器无法提供,在本地实现分页
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];  
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
            @synchronized(alsoLikeData)
            {
                [alsoLikeData removeAllObjects];
            }
             
            NSArray* temp = responseObject[@"data"][@"product_list"];
            if (temp.count>0)
            {
                 [alsoLikeData addObjectsFromArray:temp];
            }
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

     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self stopLoad];
         [self reLoadView];
         [ProgressHUD showError:error.localizedDescription];
     }];
}

- (void)reLoadView
{
    [mainTableView reloadData];
}

#pragma mark - Square view
- (void)squareTap:(id)sender
{
    NSDictionary *dict = sender;
    
    NSString* url=@"";
    SET_IF_NOT_NULL(url, dict[@"link"]);
        
    NSString* type=@"";
    SET_IF_NOT_NULL(type, dict[@"type"]);
        
    if ([type isEqualToString:@"weburl"])
    {
        NSString* web_url = [NSString stringWithFormat:@"%@&longitude=%f&latitude=%f&language_id=%@",url,[[GDSettingManager instance] getCityLongitude],[[GDSettingManager instance] getCityLatitude],@([[GDSettingManager instance] language_id:NO])];
            GDBuyGetFreeViewController* nv = [[GDBuyGetFreeViewController alloc] init:web_url];
        [self.navigationController pushViewController:nv animated:YES];
    }
    if ([type isEqualToString:@"movie"])
    {
        GDJoinViewController* nv = [[GDJoinViewController alloc] init:url];
        [self.navigationController pushViewController:nv animated:YES];
    }
    else if ([type isEqualToString:@"collection"])
    {
        NSString* title=@"";
        SET_IF_NOT_NULL(title, dict[@"title"]);
        
        GDCollectionViewController* nv = [[GDCollectionViewController alloc] init:[url intValue] withTitle:title];
        [self.navigationController pushViewController:nv animated:YES];
    }
    else if ([type isEqualToString:@"delivery"])
    {
        GDReservationAreaListViewController* nv = [[GDReservationAreaListViewController alloc] init];
        [self.navigationController pushViewController:nv animated:YES];
    }
   
}

- (UIButton*)createBut:(int)section withimage:(NSString*)iconimg withselector:(SEL)action withname:(NSString*)iconname withX:(int)offsetX withY:(int)offsexY
{
    UIButton    *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(offsetX,offsexY,([GDPublicManager instance].screenWidth-15)/2,65);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,5,([GDPublicManager instance].screenWidth-15)/2,65)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [imageView sd_setImageWithURL:[NSURL URLWithString:[iconimg encodeUTF]]
                         placeholderImage:[UIImage imageNamed:@"live_product_default.png"]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,5,([GDPublicManager instance].screenWidth-15)/2,65)];
    [label setText:iconname];
    label.textColor = [UIColor whiteColor];
    label.font = MOLightFont(16);
    //label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    
    [button addSubview:imageView];
    [button addSubview:label];
    
    button.tag = section;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kCategorySection)
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell ;
            static NSString *ID = @"CategorySection";
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        
            [hotCategoryView removeFromSuperview];
            [hotCategoryPageControl removeFromSuperview];
        
            CGRect r = self.view.frame;
            int nCount = (int)hotCategoryData.count;
            int numOfPages  = [self numberOfPages:hotCagetoryItemOfPage withCount:nCount];
        
            if (hotCategoryView==nil)
            {
                hotCategoryView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, hotCagetoryHeight)];
            
                hotCategoryView.pagingEnabled = YES;
                hotCategoryView.scrollEnabled = YES;
                hotCategoryView.delegate = self;
                hotCategoryView.showsHorizontalScrollIndicator = NO;
                hotCategoryView.showsVerticalScrollIndicator = NO;
                hotCategoryView.backgroundColor = MOColorAppBackgroundColor();
            }
        
            CGRect classificationRect = hotCategoryView.frame;
            hotCategoryView.contentSize = CGSizeMake(CGRectGetWidth(classificationRect) * numOfPages, CGRectGetHeight(classificationRect));
        
            int pageSize = hotCagetoryItemOfPage;
        
            for (UIView *view in hotCategoryView.subviews)
            {
                [view removeFromSuperview];
            }
        
            for (int i = 0; i < numOfPages; i++)
            {
                GDLiveClassPanelView *eView = nil;
            
                eView = [[GDLiveClassPanelView alloc] initWithFrame:CGRectMake(i*CGRectGetWidth(classificationRect), 0,CGRectGetWidth(classificationRect), CGRectGetHeight(classificationRect))];
                eView.ItemOfPage = nCount>5?hotCagetoryItemOfPage:5;
                eView.LineHeight = hotCagetoryHeight;
                eView.yspaceing  = 5;
                eView.imageWidth = 45;
                eView.imageHeight= 45;
                eView.ItemOfLine = 5;
            
                eView.target = self;
                eView.callback = @selector(didSelectHotCagetoryViewItem:);
                eView.backgroundColor = [UIColor clearColor];
                [hotCategoryView addSubview:eView];
            
                NSRange range = NSMakeRange(i*pageSize,
                                        (i+1)*pageSize >= nCount ? nCount-i*pageSize : pageSize);
            
                NSArray *subarray = [hotCategoryData subarrayWithRange:range];
                [eView setRecentItems:subarray];
            }

//            if (nCount>hotCagetoryItemOfPage)
//            {
//                if (hotCategoryPageControl==nil)
//                {
//                    hotCategoryPageControl = [[UIPageControl alloc] initWithFrame:  CGRectMake(0, hotCagetoryHeight, 320, pageControlHeight)];
//                    hotCategoryPageControl.currentPageIndicatorTintColor = MOColorPageIndicator();
//                    hotCategoryPageControl.pageIndicatorTintColor = [UIColor grayColor];
//                    hotCategoryPageControl.hidesForSinglePage = YES;
//                    hotCategoryPageControl.backgroundColor = MOColorAppBackgroundColor();
//                }
//            
//                hotCategoryPageControl.numberOfPages = numOfPages;
//                hotCategoryPageControl.currentPage = 0;
//                MODebugLayer(hotCategoryPageControl, 1.f, [UIColor redColor].CGColor);
//            }
       
            [cell.contentView addSubview:hotCategoryView];
        
            if (hotCategoryPageControl!=nil)
            {
                [cell.contentView addSubview:hotCategoryPageControl];
            }
        
            return cell;
        }
    
    }
    else if (indexPath.section == kOperationSection)
    {
        UITableViewCell *cell ;
        static NSString *ID = @"kOperation1";
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [operationView removeFromSuperview];
        
        CGRect r = self.view.frame;
        
        if (operationView==nil)
        {
            operationView = [[UIOperationADView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, 160)];
            operationView.target = self;
            operationView.callback = @selector(squareTap:);
        }
        
        [operationView setRecentItems:event_banners];
        
        [cell.contentView addSubview:operationView];
        
        return cell;
    }
    else if (indexPath.section == kNewSection)
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell ;
            static NSString *ID = @"kNewSection1";
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            cell.textLabel.font = MOLightFont(16);
            cell.textLabel.textColor = MOColor33Color();
            cell.textLabel.text = NSLocalizedString(@"NEW IN THIS WEEK ",@"本周上新");
            
            cell.detailTextLabel.font = MOLightFont(16);
            cell.detailTextLabel.text = NSLocalizedString(@"View All",@"查看全部");
            
            return cell;
        }
        else 
        {
            static NSString *ID = @"kNewSection2";
            
            GDProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (!cell) {
                cell = [[GDProductListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
            }
            
            NSDictionary* product = [newDealsData objectAtIndex:indexPath.row-1];
            
            NSString*  imgUrl=@"";
            NSString*  productname=@"";
            NSString*  originprice=@"0"; //商家原价
            NSString*  saleprice=@"0";   //平台销售价
            NSString*  setsale=@"0";     //商家优惠价
            
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
    else if (indexPath.section == kLikeSection)
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell ;
            static NSString *ID = @"guessname";
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            cell.textLabel.font = MOLightFont(16);
            cell.textLabel.textColor = MOColor33Color();
            cell.textLabel.text = NSLocalizedString(@"RECOMMENDED", @"推荐");
            cell.textLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
            
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"guessCell";
    
            GDProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
            cell = [[GDProductListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
             }
            
            NSDictionary* product = [alsoLikeData objectAtIndex:indexPath.row-1];
        
            NSString*  imgUrl=@"";
            NSString*  productname=@"";
            NSString*  originprice=@"0";
            NSString*  saleprice=@"0";
            NSString*  setsale=@"0";     //商家优惠价
            
            SET_IF_NOT_NULL(imgUrl, product[@"image"]);
            SET_IF_NOT_NULL(productname, product[@"name"]);
            SET_IF_NOT_NULL(originprice, product[@"original_price"]);
            SET_IF_NOT_NULL(saleprice, product[@"price"]);
            SET_IF_NOT_NULL(setsale, product[@"set_price"]);
            
            [cell.productImage sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                                 placeholderImage:[UIImage imageNamed:@"live_product_default.png"]];
            
            
            cell.vendorLabel.text = product[@"vendor_info"][@"vendor_name"];
            
            int  oprice = [originprice intValue];
            int  sprice = [saleprice intValue];
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
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   
    int nIndex  = 0;
    
    if (hotCategoryData.count>0)
        kCategorySection = nIndex++;
    else
        kCategorySection = 6;
    
    if (event_banners.count>0)
        kOperationSection = nIndex++;
    else
        kOperationSection = 6;
    
    if (newDealsData.count>0)
        kNewSection = nIndex++;
    else
        kNewSection = 6;
    
    if (alsoLikeData.count>0)
        kLikeSection = nIndex++;
    else
        kLikeSection = 6;
    
    if (!reloading && bannerData.count<=0)
    {
        if (netWorkError)
        {
            isLoadData = NO;
            [mainTableView insertSubview:[self noNetworkView] atIndex:0];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(refreshData)];
            [[self noNetworkView] addGestureRecognizer:tapGesture];
            
            mainTableView.backgroundColor = MOColorAppBackgroundColor();
        }
    }
    
    if (nIndex>0)
    {
        [_noNetworkView removeFromSuperview];
        mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    }
    
    return nIndex;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kCategorySection)
    {
        return 1;//no buy one get free one
    }
    else if (section == kOperationSection)
    {
        return 1;
    }
    else if (section == kNewSection)
    {
        return 1+newDealsData.count;
    }
    else if (section == kLikeSection)
    {
        return 1+alsoLikeData.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==  kCategorySection)
    {
        if (indexPath.row == 0)
        {
        //int nCount = (int)hotCategoryData.count;
        //int numOfPages  = [self numberOfPages:hotCagetoryItemOfPage withCount:nCount];
        
//        if (numOfPages>1)
//            return pageControlHeight + hotCagetoryHeight;
//        else
            return hotCagetoryHeight;
        }
//        else
//        {
//            return 44;
//        }
    }
    if (indexPath.section ==  kOperationSection)
    {
        return 160;
    }
    else if (indexPath.section == kNewSection)
    {
        if (indexPath.row == 0)
        {
            return 40;
        }
        return 224;
    }
    else if (indexPath.section == kLikeSection)
    {
        if (indexPath.row == 0)
            return 40;
        return 224;
   
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == kCategorySection)
    {
//        if (indexPath.row == 0)
//        {
//            if (top_event_banners.count>0)
//            {
//                NSString* url=@"";
//                SET_IF_NOT_NULL(url, top_event_banners[@"link"]);
//               
//                NSString* web_url = [NSString stringWithFormat:@"%@&longitude=%f&latitude=%f&language_id=%@",url,[[GDSettingManager instance] getCityLongitude],[[GDSettingManager instance] getCityLatitude],@([[GDSettingManager instance] language_id:NO])];
//                
//                GDBuyGetFreeViewController* nv = [[GDBuyGetFreeViewController alloc] init:web_url];
//                [self.navigationController pushViewController:nv animated:YES];
//            }
//           
//        }
    }
    else if (indexPath.section==kNewSection)
    {
        if (indexPath.row == 0)
        {
            GDNewDealsViewController *nv = [[GDNewDealsViewController alloc] init];
            [self.navigationController pushViewController:nv animated:YES];
        }
        else
        {
            NSDictionary* product = [newDealsData objectAtIndex:indexPath.row-1];
            if (product!=nil)
            {
                int productId = [product[@"product_id"] intValue];
                NSString* type=@"";
                SET_IF_NOT_NULL(type, product[@"type"]);
                
                GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:productId withOrder:YES];
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
    }
    else if (indexPath.section==kLikeSection)
    {
        if (indexPath.row>0)
        {
            NSDictionary* product = [alsoLikeData objectAtIndex:indexPath.row-1];
            if (product!=nil)
            {
                int productId = [product[@"product_id"] intValue];
                NSString* type=@"";
                SET_IF_NOT_NULL(type, product[@"type"]);
            
                UIViewController *viewController = [[GDProductDetailsViewController alloc] init:productId withOrder:YES];
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
    }
   
}

#pragma mark - View lifecycle

- (void)tapClass
{
//    GDLiveAllCategoryViewController *viewController = [[GDLiveAllCategoryViewController alloc] init];
//    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)tapSearch
{
    [self pushProduct];
}

- (void)pushProduct
{
    GDLiveSearchViewController* nv = [[GDLiveSearchViewController alloc] init];
    [self.navigationController pushViewController:nv animated:YES];
}

- (void)reCaluCityWidth
{
    CGSize size = [countryBut.titleLabel.text moSizeWithFont:countryBut.titleLabel.font withWidth:100];
    countryBut.frame = CGRectMake(0, 0, size.width+12, 40);
    if([GDSettingManager instance].isRightToLeft)
    {
        [countryBut setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -130)];
    }
    else
    {
        [countryBut setTitleEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
    }
    [countryBut setImageEdgeInsets:UIEdgeInsetsMake(2, size.width, 0, 0)];
}

- (void)resetCity
{
    GDSelectCityViewController* vc = [[GDSelectCityViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *nc = [[UINavigationController alloc]
                                  initWithRootViewController:vc];
    vc.target = self;
    vc.callback = @selector(didSelectCity:);
    [self presentViewController:nc animated:YES completion:^(void) {
        
    }];
}

- (void)changeCountry
{
    [countryBut setTitle:[[GDSettingManager instance] getCountryShort] forState:UIControlStateNormal];
    [self reCaluCityWidth];
        
    //recall data
    [self refreshData];
}


- (void)didSelectCity:(id)sender
{
    NSDictionary* info = [GDSettingManager instance].nUserCity;
    NSString*     selCountry   = info[@"selCountry"];
    int           selCountryId = [info[@"selCountryId"] intValue];
   
    if (selCountryId != [GDSettingManager instance].currentCountryId)
    {
        [GDSettingManager instance].currentCountryId = selCountryId;
        [GDSettingManager instance].currentCountry   = selCountry;
        
        [countryBut setTitle: [[GDSettingManager instance] getCountryShort] forState:UIControlStateNormal];
        [self reCaluCityWidth];
        //recall data
        [self refreshData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!isLoadData)
    {
        [self getDataList];
        //[self getBannerData];
        //[self getEventData];
        //[self getHotCategoryData];
        [self getNewDealData];
        [self getLikeData];
       
        isLoadData = YES;
    }
    
}

#pragma mark Refresh
- (void)refreshData
{
    LOG(@"refresh data");
    
    seekPage = 1;
    
    [self getDataList];
    //[self getEventData];
    //[self getBannerData];
    //[self getHotCategoryData];
    [self getNewDealData];
    [self getLikeData];
}

- (void)nextPage
{
//    if (lastCountFromServer>=prePageNumber)
//    {
//        LOG(@"get next page");
//        [self loadMoreView];
//        seekPage++;
//        
//        [self getProductData];
//    }
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
                GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:proId withOrder:YES];
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else if ([type isEqualToString:@"category"])
            {
                int category_id = [dict[@"id"] intValue];
                
                GDLiveDiscountViewController* discountVC = [[GDLiveDiscountViewController alloc] init:category_id  withDrop:YES isDiscount:YES];
                [self.navigationController pushViewController:discountVC animated:YES];
                
            }
            else if ([type isEqualToString:@"weburl"])
            {
                NSString* urlText = dict[@"link"];
                
                GDReturnsViewController* nv = [[GDReturnsViewController alloc] init:urlText];
                [self.navigationController pushViewController:nv animated:YES];

            }
            else if ([type isEqualToString:@"activityurl"])
            {
                NSString* urlText = dict[@"link"];
                
                NSString* strUrl  = [NSString stringWithFormat:@"%@&app=ios&language_id=%@&token=%@",urlText,@([[GDSettingManager instance] language_id:NO]),[GDPublicManager instance].token];
                
                GDJoinViewController* nv = [[GDJoinViewController alloc] init:strUrl];
                [self.navigationController pushViewController:nv animated:YES];
                
            }
        }
    }
}

#pragma mark scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == hotCategoryView)
    {
        int currentPage = scrollView.contentOffset.x/scrollView.frame.size.width;
        
        hotCategoryPageControl.currentPage = currentPage;
    }
    else if (scrollView == mainTableView)
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

