// RDVThirdViewController.h
// RDVTabBarController
//
// Copyright (c) 2013 Robert Dimitrov

#import <UIKit/UIKit.h>
#import "JCTopic.h"
#import "GDBaseTableViewController.h"
#import "UIOperationADView.h"

@interface GDLiveViewController : GDBaseTableViewController<JCTopicDelegate,UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>
{
    BOOL             isLoadData;
    
    UIButton         *countryBut;
    
    NSMutableArray   *alsoLikeData;
    NSMutableArray   *newDealsData;
    
    int              seekPage;
    
    JCTopic          *bannerView;
    NSMutableArray   *bannerData;
    
    UIScrollView     *hotCategoryView;
    UIPageControl    *hotCategoryPageControl;
    NSMutableArray   *hotCategoryData;
 
    UIOperationADView *operationView;
    
    NSMutableArray   *event_banners;
    
    int              kCategorySection;
    int              kOperationSection;
    int              kNewSection;
    int              kLikeSection;
}

@end

