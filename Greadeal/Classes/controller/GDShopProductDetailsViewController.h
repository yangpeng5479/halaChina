//
//  GDShopProductDetailsViewController.h
//  GDShopProductDetailsViewController
//
//  Created by Robert Dimitrov on 11/8/14.
//  Copyright (c) 2014 Robert Dimitrov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OTPageScrollView.h"
#import "OTPageView.h"

#import "LXActivity.h"

#import <MessageUI/MessageUI.h>

#import "GDNoNetworkViewController.h"
#import "DJQRateView.h"

#import "SVAnnotation.h"
#import "SVPulsingAnnotationView.h"

@interface GDShopProductDetailsViewController : GDNoNetworkViewController<OTPageScrollViewDataSource,OTPageScrollViewDelegate,UITableViewDelegate, UITableViewDataSource,LXActivityDelegate,MZTimerLabelDelegate,MFMailComposeViewControllerDelegate,MKMapViewDelegate,UIWebViewDelegate>
{
     UITableView      *mainTableView;
     OTPageView       *PScrollView;
    
     UIView           *cartsView;
     UIButton         *cartsBut;
    
     NSDictionary     *dictData;
    
     NSMutableArray   *_imageArray;
     NSMutableArray   *_packageList;
     NSMutableArray   *_rateList;
    
     UILabel          *totalSingular;
     UIImageView      *imageViewForAnimation;
     DJQRateView      *rateView;
    
     BOOL             isLoadData;
    
     int              productId;
     NSString*        name;
     int              oprice;
     int              sprice;
     int              setsale;
    
     int              quantity;
     int              order_maximum;
    
     NSString*        productUrl;
    
     int              option_quantity;
     int              option_value_id;
     NSString*        option_value_name;
     NSString*        vendor_phone;
    
     NSString*        payment_info;
     UILabel          *paymentLabel;
    
     int kNameSection;
     int kVendorSection;
     int kPackageSection;
     int kHowtouseSection;
     int kHighlightsSection;
     int kMoreinfoSection;
     
     int kCuisinesSection;
     int kTagSection;
     int kRateSection;
     int kPaymentInfo;
    
     NSString         *sHighlights;
     UIWebView        *highlightsLabel;
     float            highlightHeight;
    
     NSString         *sHowtouse;
     UILabel          *howtouseLabel;
    
     NSString         *sCuisines;
     UILabel          *cuisinesLabel;
    
     NSString         *sMoreinfo;
     UILabel          *moreinfoLabel;
    
     NSMutableArray   *_tagArrays;
     NSMutableArray   *_openHours;
    
     UIButton         *subtractionBut;
     UIButton         *addBut;
     UILabel          *qtyLabel;
     int              orderQty;
    
     ACPButton        *buyNowBut;
     UILabel          *soldoutLabel;
    
     int              toolViewHeight;
    
     NSMutableIndexSet *expandedSections;
}

- (id)init:(int)product_id  withOrder:(BOOL)isView;

@end

