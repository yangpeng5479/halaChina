// RDVSecondViewController.h
// RDVTabBarController
//
// Copyright (c) 2013 Robert Dimitrov
//

#import <UIKit/UIKit.h>
#import "GDBaseTableViewController.h"
#import "JCTopic.h"

@interface GDSuperViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate,JCTopicDelegate>
{
    BOOL             isLoadData;
    
    NSMutableArray   *productData;
    NSMutableArray   *marketData;
    NSMutableArray   *bannerData;
    
    JCTopic          *bannerView;
    
    int              seekPage;
    int              lastCountFromServer;

    UIView           *_noMarketView;
    UIView           *_noSelectView;
    BOOL             popChooseAddress;
}
@end
