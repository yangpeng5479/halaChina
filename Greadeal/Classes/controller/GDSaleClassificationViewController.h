//
//  GDSaleClassificationViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/29.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDNoNetworkViewController.h"
@interface GDSaleClassificationViewController : GDNoNetworkViewController<UITableViewDelegate, UITableViewDataSource>
{
    UITableView      *mainTableView;
    BOOL             isLoadData;
    
    NSMutableArray   *productData;
    
    classType        selectType;
}
@property (nonatomic, strong)  id superNav;

- (id)init:(int)atype;

@end
