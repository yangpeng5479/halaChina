//
//  GDSaleProductSearchViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/15.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "TMQuiltViewController.h"

@interface GDSaleProductSearchViewController : TMQuiltViewController<UISearchBarDelegate>
{
    UISearchBar      *insearchBar;
    NSString         *searchStr;
    
    NSMutableArray   *productData;
    int              seekPage;
    int              lastCountFromServer;
   
    BOOL             isLoadData;
}
@end
