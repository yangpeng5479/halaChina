//
//  GDLiveVendorViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/25.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBaseTableViewController.h"
#import "LXActivity.h"
#import <MessageUI/MessageUI.h>

#import "OTPageScrollView.h"
#import "OTPageView.h"

#import "DJQRateView.h"

#import "SVAnnotation.h"
#import "SVPulsingAnnotationView.h"

@interface GDLiveVendorViewController : GDBaseTableViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate,MFMailComposeViewControllerDelegate,LXActivityDelegate,OTPageScrollViewDataSource,OTPageScrollViewDelegate,MKMapViewDelegate>
{
    OTPageView       *PScrollView;
    
    NSDictionary     *vendorData;
    
    BOOL             isLoadData;
    
    int              vendorId;
    NSString         *vendorName;
    
    NSString         *vendorUrl;
    NSString         *vendorImage;
    NSString*        vendor_address;
    NSString*        vendor_phone;
    
    NSMutableArray   *_productData;
    NSMutableArray   *_imageList;
    NSMutableArray   *_menuList;
    NSMutableArray   *_rateList;
    
    int     fee_per_person;
    int     is_wish_vendor;
    
    int     kAddressSection;
    int     kFavoriteSection;
    int     kMenuSection;
    int     kProductSection;
    int     kOpenhoursSection;
    int     kCuisinesSection;
    int     kTagSection;
    int     kRateSection;
    int     kDescSection;
    
    NSString         *sCuisines;
    UILabel          *cuisinesLabel;
    
    NSString         *sDescription;
    UILabel          *_descView;
    
    NSMutableArray   *_tagArrays;
    NSMutableArray   *_openHours;
    
    DJQRateView      *rateView;
    
    NSMutableIndexSet *expandedSections;
    MKMapView *vmapView;
}

- (id)init:(int)vendor_id withName:(NSString*)vendor_name withUrl:(NSString*)vendor_url withImage:(NSString*)vendor_image;

@end
