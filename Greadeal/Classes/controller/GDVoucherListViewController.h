//
//  GDVoucherListViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/6.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"
#import "PayPalMobile.h"
#import "GDPaypal.h"
#import "AliPayment.h"
#import "GDEtisalatWebViewController.h"

@interface GDVoucherListViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,PayPalPaymentDelegate,AliPayDelegate,etisalatDelegate>
{
    NSMutableArray   *orderData;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    UIView		     *_noOrderView;
    
    vourcherOrderSearchType  orderFindType;
    float      exchangeUsdRate;//AED-USD
    float      exchangeCnyRate;
    
    NSString*  order_id;
    NSString*  paying_code;
    
}

@property (nonatomic, weak)  id superNav;

- (id)init:(vourcherOrderSearchType)atype;

@end
