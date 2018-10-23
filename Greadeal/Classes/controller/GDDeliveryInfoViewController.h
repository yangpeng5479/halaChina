//
//  GDDeliveryInfoViewController.h
//  Greadeal
//
//  Created by Elsa on 16/6/3.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDDeliveryInfoViewController : GDBaseTableViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSDictionary* venderinfo;
}
@property (nonatomic, weak)  id superNav;

- (id)init:(NSDictionary*)vender_info;

@end
