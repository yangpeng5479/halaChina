//
//  UIImage+MOAdditions.h
//  Mozat
//
//  Created by Yixiang Lu on 5/31/10.
//  Copyright 2010 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MOAdditions)

-(UIImage*)imageByScaleToSize:(CGSize)size;
-(UIImage*)imageByScaleToPercent:(CGFloat)scale;
+(UIImage*)imageWithData:(NSData*)data forceScale:(CGFloat)forceScale;
-(UIImage*)imageByGrayscalingSelf;
- (UIImage *)resizableImageWithSize:(CGSize)size;
+(UIImage *)imageWithColor:(UIColor *)color withHeight:(CGFloat)nHeight  withWidth:(CGFloat)nWidth;
+ (UIImage *)imageNotCache:(NSString *)filename;
+ (UIImage *)scaleImage:(UIImage *)image ToSize:(CGSize)size;
- (UIImage *)adjustColor:(UIColor*)color;
-(UIImage *)grayImage;
@end
