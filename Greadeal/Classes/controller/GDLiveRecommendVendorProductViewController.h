//
//  GDLiveRecommendVendorProductViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/23.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"

@interface GDLiveRecommendVendorProductViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray   *productList;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    NSString*        vendor_address;
    NSString*        vendor_phone;
    NSString*        vendor_url;
    NSString*        vendor_image;
    
    NSMutableArray   *_imageList;
    
    int kAddressSection;
    int kPhotoSection;
    int kProductSection;
    
    int vendor_id;
}

- (id)init:(int)vendorId;

@end
