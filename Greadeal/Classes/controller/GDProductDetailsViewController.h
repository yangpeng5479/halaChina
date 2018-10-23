//
//  GDProductDetailsViewController.h
//  GDProductDetailsViewController
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

#import "YTPlayerView.h"

@interface GDProductDetailsViewController : GDNoNetworkViewController<OTPageScrollViewDataSource,OTPageScrollViewDelegate,UITableViewDelegate, UITableViewDataSource,LXActivityDelegate,MZTimerLabelDelegate,MFMailComposeViewControllerDelegate,MKMapViewDelegate,UIWebViewDelegate,YTPlayerViewDelegate>
{
     UITableView      *mainTableView;
     OTPageView       *PScrollView;
    
     UIView           *cartsView;
     UIButton         *cartsBut;
    
     NSDictionary     *dictData;
    
     NSMutableArray   *_imageArray;
     NSMutableArray   *_packageList;
     NSMutableArray   *_rateList;
    
     NSMutableArray   *_couponsList;
    
     UILabel          *totalSingular;
     UIImageView      *imageViewForAnimation;
     
     BOOL             isLoadData;
    
     int              productId;
     NSString*        name;
     int              oprice;
     int              sprice;
     int              setsale;
    
     int              quantity;
     int              order_maximum;
    
     BOOL             is_wish;
    
     NSString*        productUrl;
    
    //int              option_quantity;
     int              option_value_id;
     NSString*        option_value_name;
     NSMutableArray   *_optionArray;
     NSString         *optionName;

     NSString*        vendor_phone;
    
     int kNameSection;
     int kOptionSection;
     int kHighlightsSection;
     int kTermsSection;
     int kPaymentInfo;
     int kCareinfoSection;
     int kVendorSection;
     int kRateSection;
     int kProductSection;
    
     //int kPackageSection;
     //int kCuisinesSection;
     //int kTagSection;
    
     NSString         *sHighlights;
     UIWebView        *highlightsLabel;
     float            highlightHeight;
    
     NSString         *sTerms;
     UIWebView        *termsLabel;
     float            termsHeight;

     NSString         *sCareinfo;
     UIWebView        *careinfoLabel;
     float            careHeight;
    
     NSString*        payment_info;
     UIWebView        *paymentLabel;
     float            paymentHeight;
    
    //NSString         *sCuisines;
    //UILabel          *cuisinesLabel;
    
     NSMutableArray   *_tagArrays;
     NSMutableArray   *_openHours;
    
     UIButton         *subtractionBut;
     UIButton         *addBut;
     UILabel          *qtyLabel;
     int              orderQty;
     UIImageView*     modiImage;
    
     ACPButton        *buyNowBut;
     UILabel          *soldoutLabel;
    
     int              toolViewHeight;
    
     NSMutableIndexSet *expandedSections;

     MKMapView *vmapView;
    
     ////youbute
     YTPlayerView *Player;
     NSString *youtubeId;
    
     NSMutableArray* date_unavailable;
}

- (id)init:(int)product_id  withOrder:(BOOL)isView;

@end

