//
//  GDMemberCardViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/14.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOPDropDownMenu.h"
#import "GDBaseTableViewController.h"

@interface GDMemberCardViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate,DOPDropDownMenuDataSource,DOPDropDownMenuDelegate>
{
    NSMutableArray   *merchantList;
    NSMutableArray   *categoryArrays;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    int              categoryId;
    BOOL             showCagetoryDrop;
    
    DOPDropDownMenu  *dropMenu;
    
    NSString         *sortChoose;
    //address show
    UILabel*         areaLabel;
    UIButton*        getAddressBut;
    UIActivityIndicatorView *activityIndicatorView;
    
    categoryType     showCategory;
}

- (id)init:(categoryType)selType withDrop:(BOOL)showDrop;

@property (nonatomic, strong)  id superNav;

@property (nonatomic, strong)  NSArray *sorts;

@end
