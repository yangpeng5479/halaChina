//
//  MyVouchersListViewController.h
//  Greadeal
//
//  Created by Elsa on 15/10/17.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"
#import "LXActivity.h"
#import <MessageUI/MessageUI.h>

@interface GDMyVouchersListViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,LXActivityDelegate,MFMailComposeViewControllerDelegate>
{
    NSMutableArray   *coupon_lists;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    UIView		     *_noOrderView;
    
    vourchersSearchType  vourchersType;
    
    NSMutableDictionary *shareData;
}

@property (nonatomic, weak)  id superNav;

- (id)init:(vourchersSearchType)atype;

@end
