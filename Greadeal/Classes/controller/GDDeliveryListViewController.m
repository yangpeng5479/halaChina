//
//  GDDeliveryListViewController.m
//  Greadeal
//
//  Created by Elsa on 16/2/18.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDDeliveryListViewController.h"
#import "RDVTabBarController.h"

#import "GDDeliverListCell.h"

#import "GDDeliveryVendorViewController.h"
#import "UIImage+MOAdditions.h"

#import "GDDeliverySearchViewController.h"

#import "MOItemSelectViewController.h"

#define DropDownListHeight 40
#define cityViewHeight 40

@interface GDDeliveryListViewController ()

@end

@implementation GDDeliveryListViewController

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

- (void)noFindCity
{
   // hView.hidden = YES;
   // [mainTableView addSubview:[self noDeliveryView]];
   // mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    int  areaid = 342;//International City
    int  cityid = 3509;
    
    [[GDSettingManager instance].userDeliveryInfo setObject:@(areaid) forKey:@"selAreaId"];
        
    NSString* areaName = [[GDSettingManager instance] searchAarea:areaid withCityID:cityid];
        
    //find nearby area
    areaLabel.text = [NSString stringWithFormat:@"%@, %@",areaName,@"Dubai"];
        
    //get cagetory and stores
    [self getData];
        
    getAddressBut.hidden = NO;
}

- (void)getArea:(NSString*)country withcity:(NSString*)city withlatitude:(double)latitude withlongitude:(double)longitude;
{
    NSString* url;
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/TakeoutAddress/location"];
    
    NSDictionary* parameters = @{@"country":country,@"zone":city,@"longitude":@(longitude),@"latitude":@(latitude)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             NSDictionary* location = nil;
             SET_IF_NOT_NULL(location, responseObject[@"data"][@"location"]);
             
             if (location!=nil)
             {
                 NSString* area_id = @"";
                 SET_IF_NOT_NULL(area_id, location[@"area_id"]);
                 int  areaid = [area_id intValue];
             
                 NSString* city_id = @"";
                 SET_IF_NOT_NULL(city_id, location[@"zone_id"]);
                 int  cityid = [city_id intValue];
                 
                 if (areaid>0)
                 {
                     [[GDSettingManager instance].userDeliveryInfo setObject:@(areaid) forKey:@"selAreaId"];
                 
                     NSString* areaName = [[GDSettingManager instance] searchAarea:areaid withCityID:cityid];
                 
                     //find nearby area
                     areaLabel.text = [NSString stringWithFormat:@"%@, %@",areaName,city];
                 
                     //get cagetory and stores
                     [self getData];

                     getAddressBut.hidden = NO;
                 }
             }
             else
             {
                 //can't find
                 [self noFindCity];
             }
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             
             [self noFindCity];
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [ProgressHUD showError:error.localizedDescription];
     }];

}

- (void)getLocaltion
{
    [ProgressHUD show:nil];
    
    [activityIndicatorView startAnimating];
    getAddressBut.hidden = YES;
    //  Get FTLocationManager singleton instance
    FTLocationManager *locationManager = [FTLocationManager sharedManager];
    
    //  Optionaly you can change properties like error timeout and errors count threshold
    //  Ask the location manager to get current location and get notified using
    //  provided handler block
    
    [locationManager updateLocationWithCompletionHandler:^(CLLocation *location, NSDictionary *userplace,NSError *error, BOOL locationServicesDisabled)
     {
         
            [activityIndicatorView stopAnimating];
         
             if (userplace!=nil)
             {
                 NSString* country  = userplace[@"country"];
                 NSString* localCity = userplace[@"city"];
                
                 NSString* address   = userplace[@"address"];
                 [[GDSettingManager instance].userDeliveryInfo setObject:address forKey:@"address"];
                 
                 //go on find area
                 [self getArea:country withcity:localCity withlatitude:location.coordinate.latitude withlongitude:location.coordinate.longitude];
                 
             }
             else
             {
                 //google never return

                 areaLabel.text = [GDSettingManager instance].currentCountry;
                 
                 [self chooseArea:[GDSettingManager instance].currentCountryId with:   [GDSettingManager instance].currentCountry];
                 
                 getAddressBut.hidden = NO;
             }
             [ProgressHUD dismiss];
     }];
}

- (void)changeArea
{
    [self chooseArea:[GDSettingManager instance].currentCountryId with:[GDSettingManager instance].currentCountry];
}

