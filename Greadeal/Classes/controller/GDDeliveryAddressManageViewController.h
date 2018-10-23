//
//  GDDeliveryAddressManageViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/4.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GDBaseTableViewController.h"

@interface GDDeliveryAddressManageViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray   *productData;
    UIView		     *_noAddressView;
}

@property (assign) id  target;
@property (assign) SEL callback;

@property (nonatomic,assign) BOOL isChoose;
@property (nonatomic,assign) int  sel_address_id;

@end
