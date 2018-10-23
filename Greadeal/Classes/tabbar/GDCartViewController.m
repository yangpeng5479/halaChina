//
//  GDCartViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/11.
//  Copyright (c) 2015年 Elsa. All rights reserved.mainTableView
//

#import "GDCartViewController.h"
#import "GDProductDetailsViewController.h"

#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"

#import "GDCartsListCell.h"
#import "GDMakeOrderViewController.h"

#import "GDLoginViewController.h"
#import "GDRegsiterViewController.h"

#import "UIActionSheet+Blocks.h"
#import "GDShopDeliveryOrderViewController.h"

#define toolViewHeight 0
#define xMargin 10
#define yMargin 5

@interface GDCartViewController ()

@end

@implementation GDCartViewController

#pragma mark - init

- (NSDictionary*)dataToProduct:(NSData*)aData
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aData];
    NSDictionary *product = [unarchiver decodeObjectForKey:@"yourproduct"];
    [unarchiver finishDecoding];
    return product;
}

- (void)getCartDB
{
    NSArray* temp = [[WCDatabaseManager instance] getCart];
    if (temp!=nil)
    {
        for (NSDictionary* obj in temp)
        {
            int qty = [obj[@"qty"] intValue];
            NSMutableDictionary *product = [[self dataToProduct:obj[@"product"]] mutableCopy];
            [product setObject:@(qty) forKey:@"order_qty"];
            [self cartsSectionsForAdd:product];
        }
    }
}

//alter login get data
- (void)getCartFromDB
{
    [[GDPublicManager instance] clearCart];
    
    if ([GDPublicManager instance].defaultCount>0)
    {
        //check time
        NSTimeInterval sub = -[[GDSettingManager instance].nLastAddToCartDate timeIntervalSinceNow];
        if (sub<=[GDPublicManager instance].defaultCount*60)
        {
            [self getCartDB];
        }
        else
        {
            [[WCDatabaseManager instance] deleteCartOfAll];
        }
    }
    else
    {
        [self getCartDB];
    }
    
}

- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Cart", @"购物车");
        
        seekPage = 1;
        lastCountFromServer = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBadge:) name:kNotificationDidAddToCart object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subBadge:) name:kNotificationDidSubToCart object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCountdown) name:kNotificationDidClearCart object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCartFromDB) name:kNotificationGetCacheCart object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addRemind) name:kNotificationGetRemindCart object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteVendor:) name:kNotificationDeleteVendorCart object:nil];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Action

