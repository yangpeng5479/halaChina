//
//  GDNewArrivedViewController.h
//  Greadeal
//
//  Created by Elsa on 15/8/5.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDNewArrivedViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray   *productList;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    int              vendorId;
    
}

- (id)init:(int)vendor_id;

@end
