//
//  GDSaleClassificationViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/29.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDSaleClassificationViewController.h"
#import "RDVTabBarController.h"
#import "GDSaleSearchPanelView.h"

#import "GDSaleProductListViewController.h"

#define cellHeight     92//88
#define numbersOfCell  4

@interface GDSaleClassificationViewController ()

@end

@implementation GDSaleClassificationViewController


- (id)init:(int)atype
{
    self = [super init];
    if (self)
    {
        selectType = atype;
        self.title = NSLocalizedString(@"Categories", @"分类");
        productData = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect r =  self.view.bounds;
    if (selectType == SALE)
    {
        float h = 44;
        r.size.height-=h;
    }
    mainTableView = MOCreateTableView( r , UITableViewStylePlain, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    MODebugLayer(mainTableView, 1.f, [UIColor redColor].CGColor);
    mainTableView.backgroundColor = MOColorAppBackgroundColor();
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [mainTableView setTableFooterView:view];
    
    if (!isLoadData)
    {
        [self getProductData];
        
        
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didSelectItem:(id)sender
{
    //{"s":<string> sticker name, if applicable, "e":<string> emoji code, if applicable.}
    NSDictionary *dict = sender;
    LOG(@"dict=%@",dict);
    NSString* endtime = @"";
    SET_IF_NOT_NULL(endtime, dict[@"date_end"]);
    if (selectType == SALE)
    {
        GDSaleProductListViewController *viewController = [[GDSaleProductListViewController alloc] init:YES withId:[dict[@"category_id"] intValue]];
        viewController.endTime = endtime;
        SET_IF_NOT_NULL( viewController.title , dict[@"name"]);
        [_superNav  pushViewController:viewController animated:YES];
    }
}

- (float)caluGalleryHeight:(int)section
{
    float aheight;
    
    NSDictionary* obj = [productData objectAtIndex:section];
    
    NSMutableArray   *listData = [[NSMutableArray alloc] init];
    [listData addObjectsFromArray:obj[@"list"]];
    
    if (listData.count%numbersOfCell==0)
        aheight = listData.count/numbersOfCell*cellHeight;
    else
        aheight = listData.count/numbersOfCell*cellHeight+cellHeight;
    return aheight;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [ProgressHUD dismiss];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}

#pragma mark - Data

- (void)getProductData
{
    [ProgressHUD show:nil];
    
    reloading = YES;
    
    NSString* url;
    NSDictionary *parameters;
    
    switch (selectType) {
        case SALE:
            url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"sale/get_category_list_onsale"];
            break;
        case SUPER:
            break;
        case LIVE:
            url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"live/get_category_list"];
            break;
        default:
            break;
    }
    
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO])};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         LOG(@"JSON: %@", responseObject);
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             @synchronized(productData)
             {
                 [productData removeAllObjects];
             }
             
             [productData addObjectsFromArray:responseObject[@"data"]];
             
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             [ProgressHUD showError:errorInfo];
         }
         
         [ProgressHUD dismiss];
         netWorkError = NO;
         reloading = NO;
         [mainTableView reloadData];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         reloading = NO;
         netWorkError = YES;
         [mainTableView reloadData];
         [ProgressHUD showError:error.localizedDescription];
     }];
}


#pragma mark - Table view
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary* obj = [productData objectAtIndex:section];
    
    NSString*  categoryName=@"";
    SET_IF_NOT_NULL(categoryName, obj[@"name"]);

    UILabel* titleLabel = MOCreateLabelAutoRTL();
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.text = categoryName;
    
    CGRect r =self.view.bounds;
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, 0, r.size.width, 40)];

    titleLabel.frame = CGRectMake(r.origin.x+15, 0, r.size.width-30, 40);
   
    [hView addSubview:titleLabel];
    
    UIImageView* backgroundView = [[UIImageView alloc] init];
    backgroundView.image = [[UIImage imageNamed:@"productLline.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    backgroundView.frame= CGRectMake(r.origin.x, 39.5,
                                     r.size.width, 0.5);
    [hView addSubview:backgroundView];
    
     hView.backgroundColor =[UIColor colorWithRed:(254/255.0) green:(254/255.0) blue:(254/255.0) alpha:1.0];
    
    return hView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"photo";
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
    
    NSDictionary* obj = [productData objectAtIndex:indexPath.section];
    
    NSMutableArray   *listData = [[NSMutableArray alloc] init];
    [listData addObjectsFromArray:obj[@"list"]];
    
    GDSaleSearchPanelView* galleryView = [[GDSaleSearchPanelView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth(r), [self caluGalleryHeight:(int)indexPath.section])];
    galleryView.ItemOfPage = (int)listData.count;
    
    galleryView.LineHeight = cellHeight;
  
    galleryView.ItemOfLine = 4;
    galleryView.xspaceing  = 5;
    galleryView.yspaceing  = 5;
    galleryView.imageHeight = 50;
    galleryView.target     = self;
    galleryView.callback   = @selector(didSelectItem:);
    galleryView.backgroundColor = [UIColor clearColor];
    
    [galleryView setRecentItems:listData];
    [cell.contentView addSubview:galleryView];
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!reloading && productData.count<=0)
    {
        if (netWorkError)
        {
        [mainTableView insertSubview:[self noNetworkView] atIndex:0];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getProductData)];
        [[self noNetworkView] addGestureRecognizer:tapGesture];
        }
    }
    
    if (productData.count>0)
    {
        [_noNetworkView removeFromSuperview];
    }
    
    return productData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = [self caluGalleryHeight:(int)indexPath.section];
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
