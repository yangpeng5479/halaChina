//
//  GDStoreListViewController.h
//  Greadeal
//
//  Created by Elsa on 15/7/29.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDStoreListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    UITableView      *mainTableView;
    
    NSArray   *productData;
    NSArray   *indexList;
    
    BOOL             isLoadData;
    
    classType        selectType;
}
- (id)init:(int)atype;
@end
