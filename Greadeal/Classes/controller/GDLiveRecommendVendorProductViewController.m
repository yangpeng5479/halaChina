//
//  GDLiveRecommendVendorProductViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/23.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDLiveRecommendVendorProductViewController.h"
#import "GDProductDetailsViewController.h"
#import "GDLiveProductListCell.h"
#import "GDVendorCell.h"

#import "RDVTabBarController.h"

#import "GDGridLayoutViewController.h"

#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

#define numberOfLine 4
#define photosHeight (([[UIScreen mainScreen] bounds].size.width-20.0)/numberOfLine)

@interface GDLiveRecommendVendorProductViewController ()

@end

@implementation GDLiveRecommendVendorProductViewController

- (id)init:(int)vendorId
{
    self = [super init];
    if (self)
    {
        productList = [[NSMutableArray alloc] init];
        _imageList  = [[NSMutableArray alloc] init];

        seekPage = 1;
        lastCountFromServer = 0;
        
        vendor_phone = @"";
        vendor_address = @"";
        vendor_url = @"";
        vendor_image = @"";
        
        vendor_id = vendorId;
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
    //mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    [self addRefreshUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data
- (void)getPhotos
{
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"vendor/get_image_list"];
    parameters = @{@"vendor_id":@(vendor_id)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [ProgressHUD dismiss];
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             @synchronized(_imageList)
             {
                [_imageList removeAllObjects];
             }
             
             if(responseObject[@"data"][@"image_list"] != [NSNull null] && responseObject[@"data"][@"image_list"] != nil)
             {
                 NSArray* temp = responseObject[@"data"][@"image_list"];
                 [_imageList addObjectsFromArray:temp];
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
         [self stopLoad];
         [ProgressHUD showError:error.localizedDescription];
     }];
}

- (void)getProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    reloading = YES;
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"live/get_rec_vendor_with_product_list"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"page":@(seekPage),@"limit":@(prePageNumber)};
    
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
                 @synchronized(productList)
                 {
                     [productList removeAllObjects];
                 }
             }
             
             if(responseObject[@"data"][@"product_list"] != [NSNull null] && responseObject[@"data"][@"product_list"] != nil)
             {
                  NSArray* temp = responseObject[@"data"][@"product_list"];
                  [productList addObjectsFromArray:temp];
                  lastCountFromServer = (int)temp.count;
                 
                  NSString*  address=@"";
                  NSString*  city=@"";
                  NSString*  area=@"";
                 
                  SET_IF_NOT_NULL(vendor_phone, responseObject[@"data"][@"telephone"]);
                  SET_IF_NOT_NULL(vendor_image, responseObject[@"data"][@"vendor_image"]);
                  SET_IF_NOT_NULL(vendor_url, responseObject[@"data"][@"store_url"]);
                 
                  SET_IF_NOT_NULL(address, responseObject[@"data"][@"address_1"]);
                  SET_IF_NOT_NULL(city, responseObject[@"data"][@"zone_name"]);
                  SET_IF_NOT_NULL(area, responseObject[@"data"][@"zone_area_name"]);
                 
                  vendor_address = [NSString stringWithFormat:@"%@,%@,%@",address,area,city];
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
         [ProgressHUD showError:error.localizedDescription];
     }];
}

