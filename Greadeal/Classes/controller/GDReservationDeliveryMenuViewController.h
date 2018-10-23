//
//  GDReservationDeliveryMenuViewController.h
//  Greadeal
//
//  Created by Elsa on 16/2/18.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDReservationDeliveryMenuViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

{
    UITableView      *leftTablew;
    UITableView      *rightTableView;
    
    NSMutableArray   *leftData;
    NSMutableArray   *rightData;
    
    int              selectIndex;
    
    BOOL             isLoadData;
    BOOL             haveImageCell;
    
    UIView           *cartsView;
    UIButton         *cartsBut;
    
    UILabel          *subTotalLabel;
    UILabel          *deliveryChargeLabel;
    
    UILabel          *totalSingular;
    UIButton         *buyNowBut;
    
    int              venderId;
    int              deliverFee;
    int              minCharge;
    int              discount;
    
    int              order_sum_price;
    
    BOOL isopen;
    
    NSString*        telephone;
    NSString*        vender_address;
    
}

@property (nonatomic, weak)  id superNav;
/*
 *  左边背景颜色
 */
@property(strong,nonatomic) UIColor * leftBgColor;
/*
 *  左边点中文字颜色
 */
@property(strong,nonatomic) UIColor * leftSelectColor;
/*
 *  左边点中背景颜色
 */
@property(strong,nonatomic) UIColor * leftSelectBgColor;
/*
 *  左边未点中文字颜色
 */
@property(strong,nonatomic) UIColor * leftUnSelectColor;
/*
 *  左边未点中背景颜色
 */
@property(strong,nonatomic) UIColor * leftUnSelectBgColor;
/*
 *  tablew 的分割线
 */
@property(strong,nonatomic) UIColor * leftSeparatorColor;

- (id)init:(NSDictionary*)vender_info;

@end
