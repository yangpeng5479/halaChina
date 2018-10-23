//
//  GDPayMemberViewController.h
//  Greadeal
//
//  Created by Elsa on 15/11/27.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"
#import "PayPalMobile.h"
#import "GDPaypal.h"
#import "AliPayment.h"
#import "GDEtisalatWebViewController.h"

@interface GDPayMemberViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,PayPalPaymentDelegate,AliPayDelegate,etisalatDelegate>
{
     NSMutableArray   *payWayInfo;
    
     UIView           *paymentView;
     NSString         *choosePayType;
    
     float            exchangeUsdRate;//AED-USD
     float            exchangeCnyRate;//AED-CNY
    
     NSString         *order_id;
    
     int              choosePay;
     int              memberRank;
     int              cardLevel;
     float            memberPrice;
}

- (id)init:(int)selectRank withPrice:(float)aPrice withLevel:(int)aLevel;

@end
