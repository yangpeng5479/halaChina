//
//  GDDeliveryVendorViewController.h
//  Greadeal
//
//  Created by Elsa on 16/6/3.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "ViewPagerController.h"

@interface GDDeliveryVendorViewController : ViewPagerController<ViewPagerDataSource, ViewPagerDelegate>
{
    int indexCount;
    NSDictionary* vendorinfo;
}

- (id)init:(NSDictionary*)vendor_info;

@end
