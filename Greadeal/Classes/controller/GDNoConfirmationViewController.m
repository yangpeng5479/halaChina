//
//  GDNoConfirmationViewController.m
//  Greadeal
//
//  Created by Elsa on 15/7/16.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDNoConfirmationViewController.h"
#import "RDVTabBarController.h"

#import "GDOrderListCell.h"

@interface GDNoConfirmationViewController ()

@end

@implementation GDNoConfirmationViewController


- (id)init
{
    self = [super init];
    if (self)
    {
        orderData = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
        
        self.title = NSLocalizedString(@"Goods Awaiting Confirmation", @"待评价");
    }
    
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapPay
{
    
}

- (void)tapSee
{
    
}

- (void)tapGo
{
    [[self rdv_tabBarController] setSelectedIndex:[GDSettingManager instance].nTabSale];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Data

- (UIView *)noReceiptView
{
    if (!_noReceiptView) {
        
        CGRect r = self.view.frame;
        
        _noReceiptView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height)];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, r.size.height/2-40, r.size.width, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"You have no relevant orders.", @"您没有相关订单");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:16];
        [_noReceiptView addSubview:label];
        
        ACPButton* goBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        goBut.frame = CGRectMake(10, r.size.height/2, r.size.width-20, 36);
        [goBut setStyleWithImage:@"loginNormal.png" highlightedImage:@"loginPress.png" disableImage:@"loginPress.png" andInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [goBut setTitle: NSLocalizedString(@"Go Shopping", @"去购物") forState:UIControlStateNormal];
        [goBut addTarget:self action:@selector(tapGo) forControlEvents:UIControlEventTouchUpInside];
        [goBut setLabelFont:[UIFont systemFontOfSize:14]];
        [_noReceiptView addSubview:goBut];
        
        MODebugLayer(_noDataView, 1.f, [UIColor redColor].CGColor);
        MODebugLayer(goBut, 1.f, [UIColor redColor].CGColor);
        // MODebugLayer(label, 1.f, [UIColor redColor].CGColor);
    }
    return _noReceiptView;
}


- (void)getProductData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    reloading = YES;
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",APIBaseUrl,@"wsProductGetAll.php"];
    parameters = @{@"page":@(seekPage),@"limit":@(prePageNumber)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
        
         lastCountFromServer = [responseObject[@"count"] intValue];
         
         if (lastCountFromServer>0)
         {
             if (seekPage == 1)
             {
                 @synchronized(orderData)
                 {
                     [orderData removeAllObjects];
                 }
             }
             [orderData addObjectsFromArray:responseObject[@"result"]];
             
             [self stopLoad];
             
             [self performSelectorOnMainThread:@selector(reLoadView) withObject:nil waitUntilDone:NO];
             
         }
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
    
    if (!isLoadData)
    {
        isLoadData = NO;
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
    
    if (indexPath.row ==0)
    {
        static NSString *CellIdentifier = @"Cell";
        UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
        }
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.text= @"商店名称";
        cell.detailTextLabel.text = @"下单时间 22015-05-20 14:30";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else if (indexPath.row ==1)
    {
        static NSString *CellIdentifier = @"listCell";
        
        GDOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GDOrderListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellSelectionStyleNone;
        }
        
        NSDictionary* obj = [orderData objectAtIndex:indexPath.row];
        
        NSString*  imgUrl =    obj[@"featured_src"];
        NSString*  title_name = obj[@"title"];
        float  price = [obj[@"price"] floatValue];
        
        
        if ([imgUrl isKindOfClass:[NSString class]])
            [cell.photoView sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                              placeholderImage:[UIImage imageNamed:@"order_default.png"]];
        
        if ([title_name isKindOfClass:[NSString class]])
            cell.title.text = title_name;
        
        cell.total_qty.text = NSLocalizedString(@"3 Items", @"3件商品");
        
        cell.price.text =  [NSString stringWithFormat:NSLocalizedString(@"Total:%@%.1f", @"总价:%@%.1f"),[GDPublicManager instance].currency, price];
        
        return cell;
        
        
    }
    else if (indexPath.row ==2)
    {
        UITableViewCell *cell ;
        static NSString *ID = @"button";
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        ACPButton* seeBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        seeBut.frame = CGRectMake(160,4, 150, 32);
        [seeBut setStyleWithImage:@"loginNormal.png" highlightedImage:@"loginPress.png" disableImage:@"loginPress.png" andInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        
        [seeBut setLabelTextColor:[UIColor whiteColor] highlightedColor:[UIColor greenColor] disableColor:nil];
        [seeBut setLabelFont:[UIFont systemFontOfSize:14]];
        [seeBut setTitle:NSLocalizedString(@"Review", @"评价") forState:UIControlStateNormal];
        [seeBut setCornerRadius:1];
        [seeBut addTarget:self action:@selector(tapSee) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:seeBut];
        
        return cell;
        
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!reloading && !orderData.count)
    {
        [mainTableView addSubview:[self noReceiptView]];
        
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    
    if (orderData.count>0)
    {
        [_noReceiptView removeFromSuperview];
        
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    
    return orderData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return 45;
            break;
        case 1:
            return 80;
        case 2:
            return 40;
        default:
            break;
    }
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
