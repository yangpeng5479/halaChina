//
//  GDReservationDeliveryListViewController.m
//  Greadeal
//
//  Created by Elsa on 16/2/18.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDReservationDeliveryListViewController.h"
#import "RDVTabBarController.h"

#import "GDTimesListCell.h"
#import "GDVendorListCell.h"

#import "GDReservationDeliveryVendorViewController.h"
#import "UIImage+MOAdditions.h"

@interface GDReservationDeliveryListViewController ()

@end

@implementation GDReservationDeliveryListViewController

- (void)addRefreshUI
{
    CGRect viewRect = self.view.bounds;
    refreshHeaderView = [[MORefreshTableHeaderView alloc] initWithFrame:
                         CGRectMake(0.0f,0.0-viewRect.size.height,
                                    viewRect.size.width, viewRect.size.height)];
    [refreshHeaderView setLastUpdatedDate:[NSDate date]];
    [mainTableView addSubview:refreshHeaderView];
    
    CGRect barRect = self.view.bounds;
    barRect.size.height = kThumbsViewMoreHeight;
    
    barRect.origin.y = 0;
    
    getMoreview= [[UIView alloc] initWithFrame:barRect];
    getMoreview.backgroundColor= MOColorAppBackgroundColor();
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = CGPointMake(barRect.size.width/2, kThumbsViewMoreHeight/2);
    indicator.hidesWhenStopped = YES;
    indicator.color = HUD_SPINNER_COLOR;
    
    [getMoreview addSubview:indicator];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect r = self.view.bounds;
    
    self.view.backgroundColor = MOColorSaleProductBackgroundColor();
    
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    [self addRefreshUI];

    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Data
- (void)getData
{
    seekPage = 1;
    reloading = YES;
    
    [self  getProductData];
}

- (void)getProductData
{
    NSNumber* areaNumber = [GDSettingManager instance].userDeliveryInfo[@"selAreaId"];
    int areaId = [areaNumber intValue];
    if (areaId<0)
        return;
    
    NSNumber* cityNumber = [GDSettingManager instance].userDeliveryInfo[@"selCityId"];
    int cityId = [cityNumber intValue];
    if (cityId<0)
        return;
    
    [ProgressHUD show:nil];
    
    NSString* url;
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"Takeout/v1/TakeoutVendor/get_bat_vendor_list"];
    
    NSDictionary* parameters = nil;
    
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"page":@(seekPage),@"limit":@(prePageNumber),@"area_id":@(areaId),@"longitude":@([[GDSettingManager instance] getCityLongitude]),@"latitude":@([[GDSettingManager instance] getCityLatitude]),@"zone_id":@(cityId)};
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [ProgressHUD dismiss];
         
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
             
             NSArray* temp = responseObject[@"data"][@"vendor_list"];
             
             lastCountFromServer = (int)temp.count;
             
             if (temp.count>0)
             {
                 [productData addObjectsFromArray:temp];
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

- (void)refreshData
{
    LOG(@"refresh data");
    
    seekPage = 1;
    reloading = YES;
    
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
- (id)init:(NSString*)title  withTimes:(NSArray*)timesList
{
    self = [super init];
    if (self)
    {
        productData    = [[NSMutableArray alloc] init];
        timesData      = [[NSMutableArray alloc] init];
        
        [timesData addObjectsFromArray:timesList];
        
        seekPage = 1;
        lastCountFromServer = 0;
        
        self.title = title;

    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [ProgressHUD dismiss];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (BOOL)checkStoreOpenTime:(NSString*)sTime withEtime:(NSString*)eTime
{
    NSDate * senddate=[NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH"];
    NSString * locationString=[dateformatter stringFromDate:senddate];
    int currentTime = [locationString intValue];
    
    int nStime = [sTime intValue];
    int nEtime = [eTime intValue];
    
    if (currentTime>=nStime && currentTime<=nEtime)
    {
        return YES;
    }
    else
        return NO;
}

- (UIView*)makeAview:(float)offsetX withText:(NSString*)str withImage:(NSString*)imgurl
{
    UIView* hView = [[UIView alloc] initWithFrame:CGRectMake(offsetX,0, [GDPublicManager instance].screenWidth/2,45)];
    hView.backgroundColor = [UIColor clearColor];
    
    UILabel* noteLabel = MOCreateLabelAutoRTL();
    noteLabel.textAlignment = NSTextAlignmentCenter;
    noteLabel.backgroundColor = [UIColor clearColor];
    noteLabel.textColor = colorFromHexString(@"3C4149");
    noteLabel.font = MOLightFont(17);
    noteLabel.text = str;
    [hView addSubview:noteLabel];
    
    CGSize titleSize = [noteLabel.text moSizeWithFont:noteLabel.font withWidth:150];
    noteLabel.frame = CGRectMake(([GDPublicManager instance].screenWidth/2-titleSize.width)/2, 0,  titleSize.width,45);
    
    UIImageView *Image = [[UIImageView alloc] init];
    Image.image = [UIImage imageNamed:imgurl];
    Image.frame = CGRectMake(([GDPublicManager instance].screenWidth/2-titleSize.width)/2-22, (45-17)/2,17, 17);
    [hView addSubview:Image];

    return hView;
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            static NSString *CellIdentifier = @"oneCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            
            [cell.contentView addSubview:[self makeAview:0 withText:NSLocalizedString(@"Booking Time",@"预定时间") withImage:@"delivery_time.png"]];
            [cell.contentView addSubview:[self makeAview:[GDPublicManager instance].screenWidth/2 withText:NSLocalizedString(@"Delivery Arrival",@"送达时间") withImage:@"delivery_bus.png"]];
            
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"listCell";
            GDTimesListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GDTimesListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            
            NSDictionary* product = [timesData objectAtIndex:indexPath.row-1];
            
            NSString*  order_start_time=@"";
            NSString*  order_end_time=@"";
            NSString*  arrive_start_time=@"";
            NSString*  arrive_end_time=@"";
            
            SET_IF_NOT_NULL(order_start_time, product[@"order_start_time"]);
            SET_IF_NOT_NULL(order_end_time, product[@"order_end_time"]);
            SET_IF_NOT_NULL(arrive_start_time, product[@"arrive_start_time"]);
            SET_IF_NOT_NULL(arrive_end_time, product[@"arrive_end_time"]);
            
            NSString* rTime = [NSString stringWithFormat:@"%@-%@",[order_start_time substringToIndex:5],[order_end_time substringToIndex:5]];
          
            NSString* dTime = [NSString stringWithFormat:@"%@-%@",[arrive_start_time substringToIndex:5],[arrive_end_time substringToIndex:5]];
            
            cell.rTimeLabel.text = rTime;
            cell.dTimeLabel.text = dTime;
            
            return cell;

        }
    }
    else
    {
        static NSString *CellIdentifier = @"vendorCell";
        GDVendorListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GDVendorListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        NSDictionary* product = [productData objectAtIndex:indexPath.section-1];
        
        NSString*  imgUrl=@"";
        NSString*  desc=@"";
        NSString*  productname=@"";
        float      rating = [product[@"rating"] floatValue];
        
        SET_IF_NOT_NULL(imgUrl, product[@"vendor_image"]);
        SET_IF_NOT_NULL(desc, product[@"desc"]);
        SET_IF_NOT_NULL(productname, product[@"vendor_name"]);
        
        cell.vendorLabel.text = productname;
        cell.serviceLabel.text = desc;
        cell.starRateView.scorePercent = rating*1.0/5;
        
        
        [cell.productImage sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                             placeholderImage:[UIImage imageNamed:@"delivery_vendor_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             }];
        
        return cell;
        
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1+productData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1+timesData.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
    {
        if (indexPath.row ==0)
            return 45;
        else
            return 36;
    }
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section != 0)
    {
        NSDictionary* product = [timesData lastObject];
            
        NSString*  order_end_time=@"";
        SET_IF_NOT_NULL(order_end_time, product[@"order_end_time"]);
        order_end_time = [order_end_time substringToIndex:5];
        
        NSDate *  todate=[NSDate date];
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"HH:mm"];
        NSString *toString=[dateformatter stringFromDate:todate];
        
        if ([order_end_time compare:toString options:NSCaseInsensitiveSearch|NSNumericSearch]==NSOrderedDescending)
        {
            NSDictionary* vendor = [productData objectAtIndex:indexPath.section-1];
            if (vendor!=nil)
            {
                GDReservationDeliveryVendorViewController *viewController = [[GDReservationDeliveryVendorViewController alloc] init:vendor];
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
        else
        {
        
            [UIAlertView showWithTitle:nil
                               message:[NSString stringWithFormat:NSLocalizedString(@" Booking working meals before %@ at the latest, you can only book tomorrow's. Do you want to continue?", @"今天最迟预定时间是%@,现在只能预定明天的工作餐，要继续吗?"), order_end_time]
                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
                     otherButtonTitles:@[NSLocalizedString(@"Continue", @"继续")]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex ==1) {
                                      NSDictionary* vendor = [productData objectAtIndex:indexPath.section-1];GDReservationDeliveryVendorViewController *viewController = [[GDReservationDeliveryVendorViewController alloc] init:vendor];
                                      [self.navigationController pushViewController:viewController animated:YES];
                                  }
                              }];
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
