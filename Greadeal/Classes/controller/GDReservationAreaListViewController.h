//
//  GDReservationAreaListViewController.h
//  Greadeal
//
//  Created by Elsa on 16/6/21.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDReservationAreaListViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray   *productData;
    
    int              seekPage;
    int              lastCountFromServer;
    
}

@end
