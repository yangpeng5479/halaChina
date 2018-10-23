//
//  GDMakeOrderViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/26.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"
#import "PayPalMobile.h"
#import "GDPaypal.h"
#import "AliPayment.h"
#import "GDEtisalatWebViewController.h"
#import "AliPayment.h"

@interface GDMakeOrderViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,PayPalPaymentDelegate,AliPayDelegate,etisalatDelegate,wechatPayDelegate>
{
    int              vendorId;
    NSString         *vendorName;
    
    NSDictionary     *receiveInfo;
    NSMutableArray   *deliverInfo;
    NSMutableArray   *payWayInfo;
    NSString         *comment;
    NSDictionary     *IdPassport;
    UIView           *paymentView;
    
    int     kAddressSection;
    int     kDeliverSection;
    int     kPaymentSection;
    int     kCommentSection;
    int     kOrdersSection;
    int     kPriceSection;
    int     kRequireID;
    
    float   sprice;
    float   deliveryFee;
    float   codFee;
    
    //choose
    float   chosseCodFee;
    int     chooseDeliver;
    int     choosePay;
    
    int     membershipLevel;
    
    ACPButton  *confirmBut;
    
    NSString   *order_id;
    NSString   *choosePayType;
    NSString   *order_type;
     
    float      exchangeUsdRate;//AED-USD
    float      exchangeCnyRate;//AED-CNY
    
    BOOL       isFree;
    BOOL       require_passport_or_idcard;
    
    NSString*  startDate;
    
    NSMutableArray* date_unavailable;
    NSString* endDate;
}

@property(nonatomic, assign) int      vendorId;
@property(nonatomic, strong) NSArray* productData;

@property (nonatomic, weak)  id superNav;

- (id)init:(NSArray*)aproductData withPrice:(BOOL)is_free withLevel:(int)membership_level;

@end
