//
//  GDRateViewController.m
//  Greadeal
//
//  Created by Elsa on 15/10/15.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "GDRateViewController.h"
#import "RDVTabBarController.h"
#import "GDRateListCell.h"

@interface GDRateViewController ()

@end

@implementation GDRateViewController

- (id)initWithProduct:(int)product_id
{
    self = [super init];
    if (self)
    {
        isVendor = NO;
        
        productId  = product_id;
        _rateList  = [[NSMutableArray alloc] init];
    
        seekPage = 1;
        lastCountFromServer = 0;
        
    }
    return self;
}

- (id)initWithVendor:(int)vendor_id
{
    self = [super init];
    if (self)
    {
        isVendor = YES;
        
        vendorId = vendor_id;
        _rateList   = [[NSMutableArray alloc] init];
        
        seekPage = 1;
        lastCountFromServer = 0;
        
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
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    self.title = NSLocalizedString(@"Rate", @"评价");
  
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
    
    if (isVendor)
    {
        url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/vendor/get_vendor_review_list"];
        parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"vendor_id":@(vendorId),@"page":@(seekPage),@"limit":@(prePageNumber)};
    }
    else
    {
        url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Product/get_product_review_list"];
        parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"product_id":@(productId),@"page":@(seekPage),@"limit":@(prePageNumber)};
    }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             @synchronized(_rateList)
             {
                 [_rateList removeAllObjects];
             }
             
             NSArray* temp = responseObject[@"data"][@"review_list"];
             if (temp.count>0)
             {
                 for (NSDictionary* newDict in  temp)
                 {
                     NSMutableDictionary *muNewDict=[newDict mutableCopy];
                     [muNewDict setObject:@"" forKey:ExText];
                     [muNewDict setObject:@(0) forKey:isCN];//0 no 1 yes
                     [_rateList addObject:muNewDict];
                 }
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
         
         [self stopLoad];
         [self reLoadView];
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self stopLoad];
         [self reLoadView];
         [ProgressHUD showError:error.localizedDescription];
     }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    if (!isLoadData)
    {
        [self  getProductData];
        isLoadData = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [ProgressHUD dismiss];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)tapTrans:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    int selectedIndex = (int)button.tag;
    
    __block NSMutableDictionary* dict = [_rateList objectAtIndex:selectedIndex];
    NSString* cnText = dict[ExText];
    NSString* enText = dict[@"text"];
    
    if (cnText.length<=0)
    {
        [[GDPublicManager instance] toChinese:enText success:^(NSString *translated) {
            if (translated.length>0)
            {
                [dict setObject:translated forKey:ExText];
                LOG(@"%@",translated);
                [self reLoadView];
            }
        }];
    }
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        GDRateListCell *cell;
        static NSString *ID = @"rateList1";
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
                cell = [[GDRateListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
            
        NSDictionary* dict = [_rateList objectAtIndex:indexPath.row];
            
        cell.userLabel.text  = dict[@"author"];
        cell.rateLabel.text  = [NSString stringWithFormat:NSLocalizedString(@"Rated %.1f", @"评分 %.1f"),[dict[@"rating"] floatValue]];
        cell.dateLabel.text  = dict[@"date_added"];
        cell.contentLabel.text = dict[@"text"];

        if(dict[@"imagelist_list"] != [NSNull null] && dict[@"imagelist_list"]!= nil)
        {
            NSArray* imagelist_list = dict[@"imagelist_list"];
            if (imagelist_list.count>0)
            {
                cell.imageArrar = imagelist_list;
            }
        }
    
        NSString* strChinese = dict[ExText];
        if (strChinese.length>0)
            cell.contentLabel.text = strChinese;
        else
            cell.contentLabel.text = dict[@"text"];
    
        [cell.userImage sd_setImageWithURL:[NSURL URLWithString:dict[@"header"]]
                      placeholderImage:[UIImage imageNamed:@"user_1.png"]];
    
        if ([[GDSettingManager instance] isChinese])
        {
            cell.translationBut.hidden = NO;
            cell.translationBut.tag = indexPath.row;
            [cell.translationBut addTarget:self action:@selector(tapTrans:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            cell.translationBut.hidden = YES;
        }
    
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _rateList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSDictionary* dict = [_rateList objectAtIndex:indexPath.row];
    NSString* content = dict[@"text"];
        
    CGSize titleSize = [content moSizeWithFont:MOLightFont(12) withWidth:[GDPublicManager instance].screenWidth-60];
        
    float  photosWidth = 0;
    if(dict[@"imagelist_list"] != [NSNull null] && dict[@"imagelist_list"]!= nil)
    {
        NSArray* imagelist_list = dict[@"imagelist_list"];
        if (imagelist_list.count>0)
        {
            photosWidth = (([[UIScreen mainScreen] bounds].size.width-70.0)/4);
        }
    }
    float translationBut = 0;
    if ([[GDSettingManager instance] isChinese])
        translationBut = 0;

    return 56+titleSize.height+8+photosWidth+translationBut;


}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
