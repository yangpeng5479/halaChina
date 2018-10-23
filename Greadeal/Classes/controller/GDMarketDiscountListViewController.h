//
//  GDMarketDiscountListViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/17.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDMarketDiscountListViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray   *productList;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    int              vendorId;

}

- (id)init:(int)vendor_id;

@end
