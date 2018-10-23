//
//  GDWishListViewController.m
//  Greadeal
//
//  Created by Elsa on 16/8/28.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDWishListViewController.h"
#import "RDVTabBarController.h"

#import "GDProductDetailsViewController.h"
#import "GDProductListCell.h"

@interface GDWishListViewController ()

@end

@implementation GDWishListViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        productData = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
        
        self.title = NSLocalizedString(@"Wish List", @"收藏");
     
        
        reloading = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    reloading = YES;
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/get_my_wishlist"];
    parameters=@{@"token":[GDPublicManager instance].token,@"longitude":@([[GDSettingManager instance] getCityLongitude]),@"latitude":@([[GDSettingManager instance] getCityLatitude])};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [ProgressHUD dismiss];
         
         @synchronized(productData)
         {
             [productData removeAllObjects];
         }
         
         NSArray* temp = responseObject[@"data"];
         lastCountFromServer = (int)temp.count;
         
         if (temp.count>0)
         {
             [productData addObjectsFromArray:temp];
         }
         
         [self stopLoad];
         [self reLoadView];
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self stopLoad];
         
         [ProgressHUD showError:error.localizedDescription];
         
     }];}

- (void)refreshData
{
    LOG(@"refresh data");
    
    seekPage = 1;
    
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

- (void)tapDel
{
    [UIAlertView showWithTitle:nil
                       message:NSLocalizedString(@"Are you sure to clear Wish List?", @"您确定要删除所有收藏吗?")
             cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
             otherButtonTitles:@[NSLocalizedString(@"OK", @"确定")]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex ==1) {
             
             NSString* url;
             url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Customer/remove_vendor_wishlist"];
             
             NSDictionary *parameters=@{@"token":[GDPublicManager instance].token};
             
             AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
             
             [manager POST:url
                parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
              {
                  int status = [responseObject[@"status"] intValue];
                  if (status==1)
                  {
                      [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
                      [self.navigationController popViewControllerAnimated:YES];
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
                  LOG(@"%@",operation.responseObject);
                  
                  [ProgressHUD showError:error.localizedDescription];
                  
              }];
         }
     }];
}


#pragma mark UIView
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!isLoadData)
    {
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect r = self.view.frame;
    
    UIBarButtonItem*  delButItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear",@"清除") style:UIBarButtonItemStylePlain target:self action:@selector(tapDel)];
    self.navigationItem.rightBarButtonItem = delButItem;
    
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    mainTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
}

- (UIView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        UIImageView *imgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"collectEmpty.png"]];
        imgV.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0-100);
        [_emptyView addSubview:imgV];
        
        float h = imgV.frame.origin.y + imgV.frame.size.height;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, h, self.view.frame.size.width, 40)];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"No Wish", @"暂无收藏");
        
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        
        label.font = MOBlodFont(16);
        [_emptyView addSubview:label];
        
    }
    return _emptyView;
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"guessCell";
    
    GDProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GDProductListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* product = [productData objectAtIndex:indexPath.row];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return productData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 224;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* product = [productData objectAtIndex:indexPath.row];
    if (product!=nil)
    {
        int productId = [product[@"product_id"] intValue];
        NSString* type=@"";
        SET_IF_NOT_NULL(type, product[@"type"]);
        
        UIViewController *viewController = [[GDProductDetailsViewController alloc] init:productId withOrder:YES];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
