//
//  GDSaleBrandViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/29.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDNoNetworkViewController.h"
@interface GDSaleBrandViewController : GDNoNetworkViewController<UITableViewDelegate, UITableViewDataSource>
{
    UITableView      *mainTableView;
    
    NSArray          *productData;
    NSArray          *indexList;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;

}
@property (nonatomic, strong)  id superNav;

@end
