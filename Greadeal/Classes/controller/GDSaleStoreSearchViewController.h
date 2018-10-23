//
//  GDSaleStoreSearchViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/15.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDSaleStoreSearchViewController : GDBaseTableViewController<UISearchBarDelegate,UITableViewDelegate, UITableViewDataSource>
{
    UISearchBar *insearchBar;
    NSString    *searchStr;
    
    NSMutableArray   *productData;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    classType        selectType;
}
- (id)init:(int)atype;
@end