- (void)chooseArea:(int)selCityId with:(NSString*)selCityName
{
    NSDictionary* info = nil;
    
    NSArray* tempArrar = [GDSettingManager instance].nDeliveryCity;
    if (tempArrar.count>0)
    {
        info = [tempArrar objectAtIndex:0];
    }
    
    NSMutableDictionary*  areaDict = [[NSMutableDictionary alloc] init];
    
    NSArray* tempArray = nil;
    SET_IF_NOT_NULL(tempArray,info[@"zone_list"]);
    
    NSArray* areaArray = nil;
    
    for (NSDictionary* dict in tempArray)
    {
        int   cityId = [dict[@"zone_id"] intValue];
        if (cityId==selCityId)
        {
            SET_IF_NOT_NULL(areaArray,dict[@"area_list"]);
            break;
        }
    }
    
    if (areaArray!=nil)
    {
        for (NSDictionary* dict in areaArray)
        {
            NSString*  areaName = @"";
            int        areaId = [dict[@"area_id"] intValue];
            SET_IF_NOT_NULL(areaName,dict[@"name"]);
            
            [areaDict setObject:areaName forKey:@(areaId)];
        }
    }
    
    NSString* previous = @"";
    previous = [GDSettingManager instance].userDeliveryInfo[@"selArea"];
    
    MOItemSelectViewController *selectItem = [[MOItemSelectViewController alloc] initWithStyle:UITableViewStylePlain withDict:areaDict value:previous target:self action:@selector(selectedArea:) withTitle:selCityName];
    [self.navigationController pushViewController:selectItem animated:YES];

    [[GDSettingManager instance].userDeliveryInfo setObject:@(selCityId) forKey:@"selCityId"];
    [[GDSettingManager instance].userDeliveryInfo setObject:selCityName forKey:@"selCity"];
}

- (void)selectedArea:(NSDictionary *)value
{
    LOG(@"%@",value);
    int selAreaId = [value[@"id"] intValue];
    NSString* selArea = value[@"name"];

    [[GDSettingManager instance].userDeliveryInfo setObject:@(selAreaId) forKey:@"selAreaId"];
    [[GDSettingManager instance].userDeliveryInfo setObject:selArea forKey:@"selArea"];
    
    areaLabel.text = [NSString stringWithFormat:@"%@, %@",[GDSettingManager instance].userDeliveryInfo[@"selArea"],[GDSettingManager instance].userDeliveryInfo[@"selCity"]];
    
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Delivery",@"外卖");

    CGRect r = self.view.bounds;
    
    r.origin.y = DropDownListHeight;
    r.size.height -= DropDownListHeight;

    r.origin.y += cityViewHeight;
    r.size.height -= cityViewHeight;
    
    self.view.backgroundColor = MOColorSaleProductBackgroundColor();
    
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    //add table header view
    if (cityViewHeight>0)
    {
        hView = [[UIView alloc] initWithFrame:CGRectMake(0,0, r.size.width,cityViewHeight)];
        hView.backgroundColor = colorFromHexString(@"e6e6e6");
        hView.userInteractionEnabled = YES;
        [hView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeArea)]];
        [self.view addSubview:hView];
        
        UIImageView *addressImage = [[UIImageView alloc] init];
        addressImage.image = [UIImage imageNamed:@"Coordinate.png"];
        addressImage.frame = CGRectMake(5, 10,
                                        15, 19);
        [hView addSubview:addressImage];
        
        areaLabel = MOCreateLabelAutoRTL();
        areaLabel.backgroundColor = [UIColor clearColor];
        areaLabel.textColor = MOColor66Color();
        areaLabel.font = MOLightFont(14);
        areaLabel.text = NSLocalizedString(@"Detecting Location...",@"自动定位...");
        areaLabel.frame = CGRectMake(25, 0, r.size.width-100,cityViewHeight);
        [hView addSubview:areaLabel];
        
        getAddressBut=[UIButton buttonWithType:UIButtonTypeCustom];
       
        [getAddressBut setImage:[UIImage imageNamed:@"rightArrow.png"]  forState:UIControlStateNormal];
        getAddressBut.frame = CGRectMake(r.size.width-70, 5, 65,30);
        [getAddressBut addTarget:self action:@selector(changeArea) forControlEvents:UIControlEventTouchUpInside];
        [hView addSubview:getAddressBut];
        getAddressBut.hidden = YES;
        
        UILabel* switchLabel = MOCreateLabelAutoRTL();
        switchLabel.textAlignment = NSTextAlignmentLeft;
        switchLabel.backgroundColor = [UIColor clearColor];
        switchLabel.textColor = [UIColor whiteColor];
        switchLabel.font = MOLightFont(14);
        switchLabel.text = NSLocalizedString(@"Select",@"切换");
        switchLabel.frame = CGRectMake(10, 0, 50,30);
        [getAddressBut addSubview:switchLabel];
        
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.hidesWhenStopped = YES;
        activityIndicatorView.frame = CGRectMake(r.size.width-40, 0, 40,40);
        [hView addSubview:activityIndicatorView];
        
        if ([GDSettingManager instance].isRightToLeft)
        {
            CGRect tempRect = activityIndicatorView.frame;
            tempRect.origin.x = addressImage.frame.origin.x;
            activityIndicatorView.frame = tempRect;
            
            tempRect = getAddressBut.frame;
            tempRect.origin.x = addressImage.frame.origin.x;
            getAddressBut.frame = tempRect;
            
            tempRect = addressImage.frame;
            tempRect.origin.x = r.size.width-25;
            addressImage.frame = tempRect;
        }
    }
    
    [self getLocaltion];
    
    [self addRefreshUI];

    UIBarButtonItem*  searchButItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(tapSearch)];
    self.navigationItem.rightBarButtonItem = searchButItem;
}

