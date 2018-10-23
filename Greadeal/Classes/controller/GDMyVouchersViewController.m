//
//  GDVourchsViewController.m
//  Greadeal
//
//  Created by Elsa on 15/10/17.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "GDMyVouchersViewController.h"
#import "RDVTabBarController.h"
#import "GDMyVouchersListViewController.h"
#import "UIActionSheet+Blocks.h"

@interface GDMyVouchersViewController ()

@end

@implementation GDMyVouchersViewController

- (id)init
{
    self = [super init];
    if (self) {
        indexCount = 3;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    
    self.title = NSLocalizedString(@"All Coupons", @"全部优惠券");
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
   
    UIBarButtonItem*  buyButItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Language", @"语言") style:UIBarButtonItemStylePlain
                                                                   target:self action:@selector(tapSwicth)];
    self.navigationItem.rightBarButtonItem = buyButItem;
   
    
    [super viewDidLoad];
}

- (void)tapSwicth
{
    [UIActionSheet showInView:self.view
                    withTitle:NSLocalizedString(@"Language", @"语言")
            cancelButtonTitle:NSLocalizedString(@"Cancel",@"取消")
       destructiveButtonTitle:nil
            otherButtonTitles:@[NSLocalizedString(@"English", @"英文"), NSLocalizedString(@"Chinese", @"中文")]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                         
                         if (buttonIndex == 0)
                             [GDSettingManager instance].switchLanguage = 1;
                         else
                             [GDSettingManager instance].switchLanguage = 3;
                         
                         //refresh
                         if (buttonIndex!=2)
                         {
                             [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSwitchLanagues object:nil userInfo:nil];
                         }
                     }];
    

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
            label.text = NSLocalizedString(@"All Coupons", @"全部优惠券");
            break;
        case 1:
            label.text = NSLocalizedString(@"Unuse", @"未使用");
            break;
        case 2:
            label.text = NSLocalizedString(@"Used", @"已使用");
            break;
        default:
            break;
    }
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = MOColor66Color();
    [label sizeToFit];
    
    CGSize titleSize = [label.text moSizeWithFont:label.font withWidth:220];
    label.tag = (int)titleSize.width+56;
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
            GDMyVouchersListViewController* cvc = [[GDMyVouchersListViewController alloc] init:VOUCHERS_ALL];
            cvc.superNav = self.navigationController;
            return cvc;
        }
            break;
        case 1:
        {
            GDMyVouchersListViewController* cvc = [[GDMyVouchersListViewController alloc] init:VOUCHERS_AWAITING_USE];
            cvc.superNav = self.navigationController;
            return cvc;
        }
            break;
        case 2:
        {
            GDMyVouchersListViewController* cvc = [[GDMyVouchersListViewController alloc] init:VOUCHERS_USED];
            cvc.superNav = self.navigationController;
            return cvc;
        }
            break;
        case 3:
        {
            GDMyVouchersListViewController* cvc = [[GDMyVouchersListViewController alloc] init:VOUCHERS_RETURNS];
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