-(void)setFavorite
{
    NSString* url;
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/add_wishlist"];
    
    for (NSDictionary* dict in [GDPublicManager instance].cartsItem)
    {
        NSArray* tempArrar = dict[@"Items"];
        for (NSDictionary* obj in tempArrar)
        {
            NSDictionary *parameters=@{@"token":[GDPublicManager instance].token,
                                       @"product_id":@([obj[@"product_id"] intValue])};
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            [manager POST:url
               parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 int status = [responseObject[@"status"] intValue];
                 if (status==1)
                 {
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
    }
}


- (void)addRemind
{
    CGRect r = self.view.frame;
    
    UILabel* headView = MOCreateLabelAutoRTL();
    headView.frame = CGRectMake(r.origin.x+10, r.origin.y, r.size.width-20,60);
    headView.font = MOLightFont(14);
    headView.textColor = [UIColor whiteColor];
    headView.numberOfLines = 0;
    headView.textAlignment = NSTextAlignmentCenter;
    headView.backgroundColor = MOAppTextBackColor();
    
    headView.text=NSLocalizedString(@"Carts will be clear 10 Minutes later, please purchase ASAP, please purchase ASAP. You can find deleted product in Me->Wish List.", @"10分钟后商品将会从购物车中岀出,请尽快购买. 您可以在 我的->收藏 找到被删除的商品.");
    
    mainTableView.tableHeaderView = headView;
    
    //save product to my Wish List
    if ([GDPublicManager instance].cid>0)
    {
        [self setFavorite];
    }
}

- (void)clearCountdown
{
    mainTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,mainTableView.bounds.size.width, 1)];
    [self showCartCountdown:NO];
    [self reCaluPrice];
    [self reLoadView];
    [[self rdv_tabBarItem] setBadgeValue:nil];
}

- (void)setCartCount
{
    int order_qty = 0;
    for (NSMutableDictionary* dict in [GDPublicManager instance].cartsItem)
    {
        if (dict!=nil)
        {
            NSArray* tempArrar = dict[@"Items"];
            for (NSDictionary* obj in tempArrar)
            {
                //check option_value_id and product_id the same
                order_qty  += [obj[@"order_qty"] intValue];
            }
        }
    }
    if (order_qty>0)
        [[self rdv_tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d",order_qty]];
    else
        [[self rdv_tabBarItem] setBadgeValue:nil];
}

- (void)addNewToCarts:(NSDictionary*)dict
{
    int userid = -1;
    userid = [GDPublicManager instance].cid>0?[GDPublicManager instance].cid:-1;
    
    int     qty = [dict[@"order_qty"] intValue];
    int     price = [dict[@"sprice"] intValue];
    int     proid = [dict[@"product_id"] intValue];
    float optionid = [dict[@"option_value_id"] intValue];
    float vendor_id = [dict[@"vendor_id"] intValue];
    NSString* vendor_name = dict[@"vendor_name"];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dict forKey:@"yourproduct"];
    [archiver finishEncoding];
    
    /** data is ready now, and you can use it **/
    NSDictionary *parameters = @{@"product":data,@"userid":@(userid),@"qty":@(qty),@"price":@(price),@"vendor_id":@(vendor_id),@"proid":@(proid),@"optionid":@(optionid),@"vendor_name":vendor_name};
    
    BOOL isResult = NO;
    isResult = [[WCDatabaseManager instance] saveCart:parameters];
    
}

- (void)subBadge:(NSNotification *)notfication
{
    [self performSelectorOnMainThread:@selector(reLoadView) withObject:nil waitUntilDone:NO];
    [self setCartCount];
    [self reCaluPrice];
}

- (void)addBadge:(NSNotification *)notfication
{
    LOG(@"obj=%@",notfication);
    
    NSDictionary* newDict=notfication.object;
    BOOL   isNew = YES;
    int option_value_id = [newDict[@"option_value_id"] intValue];
    int product_id      = [newDict[@"product_id"] intValue];
    
    for (NSMutableDictionary* dict in [GDPublicManager instance].cartsItem)
    {
        //check option_value_id and product_id the same
        if (dict!=nil)
        {
            NSArray* tempArrar = dict[@"Items"];
            for (NSMutableDictionary* obj in tempArrar)
            {
                int temp_option_value_id = [obj[@"option_value_id"] intValue];
                int temp_product_id      = [obj[@"product_id"] intValue];
                
                if (product_id == temp_product_id) //check qty
                {
                    int  order_qty       = [newDict[@"order_qty"] intValue];
                    int  product_qty = [newDict[@"product_qty"] intValue];

                    int  temp_order_qty  = [obj[@"order_qty"] intValue];
                    
                    int added_order_qty =  [[GDPublicManager instance] getOrderQtyOfProudct:product_id withoption:0];
                  
                    if (product_qty>=order_qty+added_order_qty)
                    {
                       
                        if (option_value_id == temp_option_value_id)
                        {
                            isNew = NO;
                            
                            int  option_value_id = [newDict[@"option_value_id"] intValue];
                            
                            [obj setObject:@(order_qty+temp_order_qty) forKey:@"order_qty"];
                                
                            //update carts db
                            [[WCDatabaseManager instance] updateCartQty:order_qty+temp_order_qty withID:product_id withOption:option_value_id];
                            
                        }

                    }
                    else
                    {
                        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                                           message:NSLocalizedString(@"Oops,Over inventory", @"超过库存数量!")
                                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                 otherButtonTitles:nil
                                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                                  
                                              }
                                          }];
                        return;
                    }
                }
            }
        }
    }
    
    if (isNew)
    {
        ////add new carts db
        [self addNewToCarts:newDict];
        [self cartsSectionsForAdd:newDict];
    }
    
    [self performSelectorOnMainThread:@selector(reLoadView) withObject:nil waitUntilDone:NO];
    
    [self setCartCount];
    [self reCaluPrice];
         
    [[GDSettingManager instance] setLastAddToCartDate];
    
    mainTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,mainTableView.bounds.size.width, 1)];
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect r = self.view.bounds;
    r.size.height-=toolViewHeight;
    
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    mainTableView.backgroundColor =  MOColorAppBackgroundColor();
   
    if (self.rdv_tabBarController.tabBar.translucent) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0,
                                               0,
                                               CGRectGetHeight(self.rdv_tabBarController.tabBar.frame),
                                               0);
        
        mainTableView.contentInset = insets;
        mainTableView.scrollIndicatorInsets = insets;
    }
    
    r.origin.y= self.view.bounds.size.height- self.rdv_tabBarController.tabBar.frame.size.height-toolViewHeight-[[UIApplication sharedApplication] statusBarFrame].size.height-self.navigationController.navigationBar.frame.size.height;
    r.size.height=toolViewHeight;
    
    paymentView = [[UIView alloc] initWithFrame:r];
    [self.view addSubview:paymentView];
    
    UIImageView* backgroundView = [[UIImageView alloc] init];
    backgroundView.image = [[UIImage imageNamed:@"productLline.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    backgroundView.frame= CGRectMake(r.origin.x, 0,
                                     r.size.width, 0.5);
    [paymentView addSubview:backgroundView];

    
    //MODebugLayer(paymentView, 1.f, [UIColor redColor].CGColor);
    
    textPrice = MOCreateLabelAutoRTL();
    textPrice.font = MOLightFont(18);
    textPrice.textColor = MOColorSaleFontColor();
    textPrice.backgroundColor = [UIColor clearColor];
    textPrice.text = NSLocalizedString(@"Total:", @"总金额:");
    [paymentView addSubview:textPrice];
    
    sumPrice = MOCreateLabelAutoRTL();
    sumPrice.font = MOLightFont(18);
    sumPrice.textColor = MOColorSaleFontColor();
    sumPrice.backgroundColor = [UIColor clearColor];
    sumPrice.text = @"0";
    [paymentView addSubview:sumPrice];
    
    offSumPrice = [[LPLabel alloc] init];
    offSumPrice.font = MOLightFont(14);
    offSumPrice.textColor = [UIColor grayColor];
    offSumPrice.backgroundColor = [UIColor clearColor];
    [paymentView addSubview:offSumPrice];
    offSumPrice.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
}

