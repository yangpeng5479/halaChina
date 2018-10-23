//
//  GDDeliverySearchViewController.h
//  Greadeal
//
//  Created by Elsa on 16/5/5.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDDeliverySearchViewController : GDBaseTableViewController<UISearchBarDelegate,UITableViewDelegate, UITableViewDataSource>
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
