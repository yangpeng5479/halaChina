//
//  GDNewOnLineViewController.h
//  JUMPSTAR
//
//  Created by tao tao on 3/4/15.
//  Copyright (c) 2015 tao tao. All rights reserved.
//

#import "TMQuiltViewController.h"
#import "JCTopic.h"

@interface GDNewOnLineViewController : TMQuiltViewController<JCTopicDelegate>
{
    JCTopic          *bannerView;
    UILabel          *titleLabel;
    UIImageView      *backTitle;
    
    NSMutableArray   *bannerData;
    NSMutableArray   *productData;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             needBanner;
    BOOL             isLoadData;
}

@property (nonatomic, weak)  id superNav;

- (id)init:(BOOL)haveRefreshView withBanner:(BOOL)haveBanner;

@end
