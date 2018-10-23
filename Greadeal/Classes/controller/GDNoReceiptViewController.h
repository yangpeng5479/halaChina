//
//  GDNoReceiptViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/6.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDNoReceiptViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray   *orderData;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    UIView		     *_noReceiptView;
}


@end
