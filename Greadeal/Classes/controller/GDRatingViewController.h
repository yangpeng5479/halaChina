//
//  GDRatingViewController.h
//  Greadeal
//
//  Created by Elsa on 15/10/22.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWStarRateView.h"
#import "UICharCountingTextView.h"
#import "ELCImagePickerHeader.h"

#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

@interface GDRatingViewController : UIViewController<UICharCountingTextViewDelegate,ELCImagePickerControllerDelegate,UIImagePickerControllerDelegate,MJPhotoBrowserDelegate,CWStarRateViewDelegate>
{
    UILabel *lastRatingTitleLabel;
    UICharCountingTextView *inputTextView;
    
    int              productId;
    int              vendorId;
    
    BOOL             isVendor;
    
    NSMutableArray  *chosenImages;
    NSMutableArray  *image_key_list;
    
    UIView          *photosPage;
    UIButton        *addBut;
}

- (id)initWithProduct:(int)product_id;
- (id)initWithVendor:(int)vendor_id;

@end
