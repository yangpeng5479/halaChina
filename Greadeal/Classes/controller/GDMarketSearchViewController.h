//
//  GDMarketSearchViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/25.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"


@interface GDMarketSearchViewController : GDBaseTableViewController<UISearchBarDelegate,UITableViewDelegate, UITableViewDataSource>
{
    UISearchBar *insearchBar;
    
    NSMutableArray   *productList;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    int              vendorId;
    
    NSString         *searchStr;
}
- (id)init:(int)vendor_id;
@end
