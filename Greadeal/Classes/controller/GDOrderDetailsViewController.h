//
//  GDOrderDetailsViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/6.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"
#import "LXActivity.h"
#import <MessageUI/MessageUI.h>

@interface GDOrderDetailsViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,LXActivityDelegate,MFMailComposeViewControllerDelegate>
{
    NSDictionary     *orderData;
    NSString         *order_id;
    
    NSMutableArray   *deliverData;
    NSMutableArray   *coupon_lists;
    
    UIView		     *_noDetailsView;
    
    NSMutableDictionary *shareData;
}

- (id)init:(NSDictionary*)aObj;
- (id)initWithOrderId:(NSString*)orderId;

@end
