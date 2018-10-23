//
//  GDNewDealsViewController.h
//  Greadeal
//
//  Created by Elsa on 15/10/11.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDNewDealsViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray   *productData;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
}
@end
