//
//  ILSMLAlertView.h
//  MoreLikers
//
//  Created by taotao on 14-9-9.
//  Copyright (c) 2014年 taotao. All rights reserved.
//
//how to use
//- (void)twoBtnClicked:(id)sender
//{
//    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Congratulations" contentText:@"You have bought something" leftButtonTitle:@"Ok" rightButtonTitle:@"Fine"];
//    [alert show];
//    alert.leftBlock = ^() {
//        NSLog(@"left button clicked");
//    };
//    alert.rightBlock = ^() {
//        NSLog(@"right button clicked");
//    };
//    alert.dismissBlock = ^() {
//        NSLog(@"Do something interesting after dismiss block");
//    };
//}
//
//- (void)OneBtnClicked:(id)sender
//{
//    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Congratulations" contentText:@"You have bought something" leftButtonTitle:nil rightButtonTitle:@"Fine"];
//    [alert show];
//    alert.rightBlock = ^() {
//        NSLog(@"right button clicked");
//    };
//    alert.dismissBlock = ^() {
//        NSLog(@"Do something interesting after dismiss block");
//    };
//}


#import <UIKit/UIKit.h>

@interface DXAlertView : UIView
{
}
- (id)initWithTitle:(NSString *)title
        contentText:(NSString *)content
    leftButtonTitle:(NSString *)leftTitle
   rightButtonTitle:(NSString *)rigthTitle;

- (void)show;

@property (nonatomic, copy) dispatch_block_t leftBlock;
@property (nonatomic, copy) dispatch_block_t rightBlock;
@property (nonatomic, copy) dispatch_block_t dismissBlock;

@end

@interface UIImage (colorful)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end