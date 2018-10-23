//
//  GDMarketFindVendorProductViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/25.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"
#import "LXActivity.h"
#import <MessageUI/MessageUI.h>

@interface GDMarketFindVendorProductViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate,MFMailComposeViewControllerDelegate,LXActivityDelegate>
{
    NSMutableArray   *productList;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    int              vendorId;
    NSString         *vendorName;
    NSString         *vendorUrl;
    NSString         *vendorImage;
}

- (id)init:(int)vendor_id withName:(NSString*)vendor_name withUrl:(NSString*)vendor_url withImage:(NSString*)vendor_image;


@end
