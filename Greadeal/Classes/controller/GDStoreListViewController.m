//
//  GDStoreListViewController.m
//  Greadeal
//
//  Created by Elsa on 15/7/29.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDStoreListViewController.h"
#import "GDSaleFindVendorProductViewController.h"
#import "GDLiveFindVendorProductViewController.h"
#import "RDVTabBarController.h"

@interface GDStoreListViewController ()

@end

@implementation GDStoreListViewController

- (id)init:(int)atype
{
    self = [super init];
    if (self)
    {
        selectType = atype;
        
        productData = [[NSMutableArray alloc] init];
        indexList   = [[NSArray alloc] init];
        
        self.title = NSLocalizedString(@"Store List", @"商家列表");
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)arrayForSections:(NSArray *)objects {
    
    //    https://gist.github.com/davidhexd/11123942
    //    //  For some locales (Arabic is one), index is always off by one -.-
    //
    //    NSInteger index = [[UILocalizedIndexedCollation currentCollation] sectionForObject:@"Alex" collationStringSelector:@selector(description)];
    //    NSString *sectionTitle = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:index];
    
    //  In this situation, sectionTitle is "B".
    /*
     * selector 需要返回一个 NSString ，按照这个返回的string来做分组排序，
     * | name | 是 | ContactEntity | 的Propty，直接有get方法
     */
    SEL selector = @selector(self);
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    // | sectionTitlesCount | 的值为 27 , | sectionTitles | 的内容为 A - Z + #，总计27，（不同的Locale会返回不同的值，见http://nshipster.com/uilocalizedindexedcollation/）
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    
    // 创建 27 个 section 的内容
    NSMutableArray *mutableSections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        [mutableSections addObject:[NSMutableArray array]];
    }
    
    // 将| objects |中的内容加入到 创建的 27个section中
    for (NSDictionary* object in objects) {
        
        NSInteger sectionNumber = [collation sectionForObject:object[@"vendor_name"]
                                      collationStringSelector:selector];
        
        //For some locales (Arabic is one), index is always off by one -.-
        if ([GDSettingManager instance].isRightToLeft)
        {
            if (sectionNumber>1)  sectionNumber--;
        }
        [[mutableSections objectAtIndex:sectionNumber] addObject:object];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"vendor_name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        NSArray *objectsForSection = [mutableSections objectAtIndex:idx];
        NSArray *sortedArray = [objectsForSection sortedArrayUsingDescriptors:sortDescriptors];
        [mutableSections replaceObjectAtIndex:idx withObject:sortedArray];
    }
    
    // 删除空的section
    NSMutableArray *existTitleSections = [NSMutableArray array];
    
    for (NSArray *section in mutableSections) {
        if ([section count] > 0) {
            [existTitleSections addObject:section];
        }
    }
    
    // 删除空section 对应的索引(index)
    
    NSMutableArray *existTitles = [NSMutableArray array];
    NSArray *allSections = [collation sectionIndexTitles];
    
    for (NSUInteger i = 0; i < [allSections count]; i++) {
        if ([mutableSections[ i ] count] > 0) {
            [existTitles addObject:allSections[ i ]];
        }
    }
    indexList = existTitles;
    
    return existTitleSections;
}

- (void)getProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"vendor/get_vendor_list"];
    
    switch (selectType) {
        case SALE:
            parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"type":@"sale"};
            break;
        case LIVE:
            parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"type":@"live"};
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
             @synchronized(productData)
             {
                 productData = [self arrayForSections:responseObject[@"data"][@"vendor_list"]];
             }
             [mainTableView reloadData];
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


#pragma mark UIView
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    if (!isLoadData)
    {
        [self  getProductData];
        
        isLoadData = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [ProgressHUD dismiss];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}


#pragma mark - Table view
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* str = indexList[section];
    
    UILabel* titleLabel = MOCreateLabelAutoRTL();
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.text = str;
    
    CGRect r =self.view.bounds;
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, 0, r.size.width, 20)];
    titleLabel.frame = CGRectMake(r.origin.x+15, 4, r.size.width-30, 20);
    hView.backgroundColor =[UIColor colorWithRed:(245/255.0) green:(245/255.0) blue:(245/255.0) alpha:1.0];
    
    [hView addSubview:titleLabel];
    return hView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return indexList[ section ];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return indexList;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    NSDictionary* obj = productData[indexPath.section][indexPath.row];
    
    NSString*  title_name = @"";
    SET_IF_NOT_NULL( title_name , obj[@"vendor_name"]);
    
    cell.textLabel.text = title_name;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return productData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [productData[section] count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* obj = productData[indexPath.section][indexPath.row];
    
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
