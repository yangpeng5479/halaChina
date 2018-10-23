//
//  GDDiscountAndStoreViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/21.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFSegmentView.h"

#import "GDLiveDiscountViewController.h"

@interface GDDiscountAndStoreViewController : UIViewController<RFSegmentViewDelegate>
{
    NSArray* segmentControlTitles;
    BOOL isLoadData;
    
    GDLiveDiscountViewController*  discountVC;
    GDLiveDiscountViewController*  storeVC;
    
    int category_id;
}

- (id)init:(int)categoryId;

@end
