//
//  GDSaleStoreSearchViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/15.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDSaleStoreSearchViewController.h"
#import "RDVTabBarController.h"

#import "GDProductListCell.h"
#import "GDProductDetailsViewController.h"

#import "GDSaleFindVendorProductViewController.h"
#import "GDLiveFindVendorProductViewController.h"

@interface GDSaleStoreSearchViewController ()

@end

@implementation GDSaleStoreSearchViewController

- (id)init:(int)atype
{
    self = [super init];
    if (self)
    {
        selectType = atype;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    insearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20.0, 4.0, 200.0, 34.0)];
    insearchBar.delegate = self;
    insearchBar.placeholder =  NSLocalizedString(@"Search Store", @"搜索商家");
    insearchBar.showsCancelButton=YES;
    self.navigationItem.titleView = insearchBar;
    
    [insearchBar becomeFirstResponder];
    
    CGRect r =  self.view.bounds;
    
    mainTableView = MOCreateTableView( r , UITableViewStylePlain, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [mainTableView setTableFooterView:view];
    mainTableView.backgroundColor = MOColorAppBackgroundColor();
    
    productData = [[NSMutableArray alloc] init];
    
    seekPage = 1;
    lastCountFromServer = 0;
    searchStr = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [ProgressHUD dismiss];
    [insearchBar resignFirstResponder];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}


- (void)searchProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"search/search_vendor"];
    
    switch (selectType) {
        case SALE:
              parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"page":@(seekPage),@"limit":@(prePageNumber),@"type":@"sale",@"keyword":searchStr};
            break;
        case SUPER:
            break;
        case LIVE:
              parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"page":@(seekPage),@"limit":@(prePageNumber),@"type":@"live",@"keyword":searchStr};
            break;
        default:
            break;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    [ProgressHUD show:nil];
    
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
             
             lastCountFromServer = [responseObject[@"data"][@"count"] intValue];
             if (lastCountFromServer>0)
             {
                 [productData addObjectsFromArray:responseObject[@"data"][@"list"]];
             }
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             [ProgressHUD showError:errorInfo];
         }
         reloading = NO;
         [mainTableView reloadData];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         reloading = NO;
         [ProgressHUD showError:error.localizedDescription];
     }];
}

- (void)refreshData
{
    LOG(@"refresh data");
    
    if (searchStr.length>0)
    {
        seekPage   = 1;
        isLoadData = NO;
        reloading = YES;
        [self searchProductData];
    }
}

- (void)nextPage
{
    if (lastCountFromServer>=prePageNumber)
    {
        LOG(@"get next page");
        [self loadMoreView];
        seekPage++;
        
        [self searchProductData];
    }
}


#pragma mark - search bar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    LOG(@"%@",searchBar.text);
    searchStr = searchBar.text;
    [insearchBar resignFirstResponder];
    
    if (searchStr.length>0)
    {
        seekPage   = 1;
        isLoadData = NO;
        reloading = YES;
        [self searchProductData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [insearchBar resignFirstResponder];
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"photo";
    UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    NSDictionary* obj = productData[indexPath.row];
    
    NSString*  title_name = @"";
    SET_IF_NOT_NULL( title_name , obj[@"vendor_name"]);
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.text = title_name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!reloading && !productData.count)
    {
        [mainTableView addSubview:[self noDataView]];
        
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    
    if (productData.count>0)
    {
        [_noDataView removeFromSuperview];
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }

    return productData.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* obj = productData[indexPath.row];
    
    int vendor_id = [obj[@"vendor_id"] intValue];
    NSString* vendor_name = @"vendor name";
    NSString* vendor_image = @"";
    NSString* vendor_url = @"";

    SET_IF_NOT_NULL(vendor_name, obj[@"vendor_name"]);
    SET_IF_NOT_NULL(vendor_url, obj[@"store_url"]);
    SET_IF_NOT_NULL(vendor_image, obj[@"vendor_image"]);
    
    if (selectType == SALE)
    {
        GDSaleFindVendorProductViewController * vc = [[GDSaleFindVendorProductViewController alloc] init:YES withId:vendor_id withName:vendor_name withUrl:vendor_url withImage:vendor_image];
        vc.title = vendor_name;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (selectType == LIVE)
    {
        GDLiveFindVendorProductViewController * vc = [[GDLiveFindVendorProductViewController alloc] init:vendor_id withName:vendor_name withUrl:vendor_url withImage:vendor_image];
        vc.title = vendor_name;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
