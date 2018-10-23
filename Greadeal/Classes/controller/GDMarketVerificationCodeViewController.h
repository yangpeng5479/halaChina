//
//  GDMarketVerificationCodeViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/29.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDMarketVerificationCodeViewController : UITableViewController<UITextFieldDelegate,MZTimerLabelDelegate>
{
    MZTimerLabel* countDown;
    UITextField*  verifypass;
    ACPButton*    okBut;
    
    UILabel*      newVerify;
    BOOL          finishCount;
    int           countIndex;
    
    NSString*     userPhone;
}

@property (assign) id  target;
@property (assign) SEL callback;

@property (atomic, strong) NSString *userPhone;
@property (atomic, strong) NSString *vercode;
@property (atomic, assign) int      address_id;

@end