- (void)tapSearch
{
    GDDeliverySearchViewController* nv = [[GDDeliverySearchViewController alloc] init];
    [self.navigationController pushViewController:nv animated:YES];
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
    
    [self  getAllCategory];
    //[self  getProductData];
}

- (void)getAllCategory
{
    NSNumber* areaNumber = [GDSettingManager instance].userDeliveryInfo[@"selAreaId"];
    int areaId = [areaNumber intValue];
    if (areaId<0)
        return;
    
    NSString* url;
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/TakeoutVendor/get_vendor_category_list_nearby"];
    
    NSDictionary* parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"area_id":@(areaId)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             @synchronized(categoryArrays)
             {
                 [categoryArrays removeAllObjects];
             }
             
             NSArray* temp = responseObject[@"data"][@"category_list"];
            
             int nCount = 0;
             for (NSDictionary* dict in temp)
             {
                 nCount += [dict[@"count"] intValue];
             }
             
             categoryArrays = [temp mutableCopy];
             
             //add all + count
             NSDictionary* allSection = @{@"category":@"All",@"count":@(nCount)};
             [categoryArrays insertObject:allSection atIndex:0];
             
             categoryName = @"All";
             
             if (dropMenu==nil)
             {
                 [self initDropDown];
             }
             else
             {
                 [dropMenu reloadData];
             }
             
             [self setDropDownIndex];
             
             [self getProductData];
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             [ProgressHUD showError:errorInfo];
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [ProgressHUD showError:error.localizedDescription];
     }];
    
}

