//
//  GDLiveVendorListViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/14.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDMemberCardViewController.h"
#import "GDProductDetailsViewController.h"

#import "GDLiveVendorViewController.h"

#import "GDLiveVendorListCell.h"
#import "GDLiveProductListCell.h"
#import "GDProductDetailsViewController.h"

#import "GDBuyMemberViewController.h"

#define DropDownListHeight 40
#define cityViewHeight 0

@interface GDMemberCardViewController ()

@end

@implementation GDMemberCardViewController

- (id)init:(categoryType)selType withDrop:(BOOL)showDrop
{
    self = [super init];
    if (self)
    {
        merchantList   = [[NSMutableArray alloc] init];
        categoryArrays = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
        categoryId = 0;
        
        showCategory = selType;
        
        showCagetoryDrop = showDrop;
         
        sortChoose = @"distance";//（distance ：rating）
        
        self.title = NSLocalizedString(@"Member", @"会员");
        [self addFBEvent:@"Member"];
    }
    return self;
}


- (void)setDropDownIndex
{
    int nRow  = 0;
    int nItem = 0;
    
    DOPIndexPath* defaultSelect = [DOPIndexPath indexPathWithCol:0 row:nRow item:nItem];
    
    for (NSDictionary* dict in categoryArrays)
    {
        int temp_id = [dict[@"category_id"] intValue];
        if (categoryId == temp_id)
        {
            defaultSelect.row  = nRow;
            defaultSelect.item = 0;
            [dropMenu selectIndexPath:defaultSelect];
            return;
        }
        else
        {
            nItem = 1;
            NSArray* temp = dict[@"list"];
            for (NSDictionary* dictTwo in temp)
            {
                int temp_two_id = [dictTwo[@"category_id"] intValue];
                if (categoryId == temp_two_id)
                {
                    defaultSelect.row  = nRow;
                    defaultSelect.item = nItem;
                    [dropMenu selectIndexPath:defaultSelect];
                    return;
                }
                nItem ++;
            }
            
        }
        nRow++;
    }
}

