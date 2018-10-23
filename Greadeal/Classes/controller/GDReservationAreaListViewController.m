//
//  GDReservationAreaListViewController.m
//  Greadeal
//
//  Created by Elsa on 16/6/21.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDReservationAreaListViewController.h"
#import "RDVTabBarController.h"

#import "GDAreaListCell.h"

#import "GDReservationDeliveryListViewController.h"

#define lableViewHeight 0

@interface GDReservationAreaListViewController ()

@end

@implementation GDReservationAreaListViewController

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
    
    self.title = NSLocalizedString(@"Choose Your Area",@"选择您的区域");
    
    CGRect r = self.view.bounds;
    
    r.origin.y += lableViewHeight;
    r.size.height -= lableViewHeight;
   
    self.view.backgroundColor = MOColorSaleProductBackgroundColor();
    
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    
    //add table header view
    if (lableViewHeight>0)
    {
        UIView* hView = [[UIView alloc] initWithFrame:CGRectMake(0,0, r.size.width,lableViewHeight)];
        hView.backgroundColor = colorFromHexString(@"e6e6e6");
        hView.userInteractionEnabled = YES;
        [self.view addSubview:hView];
        
        
        UILabel* noteLabel = MOCreateLabelAutoRTL();
        noteLabel.textAlignment = NSTextAlignmentCenter;
        noteLabel.backgroundColor = [UIColor clearColor];
        noteLabel.textColor = colorFromHexString(@"7E674E");
        noteLabel.font = MOLightFont(17);
        noteLabel.text = NSLocalizedString(@"Free Delivery To All Areas",@"所有区域 免费配送");
        [hView addSubview:noteLabel];
        
        CGSize titleSize = [noteLabel.text moSizeWithFont:noteLabel.font withWidth:200];
        noteLabel.frame = CGRectMake((r.size.width-titleSize.width)/2, 0,  titleSize.width,lableViewHeight);
        
        UIImageView *busImage = [[UIImageView alloc] init];
        busImage.image = [UIImage imageNamed:@"delivery_bus.png"];
        busImage.frame = CGRectMake((r.size.width-titleSize.width)/2-22, (lableViewHeight-17)/2,
                                    17, 17);
        [hView addSubview:busImage];
        
        
    }
    
    [self addRefreshUI];
    
    [self getProductData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getProductData
{
    NSNumber* areaNumber = [GDSettingManager instance].userDeliveryInfo[@"selAreaId"];
    int areaId = [areaNumber intValue];
    
    if (areaId<0)
        return;
    
    [ProgressHUD show:nil];
    
    NSString* url;
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/TakeoutAddress/get_bat_takeout_area_list"];
    
    NSDictionary* parameters = nil;
    
//    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"page":@(seekPage),@"limit":@(prePageNumber),@"area_id":@(areaId),@"longitude":@([[GDSettingManager instance] getCityLongitude]),@"latitude":@([[GDSettingManager instance] getCityLatitude])};
//    
    
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
             
             NSArray* temp = responseObject[@"data"][@"area_list"];
             
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
- (id)init
{
    self = [super init];
    if (self)
    {
        productData  = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
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

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"guessCell";
    GDAreaListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GDAreaListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* product = [productData objectAtIndex:indexPath.section];
    
    NSString*  imgUrl=@"";
    NSString*  area_name=@"";
    NSString*  bat_takeout_title=@"";
    
    SET_IF_NOT_NULL(imgUrl, product[@"image"]);
    SET_IF_NOT_NULL(area_name, product[@"area_name"]);
    SET_IF_NOT_NULL(bat_takeout_title, product[@"bat_takeout_title"]);
 
    [cell.productImage sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                         placeholderImage:[UIImage imageNamed:@"delivery_vendor_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                         }];
    
    cell.areaLabel.text = area_name;
    cell.areaSubLabel.text = bat_takeout_title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return productData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* obj = [productData objectAtIndex:indexPath.section];
    if (obj!=nil)
    {
        NSString*  area_name=@"";
        int        area_id  =[obj[@"area_id"] intValue];
        SET_IF_NOT_NULL(area_name, obj[@"area_name"]);
        
        NSArray*   timelist  = obj[@"takeout_times"];
        
        [[GDSettingManager instance].userDeliveryInfo setObject:@(area_id) forKey:@"selAreaId"];
        [[GDSettingManager instance].userDeliveryInfo setObject:area_name forKey:@"selArea"];
        
        NSString*     selCity   = [GDSettingManager instance].currentCountry;
        int           selCityId = [GDSettingManager instance].currentCountryId;

        [[GDSettingManager instance].userDeliveryInfo setObject:@(selCityId) forKey:@"selCityId"];
        [[GDSettingManager instance].userDeliveryInfo setObject:selCity forKey:@"selCity"];
        
        GDReservationDeliveryListViewController *viewController = [[GDReservationDeliveryListViewController alloc] init:area_name withTimes:timelist];
        [self.navigationController pushViewController:viewController animated:YES];
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