- (void)getProductData
{
    NSNumber* areaNumber = [GDSettingManager instance].userDeliveryInfo[@"selAreaId"];
    int areaId = [areaNumber intValue];
    
    if (areaId<0)
        return;
    
    [ProgressHUD show:nil];
    
    NSString* url;
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/TakeoutVendor/get_vendor_list_nearby"];
    
    NSDictionary* parameters = nil;
    
    if ([categoryName isEqualToString:@"All"])
    {
        parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"page":@(seekPage),@"limit":@(prePageNumber),@"area_id":@(areaId),@"longitude":@([[GDSettingManager instance] getCityLongitude]),@"latitude":@([[GDSettingManager instance] getCityLatitude]),@"sort":sortChoose};
    }
    else
    {
         parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"page":@(seekPage),@"limit":@(prePageNumber),@"area_id":@(areaId),@"longitude":@([[GDSettingManager instance] getCityLongitude]),@"latitude":@([[GDSettingManager instance] getCityLatitude]),@"sort":sortChoose,@"category":categoryName};
    }
    
    
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
- (id)init
{
    self = [super init];
    if (self)
    {
        productData    = [[NSMutableArray alloc] init];
        categoryArrays = [[NSMutableArray alloc] init];
       
        categoryName = @"All";
        sortChoose = @"distance";//（distance ：rating）
        
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

#pragma mark DropDown
- (void)setDropDownIndex
{
    int nRow  = 0;
    int nItem = 0;
    
    DOPIndexPath* defaultSelect = [DOPIndexPath indexPathWithCol:0 row:nRow item:nItem];
    
    for (NSDictionary* dict in categoryArrays)
    {
        NSString* temp_name = dict[@"category"];
        if (categoryName == temp_name)
        {
            defaultSelect.row  = nRow;
            defaultSelect.item = 0;
            [dropMenu selectIndexPath:defaultSelect];
            return;
        }
//        else
//        {
//            nItem = 1;
//            NSArray* temp = dict[@"list"];
//            for (NSDictionary* dictTwo in temp)
//            {
//                NSString* temp_two_name = dictTwo[@"category_id"];
//                if (categoryName == temp_two_name)
//                {
//                    defaultSelect.row  = nRow;
//                    defaultSelect.item = nItem;
//                    [dropMenu selectIndexPath:defaultSelect];
//                    return;
//                }
//                nItem ++;
//            }
//            
//        }
        nRow++;
    }
}

- (void)initDropDown
{
    self.sorts = @[NSLocalizedString(@"Nearest", @"离我最近"),NSLocalizedString(@"Min.Orders", @"最小起送"),NSLocalizedString(@"Min. Delivery time", @"配送时间最少"),NSLocalizedString(@"High Rating", @"好评优先")];
    
    // 添加下拉菜单
    dropMenu = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(0,cityViewHeight) andHeight:DropDownListHeight];
    dropMenu.delegate = self;
    dropMenu.dataSource = self;
    [self.view addSubview:dropMenu];
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

#pragma mark  DropDown DataSource
- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu
{
    return 2;
}

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column
{
    if (column == 0){
        return categoryArrays.count;
    }
    else {
        return self.sorts.count;
    }
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath
{
    if (indexPath.column == 0)
    {
        if (indexPath.row<categoryArrays.count)
        {
            NSDictionary* dict = [categoryArrays objectAtIndex:indexPath.row];
            NSString* name = @"";
            SET_IF_NOT_NULL(name, dict[@"category"]);
            
            int count = [dict[@"count"] intValue];
            
            NSString* str = [NSString stringWithFormat:@"%@ (%d)",name,count];
            return str;
        }
    }
    else
    {
        return self.sorts[indexPath.row];
    }
    return nil;
}

- (NSString *)menu:(DOPDropDownMenu *)menu imageNameForRowAtIndexPath:(DOPIndexPath *)indexPath
{
    //if (indexPath.column == 0 || indexPath.column == 1) {
    //    if (indexPath.column == 0 ) { //一级图片
    //        return [NSString stringWithFormat:@"ic_filter_category_%ld",indexPath.row];
    //    }
    return nil;
}

- (NSString *)menu:(DOPDropDownMenu *)menu imageNameForItemsInRowAtIndexPath:(DOPIndexPath *)indexPath
{
    // if (indexPath.column == 0 && indexPath.item >= 0) {  //二级图片
    //        return [NSString stringWithFormat:@"ic_filter_category_%ld",indexPath.item];
    //    }
    return nil;
}

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfItemsInRow:(NSInteger)row column:(NSInteger)column
{
//    if (column == 0) {//二级目录行
//        
//        if (row<categoryArrays.count)
//        {
//            NSDictionary* dict = [categoryArrays objectAtIndex:row];
//            NSString* name = @"";
//            SET_IF_NOT_NULL(name, dict[@"category"]);
//            
//            if (dict!=nil)
//            {
//                NSArray* temp = dict[@"list"];
//                return temp.count + 1;
//            }
//        }
//    }
    return 0;
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForItemsInRowAtIndexPath:(DOPIndexPath *)indexPath
{
//    if (indexPath.column == 0) {//二级目录菜单
//        
//        NSDictionary* dict = [categoryArrays objectAtIndex:indexPath.row];
//        NSString* name = @"";
//        SET_IF_NOT_NULL(name, dict[@"category"]);
//        return name;
//        
//    }
    return nil;
}

#pragma mark dropDownListDelegate

- (void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath
{
    if (indexPath.column == 0)
    {
        if (indexPath.row < categoryArrays.count)
        {
            NSDictionary* dict = [categoryArrays objectAtIndex:indexPath.row];
            
            categoryName =  dict[@"category"];
//            else
//            {
//                NSArray* temp = dict[@"list"];
//                if (temp.count>0)
//                {
//                    NSDictionary* dictTwo = [temp objectAtIndex:indexPath.item - 1];
//                    categoryName =  dictTwo[@"category"];
//                }
//            }
            [self refreshData];
        }
    }
    else
    {
        if (indexPath.row == 0)
        {
            sortChoose = @"distance";
        }
        else if (indexPath.row == 1)
        {
            sortChoose = @"min_order_fee";
        }
        else if (indexPath.row == 2)
        {
            sortChoose = @"delivery_time";
        }
        else if (indexPath.row == 3)
        {
            sortChoose = @"rating";
        }
        
        [self refreshData];
    }
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"guessCell";
    GDDeliverListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GDDeliverListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* product = [productData objectAtIndex:indexPath.section];
    
    NSString*  imgUrl=@"";
    NSString*  delivery_fee=@"";
    NSString*  productname=@"";
    NSString*  min_order_fee=@"0";
    NSString*  delivery_time_min=@"0";
    NSString*  delivery_time_max=@"0";
    NSString*  distance=@"0";
    float      rating = [product[@"rating"] floatValue];
    
    SET_IF_NOT_NULL(imgUrl, product[@"vendor_image"]);
    SET_IF_NOT_NULL(delivery_fee, product[@"delivery_fee"]);
    SET_IF_NOT_NULL(productname, product[@"vendor_name"]);
    SET_IF_NOT_NULL(min_order_fee, product[@"min_order_fee"]);
    SET_IF_NOT_NULL(delivery_time_min, product[@"delivery_time_min"]);
    SET_IF_NOT_NULL(delivery_time_max, product[@"delivery_time_max"]);
    SET_IF_NOT_NULL(distance, product[@"distance"]);

    
    cell.vendorLabel.text = productname;
    cell.nDist =  [distance intValue];
    
    cell.deliveryChargeLabel.text  = [NSString stringWithFormat:NSLocalizedString(@"Delivery Chagres: %@%d",@"配送费: %@%d"),[GDPublicManager instance].currency,[delivery_fee intValue]];
    [cell.deliveryChargeLabel findCurrency:10];
    
    
    cell.starRateView.scorePercent = rating*1.0/5;
    
    cell.minorderLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Min.Order: %@%@",@"起送价: %@%@"),[GDPublicManager instance].currency,min_order_fee];
    [cell.minorderLabel findCurrency:10];
    
    cell.deliverytimeLabel.text =  [NSString stringWithFormat:NSLocalizedString(@"%@Mins",@"%@分钟"),delivery_time_min];
    
    [cell.productImage sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                         placeholderImage:[UIImage imageNamed:@"delivery_vendor_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                         }];
    
    BOOL isopen = NO;
    NSArray* openTimeArray = nil;
    SET_IF_NOT_NULL(openTimeArray,product[@"open_time"]);
    if (openTimeArray.count>0)
    {
        NSDictionary* dict = [openTimeArray objectAtIndex:0];
        if (dict!=nil)
        {
            NSString* open_time_start = dict[@"open_time_start"];
            NSString* open_time_end = dict[@"open_time_end"];
            
            NSString* sTime = [NSString stringWithFormat:@"%@",[open_time_start substringToIndex:5]];
            NSString* eTime = [NSString stringWithFormat:@"%@",[open_time_end substringToIndex:5]];
            
            cell.openhoursLabel.text = [NSString stringWithFormat:@"%@ - %@",sTime,eTime];
            
            isopen = [self checkStoreOpenTime:sTime withEtime:eTime];
            if (isopen){
                cell.closeImage.image = [UIImage imageNamed:@"open_store.png"];
            }
            else
            {
                cell.closeImage.image = [UIImage imageNamed:@"close_store.png"];
            }
        }
    }
    
    NSString*  sale_off=@"0";
    SET_IF_NOT_NULL(sale_off, product[@"discount"]);
    
    int  n_sale_off = [sale_off intValue];
    if (n_sale_off>0)
    {
        cell.saleImage.hidden = NO;
        if (isopen){
            cell.saleImage.image = [UIImage imageNamed:@"list_sale_open.png"];
        }
        else
        {
            cell.saleImage.image = [UIImage imageNamed:@"list_sale_close.png"];
        }
        cell.saleLabel.text = [NSString stringWithFormat:@"%d%% OFF",n_sale_off];
    }
    else
    {
        cell.saleImage.hidden = YES;
    }
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    if (!reloading && !productData.count)
//    {
//        [mainTableView addSubview:[self noDeliveryView]];
//        mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
//    }
//    
//    if (productData.count>0)
//    {
//        [_noDeliverView removeFromSuperview];
//        mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
//    }
    
    return productData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* vendor = [productData objectAtIndex:indexPath.section];
    if (vendor!=nil)
    {
        GDDeliveryVendorViewController *viewController = [[GDDeliveryVendorViewController alloc] init:vendor];
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
