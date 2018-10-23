// RDVSecondViewController.m
// RDVTabBarController
//
// Copyright (c) 2013 Robert Dimitrov

#import "GDSuperViewController.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"

#import "GDProductListCell.h"

#import "GDProductDetailsViewController.h"

#import "GDSaleClassificationViewController.h"

#import "GDMarketAddSelectViewController.h"
#import "GDMarketProtalViewController.h"

#import "GDMarketProductListViewController.h"
#import "GDMarketListCell.h"

#define xMargin        0
#define yMargin        10

#define bannerHeight   100

@implementation GDSuperViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.title = NSLocalizedString(@"Market", @"超市");
        
        productData = [[NSMutableArray alloc] init];
        marketData  = [[NSMutableArray alloc] init];
        bannerData  = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
        
        popChooseAddress = YES;
    }
    return self;
}

#pragma mark - Data
- (void)didSelectAddress:(id)sender
{
    //get market from server
    [self refreshData];
}

- (void)getMarketData
{
    reloading = YES;
    NSDictionary* info = [GDSettingManager instance].nUserCityAddress;
    
    if (info!=nil)
    {
        NSString* url;
        NSDictionary *parameters;
        
    int zoneId = [info[@"selCommunityId"] intValue];
        
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"supermarket/get_vender_list_nearby"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"zone_area_id":@(zoneId)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
            @synchronized(marketData)
            {
                [marketData removeAllObjects];
            }
             
             [marketData addObjectsFromArray:responseObject[@"data"]];
             
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
         
         if (marketData.count<=0)
         {
             [mainTableView addSubview:[self noMarketView]];
         }
         else
         {
             [_noMarketView removeFromSuperview];
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self stopLoad];
         [self reLoadView];
         [ProgressHUD showError:error.localizedDescription];
     }];

    }
}

- (void)getBannerData
{
    CGRect r = self.view.frame;
    if (bannerView==nil)
    {
        bannerView = [[JCTopic alloc]initWithFrame:CGRectMake(0, 0, r.size.width, bannerHeight) ];
        bannerView.JCdelegate = self;
    }
        
    NSString* url;
    NSDictionary *parameters;
        
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"supermarket/get_banner_list"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES])};
        
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
        
    [manager POST:url
           parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
             [ProgressHUD dismiss];
             
             int status = [responseObject[@"status"] intValue];
             if (status==1)
             {
                 @synchronized(bannerData)
                 {
                     [bannerData removeAllObjects];
                 }
                 
                 if(responseObject[@"data"][@"top_banners"] != [NSNull null] && responseObject[@"data"][@"top_banners"] != nil)
                 {
                     [bannerData addObjectsFromArray:responseObject[@"data"][@"top_banners"]];
                     
                     NSMutableArray *pictureArrar = [[NSMutableArray alloc] init];
                     for (NSDictionary* dict in bannerData) {
                         NSString* image = @"";
                         SET_IF_NOT_NULL( image , dict[@"image"]);
                         [pictureArrar addObject:image];
                     }
                     
                     bannerView.pics = pictureArrar;
                     [bannerView upDate:@"live_banner_default.png"];
                 }
             }
             else
             {
                 NSString *errorInfo =@"";
                 SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
                 LOG(@"errorInfo: %@", errorInfo);
                 [ProgressHUD showError:errorInfo];
             }
             if (bannerView.pics.count>0)
                 mainTableView.tableHeaderView = bannerView;
             else
                 mainTableView.tableHeaderView = nil;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [ProgressHUD showError:error.localizedDescription];
         }];
}

- (void)getProductData
{
    NSDictionary* info = [GDSettingManager instance].nUserCityAddress;
    
    if (info!=nil)
    {
        NSString* url;
        NSDictionary *parameters;
        
        int zoneId = [info[@"selCommunityId"] intValue];

        if (!isLoadData)
            [ProgressHUD show:nil];
    
        url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"supermarket/get_rec_product_list"];
        parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"zone_area_id":@(zoneId),@"page":@(seekPage),@"limit":@(prePageNumber)};
    
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
             
             if(responseObject[@"data"][@"product_list"] != [NSNull null] && responseObject[@"data"][@"product_list"] != nil)
             {
                 [productData addObjectsFromArray:responseObject[@"data"][@"product_list"]];
             
                 NSArray* temp = responseObject[@"data"];
                 lastCountFromServer = (int)temp.count;
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
            [ProgressHUD dismiss];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self stopLoad];
         [self reLoadView];
         
         [ProgressHUD showError:error.localizedDescription];
     }];
    }
}

- (void)reLoadView
{
    [mainTableView reloadData];
}

#pragma mark - View lifecycle

