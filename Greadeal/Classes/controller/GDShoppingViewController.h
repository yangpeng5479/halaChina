//
//  GDShoppingViewController.h
//  Greadeal
//
//  Created by Elsa on 16/1/27.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDShoppingViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>

{
    NSMutableArray   *productData;
        
    int              seekPage;
    int              lastCountFromServer;
        
    BOOL             isLoadData;
    
    int              showtype;
}

- (id)init:(int)showType;

@end