//- (void)checkQuantity:(int)section
//{
//    NSMutableDictionary *dict = [[GDPublicManager instance].cartsItem objectAtIndex:section];
//    
//    if (dict!=nil)
//    {
//        NSArray* orderArrar = dict[@"Items"];
//        
//        [GDOrderCheck instance].target = self;
//        [GDOrderCheck instance].callback = @selector(goCheckout:);
//        [[GDOrderCheck instance] checkVaild:orderArrar withReturn:section];
//        
//    }
//}

- (void)goCheckout:(int)section
{
    //check login infomation
    if ([GDPublicManager instance].cid>0)
    {
        if ([GDPublicManager instance].cartsItem.count>section)
        {
            NSMutableDictionary *dict = [[GDPublicManager instance].cartsItem objectAtIndex:section];
            if (dict!=nil)
            {
                int vendor_id = [dict[@"vendor_id"] intValue];
                NSArray* orderArrar = dict[@"Items"];
            
                int  membership_level = 0;
                if (orderArrar.count>0)
                {
                    NSMutableDictionary* obj = [orderArrar objectAtIndex:0];
                    membership_level  = [obj[@"membership_level"] intValue];
                }
                
//                if (membership_level == MEMBER_SHOPPING)
//                {
//                    GDShopDeliveryOrderViewController* vc = [[GDShopDeliveryOrderViewController alloc] init:orderArrar withDeliveryFee:0];
//                    vc.superNav = self.navigationController;
//                    vc.vendorId = vendor_id;
//                    [self.navigationController pushViewController:vc animated:YES];
//                }
//                else
//                {
                    BOOL isFree = [[GDPublicManager instance] nonMemberFree:orderArrar];
                    if (!isFree)
                    {
                        //check member rank
                        isFree = [[GDPublicManager instance] isVaildFreeBuy:membership_level withNote:NO];
                    }

                    GDMakeOrderViewController* vc = [[GDMakeOrderViewController alloc] init:orderArrar withPrice:isFree withLevel:membership_level];
                    vc.superNav = self.navigationController;
                    vc.vendorId = vendor_id;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
  //      }
    }
    else
    {
        [UIActionSheet showInView:self.view
                        withTitle:NSLocalizedString(@"Please login first and check out", @"您还没有登录,请先登录再购买")
                cancelButtonTitle:NSLocalizedString(@"Cancel",@"取消")
           destructiveButtonTitle:nil
                otherButtonTitles:@[NSLocalizedString(@"Login", @"登录"), NSLocalizedString(@"Sign Up", @"注册")]
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                             if (buttonIndex==0)
                             {
                                 GDLoginViewController* vc = [[GDLoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
                                 
                                 UINavigationController *nc = [[UINavigationController alloc]
                                                               initWithRootViewController:vc];
                                 
                                 [self presentViewController:nc animated:YES completion:^(void) {}];
                             }
                             else if (buttonIndex==1)
                             {
                                 GDRegsiterViewController* vc = [[GDRegsiterViewController alloc] initWithStyle:UITableViewStyleGrouped];
                                 UINavigationController *nc = [[UINavigationController alloc]
                                                               initWithRootViewController:vc];
                                 
                                 [self presentViewController:nc animated:YES completion:^(void) {}];
                             }
                         }];
        
    }
}

- (void)checkTap:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    int selectedIndex = (int)button.tag;
    [self goCheckout:selectedIndex];
    //[self checkQuantity:selectedIndex];

}

- (void)showCartCountdown:(BOOL)reset
{
    if ([GDPublicManager instance].countDownPay.superview!=nil)
        [[GDPublicManager instance].countDownPay removeFromSuperview];
    
    if ([GDPublicManager instance].cartsItem.count>0 )
    {
        
        [GDPublicManager instance].countDownPay.frame = CGRectMake(240, yMargin, 70, 30);
        [paymentView addSubview:[GDPublicManager instance].countDownPay];
        
        [GDPublicManager instance].countDownPay.timeLabel.textColor = [UIColor redColor];
        
        if (reset && [GDPublicManager instance].defaultCount>0)
        {
            [[GDPublicManager instance].countDownPay reset];
            
            [[GDPublicManager instance].countDownPay setCountDownTime:[GDPublicManager instance].defaultCount*60];
            
            [[GDPublicManager instance].countDownPay start];
        }
        else
        {
            NSTimeInterval sub = -[[GDSettingManager instance].nLastAddToCartDate timeIntervalSinceNow];
            if (sub<=[GDPublicManager instance].defaultCount*60)
            {
                //default value from DB
                [[GDPublicManager instance].countDownPay reset];
            
                [[GDPublicManager instance].countDownPay setCountDownTime:[GDPublicManager instance].defaultCount*60-sub];
            
                [[GDPublicManager instance].countDownPay start];
            }
        }
    }
}

#pragma mark - Data
- (void)deleteVendor:(NSNotification *)notification
{
    NSDictionary* dict=notification.object;
    int verdorId= [dict[@"verdorId"] intValue];
    //delete category
    @synchronized([GDPublicManager instance].cartsItem)
    {
        [[GDPublicManager instance] deleteVendor:verdorId];
//        if (section<[GDPublicManager instance].cartsItem.count)
//            [[GDPublicManager instance].cartsItem removeObjectAtIndex:section];
    }
    
    [self setCartCount];
}

- (void)cartsSectionsForDel:(NSIndexPath*)indexPath
{
    NSMutableDictionary * dict = [[GDPublicManager instance].cartsItem objectAtIndex:indexPath.section];
    if (dict!=nil)
    {
        NSMutableArray* tempArrar = dict[@"Items"];
        @synchronized(tempArrar)
        {
            [tempArrar removeObjectAtIndex:indexPath.row];
            if (tempArrar.count<=0)
            {
                //delete category
                @synchronized([GDPublicManager instance].cartsItem)
                {
                    [[GDPublicManager instance].cartsItem removeObjectAtIndex:indexPath.section];
                }
            }
        }
    }
}

- (void)cartsSectionsForAdd:(NSDictionary*)newDict
{
    NSMutableDictionary *muNewDict=[newDict mutableCopy];
    
    int new_vendor_id = [newDict[@"vendor_id"] intValue];
    
    for (NSMutableDictionary* dict in [GDPublicManager instance].cartsItem)
    {
        //check option_value_id and product_id the same
        int vendor_id = [dict[@"vendor_id"] intValue];
       
        if (new_vendor_id == vendor_id)
        {
            NSMutableArray* tempArrar = dict[@"Items"];
            [tempArrar addObject:muNewDict];
            
            [dict setObject:tempArrar forKey:@"Items"];
    
            return;
        }
    }
    
    NSString* vendor_name = newDict[@"vendor_name"];
    
    NSMutableArray *mutableArrars = [[NSMutableArray alloc] init];
    [mutableArrars addObject:muNewDict];
    
    NSMutableDictionary* mutableDict = [[NSMutableDictionary alloc] init];
    [mutableDict setObject:@(new_vendor_id) forKey:@"vendor_id"];
    [mutableDict setObject:vendor_name forKey:@"vendor_name"];
    [mutableDict setObject:mutableArrars forKey:@"Items"];
    
    [[GDPublicManager instance].cartsItem addObject:mutableDict];
}

#pragma mark - View

- (UIView *)noDataView
{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 320)];
        int offsety = (([UIScreen mainScreen].bounds.size.height - _noDataView.frame.size.height) / 2.0);
        
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height / 2.0-200, self.view.bounds.size.width, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"Your shopping cart is empty!", @"亲,您的购物车还是空的!");
        
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        
        label.font = MOLightFont(14);
        [_noDataView addSubview:label];
        
        UIImageView *imgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cart_empty.png"]];
        imgV.center = CGPointMake(self.view.frame.size.width / 2.0, 10 + offsety);
        [_noDataView addSubview:imgV];
        
    }
    return _noDataView;
}

