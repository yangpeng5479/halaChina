//
//  UILastGrabViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/11.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMQuiltViewController.h"

@interface GDLastGrabViewController : TMQuiltViewController
{
    NSMutableArray   *productData;
    
    int              seekPage;
    int              lastCountFromServer;
    
    BOOL             needBanner;
    
    BOOL             isLoadData;
    
}
@property (nonatomic, weak) id superNav;

- (id)init:(BOOL)haveRefreshView withBanner:(BOOL)haveBanner;

@end
