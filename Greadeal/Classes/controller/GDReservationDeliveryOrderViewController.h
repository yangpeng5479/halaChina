//
//  GDReservationDeliveryOrderViewController.h
//  Greadeal
//
//  Created by Elsa on 16/2/19.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"
#import "weixinAccountManage.h"
#import "AliPayment.h"

@interface GDReservationDeliveryOrderViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,wechatPayDelegate,AliPayDelegate>
{
    int              vendorId;
    NSString         *vendorName;
    
    NSMutableArray   *timeInfo;
    NSDictionary     *receiveInfo;
    NSMutableArray   *payWayInfo;
    NSString         *comment;
    
    UIView           *paymentView;
    
    int     kAddressSection;
    int     kPaymentSection;
    int     kCommentSection;
    int     kOrdersSection;
    int     kPriceSection;
    int     kTimeSection;
    
    float   sprice;
    int     deliveryFee;
    int     discount;
    float   codFee;
    
    //choose
    int     chosseCodFee;
    int     chooseDeliver;
    int     choosePay;
    int     chooseTime;
    
    
    ACPButton  *confirmBut;
    
    NSString   *order_id;
    NSString   *choosePayType;
    NSString   *order_type;
    int        timeType;
    NSString   *selectDate;
    NSString   *uuidstr;
    
    float      exchangeUsdRate;//AED-USD
    float      exchangeCnyRate;//AED-CNY
    
    
}

@property(nonatomic, assign) int      vendorId;
@property(nonatomic, strong) NSArray* productData;

@property (nonatomic, weak)  id superNav;

- (id)init:(NSArray*)aproductData withDeliveryFee:(int)delivery_Fee withDiscount:(int)acount;


@end
