//
//  AppDelegate.h
//  Greadeal
//
//  Created by Elsa on 15/5/8.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliPayment.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSDictionary *pushNotifi;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;


- (void)setCartBadge:(NSString*)value;

@end

