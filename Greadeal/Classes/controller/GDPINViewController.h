//
//  GDPINViewController.h
//  Greadeal
//
//  Created by Elsa on 16/4/12.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDPINViewController : UIViewController<UITextFieldDelegate>
{
    UITextField *_firstDigitTextField;
    UITextField *_secondDigitTextField;
    UITextField *_thirdDigitTextField;
    UITextField *_fourthDigitTextField;
    
    UITextField *_passcodeTextField;
    
    NSString* consumeCode;
}

-(id)init:(NSString*)consume_code;

@end
