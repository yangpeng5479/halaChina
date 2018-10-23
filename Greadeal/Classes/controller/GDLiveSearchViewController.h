//
//  GDLiveSearchViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/25.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDLiveSearchViewController : GDBaseTableViewController<UISearchBarDelegate,UITableViewDelegate, UITableViewDataSource>
{
    UISearchBar      *insearchBar;
    
    NSString         *searchStr;
    NSMutableArray   *products;
    
    NSMutableArray   *searchIndex;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    BOOL             isSearchActive;
    BOOL             isloadSearch;
    NSString         *strIndex;
    
    UIActivityIndicatorView *activityIndicatorView;
}
@end