- (void)tapAddress
{
    GDMarketAddSelectViewController* vc = [[GDMarketAddSelectViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *nc = [[UINavigationController alloc]
                                  initWithRootViewController:vc];
    vc.target = self;
    vc.callback = @selector(didSelectAddress:);
    [self presentViewController:nc animated:YES completion:^(void) {
       
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect r = self.view.bounds;
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    mainTableView.backgroundColor = MOColorAppBackgroundColor();
    [self.view addSubview:mainTableView];
    
    [self addRefreshUI];
    
    UIBarButtonItem*  addressButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"My Area", @"我的小区") style:UIBarButtonItemStylePlain target:self action:@selector(tapAddress)];
    self.navigationItem.rightBarButtonItem = addressButton;
}

- (UIView*)noMarketView
{
    if (!_noMarketView) {
        
        CGRect r = self.view.frame;
        
        _noMarketView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, r.size.width-20, r.size.height)];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, r.size.height/2-80, r.size.width-20, 60)];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines =0;
        label.text = NSLocalizedString(@"Oops,this service in your choosed area, will be coming soon!", @"您的小区附近,还没有超市提供在线订购服务!");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:16];
        [_noMarketView addSubview:label];
    }
    return _noMarketView;

}

- (UIView*)noSelectView
{
    if (!_noSelectView) {
        
        CGRect r = self.view.frame;
        
        _noSelectView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, r.size.width-20, r.size.height)];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, r.size.height/2-80, r.size.width-20, 60)];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines =0;
        label.text = NSLocalizedString(@"Please choose your area for free shipping.", @"请选择您要收货的小区,超市将会为您免费配送.");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:16];
        [_noSelectView addSubview:label];
        
        ACPButton* addBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        addBut.frame = CGRectMake(10, r.size.height/2, r.size.width-40, 36);
        [addBut setStyleWithImage:@"loginNormal.png" highlightedImage:@"loginPress.png" disableImage:@"loginPress.png" andInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [addBut setTitle: NSLocalizedString(@"Choose Area", @"选择小区") forState:UIControlStateNormal];
        [addBut addTarget:self action:@selector(tapAddress) forControlEvents:UIControlEventTouchUpInside];
        [addBut setLabelFont:[UIFont systemFontOfSize:18]];
        [_noSelectView addSubview:addBut];
        
    }
    return _noSelectView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
    //if user no choose area
    if ([GDSettingManager instance].nUserCityAddress!=nil)
    {
        NSDictionary* parameters = [GDSettingManager instance].nUserCityAddress;
        int selCommunityId = [parameters[@"selCommunityId"] intValue];
        if (selCommunityId!=0)
            popChooseAddress = NO;
        
        [_noSelectView removeFromSuperview];
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        
        if (!isLoadData)
        {
            [self getBannerData];
            [self getMarketData];
            [self getProductData];
            
            isLoadData= YES;
        }
    }
    else
    {
        [mainTableView addSubview:[self noSelectView]];
         mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    
    if (popChooseAddress)
    {
        GDMarketAddSelectViewController* vc = [[GDMarketAddSelectViewController alloc] initWithStyle:UITableViewStylePlain];
        UINavigationController *nc = [[UINavigationController alloc]
                                      initWithRootViewController:vc];
        vc.target = self;
        vc.callback = @selector(didSelectAddress:);
        [self presentViewController:nc animated:YES completion:^(void) {
            popChooseAddress = NO;
        }];
    }
}
#pragma mark - Table view

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (marketData.count>0)
        {
            NSDictionary* parameters = [GDSettingManager instance].nUserCityAddress;

            UILabel* cityLabel = MOCreateLabelAutoRTL();
            cityLabel.backgroundColor = [UIColor clearColor];
            cityLabel.textColor = [UIColor blackColor];
            cityLabel.font = [UIFont systemFontOfSize:14];
            cityLabel.text = [NSString stringWithFormat:@"%@ , %@", parameters[@"selCommunity"],parameters[@"selCity"]];
            
            CGRect r =self.view.bounds;
            UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, 0, r.size.width, 40)];
            
            cityLabel.frame = CGRectMake(15, 0, [GDPublicManager instance].screenWidth-30, 40);
            
            [hView addSubview:cityLabel];
            
            hView.backgroundColor = MOSectionBackgroundColor();
            
            return hView;

        }
    }
    if (section == 1)
    {
        if (productData.count>0)
        {
            UILabel* titleLabel = MOCreateLabelAutoRTL();
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.text = NSLocalizedString(@"Recommendation", @"您的专属推荐");
    
            CGRect r =self.view.bounds;
            UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, 0, r.size.width, 40)];
    
            titleLabel.frame = CGRectMake(r.origin.x+10, 0, r.size.width-30, 40);
    
            [hView addSubview:titleLabel];
       
            hView.backgroundColor =MOSectionBackgroundColor();
    
            return hView;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        if (productData.count>0)
        {
            return  40;
        }
    }
    if (section == 0)
    {
        if (marketData.count>0)
            return 40;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0)
    {
        GDMarketListCell *cell ;
        static NSString *ID = @"style1";
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[GDMarketListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        NSDictionary* obj = [marketData objectAtIndex:indexPath.row];
        
        NSString* title = @"";
        NSString* name  = @"";
        NSString* image_url = @"";
        
        SET_IF_NOT_NULL(title, obj[@"vendor_name"]);
        SET_IF_NOT_NULL(name, obj[@"address_1"]);
        SET_IF_NOT_NULL(image_url, obj[@"vendor_image"]);
        
        [cell.iconImage sd_setImageWithURL:[NSURL URLWithString:[image_url encodeUTF]]
                             placeholderImage:[UIImage imageNamed:@"market_product_default.png"]];
        cell.titleLabel.text = title;
        cell.titleLabel.tag = indexPath.row;
        cell.nameLabel.text = name;

        return cell;
        
    }
    else if (indexPath.section == 1)
    {
        static NSString *CellIdentifier = @"listCell";
        
        GDProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
        cell = [[GDProductListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
    
        NSDictionary* obj = [productData objectAtIndex:indexPath.row];
        
        NSString*  stroPrice=@"";
        NSString*  strsPrice=@"";
        NSString*  imgUrl=@"";
        NSString*  title_name =@"";
        NSString*  meta_description=@"";
        //int rating =   [obj[@"rating"] intValue];
        
        int viewed = [obj [@"viewed"] intValue];
        SET_IF_NOT_NULL(imgUrl, obj[@"image"]);
        SET_IF_NOT_NULL(title_name, obj[@"name"]);
        SET_IF_NOT_NULL(stroPrice, obj[@"price"]);
        SET_IF_NOT_NULL(meta_description, obj[@"meta_description"]);
        
        if(obj[@"special_price_info"] != [NSNull null] && obj[@"special_price_info"] != nil)
        {
            SET_IF_NOT_NULL(strsPrice, obj[@"special_price_info"][@"price"]);
        }
        else
        {
            strsPrice = stroPrice;
        }
        
        float oprice = [stroPrice floatValue];
        float sprice = [strsPrice floatValue];
          
        [cell.productImage sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                          placeholderImage:[UIImage imageNamed:@"live_product_default.png"]];
    
        cell.titleLabel.text = title_name;
    
        cell.originPrice.text =  [NSString stringWithFormat:@"%@%.1f",[GDPublicManager instance].currency, oprice];
        
        cell.salePrice.text =  [NSString stringWithFormat:@"%@%.1f",[GDPublicManager instance].currency, sprice];
        
        cell.viewed.text = [NSString stringWithFormat:NSLocalizedString(@"Viewed: %d", @"查看: %d"),viewed];
        cell.rateView.hidden = YES;
        
        if (sprice!=oprice)
            cell.discount.text = [NSString stringWithFormat:@"%d%% OFF",(int)(100-sprice*1.0/oprice*100)];
        else
            cell.discount.text = @"";

        
        return cell;
    }
    
    return  nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!reloading && !marketData.count)
    {
        [mainTableView insertSubview:[self noNetworkView] atIndex:0];
          
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(refreshData)];
        [[self noNetworkView] addGestureRecognizer:tapGesture];
        
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    
    if (marketData.count>0)
    {
        [_noNetworkView removeFromSuperview];
        
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    
    switch (section) {
        case 0:
            return marketData.count;
        case 1:
            return productData.count;
        default:
            break;
    }
    return 0;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 80;
    }
    else if (indexPath.section == 1)
    {
        return 90*[GDPublicManager instance].screenScale;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        NSDictionary* obj = [marketData objectAtIndex:indexPath.row];
        if (obj!=nil)
        {
            int vendor_id = [obj[@"vendor_id"] intValue];
            GDMarketProtalViewController *viewController = [[GDMarketProtalViewController alloc] init:vendor_id];
            SET_IF_NOT_NULL( viewController.title , obj[@"vendor_name"]);
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
    else
    {
        NSDictionary* obj = [productData objectAtIndex:indexPath.row];
        if (obj!=nil)
        {
            int productId = [obj[@"product_id"] intValue];
            NSString* type=@"";
            SET_IF_NOT_NULL(type, obj[@"type"]);
            
            UIViewController *viewController = [[GDProductDetailsViewController alloc] init:productId withtype:type];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

#pragma mark Refresh
- (void)refreshData
{
    LOG(@"refresh data");
    
    if ([GDSettingManager instance].nUserCityAddress!=nil)
    {
        [self getBannerData];
        [self getMarketData];
        seekPage = 1;
        [self getProductData];
    }
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
                GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:proId withtype:type];
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else if ([type isEqualToString:@"category"])
            {
                int categoryId = [dict[@"id"] intValue];
                int vendorId = [dict[@"vendor_id"] intValue];
                
                GDMarketProductListViewController *viewController = [[GDMarketProductListViewController alloc] init:vendorId withCategory:categoryId];
                SET_IF_NOT_NULL( viewController.title , dict[@"name"]);
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
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

@end
