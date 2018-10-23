//
//  GDDeliveryListViewController.h
//  Greadeal
//
//  Created by Elsa on 16/2/18.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"
#import "DOPDropDownMenu.h"

@interface GDDeliveryListViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate,DOPDropDownMenuDataSource,DOPDropDownMenuDelegate>
{
    NSMutableArray   *productData;
    
    int              seekPage;
    int              lastCountFromServer;
    
    NSString         *categoryName;
    NSMutableArray   *categoryArrays;
    DOPDropDownMenu  *dropMenu;
    NSString         *sortChoose;
    
    //address show
    UIView*          hView;
    UILabel*         areaLabel;
    UIButton*        getAddressBut;
    UIActivityIndicatorView *activityIndicatorView;
    
}

@property (nonatomic, strong)  NSArray *sorts;

@end
