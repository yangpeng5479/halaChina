//
//  GDMarketCategoryViewController.m
//  Greadeal
//
//  Created by Elsa on 15/8/4.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDMarketCategoryViewController.h"

#import "RDVTabBarController.h"
#import "GDSaleSearchPanelView.h"

#import "GDMarketProductListViewController.h"
#import "GDMarketSearchViewController.h"

#define categoryHeight 45
#define cellHeight     92
#define numbersOfCell  3

#define kLeftWidth     100
#define leftTag        101

@interface GDMarketCategoryViewController ()

@end

@implementation GDMarketCategoryViewController

- (id)init:(int)vendor_id withIndex:(int)aIndex
{
    self = [super init];
    if (self)
    {
        vendorId    = vendor_id;
        selectIndex = aIndex;
        leftData  = [[NSMutableArray alloc] init];
        
        self.title = NSLocalizedString(@"All Categories", @"全部分类");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect r =  self.view.bounds;
    
    self.leftSelectColor=colorFromHexString(@"41873f");
    self.leftUnSelectColor=[UIColor blackColor];
    self.leftSelectBgColor=[UIColor whiteColor];
    self.leftBgColor=colorFromHexString(@"F3F4F6");
    self.leftSeparatorColor=colorFromHexString(@"E5E5E5");
    self.leftUnSelectBgColor=colorFromHexString(@"F3F4F6");
   
    
    self.view.backgroundColor = MOColorAppBackgroundColor();
     
    leftTablew = MOCreateTableView(CGRectMake(0, 0, kLeftWidth, r.size.height), UITableViewStylePlain, [UITableView class]);
    leftTablew.dataSource = self;
    leftTablew.delegate = self;
    leftTablew.tableFooterView=[[UIView alloc] init];
    leftTablew.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:leftTablew];
    leftTablew.backgroundColor=self.leftBgColor;
    leftTablew.showsVerticalScrollIndicator = NO;
    if ([leftTablew respondsToSelector:@selector(setLayoutMargins:)]) {
        leftTablew.layoutMargins=UIEdgeInsetsZero;
    }
    if ([leftTablew respondsToSelector:@selector(setSeparatorInset:)]) {
        leftTablew.separatorInset=UIEdgeInsetsZero;
    }
    leftTablew.separatorColor=self.leftSeparatorColor;
    
    rightTableView = MOCreateTableView( CGRectMake(kLeftWidth, 0, r.size.width-kLeftWidth, r.size.height) , UITableViewStylePlain, [UITableView class]);
    rightTableView.dataSource = self;
    rightTableView.delegate = self;
    rightTableView.tableFooterView=[[UIView alloc] init];
    rightTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:rightTableView];
    rightTableView.backgroundColor = MOColorAppBackgroundColor();
    
    UIBarButtonItem*  searchButItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(tapSearch)];
    self.navigationItem.rightBarButtonItem = searchButItem;
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = leftTablew.frame;
        tempRect.origin.x = r.size.width - kLeftWidth;
        leftTablew.frame = tempRect;
        
        tempRect = rightTableView.frame;
        tempRect.origin.x = 0;
        rightTableView.frame = tempRect;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (float)caluGalleryHeight:(int)section withRow:(int)row
{
    float aheight;
    
    NSDictionary* obj = rightData[section][row];
    
    NSMutableArray   *listData = [[NSMutableArray alloc] init];
    [listData addObjectsFromArray:obj[@"category_list_lv3"]];
    
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
    
    if (!isLoadData)
    {
        [self getLeftData];
       
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

- (void)didSelectCagetory:(id)sender
{
    //{"s":<string> sticker name, if applicable, "e":<string> emoji code, if applicable.}
    NSDictionary *dict = sender;
    
    int categoryId = [dict[@"category_id"] intValue];
    
    GDMarketProductListViewController *viewController = [[GDMarketProductListViewController alloc] init:vendorId withCategory:categoryId];
    SET_IF_NOT_NULL( viewController.title , dict[@"name"]);
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Data

- (void)getLeftData
{
    if (!isLoadData)
        [ProgressHUD show:nil];
    
    isLoadData= YES;
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"supermarket/get_top_category_list_of_vendor"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"vendor_id":@(vendorId)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             @synchronized(leftData)
             {
                 [leftData removeAllObjects];
             }
             
             [leftData addObjectsFromArray:responseObject[@"data"][@"category_list"]];
             
             rightData = [[NSMutableArray alloc] initWithCapacity:leftData.count];
             for (NSUInteger idx = 0; idx < leftData.count; idx++) {
                 [rightData addObject:[NSMutableArray array]];
             }
             
             [leftTablew reloadData];
             
             //get one
             if (selectIndex<leftData.count)
                 [self getRightData:selectIndex];
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

- (void)selectedSection:(int)nRow
{
    selectIndex = nRow;
    [leftTablew reloadData];
}
- (void)getRightData:(int)nRow
{
    NSArray* temp = [rightData objectAtIndex:nRow];
    if (temp.count>0)
    {
        [self selectedSection:nRow];
        [rightTableView reloadData];
        [rightTableView setContentOffset:CGPointZero animated:NO];
        return;
    }
    
    [ProgressHUD show:nil];
    
    NSString* url;
    NSDictionary *parameters;
 
    NSDictionary* obj = [leftData objectAtIndex:nRow];
    int categoryId = [obj[@"category_id"] intValue];
   
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"supermarket/get_all_sub_category_list_of_vendor"];
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:YES]),@"vendor_id":@(vendorId),@"category_id":@(categoryId)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [ProgressHUD dismiss];
        
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             NSArray* tempArr = responseObject[@"data"][@"category_list_lv2"];
             
             @synchronized(rightData)
             {
                [rightData replaceObjectAtIndex:nRow withObject:tempArr];
             }
             
             [self selectedSection:nRow];
             
             [rightTableView reloadData];
             [rightTableView setContentOffset:CGPointZero animated:NO];
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

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (leftTablew == tableView)
    {
        static NSString *ID = @"left";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSDictionary* obj = [leftData objectAtIndex:indexPath.row];
       
        NSString*  categoryName=@"";
        SET_IF_NOT_NULL(categoryName, obj[@"name"]);
        
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.tag=leftTag;
        cell.textLabel.text=categoryName;
        cell.textLabel.numberOfLines = 0;
        
        if (indexPath.row==selectIndex) {
            cell.textLabel.textColor=self.leftSelectColor;
            cell.backgroundColor=self.leftSelectBgColor;
        }
        else{
            cell.textLabel.textColor=self.leftUnSelectColor;
            cell.backgroundColor=self.leftUnSelectBgColor;
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            cell.layoutMargins=UIEdgeInsetsZero;
        }
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset=UIEdgeInsetsZero;
        }
        return cell;
    }
    else if (rightTableView == tableView)
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
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width)];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width)];
        }
        
        NSDictionary* obj = rightData[selectIndex][indexPath.row];
        
        NSString*  categoryName=@"";
        SET_IF_NOT_NULL(categoryName, obj[@"name"]);
            
        UILabel* titleLabel = MOCreateLabelAutoRTL();
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.text = categoryName;
            
        titleLabel.frame = CGRectMake(10, 0, r.size.width-kLeftWidth-10, categoryHeight);
            
        titleLabel.backgroundColor =[UIColor whiteColor];
        
        NSMutableArray   *listData = [[NSMutableArray alloc] init];
        [listData addObjectsFromArray:obj[@"category_list_lv3"]];
            
        GDSaleSearchPanelView* galleryView = [[GDSaleSearchPanelView alloc] initWithFrame:CGRectMake(0, categoryHeight,r.size.width-kLeftWidth,[self caluGalleryHeight:selectIndex withRow:(int)indexPath.row])];
                                                                                                     
        galleryView.ItemOfPage = (int)listData.count;
        galleryView.LineHeight = cellHeight;
        galleryView.ItemOfLine = 3;
        galleryView.xspaceing  = 5;
        galleryView.yspaceing  = 5;
        galleryView.imageHeight = 50;
        galleryView.target     = self;
        galleryView.callback   = @selector(didSelectCagetory:);
        galleryView.backgroundColor = [UIColor clearColor];
        [galleryView setRecentItems:listData];
        
        [cell.contentView addSubview:titleLabel];
        [cell.contentView addSubview:galleryView];
            
        return cell;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (leftTablew == tableView)
    {
        return 1;
    }
    else if (rightTableView == tableView)
    {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (leftTablew == tableView)
    {
        return leftData.count;
    }
    else if (rightTableView == tableView)
    {
        if (section<rightData.count)
        {
            NSArray* temp = [rightData objectAtIndex:selectIndex];
            return temp.count;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (leftTablew == tableView)
    {
        return 60;
    }
    else if (rightTableView == tableView)
    {
        float height = [self caluGalleryHeight:selectIndex withRow:(int)indexPath.row];
        return height+categoryHeight;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (leftTablew == tableView)
    {
        UITableViewCell * cell=(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor=self.leftSelectColor;
        cell.backgroundColor=self.leftSelectBgColor;
        
        [leftTablew scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        if (indexPath.row<leftData.count)
             [self getRightData:(int)indexPath.row];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (leftTablew == tableView)
    {
        UITableViewCell * cell=(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor=self.leftUnSelectColor;
        cell.backgroundColor=self.leftUnSelectBgColor;
    }
}

@end
