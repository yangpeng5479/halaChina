//
//  GDDeliverViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/6.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDDeliverViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray   *deliverData;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    NSDictionary     *orderData;
    NSString         *order_id;
}
- (id)init:(NSDictionary*)aObj;
@end
