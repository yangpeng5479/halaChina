//
//  GDForgotPassViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/27.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFSegmentView.h"

@interface GDForgotPassViewController : UITableViewController<UITextFieldDelegate>
{
    UITextField* email;
    
    ACPButton* countryBut;
    UITextField* phoneNumber;
    
    BOOL         useEmail;
}

@end
