//
//  GDPassportViewController.h
//  Greadeal
//
//  Created by Elsa on 15/7/15.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDPassportViewController : UITableViewController<UITextFieldDelegate,UINavigationControllerDelegate>
{
    UITextField* passportLable;
    UITextField* iDLable;
    
    UITextField* userName;
}

@property (assign) id  target;
@property (assign) SEL callback;

@end
