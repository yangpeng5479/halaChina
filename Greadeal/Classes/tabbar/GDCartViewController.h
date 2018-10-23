//
//  GDCartViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/11.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACPButton.h"
#import "LPLabel.h"

@interface GDCartViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    BOOL             isLoadData;
    
    UITableView      *mainTableView;
    
    int              seekPage;
    int              lastCountFromServer;
    
    UIView           *paymentView;
    UILabel          *textPrice;
    UILabel          *sumPrice;
    LPLabel          *offSumPrice;
   
    UIView		     *_noDataView;
    
    UIImageView      *imageViewForAnimation;
}
@end
