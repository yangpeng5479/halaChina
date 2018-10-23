//
//  GDRegsiterViewController.h
//  greadeal
//
//  Created by tao tao on 06/06/13.
//  Copyright (c) 2013年 tao tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFSegmentView.h"

@interface GDRegsiterViewController : UITableViewController<UITextFieldDelegate,UINavigationControllerDelegate,RFSegmentViewDelegate,MZTimerLabelDelegate>
{
    UITextField*  email;
    ACPButton*   countryBut;
    
    UITextField*  phoneNumber;
    UITextField*  emailLabel;
//    UITextField*  verifyPass;
	UITextField*  userpass;
    UITextField*  username;
    BOOL          useEmail;
    
    UILabel*      facebooktitle;
    UILabel*      qqtitle;
    
    ACPButton*    registerBut;
    
    MZTimerLabel* countDown;
    UILabel*      newVerify;
    BOOL          finishCount;
    int           countIndex;

}
@end
