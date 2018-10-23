//
//  NSString+Addtional.m
//  WristCentralPos
//
//  Created by tao tao on 29/8/14.
//  Copyright (c) 2014 tao tao. All rights reserved.
//

#import "NSString+Addtional.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Addtional)

-(CGSize) moSizeWithFont:(UIFont *)font withWidth:(float)nWidth{
    CGSize theSize;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        NSDictionary *attributes = @{NSFontAttributeName:font};
        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.
        CGRect rect = [self boundingRectWithSize:CGSizeMake(nWidth, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
        theSize = rect.size;
    }
    else
    {
        theSize = [self sizeWithFont:font];
    }
    
    
    return CGSizeMake(ceil(theSize.width), ceil(theSize.height));
}

- (void)moDrawInRect:(CGRect)rect withFont:(UIFont *)font textColor:(UIColor *)color {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self drawInRect:rect withAttributes:@
         {
         NSFontAttributeName: font,
         NSForegroundColorAttributeName:color
         }];
    }
    else {
        [color setFill];
        [self drawInRect:rect withFont:font];
    }
}

- (void)moDrawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode textColor:(UIColor *)color {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
        if ((lineBreakMode & NSLineBreakByTruncatingTail) == NSLineBreakByTruncatingTail) {
            options = options | NSStringDrawingTruncatesLastVisibleLine;
        }
        [self drawWithRect:rect options:options attributes:@
         {
         NSFontAttributeName: font,
         NSForegroundColorAttributeName:color
         } context:nil];
    }
    else {
        [color setFill];
        [self drawInRect:rect withFont:font lineBreakMode:lineBreakMode];
    }
}

- (void)moDrawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment textColor:(UIColor *)color {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
        if ((lineBreakMode & NSLineBreakByTruncatingTail) == NSLineBreakByTruncatingTail) {
            options = options | NSStringDrawingTruncatesLastVisibleLine;
        }
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = alignment;
        [self drawWithRect:rect options:options attributes:@
         {
         NSFontAttributeName: font,
         NSParagraphStyleAttributeName:paragraphStyle,
         NSForegroundColorAttributeName:color
         } context:nil];
    }
    else {
        [color setFill];
        [self drawInRect:rect withFont:font lineBreakMode:lineBreakMode];
    }
}

- (void)moDrawAtPoint:(CGPoint)p withFont:(UIFont *)font textColor:(UIColor *)color {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self drawAtPoint:p withAttributes:@
         {
         NSFontAttributeName: font,
         NSForegroundColorAttributeName:color
         }];
    }
    else {
        [color setFill];
        [self drawAtPoint:p withFont:font];
    }
}

- (NSString*)encodeUTF
{
   return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(BOOL)isNullOrEmpty
{
    BOOL retVal = YES;
    
    if( self != nil )
    {
        if( [self isKindOfClass:[NSString class]] )
        {
            retVal = self.length == 0;
        }
        else
        {
            LOG(@"isNullOrEmpty, value not a string");
        }
    }
    return retVal;
}

- (NSString *)MD5String
{
    const char *str = [self UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *md5 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return md5;

}

@end
