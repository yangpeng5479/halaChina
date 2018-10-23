// RDVFirstViewController.h
// RDVTabBarController
//
// Copyright (c) 2013 Robert Dimitrov
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ViewPagerController.h"

@interface GDSaleViewController : ViewPagerController<ViewPagerDataSource, ViewPagerDelegate>
{
    int indexCount;
}

@end

