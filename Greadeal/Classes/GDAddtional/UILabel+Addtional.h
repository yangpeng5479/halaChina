//
//  UILabel+Addtional.h
//  WristCentralPos
//
//  Created by tao tao on 29/8/14.
//  Copyright (c) 2014 tao tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UILabel (Addtional)
-(void)setTextColor:(UIColor *)textColor range:(NSRange)range;
-(void)setFont:(UIFont *)font range:(NSRange)range;
-(void)findCurrency:(int)nSize;
-(void)findOff;
@end
