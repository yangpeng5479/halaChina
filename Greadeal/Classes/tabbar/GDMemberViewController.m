//
//  GDDiscountAndStoreViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/21.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDMemberViewController.h"

#define BUTTON_WIDTH 54.0
#define BUTTON_SEGMENT_WIDTH 51.0
#define CAP_WIDTH 5.0

@interface GDMemberViewController ()

@end

@implementation GDMemberViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.title = NSLocalizedString(@"Member", @"会员");
        [self addFBEvent:@"Member"];

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    RFSegmentView* segmentView = [[RFSegmentView alloc] initWithFrame:CGRectMake(0, 0,240, 36) items:@[NSLocalizedString(@"Blue",@"蓝卡"),NSLocalizedString(@"Gold",@"金卡"),NSLocalizedString(@"Platinum",@"白金卡")]];
    segmentView.tintColor = colorFromHexString(@"999999");
    segmentView.delegate = self;
    
    self.navigationItem.titleView = segmentView;
    
    CGRect r = self.view.bounds;
    float h = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height + TABBARHEIGHT;
    r.size.height-=h;
    
    blueCardVC = [[GDMemberCardViewController alloc] init:CATEGORY_BLUE_STORE  withDrop:YES ];
    blueCardVC.view.frame = r;
    blueCardVC.superNav = self.navigationController;
 
    goldCardVC = [[GDMemberCardViewController alloc] init:CATEGORY_GOLD_STORE  withDrop:YES ];
    goldCardVC.view.frame = r;
    goldCardVC.superNav = self.navigationController;
    
    platinumCardVC = [[GDMemberCardViewController alloc] init:CATEGORY_PLATINUM_STORE  withDrop:YES ];
    platinumCardVC.view.frame = r;
    platinumCardVC.superNav = self.navigationController;
    
    isLoadData = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    if (!isLoadData)
    {
        [self.view addSubview:blueCardVC.view];
        isLoadData = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
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
            [goldCardVC.view removeFromSuperview];
            [platinumCardVC.view removeFromSuperview];
            [self.view addSubview:blueCardVC.view];
            break;
        case 1:
            [blueCardVC.view removeFromSuperview];
            [platinumCardVC.view removeFromSuperview];
            [self.view addSubview:goldCardVC.view];
            break;
        case 2:
            [blueCardVC.view removeFromSuperview];
            [goldCardVC.view removeFromSuperview];
            [self.view addSubview:platinumCardVC.view];
            break;
        default:
            break;
    }
}

@end
