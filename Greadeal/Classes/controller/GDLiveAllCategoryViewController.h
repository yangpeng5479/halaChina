//
//  GDLiveAllCategoryViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/3.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDNoNetworkViewController.h"
#import "GDBaseTableViewController.h"

@interface GDLiveAllCategoryViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray   *categoryData;
    BOOL      isLoadData;
}


@end
