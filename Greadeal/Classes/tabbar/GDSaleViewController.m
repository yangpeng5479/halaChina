// RDVFirstViewController.m
// RDVTabBarController
//

#import "GDSaleViewController.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"

#import "GDLastGrabViewController.h"
#import "GDSoonOnLineViewController.h"
#import "GDNewOnLineViewController.h"
#import "GDBeautyViewController.h"

#import "GDSaleSearchViewController.h"
//#import "KxMenu.h"

#import "GDSaleStoreSearchViewController.h"
#import "GDSaleProductSearchViewController.h"

@implementation GDSaleViewController

- (id)init
{
    self = [super init];
    if (self) {
        indexCount = 4;
        self.title = NSLocalizedString(@"Sale", @"特卖");
        [self configureImageInBar];
        }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    self.dataSource = self;
    self.delegate = self;
    
    // Keeps tab bar below navigation bar on iOS 7.0+
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UIBarButtonItem*  searchButItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Classification.png"] style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(classAction:)];
    
    self.navigationItem.leftBarButtonItem = searchButItem;
   
    UIBarButtonItem*  classButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(pushProduct)];
    self.navigationItem.rightBarButtonItem = classButton;

    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return indexCount;
}
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16.0];
    
    NSUInteger offset=indexCount-1;
    if ([GDSettingManager instance].isRightToLeft)
    {
        offset = offset-index;
    }
    else
    {
        offset = offset-(offset-index);
    }
    
    switch (offset) {
        case 0:
            label.text = NSLocalizedString(@"New IN", @"最新上线");
            break;
        case 2:
            label.text = NSLocalizedString(@"Final Clearance", @"最后疯抢");
            break;
        case 1:
            label.text = NSLocalizedString(@"Beauty", @"美妆精选");
            break;
        case 3:
            label.text = NSLocalizedString(@"Coming Soon", @"即将上线");
            break;
        default:
            break;
    }
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = colorFromHexString(@"666666");
    [label sizeToFit];
    
    CGSize titleSize = [label.text moSizeWithFont:label.font withWidth:120];
    label.tag = (int)titleSize.width+36;
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    NSUInteger offset=indexCount-1;
    if ([GDSettingManager instance].isRightToLeft)
    {
        offset = offset-index;
    }
    else
    {
        offset = offset-(offset-index);
    }
    
    switch (offset) {
        case 0:
        {
            GDNewOnLineViewController* cvc = [[GDNewOnLineViewController alloc] init:YES withBanner:YES];
            cvc.superNav = self.navigationController;
            return cvc;
        }
        break;
        case 2:
        {
            GDLastGrabViewController* cvc = [[GDLastGrabViewController alloc]init:YES withBanner:NO];
            cvc.superNav = self.navigationController;
            return cvc;
        }
        break;
        case 1:
        {
            GDBeautyViewController* cvc = [[GDBeautyViewController alloc] init];
            cvc.superNav = self.navigationController;
            return cvc;
        }
        break;
        case 3:
        {
            GDSoonOnLineViewController* cvc = [[GDSoonOnLineViewController alloc] init:YES withBanner:NO];
            cvc.superNav = self.navigationController;
            return cvc;
        }
        break;
        default:
            return nil;
    }
    return nil;
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionTabOffset:
             break;
        case ViewPagerOptionLastFromSecondTab:
            if ([GDSettingManager instance].isRightToLeft)
                return 1.0;
            else
                return 0.0;
            break;
        case ViewPagerOptionCenterCurrentTab:
            return 0.0;
            break;
        case ViewPagerOptionTabLocation:
            return 1.0;
            break;
        case ViewPagerOptionTabWidth:
        {
            return 100;
        }
            break;
        default:
            break;
    }
    
    return value;
}
- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return colorFromHexString(@"70a800");
            break;
        case ViewPagerTabsView:
            return [UIColor whiteColor];
        default:
            break;
    }
    return color;
}

- (void)classAction:(id)sender
{
    GDSaleSearchViewController *viewController = [[GDSaleSearchViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)tapSearch
{
//    NSArray *menuItems =
//    @[
//      
//      [KxMenuItem menuItem:NSLocalizedString(@"Search Sale Store", @"搜索特卖商家")
//                     image:nil
//                    target:self
//                    action:@selector(pushStore)],
//      
//      [KxMenuItem menuItem:NSLocalizedString(@"Search Sale Product", @"搜索特卖商品")
//                     image:nil
//                    target:self
//                    action:@selector(pushProduct)],
//      ];
//    
//     CGRect r = self.view.frame;
//     r.origin.x = r.size.width - 75;
//     r.origin.y=-50;
//     r.size.width = 100;
//     r.size.height = 50;
//    
//     [KxMenu showMenuInView:self.view
//                  fromRect:r
//                 menuItems:menuItems];
}

- (void)pushStore
{
    GDSaleStoreSearchViewController* nv = [[GDSaleStoreSearchViewController alloc] init:SALE];
    [self.navigationController pushViewController:nv animated:YES];
}

- (void)pushProduct
{
    GDSaleProductSearchViewController* nv = [[GDSaleProductSearchViewController alloc] init];
    [self.navigationController pushViewController:nv animated:YES];
}

@end

