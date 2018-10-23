//
//  GDDeliveryOrderListViewController.h
//  Greadeal
//
//  Created by Elsa on 16/2/21.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDDeliveryOrderListViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray   *orderData;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    UIView		     *_noOrderView;
    
    NSString*  order_id;
  
}

@end
