//
//  GDDiscountAndStoreViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/21.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDDiscountAndStoreViewController.h"
#import "RDVTabBarController.h"

#define BUTTON_WIDTH 54.0
#define BUTTON_SEGMENT_WIDTH 51.0
#define CAP_WIDTH 5.0

@interface GDDiscountAndStoreViewController ()

@end

@implementation GDDiscountAndStoreViewController

- (id)init:(int)categoryId
{
    self = [super init];
    if (self)
    {
        category_id  = categoryId;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    RFSegmentView* segmentView = [[RFSegmentView alloc] initWithFrame:CGRectMake(0, 0,180, 36) items:@[NSLocalizedString(@"Coupons",@"优惠券"),NSLocalizedString(@"All Stores",@"所有商家")]];
    segmentView.tintColor = MOColorSaleFontColor();
    segmentView.delegate = self;
    
    self.navigationItem.titleView = segmentView;
    
    CGRect r = self.view.bounds;
    float h = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    r.size.height-=h;
    
    discountVC = [[GDLiveDiscountViewController alloc] init:category_id  withDrop:YES isDiscount:YES];
    discountVC.view.frame = r;
    discountVC.superNav = self.navigationController;
 
    storeVC = [[GDLiveDiscountViewController alloc] init:category_id  withDrop:YES isDiscount:NO];
    storeVC.view.frame = r;
    storeVC.superNav = self.navigationController;
    
    isLoadData = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!isLoadData)
    {
        [self.view addSubview:discountVC.view];
        isLoadData = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [ProgressHUD dismiss];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark RFSegment Delegate
- (void)segmentViewSelectIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            [storeVC.view removeFromSuperview];
            [self.view addSubview:discountVC.view];
            break;
        case 1:
            [discountVC.view removeFromSuperview];
            [self.view addSubview:storeVC.view];
            break;
        default:
            break;
    }
}

@end
