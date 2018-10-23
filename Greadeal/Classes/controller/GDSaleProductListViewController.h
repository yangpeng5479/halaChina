//
//  GDSaleProductListViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/30.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "TMQuiltViewController.h"
#import "MZTimerLabel.h"

#import "LXActivity.h"
#import <MessageUI/MessageUI.h>

@interface GDSaleProductListViewController : TMQuiltViewController<MZTimerLabelDelegate,MFMailComposeViewControllerDelegate,LXActivityDelegate>
{
    NSMutableArray   *productData;
    UILabel          *titleLabel;
    int              seekPage;
    int              lastCountFromServer;
    int              categoryId;
    BOOL             isLoadData;
    
    UIButton*        priceBut;
    
    MZTimerLabel*    proCountDown;
    NSString*        endTime;
}

@property (nonatomic, strong)  NSString* endTime;

- (id)init:(BOOL)haveRefreshView withId:(int)category_id;

@end
