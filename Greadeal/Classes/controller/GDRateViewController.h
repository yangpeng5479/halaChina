//
//  GDRateViewController.h
//  Greadeal
//
//  Created by Elsa on 15/10/15.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDRateViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray   *_rateList;
    
    int              seekPage;
    int              lastCountFromServer;
    BOOL             isLoadData;
    
    int              productId;
    int              vendorId;
    
    BOOL             isVendor;
}

- (id)initWithProduct:(int)product_id;
- (id)initWithVendor:(int)vendor_id;

@end
