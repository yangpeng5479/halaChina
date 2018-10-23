//
//  GDWishListViewController.h
//  Greadeal
//
//  Created by Elsa on 16/8/28.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDWishListViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray   *productData;
    UILabel          *titleLabel;
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    UIView		     *_emptyView;
}

@end
