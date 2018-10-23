//
//  GDCellLiveView.m
//  Greadeal
//
//  Created by Elsa on 15/5/13.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDCellLiveView.h"
#import "GDSuperADPanelView.h"

#import "GDLiveVendorViewController.h"

#define xMargin  10


@interface GDCellLiveView ()

@end

@implementation GDCellLiveView

@synthesize bannerData;
@synthesize cellData;

- (id)init
{
    self = [super init];
    if (self)
    {
        bannerData  = [[NSMutableArray alloc] init];
        cellData = [[NSMutableArray alloc] init];
    }
    return self;
}

- (float)caluGalleryHeight
{
    float cellHeight;
    if (cellData.count%numbersOfCell==0)
        cellHeight = cellData.count/numbersOfCell*cellDataHeight;
    else
        cellHeight = cellData.count/numbersOfCell*cellDataHeight+cellDataHeight;
    return cellHeight;
}

- (float)getViewHeight
{
    float cellHeight = 0;
    
    cellHeight+=[self caluGalleryHeight];
    cellHeight+=sectionHeight;
    
    if (bannerData.count>0)
        cellHeight+=bannerHeight;
    
    return cellHeight;
}

#pragma mark UIView
- (void)didSelectADItem:(id)sender
{
    //{"s":<string> sticker name, if applicable, "e":<string> emoji code, if applicable.}
    NSDictionary *dict = sender;
    LOG(@"dict=%@",dict);
    
    int vendor_id = 0;
    NSString* vendor_name = @"vendor name";
    NSString* vendor_image = @"";
    NSString* vendor_url = @"";
    
    vendor_id = [dict[@"vendor_id"] intValue];
    SET_IF_NOT_NULL(vendor_name, dict[@"vendor_name"]);
    SET_IF_NOT_NULL(vendor_url, dict[@"store_url"]);
    SET_IF_NOT_NULL(vendor_image, dict[@"vendor_image"]);

    if (vendor_id>0)
    {
        GDLiveVendorViewController * vc = [[GDLiveVendorViewController alloc] init:vendor_id withName:vendor_name withUrl:vendor_url withImage:vendor_image];
        [_superNav pushViewController:vc animated:YES];
    }
}

- (void)makeMainView
{
    CGRect r = self.frame;
    float  offsetY = 0;
    if (bannerData.count>0)
    {
        //banner
        bannerView = [[JCTopic alloc]initWithFrame:CGRectMake(0, offsetY, r.size.width, bannerHeight)];
        bannerView.JCdelegate = self;
        //MODebugLayer(bannerView, 1.f, [UIColor blueColor].CGColor);
        
        bannerView.pics = bannerData;
        [bannerView upDate:@"live_banner_default.png"];
        
        [self addSubview:bannerView];
        
        offsetY=bannerHeight;
    }
    //title
    titleLable = [[UILabel alloc] initWithFrame:CGRectMake(15, offsetY, r.size.width-30, sectionHeight)];
    titleLable.textColor = [UIColor blackColor];//;colorFromHexString(@"e42625");
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.font = MOLightFont(14);
    titleLable.text = NSLocalizedString(@"Hot Store", @"热门商店");
    titleLable.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, r.size.width, sectionHeight)];
    titleView.backgroundColor = MOSectionBackgroundColor();
    [titleView addSubview:titleLable];

    [self addSubview:titleView];
    offsetY+=sectionHeight;
    
    GDSuperADPanelView* galleryView = [[GDSuperADPanelView alloc] initWithFrame:CGRectMake(0, offsetY,CGRectGetWidth(r), [self caluGalleryHeight])];
    galleryView.ItemOfPage = (int)cellData.count;
    galleryView.LineHeight = cellDataHeight;
    galleryView.ItemOfLine = numbersOfCell;
    galleryView.target     = self;
    galleryView.callback   = @selector(didSelectADItem:);
    galleryView.backgroundColor = [UIColor clearColor];
    [self addSubview:galleryView];

    [galleryView setRecentItems:cellData];
}

#pragma mark Data

- (void)getBannerData
{
    CGRect r = self.frame;
    
    //banner
    bannerView = [[JCTopic alloc]initWithFrame:CGRectMake(0, 0, r.size.width, bannerHeight) ];
    bannerView.JCdelegate = self;
    MODebugLayer(bannerView, 1.f, [UIColor blueColor].CGColor);
    
    bannerView.pics = bannerData;
    [bannerView upDate:@"live_banner_default.png"];
        
    [self addSubview:bannerView];
    
}

#pragma mark bannerDelegate

-(void)didClick:(int)nIndex
{
}

- (void)tapView:(UIGestureRecognizer *)tapGesture
{
}

@end
