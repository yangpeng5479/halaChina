//
//  GDBuyMemberViewController.h
//  Greadeal
//
//  Created by Elsa on 15/11/26.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLRadioButton.h"

@interface GDBuyMemberViewController : UIViewController
{
    NSMutableArray *memberButtons;
    
    NSMutableArray *pricesArray;
    
    BOOL         blueSection;
    BOOL         goldSection;
    BOOL         platinumSection;
    
    float  offsetY;
}

@end
