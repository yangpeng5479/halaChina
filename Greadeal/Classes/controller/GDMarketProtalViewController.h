//
//  GDMarketProtalViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/17.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCTopic.h"

@interface GDMarketProtalViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,JCTopicDelegate>
{
    UITableView      *mainTableView;
    BOOL             isLoadData;
    
    NSMutableArray   *categoryData;
    NSMutableArray   *productData;
    NSMutableArray   *newData;
    
    int              vendorId;
    
    NSMutableArray   *bannerData;
    JCTopic          *bannerView;
    
    int kSaleSection;
    int kNewSection;
    int kAllSection;
    int kCategorySection;
}

- (id)init:(int)vendor_id;

@end
