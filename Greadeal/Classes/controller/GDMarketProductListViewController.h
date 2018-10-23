//
//  GDMarketProductListViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/18.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDMarketProductListViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray   *productList;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    int              vendorId;
    int              categoryId;
}

- (id)init:(int)vendor_id withCategory:(int)category_id;

@end
