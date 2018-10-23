//
//  NSString+Addtional.h
//  WristCentralPos
//
//  Created by tao tao on 29/8/14.
//  Copyright (c) 2014 tao tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Addtional)
- (CGSize)moSizeWithFont:(UIFont *)font  withWidth:(float)nWidth;
- (void)moDrawInRect:(CGRect)rect withFont:(UIFont *)font textColor:(UIColor *)color;
- (void)moDrawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode textColor:(UIColor *)color;
- (void)moDrawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment textColor:(UIColor *)color;

- (void)moDrawAtPoint:(CGPoint)p withFont:(UIFont *)font textColor:(UIColor *)color;

- (NSString*)encodeUTF;

-(BOOL)isNullOrEmpty;

- (NSString *)MD5String;

@end
