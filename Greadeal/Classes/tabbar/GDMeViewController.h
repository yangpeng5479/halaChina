//
//  GDMeViewController.h
//  Greadeal
//
//  Created by Elsa on 15/5/11.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCodeReaderViewController.h"
#import "LXActivity.h"
#import <QuartzCore/QuartzCore.h>


@interface GDMeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,QRCodeReaderDelegate,LXActivityDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UITableView  *meTableView;
    
    UIImageView  *headerView;
    UIImageView  *avatarView;
    
    //UIImageView  *memberView;
    ACPButton    *loginBut;
    ACPButton    *signupBut;
    
    UILabel      *username;
    //UILabel      *memberName;
    //UILabel      *userphone;
    
    //UILabel      *memberDate;
    UIView       *voucherPanel;
  
    int kBuySection;
    int kVourcherSection;
    int kDeliverySection;
    int kWishSection;
    int kShareSection;
    int kSupportSection;
}
@end
