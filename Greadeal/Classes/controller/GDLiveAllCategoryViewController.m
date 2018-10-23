//
//  GDLiveAllCategoryViewController.m
//  Greadeal
//
//  Created by Elsa on 15/6/3.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDLiveAllCategoryViewController.h"
#import "GDLiveAllClassView.h"

#import "RDVTabBarController.h"

#import "GDLiveDiscountViewController.h"

#define cellHeight     50
#define numbersOfCell  3

@interface GDLiveAllCategoryViewController ()

@end

@implementation GDLiveAllCategoryViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        self.title = NSLocalizedString(@"Categories", @"分类");
       
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    categoryData = [[NSMutableArray alloc] init];
    
    CGRect r =  self.view.bounds;
    
    mainTableView = MOCreateTableView( r , UITableViewStylePlain, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    
    [self addRefreshUI];
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
   
    GDLiveDiscountViewController *viewController = [[GDLiveDiscountViewController alloc] init:[dict[@"category_id"] intValue] withDrop:YES isDiscount:NO];
    
    [self.navigationController pushViewController:viewController animated:YES];

}

- (float)caluGalleryHeight:(int)section
{
    float aheight;
    
    NSDictionary* obj = [categoryData objectAtIndex:section];
    
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
    if (!isLoadData)
    {
        isLoadData = YES;
        [self getProductData];
    }
    //[[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    //[ProgressHUD dismiss];
    //[[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

#pragma mark - Data

- (void)getProductData
{
    [ProgressHUD show:nil];
    
    reloading = YES;
    
    [[GDPublicManager instance] getCategory:CATEGORY_ALL_STORE success:^(NSError *error) {
        [ProgressHUD dismiss];
        if (error!=nil)
        {
            netWorkError = YES;
          
            [self stopLoad];
            [self reLoadView];
            [ProgressHUD showError:error.localizedDescription];

        }
        else
        {
            @synchronized(categoryData)
            {
                [categoryData removeAllObjects];
            }
            categoryData = [[GDSettingManager instance].nAllStoreCategory mutableCopy];
            netWorkError = NO;
            
            [self stopLoad];
            [self reLoadView];
        }
    }];
    
}


#pragma mark - Table view
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary* obj = [categoryData objectAtIndex:section];
    
    NSString*  categoryName=@"";
    SET_IF_NOT_NULL(categoryName, obj[@"name"]);
    NSString*  image_url = obj[@"image"];
    
    float offsetY = 10;
    
    UIImageView * iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(offsetY, 5, 25, 25)];
    iconImage.contentMode = UIViewContentModeScaleAspectFill;
    [iconImage setClipsToBounds:YES];
    [iconImage sd_setImageWithURL: [NSURL URLWithString:[image_url encodeUTF]] placeholderImage:[UIImage imageNamed: @"sale_category_default.png"]];
    
    offsetY+=iconImage.frame.size.width;
    
    UILabel* titleLabel = MOCreateLabelAutoRTL();
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = MOLightFont(14);
    titleLabel.text = categoryName;
    
    CGRect r =self.view.bounds;
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, 0, r.size.width, 35)];
    
    CGSize titleSize = [titleLabel.text moSizeWithFont:titleLabel.font withWidth:200];
    offsetY+=10;
    titleLabel.frame = CGRectMake(offsetY, 0, titleSize.width, 35);
    
    offsetY+=titleLabel.frame.size.width;
    
    [hView addSubview:titleLabel];
    
    offsetY+=10;
    UIImageView* backgroundView = [[UIImageView alloc] init];
    backgroundView.image = [[UIImage imageNamed:@"productLline.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    backgroundView.frame= CGRectMake(offsetY, 35/2,
                                     r.size.width-offsetY-10, 1);
    [hView addSubview:backgroundView];
    [hView addSubview:iconImage];
    
    hView.backgroundColor =MOColorSaleProductBackgroundColor();
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = iconImage.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - 10;
        iconImage.frame = tempRect;
        
        tempRect = titleLabel.frame;
        tempRect.origin.x = iconImage.frame.origin.x-tempRect.size.width - 10;
        titleLabel.frame = tempRect;
        
        tempRect = backgroundView.frame;
        tempRect.origin.x = 10;
        backgroundView.frame = tempRect;
    }
    
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
    
    NSDictionary* obj = [categoryData objectAtIndex:indexPath.section];
    
    NSMutableArray   *listData = [[NSMutableArray alloc] init];
    [listData addObjectsFromArray:obj[@"list"]];
  
    
    CGRect r = self.view.frame;
    
    GDLiveAllClassView* galleryView = [[GDLiveAllClassView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth(r), [self caluGalleryHeight:(int)indexPath.section])];
    galleryView.ItemOfPage = (int)listData.count;
    galleryView.LineHeight = cellHeight;
    galleryView.ItemOfLine = numbersOfCell;
    galleryView.xspaceing  = 10;
    galleryView.yspaceing  = 8;
    galleryView.target     = self;
    galleryView.callback   = @selector(didSelectItem:);
    
    [galleryView setRecentItems:listData];
    
    [cell.contentView addSubview:galleryView];
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!reloading && categoryData.count<=0)
    {
        if (netWorkError)
        {
            [mainTableView insertSubview:[self noNetworkView] atIndex:0];
        
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getProductData)];
            [[self noNetworkView] addGestureRecognizer:tapGesture];
        }
    }
    
    if (categoryData.count>0)
    {
        [_noNetworkView removeFromSuperview];
    }

    return categoryData.count;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)refreshData
{
    LOG(@"refresh data");
    [self getProductData];
}

- (void)nextPage
{
}

#pragma mark scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == mainTableView)
    {
        NSInteger currentOffset = scrollView.contentOffset.y;
        NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if (reloading) return;
        
        if (checkForRefresh)
        {
            if (refreshHeaderView.isFlipped
                && scrollView.contentOffset.y > -kRefreshkShowAll-5
                && scrollView.contentOffset.y < 0.0f
                && !reloading) {
                [refreshHeaderView flipImageAnimated:YES];
                [refreshHeaderView setStatus:kMOPullToReloadStatus];
                
            } else if (!refreshHeaderView.isFlipped
                       && scrollView.contentOffset.y < -kRefreshkShowAll-5) {
                [refreshHeaderView flipImageAnimated:YES];
                [refreshHeaderView setStatus:kMOReleaseToReloadStatus];
                
            }
        }
        
        // Change 20.0 to adjust the distance from bottom
        if (currentOffset>0 && currentOffset - maximumOffset >= kThumbsViewMoreHeight)
        {
            [self nextPage];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == mainTableView)
    {
        if (!reloading)
        {
            checkForRefresh = YES;  //only check offset when dragging
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
   
        if (!reloading)
        {
            if (scrollView.contentOffset.y <= -kRefreshkShowAll + 10)
            {
                reloading = YES;
                [refreshHeaderView toggleActivityView:YES];
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.2];
                mainTableView.contentInset = UIEdgeInsetsMake(kRefreshkShowAll, 0.0f, 0.0f,0.0f);
                [UIView commitAnimations];
                
                mainTableView.contentOffset=scrollView.contentOffset;
                
                [self refreshData];
                
            }
            checkForRefresh = NO;
        }
}

@end