#pragma mark Refresh
- (void)refreshData
{
    LOG(@"refresh data");
    
    seekPage = 1;
    isLoadData = NO;
    [self getPhotos];
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
- (void)reLoadView
{
    [mainTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!isLoadData)
    {
        isLoadData = NO;
        [self  getPhotos];
        [self  getProductData];
        isLoadData = YES;
    }
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
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
        for (int i = 0; i < [_imageList count]; i++) {
            
            NSDictionary* dict = [_imageList objectAtIndex:i];
            NSString* getImageStrUrl = @"";
            SET_IF_NOT_NULL(getImageStrUrl, dict[@"image"]);
            
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString: [getImageStrUrl encodeUTF] ];
            [photos addObject:photo];
        }
        
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
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
    iconImage.userInteractionEnabled = YES;
    [iconImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)]];
    [iconImage sd_setImageWithURL:[NSURL URLWithString:[imageUrl encodeUTF]]
                      placeholderImage:[UIImage imageNamed:@"live_store_default.png"]];
    
    MODebugLayer(iconImage, 1.f, [UIColor redColor].CGColor);
    
    return iconImage;
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kAddressSection)
    {
        GDVendorCell *cell ;
        static NSString *ID = @"style1";
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[GDVendorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        
        if (indexPath.row == 0)
        {
            cell.iconImage.image = [UIImage imageNamed:@"Coordinate.png"];
            cell.titleLabel.text = vendor_address;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.iconImage.frame = CGRectMake(15, 15,
                                              14, 19);
        }
        else
        {
            cell.iconImage.image = [UIImage imageNamed:@"callphone.png"];
            cell.titleLabel.text = vendor_phone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.iconImage.frame = CGRectMake(13, 15,
                                              17, 17);
            
        }
      
        return cell;

    }
    else if (indexPath.section == kPhotoSection)
    {
        if (indexPath.row == 0)
        {
            static NSString *CellIdentifier = @"photoName";
            UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            cell.backgroundColor = MOSectionBackgroundColor();
            cell.textLabel.text= NSLocalizedString(@"Photos", @"店铺展示");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"photos";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            
            UIView*  photosPage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, photosHeight)];
            photosPage.backgroundColor = [UIColor whiteColor];
            
            for (int nIndex = 0;nIndex<_imageList.count && nIndex<numberOfLine;nIndex++)
            {
                NSDictionary* dict = [_imageList objectAtIndex:nIndex];
                NSString* imageUrl = @"";
                SET_IF_NOT_NULL(imageUrl, dict[@"image"]);
            
                [photosPage addSubview:[self makeOrderView:imageUrl withIndex:nIndex]];
                
                if (nIndex>=3)
                    break;
            }
          
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            [cell.contentView addSubview:photosPage];
            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width)];
            }
            
            if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width)];
            }
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
            cell.backgroundColor = MOSectionBackgroundColor();
            cell.textLabel.text= NSLocalizedString(@"Hot Recommend", @"热销推荐");
            return cell;
        }
        else
        {
        static NSString *CellIdentifier = @"listCell";
    
        GDLiveProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
        cell = [[GDLiveProductListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
    
        NSDictionary   *product = [productList objectAtIndex:indexPath.row-1];
    
        NSString*  imgUrl=@"";
        NSString*  proname=@"";
        NSString*  originprice=@"0";
        NSString*  saleprice=@"0";
        int        rating=0;
        int        quantity=0;
        NSString*  meta_description=@"";
        SET_IF_NOT_NULL(imgUrl, product[@"image"]);
        SET_IF_NOT_NULL(proname, product[@"name"]);
        SET_IF_NOT_NULL(originprice, product[@"price"]);
        SET_IF_NOT_NULL(meta_description, product[@"meta_description"]);
    
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
    
        float  oprice = [originprice floatValue];
        float  sprice = [saleprice floatValue];
    
        NSString* opricestr = [NSString stringWithFormat:@"%@%.1f",[GDPublicManager instance].currency, oprice];
        NSString* spricestr = [NSString stringWithFormat:@"%@%.1f",[GDPublicManager instance].currency, sprice];
    
        [cell.productImage sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                         placeholderImage:[UIImage imageNamed:@"live_product_default.png"]];
    
        cell.productLabel.text = proname;
    
        cell.originLabel.text = opricestr;
        cell.saleLabel.text   = spricestr;
    
        NSString* area;
        NSString* city;
        SET_IF_NOT_NULL(area, product[@"vendor"][@"zone_area_name"]);
        SET_IF_NOT_NULL(city, product[@"vendor"][@"zone_name"]);
        NSString* address=@"";
        if (area!=nil)
        {
            address = [NSString stringWithFormat:@"%@, %@",area!=nil?area:@"",city!=nil?    city:@""];
        }
        else
        {
            address = [NSString stringWithFormat:@"%@",city!=nil?city:@""];
        }
       
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
        kAddressSection = 3;
    
    if (_imageList.count>0)
    {
        kPhotoSection = nIndex++;
    }
    else
        kPhotoSection = 3;
    
    if (productList.count>0)
        kProductSection = nIndex++;
    else
        kProductSection =3;
    
    return nIndex;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == kAddressSection)
        return 2;
    else if (section == kPhotoSection)
    {
        return 2;
    }
    else if (section == kProductSection)
        return productList.count+1;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kAddressSection)
        return 50;
    else if (indexPath.section  == kPhotoSection)
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
        else
            return 116;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == kAddressSection)
    {
        if (indexPath.row == 1)
        {
            //call me
            [[GDPublicManager instance] makeCall:vendor_phone];
        }
    }
    else if (indexPath.section == kPhotoSection)
    {
        if (indexPath.row == 0)
        {
            GDGridLayoutViewController* viewController = [[GDGridLayoutViewController alloc] init:_imageList];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
    else if (indexPath.section == kProductSection)
    {
        if (indexPath.row != 0)
        {
        NSDictionary   *product = [productList objectAtIndex:indexPath.row-1];
        int productId = [product[@"product_id"] intValue];
        NSString* type=@"";
        SET_IF_NOT_NULL(type, product[@"type"]);
    
        GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:productId withtype:type];
        [self.navigationController pushViewController:viewController animated:YES];
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