- (void)initDropDown
{
    self.sorts = @[NSLocalizedString(@"Nearest", @"离我最近"),NSLocalizedString(@"High Rating", @"好评优先"),NSLocalizedString(@"Cost - high to low", @"人均价格 高到低"),NSLocalizedString(@"Cost - low to high", @"人均价格 低到高")];
    
    // 添加下拉菜单
    dropMenu = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(0, 0) andHeight:DropDownListHeight];
    dropMenu.delegate = self;
    dropMenu.dataSource = self;
    [self.view addSubview:dropMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data
- (void)tapSort
{
    isLoadData = NO;
    [self getVendorData:categoryId];
}

- (void)getAllCategory
{
     [[GDPublicManager instance] getCategory:showCategory success:^(NSError *error){
        [ProgressHUD dismiss];
        if (error!=nil)
        {
            [ProgressHUD showError:error.localizedDescription];
        }
        else
        {
            @synchronized(categoryArrays)
            {
                [categoryArrays removeAllObjects];
            }
            
            if (showCategory == CATEGORY_BLUE_STORE)
                categoryArrays = [[GDSettingManager instance].nBlueCategory mutableCopy];
            else if (showCategory == CATEGORY_GOLD_STORE)
                categoryArrays = [[GDSettingManager instance].nGoldCategory mutableCopy];
            else if (showCategory == CATEGORY_PLATINUM_STORE)
                categoryArrays = [[GDSettingManager instance].nPlatinumCategory mutableCopy];
            
            [self selectDefaultCategory];
            
            if (dropMenu==nil)
            {
                [self initDropDown];
            }
            else
            {
                [dropMenu reloadData];
            }
            
            [self setDropDownIndex];
        }
    }];

}

- (void)getVendorData:(int)cid
{
    [ProgressHUD show:nil];
    
    reloading = YES;
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/vendor/get_vendor_list_in_category_with_product_and_sort"];
    
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"category_id":@(cid),@"page":@(seekPage),@"limit":@(prePageNumber),@"sort":sortChoose,@"country_id":@([GDSettingManager instance].currentCountryId),@"longitude":@([[GDSettingManager instance] getCityLongitude]),@"latitude":@([[GDSettingManager instance] getCityLatitude]),@"on_sale":@(1),@"membership_level":@(showCategory-1)};

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
                 @synchronized(merchantList)
                 {
                     [merchantList removeAllObjects];
                 }
             }
             
             NSArray* temp = responseObject[@"data"][@"vendor_list"];
             lastCountFromServer = (int)temp.count;
             
             if (temp.count>0)
             {
                 [merchantList addObjectsFromArray:temp];
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


#pragma mark Refresh

- (void)getLocaltion
{
//    [activityIndicatorView startAnimating];
//    getAddressBut.hidden = YES;
//    //  Get FTLocationManager singleton instance
//    FTLocationManager *locationManager = [FTLocationManager sharedManager];
//    
//    //  Ask the location manager to get current location and get notified using
//    //  provided handler block
//   
//    [locationManager updateLocationWithCompletionHandler:^(CLLocation *location, NSDictionary*userplace,NSError *error, BOOL locationServicesDisabled)
//     {
//             if (userplace!=nil)
//             {
//                 areaLabel.text = userplace[@"area"];
//                 [GDSettingManager instance].areaAddress = areaLabel.text;
//             }
//         
//         [activityIndicatorView stopAnimating];
//         getAddressBut.hidden = NO;
//     }];
}

- (void)refreshData
{
    LOG(@"refresh data");
    
    seekPage = 1;
    
    [self getVendorData:categoryId];
}

- (void)nextPage
{
    if (lastCountFromServer>=prePageNumber)
    {
        LOG(@"get next page");
        [self loadMoreView];
        seekPage++;
        
        [self getVendorData:categoryId];
    }
  
}

#pragma mark UIView
- (void)reLoadView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [mainTableView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect r = self.view.bounds;
    if (showCagetoryDrop)
    {
        r.origin.y = DropDownListHeight;
        r.size.height -= DropDownListHeight;
    }
    
    r.origin.y += cityViewHeight;
    r.size.height -= cityViewHeight;
    
    mainTableView = MOCreateTableView( r , UITableViewStylePlain, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    //add table header view
    if (cityViewHeight>0)
    {
        UIView* hView = [[UIView alloc] initWithFrame:CGRectMake(0, showCagetoryDrop?DropDownListHeight:0, r.size.width,cityViewHeight)];
        hView.backgroundColor = colorFromHexString(@"e9e9e9");
        [self.view addSubview:hView];
        
        UIImageView *addressImage = [[UIImageView alloc] init];
        addressImage.image = [UIImage imageNamed:@"Coordinate.png"];
        addressImage.frame = CGRectMake(8, 8,
                                        15, 19);
        [hView addSubview:addressImage];
        
        areaLabel = MOCreateLabelAutoRTL();
        areaLabel.backgroundColor = [UIColor clearColor];
        areaLabel.textColor = MOColor66Color();
        areaLabel.font = MOLightFont(14);
        if ([GDSettingManager instance].areaAddress.length>0)
            areaLabel.text = [GDSettingManager instance].areaAddress;
        else
            areaLabel.text = NSLocalizedString(@"Detecting Location...",@"自动定位...");
        
        areaLabel.frame = CGRectMake(30, 0, r.size.width-30-40,cityViewHeight);
        [hView addSubview:areaLabel];
        
        getAddressBut=[UIButton buttonWithType:UIButtonTypeCustom];
        [getAddressBut setImage:[UIImage imageNamed:@"refersh.png"]  forState:UIControlStateNormal];
        getAddressBut.frame = CGRectMake(r.size.width-40, 0, 40,35);
        [getAddressBut addTarget:self action:@selector(getLocaltion) forControlEvents:UIControlEventTouchUpInside];
        [hView addSubview:getAddressBut];
        
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.hidesWhenStopped = YES;
        activityIndicatorView.frame = CGRectMake(r.size.width-40, 0, 40,35);
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
    
    if (showCategory == CATEGORY_BLUE_STORE)
        categoryArrays = [[GDSettingManager instance].nBlueCategory mutableCopy];
    else if (showCategory == CATEGORY_GOLD_STORE)
        categoryArrays = [[GDSettingManager instance].nGoldCategory mutableCopy];
    else if (showCategory == CATEGORY_PLATINUM_STORE)
        categoryArrays = [[GDSettingManager instance].nPlatinumCategory mutableCopy];
    
    //默认选择第一个
    if (showCagetoryDrop && categoryArrays.count>0)
    {
        [self selectDefaultCategory];
        [self initDropDown];
        [self setDropDownIndex];
    }
    
    [self addRefreshUI];
    
    if ([GDSettingManager instance].areaAddress.length<=0)
    {
        [self getLocaltion];
    }

    
}

- (void)selectDefaultCategory
{
    if (categoryArrays.count>0)
    {
        for (NSDictionary* dict in categoryArrays)
        {
            categoryId = [dict[@"category_id"] intValue];
            break;
        }
    }
}

- (void)tapBuy
{
    if ([GDPublicManager instance].cid<=0)
    {
        [UIAlertView showWithTitle:nil
                           message:NSLocalizedString(@"Please login first", @"您还没有登录")
                 cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          }];
        
        
        return;
    }
    
    GDBuyMemberViewController* vc = [[GDBuyMemberViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)initView
{
    if (!isLoadData)
    {
        [self getAllCategory];
        
        isLoadData = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initView];
    
    if ([GDPublicManager instance].buy_section_show)
    {
        UIBarButtonItem*  buyButItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Buy", @"购买") style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(tapBuy)];
        self.navigationItem.rightBarButtonItem = buyButItem;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Table view
- (int)tableView:(UITableView *)tableView retrunProductNumber:(NSInteger)section
{
    NSDictionary* obj = [merchantList objectAtIndex:section];
    
    NSMutableArray   *product_list = [[NSMutableArray alloc] init];
    [product_list addObjectsFromArray:obj[@"product_list"]];
    int nCount  = (int)product_list.count;
    
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* obj = [merchantList objectAtIndex:indexPath.section];
    
    if (indexPath.row == 0)
    {
        static NSString *CellIdentifier = @"listCell";
        
        GDLiveVendorListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GDLiveVendorListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        NSString*  merchantName=@"";
        SET_IF_NOT_NULL(merchantName,obj[@"vendor_name"]);
        
        NSString*  vendorImageUrl=@"";
        float      rating=0;
        float      dist=0;
        NSString*  categoryName=@"";
        
        SET_IF_NOT_NULL(vendorImageUrl, obj[@"vendor_image"]);
        SET_IF_NOT_NULL(categoryName,   obj[@"main_service"]);
        rating = [obj[@"rating"] floatValue];
        
        if(obj[@"distance"] != [NSNull null] && obj[@"distance"] != nil)
            dist = [obj[@"distance"] floatValue];
        
        //    int nCount = 0;
        //    NSMutableArray   *product_list = [[NSMutableArray alloc] init];
        //    [product_list addObjectsFromArray:obj[@"product_list"]];
        //
        //    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:product_list.count];
        //    for (NSDictionary* dict in product_list)
        //    {
        //        NSString*  name=@"";
        //        SET_IF_NOT_NULL(name, dict[@"name"]);
        //        NSString*  type=@"";
        //        SET_IF_NOT_NULL(type, dict[@"type"]);
        //
        //        NSDictionary* parameters = @{@"type":type,@"name":name};
        //        [temp addObject:parameters];
        //
        //        nCount++;
        //
        //        if (nCount>=3)
        //            break;
        //    }
        //
        
        [cell.productImage sd_setImageWithURL:[NSURL URLWithString:[vendorImageUrl encodeUTF]]
                             placeholderImage:[UIImage imageNamed:@"live_product_default.png"]];
        
        cell.vendorLabel.text = merchantName;
        cell.nDist = dist;
        
        cell.categoryLabel.text = categoryName;
        //cell.rateLabel.text = [NSString stringWithFormat:@"%.1f",rating];
        
        NSString* area_name = @"";
        NSString* city = @"";
        SET_IF_NOT_NULL(area_name, obj[@"area_name"]);
        SET_IF_NOT_NULL(city, obj[@"zone_name"]);
        
        if (area_name.length>0)
        {
            cell.addressLabel.text = [NSString stringWithFormat:@"%@, %@",area_name,city];
        }
        else
        {
            cell.addressLabel.text = [NSString stringWithFormat:@"%@",city];
        }
        
        return cell;
    }
    else if (indexPath.row == 1)
    {
        static NSString *ID = @"kProduct";
        
        GDLiveProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[GDLiveProductListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        }
        cell.showVendorDist = NO;
        
        NSMutableArray   *product_list = [[NSMutableArray alloc] init];
        [product_list addObjectsFromArray:obj[@"product_list"]];
        
        NSDictionary* product = [product_list objectAtIndex:indexPath.row-1];
        
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
        if(product[@"distance"] != [NSNull null] && product[@"distance"] != nil)
            cell.nDist =  [product[@"distance"] intValue];
        int soldCount = [product[@"sold_count"] intValue];
        if (soldCount>0)
        {
            cell.soldLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Sold:%d","已售:%d"),soldCount];
        }
        else
        {
            cell.soldLabel.hidden = YES;
        }
        
        cell.rateLabel.text = [NSString stringWithFormat:@"%.1f",[product[@"rating"] floatValue]];
        
        int  oprice = [originprice intValue];
        int  sprice = [saleprice intValue];
        int    setprice = [setsale intValue];
        
        NSString* opricestr = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, oprice];
        NSString* spricestr = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, sprice];
        
        [[GDSettingManager instance] setTitleAttr:cell.productLabel withTitle:productname withSale:setprice withOrigin:oprice];
        
        cell.originLabel.text = opricestr;
        cell.saleLabel.text = spricestr;
        
        if (setprice!=0 && oprice-setprice>0)
        {
            cell.savingLabel.text =  [NSString stringWithFormat:NSLocalizedString(@"Saving:%@%d",@"节省:%@%d"),[GDPublicManager instance].currency, oprice-setprice];
            cell.savingImage.hidden = NO;
            cell.savingLabel.hidden = NO;
        }
        else
        {
            cell.savingImage.hidden = YES;
            cell.savingLabel.hidden = YES;
        }

        int membership_level = [obj[@"membership_level"] intValue];
        //default
        cell.haveBlue = NO;
        cell.haveGold = NO;
        cell.havePlatinum = NO;
        
        if (MEMBER_PLATINUM>=membership_level)
            cell.havePlatinum = YES;
        if (MEMBER_GOLD>=membership_level)
            cell.haveGold = YES;
        if (MEMBER_BLUE>=membership_level)
            cell.haveBlue = YES;
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"moreProduct";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.font = MOLightFont(14);
        cell.textLabel.textColor = MOColor66Color();
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = NSLocalizedString(@"More Coupons", @"更多优惠券");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!reloading && !merchantList.count)
    {
        [mainTableView addSubview:[self noDataView]];
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    
    if (merchantList.count>0)
    {
        [_noDataView removeFromSuperview];
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    
    return merchantList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int nCount = [self tableView:tableView retrunProductNumber:section];
    
    if (nCount>1)
    {
        return 3; // only top row showing
    }
    
    return 1+nCount;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0)
        return 80;
    else if (indexPath.row == 1)
        return 130;
    
    return 36;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* dict = [merchantList objectAtIndex:indexPath.section];
    
    int vendor_id = 0;
    NSString* vendor_name = @"vendor name";
    NSString* vendor_image = @"";
    NSString* vendor_url = @"";
    
    vendor_id = [dict[@"vendor_id"] intValue];
    SET_IF_NOT_NULL(vendor_name, dict[@"vendor_name"]);
    SET_IF_NOT_NULL(vendor_url, dict[@"store_url"]);
    SET_IF_NOT_NULL(vendor_image, dict[@"vendor_image"]);
    
    if (indexPath.row == 1)
    {
        NSMutableArray   *product_list = [[NSMutableArray alloc] init];
        [product_list addObjectsFromArray:dict[@"product_list"]];
        
        NSDictionary* product = [product_list objectAtIndex:indexPath.row-1];
        if (product!=nil)
        {
            int productId = [product[@"product_id"] intValue];
            NSString* type=@"";
            SET_IF_NOT_NULL(type, product[@"type"]);
            
            GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:productId withOrder:YES];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
    else
    {
        if (vendor_id>0)
        {
            GDLiveVendorViewController * vc = [[GDLiveVendorViewController alloc] init:vendor_id withName:vendor_name withUrl:vendor_url withImage:vendor_image];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
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
//    else
//    {
//        return self.conditions.count;
//    }
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath
{
    if (indexPath.column == 0)
    {
        if (indexPath.row<categoryArrays.count)
        {
            NSDictionary* dict = [categoryArrays objectAtIndex:indexPath.row];
            NSString* name = @"";
            SET_IF_NOT_NULL(name, dict[@"name"]);
            //int count = [dict[@"count"] intValue];
           
//          NSString* str = [NSString stringWithFormat:@"%@(%d)",name,count];
//          return str;
            return name;
        }
    }
    else  {
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
    if (column == 0) {//二级目录行
       
        if (row<categoryArrays.count)
        {
            NSDictionary* dict = [categoryArrays objectAtIndex:row];
            NSString* name = @"";
            SET_IF_NOT_NULL(name, dict[@"name"]);
        
            if (dict!=nil)
            {
                NSArray* temp = dict[@"list"];
                return temp.count + 1;
            }
        }
    }
    return 0;
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForItemsInRowAtIndexPath:(DOPIndexPath *)indexPath
{
    if (indexPath.column == 0) {//二级目录菜单
    
        NSDictionary* dict = [categoryArrays objectAtIndex:indexPath.row];
      
        NSArray* temp = dict[@"list"];
        if (temp.count>0)
        {
            NSString* name = @"";
            
            if (indexPath.item == 0)
            {
                 SET_IF_NOT_NULL(name, dict[@"name"]);
                 //int count = [dict[@"count"] intValue];
                 //NSString* str = [NSString stringWithFormat:@"%@(%d)",name,count];
                 //return [NSString stringWithFormat:NSLocalizedString(@"All %@", @"全部%@"),str];
                 return name;
            }
            else
            {
                NSDictionary* dictTwo = [temp objectAtIndex:indexPath.item - 1];
                //int count = [dictTwo[@"count"] intValue];
                SET_IF_NOT_NULL(name, dictTwo[@"name"]);
                //NSString* str = [NSString stringWithFormat:@"%@(%d)",name,count];
                //return str;
                return name;
            }
        }
    }
    return nil;
}

#pragma mark dropDownListDelegate

- (void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath
{
    if (indexPath.column == 0)
    {
        if (indexPath.item >= 0)
        {
             NSDictionary* dict = [categoryArrays objectAtIndex:indexPath.row];
            
            if (indexPath.item == 0)
            {
                categoryId =  [dict[@"category_id"] intValue];
            }
            else
            {
                NSArray* temp = dict[@"list"];
                if (temp.count>0)
                {
                    NSDictionary* dictTwo = [temp objectAtIndex:indexPath.item - 1];
                    categoryId =  [dictTwo[@"category_id"] intValue];
                }
            }
            
            [self refreshData];
            
            //self.title = menu.currentSelectText;

        }
        else
        {
           
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
            sortChoose = @"rating";
        }
        else if (indexPath.row == 2)
        {
            sortChoose = @"fee_per_person_desc";
        }
        else if (indexPath.row == 3)
        {
            sortChoose = @"fee_per_person_asc";
        }
        
        [self refreshData];
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
