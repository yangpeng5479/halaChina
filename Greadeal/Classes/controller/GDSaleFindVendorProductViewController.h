//
//  GDSaleFindVendorProductViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/25.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "TMQuiltViewController.h"

#import "LXActivity.h"
#import <MessageUI/MessageUI.h>

@interface GDSaleFindVendorProductViewController : TMQuiltViewController<MZTimerLabelDelegate,MFMailComposeViewControllerDelegate,LXActivityDelegate>
{
    NSMutableArray   *productData;
    UILabel          *titleLabel;
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             isLoadData;
    
    UIButton*        priceBut;
    
    int              vendorId;
    NSString         *vendorName;
    NSString         *vendorUrl;
    NSString         *vendorImage;
  
}

- (id)init:(BOOL)haveRefreshView withId:(int)vendor_id withName:(NSString*)vendor_name withUrl:(NSString*)vendor_url withImage:(NSString*)vendor_image;

@end
