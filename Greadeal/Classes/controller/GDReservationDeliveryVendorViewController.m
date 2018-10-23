//
//  GDReservationDeliveryVendorViewController.m
//  Greadeal
//
//  Created by Elsa on 16/6/3.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDReservationDeliveryVendorViewController.h"
#import "RDVTabBarController.h"

#import "GDReservationDeliveryMenuViewController.h"
#import "GDReservationDeliveryInfoViewController.h"

@interface GDReservationDeliveryVendorViewController ()

@end

@implementation GDReservationDeliveryVendorViewController

- (id)init:(NSDictionary*)vendor_info
{
    self = [super init];
    if (self) {
        indexCount = 2;
        vendorinfo = vendor_info;
        
        NSString* vendor_name = @"";
        SET_IF_NOT_NULL(vendor_name, vendor_info[@"vendor_name"]);
       
        
        self.title = vendor_name;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
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
    label.font = MOLightFont(14);
    
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
            label.text = NSLocalizedString(@"Menus",@"菜单");
            break;
        case 1:
            label.text = NSLocalizedString(@"Information", @"商家信息");
            break;
        default:
            break;
    }
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = MOColor66Color();
    [label sizeToFit];
    
    //CGSize titleSize = [label.text moSizeWithFont:label.font withWidth:220];
    label.tag = [GDPublicManager instance].screenWidth/2;
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
            GDReservationDeliveryMenuViewController *cvc = [[GDReservationDeliveryMenuViewController alloc] init:vendorinfo];
            cvc.superNav = self.navigationController;
            return cvc;
        }
            break;
        case 1:
        {
            GDReservationDeliveryInfoViewController* cvc = [[GDReservationDeliveryInfoViewController alloc] init:vendorinfo];
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
            return MOAppTextBackColor();
            break;
        case ViewPagerTabsView:
            return [UIColor whiteColor];
        default:
            break;
    }
    return color;
}


@end
