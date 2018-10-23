//
//  GDEditProfileViewController.h
//  Greadeal
//
//  Created by Elsa on 15/7/15.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDEditProfileViewController : UITableViewController<UITextFieldDelegate,UINavigationControllerDelegate>
{
    UITextField* email;
    UITextField* username;
    UITextField* userpass;
}

@end