- (void)reCaluPrice
{
    float sprice = 0.0;
    float oprice = 0.0;
    int order_qty = 0;
   
    for (NSDictionary* dict in [GDPublicManager instance].cartsItem)
    {
        NSArray* tempArrar = dict[@"Items"];
        for (NSDictionary* obj in tempArrar)
        {
            order_qty  = [obj[@"order_qty"] intValue];
            sprice += [obj[@"sprice"] floatValue]*order_qty;
            oprice += [obj[@"oprice"] floatValue]*order_qty;
        }
    }
    
    sumPrice.text = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, (int)sprice];
    offSumPrice.text = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, (int)oprice];
    
    NSRange reage = NSMakeRange(0,[GDPublicManager instance].currency.length);
    UIFont *smallFont = MOLightFont(12);
    [sumPrice setFont:smallFont range:reage];
    [offSumPrice setFont:smallFont range:reage];
  
    float sumWidth = 0;
    
    CGSize titleSize = [textPrice.text moSizeWithFont:textPrice.font withWidth:100*[GDPublicManager instance].screenScale];
    textPrice.frame = CGRectMake(xMargin+sumWidth, xMargin, titleSize.width, 20);
  
    sumWidth+=titleSize.width;
    UIFont* titleFont = MOBlodFont(20);
    titleSize = [sumPrice.text moSizeWithFont:titleFont withWidth:100];
    sumPrice.frame = CGRectMake(xMargin+sumWidth, xMargin, titleSize.width, 20);
    sumWidth+=titleSize.width;
    
    titleFont = MOLightFont(14);
    titleSize = [offSumPrice.text moSizeWithFont:titleFont withWidth:100];
    offSumPrice.frame = CGRectMake(xMargin+sumWidth, xMargin+3, titleSize.width, titleSize.height);

}

