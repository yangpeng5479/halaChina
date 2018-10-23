//
//  GDIntroViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/19.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAIntroView.h"

@interface GDIntroViewController : UIViewController<EAIntroDelegate>
{
    
}

@property (assign) id  target;
@property (assign) SEL callback;

@end
