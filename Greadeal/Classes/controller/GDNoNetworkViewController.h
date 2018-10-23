//
//  GDNoNetworkViewController.h
//  Greadeal
//
//  Created by Elsa on 15/9/2.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDNoNetworkViewController : UIViewController
{
    BOOL     reloading;
    UIView   *_noNetworkView;
    BOOL     netWorkError;
}
-(UIView *)noNetworkView;
@end