- (void)getProductData //以后和网站同步会用到
{
}

- (void)reLoadView
{
    [mainTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!isLoadData)
    {
        //[self getProductData];
        isLoadData = YES;
    }
    
    [self showCartCountdown:NO];
    [self setCartCount];
    [self reCaluPrice];
    
    [self reLoadView];
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"listCell";
    
    GDCartsListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GDCartsListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSMutableDictionary *dict = [[GDPublicManager instance].cartsItem objectAtIndex:indexPath.section];
    if (dict!=nil)
    {
        NSArray* tempArrar = dict[@"Items"];
        NSDictionary* obj = [tempArrar objectAtIndex:indexPath.row];
        if (obj!=nil)
        {
            NSString* title_name;
            int option_value_id = [obj[@"option_value_id"] intValue];
            if (option_value_id>0)
            {
                title_name = [NSString stringWithFormat:@"%@ (%@)",obj[@"name"],obj[@"option_value_name"]];
            }
            else
            {
                title_name = obj[@"name"];
            }
            
            int oprice = [obj[@"oprice"] intValue];
            int sprice = [obj[@"sprice"] intValue];
            int setprice = [obj[@"setsale"] intValue];
            
            NSString*  imgUrl =  obj[@"image"];

            [cell.productImage sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                             placeholderImage:[UIImage imageNamed:@"carts_default.png"]];
    
            [[GDSettingManager instance] setTitleAttr:cell.titleLabel withTitle:title_name withSale:setprice withOrigin:oprice];
    
            cell.originPrice.text = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, oprice];
            cell.salePrice.text = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, sprice];
    
            int order_qty = [obj[@"order_qty"] intValue];
            cell.subLabel.text = [NSString stringWithFormat:@"Subtotal:%@%d",[GDPublicManager instance].currency, sprice * order_qty ];

            cell.qtyLabel.text = [NSString stringWithFormat:@"%d",order_qty];

            [cell.deleteBut addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];

            [cell.subtractionBut addTarget:self action:@selector(subtractionItem:) forControlEvents:UIControlEventTouchUpInside];
    
            [cell.addBut addTarget:self action:@selector(addItem:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.discount.text = @"";

        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([GDPublicManager instance].cartsItem.count>0)
        return 40;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ([GDPublicManager instance].cartsItem.count>0)
    {
        NSString* vendor_name=@"";
        NSMutableDictionary *dict = [[GDPublicManager instance].cartsItem objectAtIndex:section];
        if (dict!=nil)
        {
            vendor_name = dict[@"vendor_name"];
        }
    
        CGRect r =self.view.bounds;
        UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, 0, r.size.width, 40)];
        hView.backgroundColor =[UIColor whiteColor];
    
        ACPButton *checkBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        checkBut.frame = CGRectMake(220*[GDPublicManager instance].screenScale, 4, 90*[GDPublicManager instance].screenScale, 32);
        [checkBut setStyleRedButton];
        [checkBut setCornerRadius:3];
        checkBut.tag = section;
        [checkBut setTitle: NSLocalizedString(@"Check Out", @"结算") forState:UIControlStateNormal];
    
        checkBut.tag = section;
        [checkBut addTarget:self action:@selector(checkTap:) forControlEvents:UIControlEventTouchUpInside];
        [hView addSubview:checkBut];
    
        UIImageView* backgroundView = [[UIImageView alloc] init];
        backgroundView.image = [[UIImage imageNamed:@"productLline.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        backgroundView.frame= CGRectMake(r.origin.x, 39.5,
                                     r.size.width, 0.5);
        [hView addSubview:backgroundView];
    
        UILabel          *cellPrice;
        //LPLabel          *cellOriginPrice;
        
        cellPrice = MOCreateLabelAutoRTL();
        cellPrice.font = MOLightFont(14);
        cellPrice.textColor = MOColorSaleFontColor();
        cellPrice.backgroundColor = [UIColor clearColor];
        cellPrice.text = @"0";
       
//        cellOriginPrice = [[LPLabel alloc] init];
//        cellOriginPrice.font = MOLightFont(14);
//        cellOriginPrice.textColor = [UIColor grayColor];
//        cellOriginPrice.backgroundColor = [UIColor clearColor];
//        cellOriginPrice.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
//        
        int sprice = 0;
        int oprice = 0;
        int order_qty = 0;
        
        NSArray* tempArrar = dict[@"Items"];
        for (NSDictionary* obj in tempArrar)
        {
            order_qty  = [obj[@"order_qty"] intValue];
            sprice += [obj[@"sprice"] intValue]*order_qty;
            oprice += [obj[@"oprice"] intValue]*order_qty;
        }
        
        cellPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Total:%@%d",@"总价:%@%d"),[GDPublicManager instance].currency, sprice];

        cellPrice.frame = CGRectMake(xMargin, xMargin, 110*[GDPublicManager instance].screenScale, 20);
        //cellOriginPrice.frame = CGRectMake(xMargin*2+cellPrice.frame.size.width, xMargin, 80*[GDPublicManager instance].screenScale, 20);
        
        [cellPrice findCurrency:CurrencyFontSize];
        //[cellOriginPrice findCurrency:CurrencyFontSize];
        
        [hView addSubview:cellPrice];
        //[hView addSubview:cellOriginPrice];
        
        MODebugLayer(cellPrice, 1.f, [UIColor redColor].CGColor);
        //MODebugLayer(cellOriginPrice, 1.f, [UIColor redColor].CGColor);

        if ([GDSettingManager instance].isRightToLeft)
        {
            CGRect tempRect = checkBut.frame;
            tempRect.origin.x = xMargin;
            checkBut.frame = tempRect;
            
            tempRect = cellPrice.frame;
            tempRect.origin.x = r.size.width - tempRect.size.width - xMargin;
            cellPrice.frame = tempRect;
            
//            tempRect = cellOriginPrice.frame;
//            tempRect.origin.x = cellPrice.frame.origin.x - tempRect.size.width - xMargin*2;
//            cellOriginPrice.frame = tempRect;
        }
        return hView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([GDPublicManager instance].cartsItem.count>0)
        return 40;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([GDPublicManager instance].cartsItem.count>0)
    {
    NSString* vendor_name=@"";
    NSMutableDictionary *dict = [[GDPublicManager instance].cartsItem objectAtIndex:section];
    if (dict!=nil)
    {
        vendor_name = dict[@"vendor_name"];
    }
    
    UILabel* titleLabel = MOCreateLabelAutoRTL();
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font =  MOBlodFont(14);
    titleLabel.text = vendor_name;
    
    CGRect r =self.view.bounds;
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, 0, r.size.width, 40)];
    titleLabel.frame = CGRectMake(r.origin.x+15, 0, r.size.width-30, 40);
    hView.backgroundColor = MOSectionBackgroundColor();
    
    [hView addSubview:titleLabel];
    return hView;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([GDPublicManager instance].cartsItem.count<=0)
    {
        [mainTableView insertSubview:[self noDataView] atIndex:0];
    
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        
        [paymentView removeFromSuperview];
    }
    
    if ([GDPublicManager instance].cartsItem.count>0)
    {
        [_noDataView removeFromSuperview];
        
        [self.view addSubview:paymentView];
        
        mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }

    return [GDPublicManager instance].cartsItem.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
     NSMutableDictionary *dict = [[GDPublicManager instance].cartsItem objectAtIndex:section];
     if (dict!=nil)
     {
         NSArray* tempArrar = dict[@"Items"];
         return tempArrar.count;
     }
     return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 127;
    //return 107*[GDPublicManager instance].screenScale;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *dict = [[GDPublicManager instance].cartsItem objectAtIndex:indexPath.section];
    if (dict!=nil)
    {
        NSArray* tempArrar = dict[@"Items"];
        NSDictionary* obj = [tempArrar objectAtIndex:indexPath.row];
        if (obj!=nil)
        {
            int productId = [obj[@"product_id"] intValue];
            NSString* type=@"";
            SET_IF_NOT_NULL(type, obj[@"type"]);
            
            UIViewController *viewController = [[GDProductDetailsViewController alloc] init:productId withOrder:YES];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

#pragma mark - cellAction

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if (flag) {
        [imageViewForAnimation removeFromSuperview];
        [self showCartCountdown:YES];
        [self setCartCount];
        [self reCaluPrice];
    }
}

- (void)makeAnimation:(CGPoint)buttonPosition withImage:(NSString*)imgUrl
{
    if ([GDSettingManager instance].isRightToLeft)
        buttonPosition.x = self.view.frame.size.width-10-107;
    else
        buttonPosition.x = 10;
  
    buttonPosition.y -=50;
    
    LOG(@"%f,%f",buttonPosition.x,buttonPosition.y);
    
    if (imageViewForAnimation==nil)
    {
        imageViewForAnimation = [[UIImageView alloc] init];
    }
    imageViewForAnimation.frame=CGRectMake(buttonPosition.x, buttonPosition.y, 107, 80);
    [imageViewForAnimation sd_setImageWithURL:[NSURL URLWithString:[imgUrl encodeUTF]]
                             placeholderImage:[UIImage imageNamed:@"beauty_default.png"]];
    
    imageViewForAnimation.alpha = 1.0f;
    CGRect imageFrame = imageViewForAnimation.frame;
    //Your image frame.origin from where the animation need to get start
    CGPoint viewOrigin = imageViewForAnimation.frame.origin;
    viewOrigin.y = viewOrigin.y + imageFrame.size.height / 4.0f;
    viewOrigin.x = viewOrigin.x + imageFrame.size.width / 4.0f;
    
    imageViewForAnimation.frame = imageFrame;
    imageViewForAnimation.layer.position = viewOrigin;
    [self.view addSubview:imageViewForAnimation];
    
    // Set up fade out effect
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeOutAnimation setToValue:[NSNumber numberWithFloat:0.3]];
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.removedOnCompletion = NO;
    
    // Set up scaling
    CABasicAnimation *resizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    [resizeAnimation setToValue:[NSValue valueWithCGSize:CGSizeMake(10.0f, 10.0f)]];
    resizeAnimation.fillMode = kCAFillModeForwards;
    resizeAnimation.removedOnCompletion = NO;
    
    // Set up path movement
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    //Setting Endpoint of the animation
    CGPoint endPoint;
    CGRect r = self.view.frame;
    if ([GDSettingManager instance].isRightToLeft)
        endPoint = CGPointMake(90, r.size.height);
    else
        endPoint = CGPointMake(240, r.size.height);
    pathAnimation.delegate = self;
    //to end animation in last tab use
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, viewOrigin.x, viewOrigin.y);
    CGPathAddCurveToPoint(curvedPath, NULL, endPoint.x, viewOrigin.y, endPoint.x, viewOrigin.y, endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setAnimations:[NSArray arrayWithObjects:fadeOutAnimation, pathAnimation, resizeAnimation, nil]];
    group.duration = 1.0f;
    group.delegate = self;
    [group setValue:imageViewForAnimation forKey:@"imageViewBeingAnimated"];
    
    [imageViewForAnimation.layer addAnimation:group forKey:@"savingAnimation"];
}

-(void)subtractionItem:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:mainTableView];
    NSIndexPath *indexPath = [mainTableView indexPathForRowAtPoint:buttonPosition];

    GDCartsListCell *cell = (GDCartsListCell*)[mainTableView cellForRowAtIndexPath:indexPath];
    
    int qty = [cell.qtyLabel.text intValue];
    if (qty>1)
    {
        qty--;
        cell.qtyLabel.text = [NSString stringWithFormat:@"%d",qty];
    
        NSMutableDictionary* dict = [[GDPublicManager instance].cartsItem objectAtIndex:indexPath.section];
        if (dict!=nil)
        {
            NSArray* tempArrar = dict[@"Items"];
            NSMutableDictionary* obj = [tempArrar objectAtIndex:indexPath.row];
                
            int temp_order_qty  = [obj[@"order_qty"] intValue]-1;
            [obj setObject:@(temp_order_qty) forKey:@"order_qty"];
            
            //update carts db
            int option_value_id = [obj[@"option_value_id"] intValue];
            int product_id      = [obj[@"product_id"] intValue];
            
            [[WCDatabaseManager instance] updateCartQty:temp_order_qty withID:product_id withOption:option_value_id];
        }
        [self setCartCount];
        [self reCaluPrice];
        [self reLoadView];
    }
}

