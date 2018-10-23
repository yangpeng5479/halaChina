//
//  GDDeliveryAddressManageViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/4.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDDeliveryAddressManageViewController.h"
#import "GDDeliveryEditAddressViewController.h"

#import "RDVTabBarController.h"
#import "GDAddressCell.h"

@interface GDDeliveryAddressManageViewController ()

@end

@implementation GDDeliveryAddressManageViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.isChoose = NO;
        self.target = nil;
        self.callback = nil;
        productData = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)selectedItem:(NSString *)value
{
    LOG(@"%@",value);
}

- (void)tapAdd
{
    GDDeliveryEditAddressViewController *viewController = [[GDDeliveryEditAddressViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.canBeChangeArea = NO;
    viewController.addNew = YES;
    [self.navigationController pushViewController: viewController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem*  addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(tapAdd)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    CGRect r = self.view.bounds;
    
    mainTableView = MOCreateTableView( r , UITableViewStylePlain, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)noAddressView
{
    if (!_noAddressView) {
        
        CGRect r = self.view.frame;
        
        _noAddressView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height)];
       
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, r.size.height/2-40, r.size.width, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"No Shipping Address.", @"没有任何收货地址");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = MOLightFont(16);
        [_noAddressView addSubview:label];
        
        ACPButton* addBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        addBut.frame = CGRectMake(10, r.size.height/2, r.size.width-20, 36);
        [addBut setStyleRedButton];
        [addBut setTitle: NSLocalizedString(@"Add", @"添加") forState:UIControlStateNormal];
        [addBut addTarget:self action:@selector(tapAdd) forControlEvents:UIControlEventTouchUpInside];
        [addBut setLabelFont:MOLightFont(18)];
        [_noAddressView addSubview:addBut];

    }
    return _noAddressView;
}

#pragma mark - Data

- (void)getProductData
{
    [ProgressHUD show:nil];
    
    reloading = YES;
    
    NSNumber* areaNumber = [GDSettingManager instance].userDeliveryInfo[@"selAreaId"];
    int areaId = [areaNumber intValue];
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"takeout/v1/TakeoutAddress/get_address_list_of_customer"];
    parameters = @{@"token":[GDPublicManager instance].token,@"area_id":@(areaId)};
    
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
         
         if(responseObject[@"data"][@"address_list"] != [NSNull null] && responseObject[@"data"][@"address_list"] != nil)
         {
              [productData addObjectsFromArray:responseObject[@"data"][@"address_list"]];
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
         [mainTableView reloadData];
         [ProgressHUD dismiss];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self stopLoad];
#if defined MO_DEBUG
         [ProgressHUD showError:error.localizedDescription];
#endif
     }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    if (self.isChoose)
    {
        self.title = NSLocalizedString(@"Choose Address", @"选择地址");
    }
    else
    {
        self.title = NSLocalizedString(@"My Address", @"收货地址管理");
    }
    
    [self getProductData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [ProgressHUD dismiss];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}


#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"addressCell";
    
    GDAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GDAddressCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* obj = [productData objectAtIndex:indexPath.row];
    
    NSString*  name = @"";
    NSString*  telephone= @"";
    NSString*  address=@"";
    NSString*  country=@"";
    NSString*  city=@"";
    NSString*  area=@"";
    
    int  selected = [obj[@"selected"] floatValue];
    int  address_id = [obj[@"address_id"] intValue];
    
    SET_IF_NOT_NULL(name, obj[@"firstname"]);
    
    SET_IF_NOT_NULL(telephone, obj[@"telephone"]);
    SET_IF_NOT_NULL(address, obj[@"address_1"]);
    SET_IF_NOT_NULL(country, obj[@"country_name"]);
    SET_IF_NOT_NULL(city, obj[@"zone_name"]);
    SET_IF_NOT_NULL(area, obj[@"area_name"]);
    
    cell.name.text = name;
    cell.phone.text = telephone;
    cell.address.text = [NSString stringWithFormat:@"%@,%@,%@,%@",address,area,city,country];
    
    cell.defaultAddress.hidden = (selected==1?NO:YES);
    
    if (self.isChoose)
    {
        if (self.sel_address_id == address_id)
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick.png"]];
        else
            cell.accessoryView = nil;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!reloading && !productData.count)
    {
        [mainTableView addSubview:[self noAddressView]];
          
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    
    if (productData.count>0)
    {
        [_noAddressView removeFromSuperview];
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    
    return productData.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* obj = [productData objectAtIndex:indexPath.row];
    
    if (self.isChoose)
    {
        if ([self.target respondsToSelector:self.callback])
        {
            [self.target performSelector:self.callback withObject:obj afterDelay:0];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        GDDeliveryEditAddressViewController *viewController = [[GDDeliveryEditAddressViewController alloc] initWithStyle:UITableViewStylePlain];
        viewController.addNew = NO;
        viewController.addressDict = obj;
        [self.navigationController pushViewController: viewController animated:YES];
    }
}


@end
