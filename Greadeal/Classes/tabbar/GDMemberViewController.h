//
//  GDDiscountAndStoreViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/21.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFSegmentView.h"

#import "GDMemberCardViewController.h"

@interface GDMemberViewController : UIViewController<RFSegmentViewDelegate>
{
    NSArray* segmentControlTitles;
    BOOL isLoadData;
    
    GDMemberCardViewController*  blueCardVC;
    GDMemberCardViewController*  goldCardVC;
    GDMemberCardViewController*  platinumCardVC;
    
}

- (id)init;

@end
