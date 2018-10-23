//
//  GDBeautyViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/28.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"
#import "TMQuiltViewController.h"

@interface GDBeautyViewController : TMQuiltViewController
{
    NSMutableArray   *productData;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;

}
@property (nonatomic, weak)  id superNav;
@end
