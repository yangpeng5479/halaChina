//
//  GDLoginViewController.h
//  greadeal
//
//  Created by tao tao on 28/05/13.
//  Copyright (c) 2013年 tao tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFSegmentView.h"
@interface GDLoginViewController : UITableViewController<UITextFieldDelegate,RFSegmentViewDelegate>
{
    UITextField* email;
    ACPButton*   countryBut;
    
    UITextField* phoneNumber;
    UITextField* userpass;
    BOOL         useEmail;
    
    UILabel      *facebooktitle;
    UILabel      *qqtitle;
}
-(void)exit;
@end
