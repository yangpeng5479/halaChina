//
//  GDMarketProtalViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/17.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDMarketProtalViewController.h"
#import "RDVTabBarController.h"
#import "GDSaleSearchPanelView.h"

#import "GDMarketProductListViewController.h"
#import "GDLiveADPanelView.h"

#import "GDProductDetailsViewController.h"
#import "GDMarketDiscountListViewController.h"

#import "GDMarketSearchViewController.h"
#import "GDMarketCategoryViewController.h"
#import "GDNewArrivedViewController.h"

#define categoryHeight 0
#define cellHeight     92
#define numbersOfCell  4

#define bannerHeight   100

#define AdHeight           ([[UIScreen mainScreen] bounds].size.width/320.0*140)
//   140
#define AdItemOfPage   3

@interface GDMarketProtalViewController ()

@end

@implementation GDMarketProtalViewController

- (id)init:(int)vendor_id
{
    self = [super init];
    if (self)
    {
        vendorId = vendor_id;
        
        categoryData = [[NSMutableArray alloc] init];
        productData =  [[NSMutableArray alloc] init];
        bannerData  =  [[NSMutableArray alloc] init];
        newData     =  [[NSMutableArray alloc] init];
        
        kSaleSection = 0;
        kNewSection  = 1;
        kAllSection  = 2;
        kCategorySection =3;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    CGRect r =  self.view.bounds;
    
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [mainTableView setTableFooterView:view];
    
    UIBarButtonItem*  searchButItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(tapSearch)];
    self.navigationItem.rightBarButtonItem = searchButItem;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (float)caluGalleryHeight:(int)row
{
    float aheight;
    
    if (categoryData.count%numbersOfCell==0)
        aheight = categoryData.count/numbersOfCell*cellHeight;
    else
        aheight = categoryData.count/numbersOfCell*cellHeight+cellHeight;
    return aheight;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    if (!isLoadData)
    {
        [self getBannerData];
        [self getProductData];
        [self getNewData];
        [self getCategoryData];
        isLoadData= YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [ProgressHUD dismiss];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}

#pragma mark - Action
- (void)tapSearch
{
    GDMarketSearchViewController* nv = [[GDMarketSearchViewController alloc] init:vendorId];
    [self.navigationController pushViewController:nv animated:YES];
}

- (void)didSelectProductItem:(id)sender
{
    //{"s":<string> sticker name, if applicable, "e":<string> emoji code, if applicable.}
    NSDictionary *dict = sender;
    LOG(@"dict=%@",dict);
    int proId = [dict[@"product_id"] intValue];
    NSString* type=@"";
    SET_IF_NOT_NULL(type, dict[@"type"]);
    
    GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:proId withtype:type];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didSelectCagetory:(id)sender
{
    //{"s":<string> sticker name, if applicable, "e":<string> emoji code, if applicable.}
    NSDictionary *dict = sender;
    LOG(@"dict=%@",dict);
    
    int categoryId = [dict[@"category_id"] intValue];
    
    GDMarketProductListViewController *viewController = [[GDMarketProductListViewController alloc] init:vendorId withCategory:categoryId];
    SET_IF_NOT_NULL( viewController.title , dict[@"name"]);
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Data
- (void)reLoadView
{
    [mainTableView reloadData];
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
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             
             if(responseObject[@"data"][@"mid_banners"] != [NSNull null] && responseObject[@"data"][@"mid_banners"] != nil)
             {
                 [bannerData addObjectsFromArray:responseObject[@"data"][@"mid_banners"]];
                 
                 NSMutableArray *pictureArrar = [[NSMutableArray alloc] init];
                 for (NSDictionary* dict in bannerData) {
                     NSString* image = @"";
                     SET_IF_NOT_NULL( image , dict[@"image"]);
                     [pictureArrar addObject:image];
                 }
                 
                 bannerView.pics = pictureArrar;
                 [bannerView upDate:@"live_banner_default.png"];
                 mainTableView.tableHeaderView = bannerView;
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
         
         [mainTableView reloadData];
       
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [ProgressHUD showError:error.localizedDescription];
     }];
}

- (void)getNewData
{
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"supermarket/get_lastest_product_list_of_vendor"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"vendor_id":@(vendorId),@"page":@(1),@"limit":@(3)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             @synchronized(newData)
             {
                 [newData removeAllObjects];
             }
             
             [newData addObjectsFromArray:responseObject[@"data"][@"product_list"]];
             
             [self reLoadView];
             
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
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"supermarket/get_discount_product_list_of_vendor"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"vendor_id":@(vendorId),@"page":@(1),@"limit":@(3)};

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             @synchronized(productData)
             {
                 [productData removeAllObjects];
             }
             
             [productData addObjectsFromArray:responseObject[@"data"]];
             
             [self reLoadView];
             
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

- (void)getCategoryData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    NSString* url;
    NSDictionary *parameters;
   
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"supermarket/get_rec_category_list_of_vendor"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"vendor_id":@(vendorId),@"page":@(1),@"limit":@(12)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"JSON: %@", responseObject);
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             @synchronized(categoryData)
             {
                 [categoryData removeAllObjects];
             }
             
             [categoryData addObjectsFromArray:responseObject[@"data"][@"category_list"]];
             
             [self reLoadView];
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             [ProgressHUD showError:errorInfo];
         }
         [ProgressHUD dismiss];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [ProgressHUD showError:error.localizedDescription];
     }];
}

