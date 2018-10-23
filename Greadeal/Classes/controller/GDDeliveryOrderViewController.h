//
//  GDDeliveryOrderViewController.h
//  Greadeal
//
//  Created by Elsa on 16/2/19.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDDeliveryOrderViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>
{
    int              vendorId;
    NSString         *vendorName;
    
    NSDictionary     *receiveInfo;
    NSMutableArray   *payWayInfo;
    NSString         *comment;
    
    UIView           *paymentView;
    
    int     kAddressSection;
    int     kPaymentSection;
    int     kCommentSection;
    int     kOrdersSection;
    int     kPriceSection;
    
    float   sprice;
    int     deliveryFee;
    int     discount;
    float   codFee;
    
    //choose
    int     chosseCodFee;
    int     chooseDeliver;
    int     choosePay;
    
    
    ACPButton  *confirmBut;
    
    NSString   *order_id;
    NSString   *choosePayType;
    NSString   *order_type;
    
}

@property(nonatomic, assign) int      vendorId;
@property(nonatomic, strong) NSArray* productData;

@property (nonatomic, weak)  id superNav;

- (id)init:(NSArray*)aproductData withDeliveryFee:(int)delivery_Fee withDiscount:(int)acount;


@end
