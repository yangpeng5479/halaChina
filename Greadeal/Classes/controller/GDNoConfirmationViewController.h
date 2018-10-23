//
//  GDNoConfirmationViewController.h
//  Greadeal
//
//  Created by Elsa on 15/7/16.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDNoConfirmationViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray   *orderData;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    UIView		     *_noReceiptView;
}


@end