-(void)addItem:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:mainTableView];
    CGPoint aniPosition = [sender convertPoint:CGPointZero
                                           toView:self.view];
    NSIndexPath *indexPath = [mainTableView indexPathForRowAtPoint:buttonPosition];
    
    GDCartsListCell *cell = (GDCartsListCell*)[mainTableView cellForRowAtIndexPath:indexPath];
    
    int qty = [cell.qtyLabel.text intValue];
    
//    if (qty>0 && [[GDPublicManager instance] isMember])
//    {
//        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
//message:NSLocalizedString(@"The Member only buy one coupon at one time\n, you can continue to buy After used", @"会员一次只能购买一张券, 使用完后可以继续购买!")
//                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                 otherButtonTitles:nil
//                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                              if (buttonIndex == [alertView cancelButtonIndex]) {
//                                  
//                              }
//                          }];
//    }
//    else
//    {
    
        NSMutableDictionary* dict = [[GDPublicManager instance].cartsItem objectAtIndex:indexPath.section];
        if (dict!=nil)
        {
            NSArray* tempArrar = dict[@"Items"];
            NSMutableDictionary* obj = [tempArrar objectAtIndex:indexPath.row];
        
            int  product_qty     = [obj[@"product_qty"] intValue];
            //int  option_quantity = [obj[@"option_quantity"] intValue];
            int  option_value_id = [obj[@"option_value_id"] intValue];
            int  order_qty       = [obj[@"order_qty"] intValue];
            int  order_maximum    = [obj[@"maximum"] intValue];
            
            if (qty<order_maximum)
            {
                BOOL canBeAdd = NO;
        
                if (option_value_id>0)
                {
                    if (product_qty>=order_qty+1)
                        canBeAdd = YES;
                }
                else
                {
                    if (product_qty>=order_qty+1)
                        canBeAdd = YES;
                }
        
                if (canBeAdd)
                {
                    qty++;
                    cell.qtyLabel.text = [NSString stringWithFormat:@"%d",qty];
    
                    int temp_order_qty  = order_qty+1;
                    [obj setObject:@(temp_order_qty) forKey:@"order_qty"];
        
                    //update carts db
                    int option_value_id = [obj[@"option_value_id"] intValue];
                    int product_id      = [obj[@"product_id"] intValue];
        
                    [[WCDatabaseManager instance] updateCartQty:temp_order_qty withID:product_id    withOption:option_value_id];
        
                    NSString*  imgUrl =    obj[@"image"];
                    [self makeAnimation:aniPosition withImage:imgUrl];
        
                    [[GDSettingManager instance] setLastAddToCartDate];
        
                    mainTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,mainTableView.bounds.size.width, 1)];
        
                    [self reLoadView];
                }
                else
                {
                    [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                                message:NSLocalizedString(@"Oops,Over inventory", @"超过库存数量!")
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      
                                  }
                              }];

                }
            }
            else
            {
                [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                                   message:[NSString stringWithFormat:NSLocalizedString(@"Oops, Every one only buy %d pieces", @"每人最多购买 %d 张!"),order_maximum]
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      if (buttonIndex == [alertView cancelButtonIndex]) {
                                          
                                      }
                                  }];
            }
        }
  //  }
}

-(void)deleteItem:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:mainTableView];
    NSIndexPath *indexPath = [mainTableView indexPathForRowAtPoint:buttonPosition];
    
    [UIAlertView showWithTitle:nil
                       message:NSLocalizedString(@"Are you sure to delete this product?", @"您确定要删除此商品吗?")
             cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
             otherButtonTitles:@[NSLocalizedString(@"OK", @"确定")]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == 0){
                              
                          }
                          else if (buttonIndex ==1) {
                
                                  NSDictionary * dict = [[GDPublicManager instance].cartsItem objectAtIndex:indexPath.section];
                                  if (dict!=nil)
                                  {
                                      NSArray* tempArrar = dict[@"Items"];
                                      NSMutableDictionary* obj = [tempArrar objectAtIndex:indexPath.row];
                                      
                                      int proId = [obj[@"product_id"] intValue];
                                      int option_value_id = [obj[@"option_value_id"] intValue];
                                      [[WCDatabaseManager instance] deleteCart:proId withOption:option_value_id];
                                  
                                  
                                      [self cartsSectionsForDel:indexPath];
                                  
                                      [self setCartCount];
                                      [self reCaluPrice];
                                      
                                      [self reLoadView];
                                  }
                          }
                      }];
}

@end
