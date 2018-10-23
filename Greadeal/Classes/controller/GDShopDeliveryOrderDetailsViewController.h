//
//  GDShopDeliveryOrderDetailsViewController.h
//  Greadeal
//
//  Created by Elsa on 16/2/21.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDShopDeliveryOrderDetailsViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSDictionary     *orderData;
    NSString         *order_id;
    
    NSMutableArray   *deliverData;
    
    UIView		     *_noDetailsView;
}

- (id)init:(NSDictionary*)aObj;
- (id)initWithOrderId:(NSString*)orderId;

@end
