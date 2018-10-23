//
//  GDReservationDeliveryListViewController.h
//  Greadeal
//
//  Created by Elsa on 16/2/18.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDReservationDeliveryListViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray   *productData;
    NSMutableArray   *timesData;
    
    int              seekPage;
    int              lastCountFromServer;
}

@property (nonatomic, strong)  NSArray *sorts;

- (id)init:(NSString*)title withTimes:(NSArray*)timesList;

@end
