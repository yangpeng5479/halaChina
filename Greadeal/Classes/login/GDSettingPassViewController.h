//
//  GDSettingPassViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/27.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GDSettingPassViewController : UITableViewController<UITextFieldDelegate,MZTimerLabelDelegate>
{
    UITextField*  verifypass;
    UITextField*  newPass;
    ACPButton*    logoutBut;
    
    MZTimerLabel* countDown;
    UILabel*      newVerify;
    BOOL          finishCount;
    int           countIndex;
    
    NSString*     vercode;
}

@property (atomic, strong) NSString *phonenumber;

@end
