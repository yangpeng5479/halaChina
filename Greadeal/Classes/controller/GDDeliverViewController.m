//
//  GDDeliverViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/6.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDDeliverViewController.h"
#import "RDVTabBarController.h"

#import "GDDeliverCell.h"
#import "GDReceiveCell.h"

@interface GDDeliverViewController ()

@end

@implementation GDDeliverViewController

- (id)init:(NSDictionary*)aObj
{
    self = [super init];
    if (self)
    {
        deliverData = [[NSMutableArray alloc] init];
        orderData = aObj;
        
        seekPage = 1;
        lastCountFromServer = 0;
        
        order_id    = orderData[@"order_id"];
    }
    return self;
}

- (void)tapGo
{
    
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
  
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showDeliveryID
{
    if (deliverData.count>0)
    {
        CGRect r = self.view.bounds;
        r.size.height = 40;
        UIView *footer = [[UIView alloc] initWithFrame:r];
        footer.backgroundColor = [UIColor colorWithRed:75/255.0 green:87/255.0 blue:114/255.0 alpha:1.0];
    
        NSDictionary* obj = [deliverData objectAtIndex:0];
    
        UILabel* deliverId =  MOCreateLabelAutoRTL();
        deliverId.font = MOLightFont(13);
        deliverId.frame = CGRectMake(10, 0, 300, 0);
        deliverId.textColor = [UIColor whiteColor];
        deliverId.backgroundColor =  [UIColor clearColor];
        deliverId.text = [NSString stringWithFormat:NSLocalizedString(@"Delivery  ID: %@", @"运单编号:%@"),obj[@"shipping_order_id"]];

        [footer addSubview:deliverId];
  
        mainTableView.tableHeaderView = footer;
    }
}

#pragma mark - Data
- (void)getProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    reloading = YES;
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest/v1/shippinglog/get_shipping_logs"];
    parameters = @{@"order_id":order_id};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             @synchronized(deliverData)
             {
                 [deliverData removeAllObjects];
             }
             
             if(responseObject[@"data"][@"shipping_logs"] != [NSNull null] && responseObject[@"data"][@"shipping_logs"] != nil)
             {
                 [deliverData addObjectsFromArray:responseObject[@"data"][@"shipping_logs"]];
             }
         }
         
         [self stopLoad];
         [self performSelectorOnMainThread:@selector(reLoadView) withObject:nil waitUntilDone:NO];
         [ProgressHUD dismiss];
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self stopLoad];

         [ProgressHUD showError:error.localizedDescription];

     }];
}

#pragma mark UIView
- (void)reLoadView
{
    [mainTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"Tracking Order", @"物流信息");
    
    if (!isLoadData)
    {
        [self  getProductData];
        isLoadData = YES;
    }
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [ProgressHUD dismiss];
}


#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0)
    {
        static NSString *CellIdentifier = @"cellPro";
        
        GDReceiveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GDReceiveCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSString*  name = @"";
        NSString*  telephone= @"";
        NSString*  address=@"";
        NSString*  country=@"";
        NSString*  city=@"";
        NSString*  area=@"";
        
        SET_IF_NOT_NULL(name, orderData[@"shipping_firstname"]);
        SET_IF_NOT_NULL(telephone, orderData[@"telephone"]);
        SET_IF_NOT_NULL(address, orderData[@"shipping_address_1"]);
        SET_IF_NOT_NULL(country, orderData[@"shipping_country"]);
        SET_IF_NOT_NULL(city, orderData[@"shipping_zone"]);
        SET_IF_NOT_NULL(area, orderData[@"shipping_zone_area"]);
        
        cell.name.text  = [NSString stringWithFormat:NSLocalizedString(@"Receiver: %@", @"收货人:%@"),name];
        cell.phone.text = telephone;
        cell.address.text = [NSString stringWithFormat:@"%@,%@,%@,%@",address,area,city,country];
        return cell;

    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row ==0)
        {
            static NSString *CellIdentifier = @"Cell";
            UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
            cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            
            }
            cell.textLabel.font = MOLightFont(14);
            cell.textLabel.text= NSLocalizedString(@"Delivery Details", @"物流详情");
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"listCell";
        
            GDDeliverCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
            cell = [[GDDeliverCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.separatorInset = UIEdgeInsetsMake(0, 50, 0,0);
            }
        
            NSDictionary* obj = [deliverData objectAtIndex:indexPath.row-1];
        
            NSString*  title =obj[@"shipping_status"];
            NSString*  time = obj[@"created"];

            //    to_ship : 已经收件
            //    shipping：正在配送
            //    shipped：已经签收
            //    fail_to_ship : 无法送达
            if ([title isEqualToString:@"to_ship"])
            {
                cell.title.text  = NSLocalizedString(@"Pick up", @"已经收件");
            }
            else if ([title isEqualToString:@"shipping"])
            {
                cell.title.text  = NSLocalizedString(@"On Delivery", @"正在配送");
            }
            else if ([title isEqualToString:@"shipped"])
            {
                cell.title.text  = NSLocalizedString(@"Signed", @"已经签收");
            }
            else if ([title isEqualToString:@"fail_to_ship"])
            {
                cell.title.text  = NSLocalizedString(@"Could not be served", @"无法送达");
            }
            
            cell.details.text = time;
        
            if (indexPath.row-1 == 0)
            {
                cell.iconImage.image = [UIImage imageNamed:@"line_green.png"];
                cell.title.textColor = MOAppTextBackColor();
                cell.details.textColor = MOAppTextBackColor();
            }
            else
                cell.iconImage.image = [UIImage imageNamed:@"line_gray.png"];
            return cell;
        }
    }
     return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    return deliverData.count+1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 110;
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
            return 40;
        else
            return 60;
    }
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
