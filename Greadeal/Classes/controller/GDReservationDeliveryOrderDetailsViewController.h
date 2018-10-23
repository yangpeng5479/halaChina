//
//  GDReservationDeliveryOrderDetailsViewController.h
//  Greadeal
//
//  Created by Elsa on 16/2/21.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDReservationDeliveryOrderDetailsViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSDictionary     *orderData;
    NSString         *order_id;
    
    NSMutableArray   *deliverData;
    
    UIView		     *_noDetailsView;
    
    UIView           *paymentView;
    ACPButton        *reminderBut;
    
    BOOL             isReminder;
}

- (id)init:(NSDictionary*)aObj;
- (id)initWithOrderId:(NSString*)orderId;

@end