- (int)numberOfPages:(int)numberOfPage withCount:(int)recentCount
{
    int pageSize = numberOfPage;
    int numOfPages = ceil((double)recentCount / (double)pageSize);
    return numOfPages;
}

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
                int categoryId = [dict[@"category_id"] intValue];
                GDMarketProductListViewController *viewController = [[GDMarketProductListViewController alloc] init:vendorId withCategory:categoryId];
                SET_IF_NOT_NULL( viewController.title , dict[@"name"]);
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
    }

}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSaleSection)
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell ;
            static NSString *ID = @"cell1";
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [cell setSeparatorInset:UIEdgeInsetsZero];
                }
                
                if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                    [cell setLayoutMargins:UIEdgeInsetsZero];
                }
            }
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.text = NSLocalizedString(@"Daily Deals", @"每日特价");
            cell.textLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
            cell.backgroundColor = MOSectionBackgroundColor();
            return cell;
        }
        else if (indexPath.row == 1)
        {
            UITableViewCell *cell ;
            static NSString *ID = @"style2";
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                //cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
            }
            
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            
            int recentCount = (int)productData.count;
            int numOfPages  = [self numberOfPages:AdItemOfPage withCount:recentCount];
            
            int pageSize = AdItemOfPage;
            
            NSMutableArray* tempArrar = [[NSMutableArray alloc] init];
            for (NSDictionary *obj in productData)
            {
                NSString* imgUrl = @"";
                NSString* name=@"";
                NSString* stroPrice=@"";
                NSString* strsPrice=@"";
                
                int       productId = [obj[@"product_id"] intValue];
                SET_IF_NOT_NULL(imgUrl, obj[@"image"]);
                SET_IF_NOT_NULL(name, obj[@"name"]);
                SET_IF_NOT_NULL(stroPrice, obj[@"price"]);
                
                if(obj[@"special_price_info"] != [NSNull null] && obj[@"special_price_info"] != nil)
                {
                    SET_IF_NOT_NULL(strsPrice, obj[@"special_price_info"][@"price"]);
                }
                else
                {
                    strsPrice = stroPrice;
                }

                NSDictionary *parameters=nil;
                parameters = @{@"product_id":@(productId),@"image":imgUrl,@"name":name,@"sprice":strsPrice,@"oprice":stroPrice};
                [tempArrar addObject:parameters];
           
            }
           
            GDLiveADPanelView *eView = nil;
            
            for (int i = 0; i < numOfPages; i++)
            {
                eView = [[GDLiveADPanelView alloc] initWithFrame:CGRectMake(0, 0,self.view.bounds.size.width, AdHeight)];
                eView.xspaceing = 6;
                eView.yspaceing = 5;
                eView.ItemOfLine = 3;
                eView.ItemOfPage = AdItemOfPage;
                eView.LineHeight = AdHeight;
                
                eView.target = self;
                eView.callback = @selector(didSelectProductItem:);
                
                eView.backgroundColor = [UIColor clearColor];
                
                NSRange range = NSMakeRange(i*pageSize,
                                            (i+1)*pageSize >= recentCount ? recentCount-i*pageSize : pageSize);
                
                NSArray *subarray = [tempArrar subarrayWithRange:range];
                [eView setRecentItems:subarray];
            }
            [cell.contentView addSubview:eView];
            return cell;
        }
    }
    if (indexPath.section == kNewSection)
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell ;
            static NSString *ID = @"cell2";
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [cell setSeparatorInset:UIEdgeInsetsZero];
                }
                
                if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                    [cell setLayoutMargins:UIEdgeInsetsZero];
                }
            }
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.text = NSLocalizedString(@"New Arrivals", @"每日上新");
            cell.textLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
            cell.backgroundColor = MOSectionBackgroundColor();
            return cell;
        }
        else if (indexPath.row == 1)
        {
            UITableViewCell *cell ;
            static NSString *ID = @"style2";
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                //cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
            }
            
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            
            int recentCount = (int)newData.count;
            int numOfPages  = [self numberOfPages:AdItemOfPage withCount:recentCount];
            
            int pageSize = AdItemOfPage;
            
            NSMutableArray* tempArrar = [[NSMutableArray alloc] init];
            for (NSDictionary *obj in newData)
            {
                NSString* imgUrl = @"";
                NSString* name=@"";
                NSString* stroPrice=@"";
                NSString* strsPrice=@"";
                
                int       productId = [obj[@"product_id"] intValue];
                SET_IF_NOT_NULL(imgUrl, obj[@"image"]);
                SET_IF_NOT_NULL(name, obj[@"name"]);
                SET_IF_NOT_NULL(stroPrice, obj[@"price"]);
                
                if(obj[@"special_price_info"] != [NSNull null] && obj[@"special_price_info"] != nil)
                {
                    SET_IF_NOT_NULL(strsPrice, obj[@"special_price_info"][@"price"]);
                }
                else
                {
                    strsPrice = stroPrice;
                }
                
                NSDictionary *parameters=nil;
                parameters = @{@"product_id":@(productId),@"image":imgUrl,@"name":name,@"sprice":strsPrice,@"oprice":stroPrice};
                [tempArrar addObject:parameters];
                
            }
            
            GDLiveADPanelView *eView = nil;
            
            for (int i = 0; i < numOfPages; i++)
            {
                eView = [[GDLiveADPanelView alloc] initWithFrame:CGRectMake(0, 0,self.view.bounds.size.width, AdHeight)];
                eView.xspaceing = 6;
                eView.yspaceing = 5;
                eView.ItemOfLine = 3;
                eView.ItemOfPage = AdItemOfPage;
                eView.LineHeight = AdHeight;
                
                eView.target = self;
                eView.callback = @selector(didSelectProductItem:);
                
                eView.backgroundColor = [UIColor clearColor];
                
                NSRange range = NSMakeRange(i*pageSize,
                                            (i+1)*pageSize >= recentCount ? recentCount-i*pageSize : pageSize);
                
                NSArray *subarray = [tempArrar subarrayWithRange:range];
                [eView setRecentItems:subarray];
            }
            [cell.contentView addSubview:eView];
            return cell;
        }
    }
    else if (kAllSection == indexPath.section)
    {
        UITableViewCell *cell ;
        static NSString *ID = @"cell3";
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsZero];
            }
            
            if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                [cell setLayoutMargins:UIEdgeInsetsZero];
            }
        }
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.text = NSLocalizedString(@"All Categories", @"全部分类");
        cell.textLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
        cell.backgroundColor = MOSectionBackgroundColor();
        return cell;

    }
    else if (kCategorySection == indexPath.section)
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell ;
            static NSString *ID = @"cell4";
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
                cell.accessoryType = UITableViewCellAccessoryNone;
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [cell setSeparatorInset:UIEdgeInsetsZero];
                }
                
                if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                    [cell setLayoutMargins:UIEdgeInsetsZero];
                }
            }
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.text = NSLocalizedString(@"Hot Categories", @"热门分类");
            cell.textLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
            cell.backgroundColor = MOSectionBackgroundColor();
            return cell;
        }
        else
        {
        static NSString *ID = @"category";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
    
        CGRect r = self.view.frame;
    
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        GDSaleSearchPanelView* galleryView = [[GDSaleSearchPanelView alloc] initWithFrame:CGRectMake(0, categoryHeight,CGRectGetWidth(r), [self caluGalleryHeight:(int)indexPath.row])];
        galleryView.ItemOfPage = (int)categoryData.count;
    
        galleryView.LineHeight = cellHeight;
    
        galleryView.ItemOfLine = 4;
        galleryView.xspaceing  = 5;
        galleryView.yspaceing  = 5;
        galleryView.imageHeight = 50;
        galleryView.target     = self;
        galleryView.callback   = @selector(didSelectCagetory:);
        galleryView.backgroundColor = [UIColor clearColor];
    
        [galleryView setRecentItems:categoryData];
        [cell.contentView addSubview:galleryView];
    
        return cell;
        }
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int nIndex  = 0;
    if (productData.count>0)
    {
        kSaleSection = nIndex++;
    }
    else
        kSaleSection = 4;

    
    if (newData.count>0)
    {
        kNewSection = nIndex++;
    }
    else
        kNewSection = 4;

    kAllSection = nIndex++;
    
    if (categoryData.count>0)
        kCategorySection = nIndex++;
    else
        kCategorySection = 4;
    
    return nIndex;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kSaleSection)
        return 2;
    else if (section == kNewSection)
        return 2;
    else if (section == kAllSection)
        return 1;
    else if (section == kCategorySection)
        return 2;
    return 0;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSaleSection)
    {
        if (indexPath.row == 0)
        {
            return 40;
        }
        else
            return AdHeight;
    }
    else if (indexPath.section == kNewSection)
    {
        if (indexPath.row == 0)
        {
            return 40;
        }
        else
            return AdHeight;
    }
    else if (indexPath.section == kAllSection)
    {
        return 40;
    }
    else if (indexPath.section == kCategorySection)
    {
        if (indexPath.row == 0)
        {
            return 40;
        }
        else
        {
            float height = [self caluGalleryHeight:(int)indexPath.
                        row];
            return height+categoryHeight;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kSaleSection)
    {
        if (indexPath.row == 0)
        {
            GDMarketDiscountListViewController* nv = [[GDMarketDiscountListViewController alloc] init:vendorId];
            [self.navigationController pushViewController:nv animated:YES];
        }
    }
    else if (indexPath.section == kNewSection)
    {
        if (indexPath.row == 0)
        {
            GDNewArrivedViewController* nv = [[GDNewArrivedViewController alloc] init:vendorId];
            [self.navigationController pushViewController:nv animated:YES];
        }
    }
    else if (indexPath.section == kAllSection)
    {
        GDMarketCategoryViewController* nv = [[GDMarketCategoryViewController alloc] init:vendorId withIndex:0];
        [self.navigationController pushViewController:nv animated:YES];
    }
    
}


@end
