//
//  UIImage+MOAdditions.m
//  Mozat
//
//  Created by Yixiang Lu on 5/31/10.
//  Copyright 2010 Mozat. All rights reserved.
//

#import "UIImage+MOAdditions.h"

@implementation UIImage (MOAdditions)

static UIImage* MOResizeImage(UIImage* inputImage, CGSize newSize)
{
	
	// create a new bitmap image context
	//
	UIGraphicsBeginImageContext(newSize);
    /*if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(newSize);
    }*/
	
	// get context
	//
	//CGContextRef context = UIGraphicsGetCurrentContext();
	
	// push context to make it current 
	// (need to do this manually because we are not drawing in a UIView)
	//
	//UIGraphicsPushContext(context);
	
	// drawing code comes here- look at CGContext reference
	// for available operations
	//
	// this example draws the inputImage into the context
	//
	[inputImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	
	
	// pop context 
	//
	//UIGraphicsPopContext();
	
	// get a UIImage from the image context- enjoy!!!
	//
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// clean up drawing environment
	//
	UIGraphicsEndImageContext();
	
	return outputImage;
}


typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} MOPixelIndex;

UIImage* MOGrayscaledImage(UIImage* source)
{
	int scale = 1;
	if([source respondsToSelector:@selector(scale)])
	{
		scale = [source scale];
	}
	
    CGSize size = [source size];
	size.width *= scale;
	size.height *= scale;
	
    int width = size.width;
    int height = size.height;
	
    // the MOPixelIndex will be painted to this array
    uint32_t *MOPixelIndex = (uint32_t *) malloc(width * height * sizeof(uint32_t));
	
    // clear the MOPixelIndex so any transparency is preserved
    memset(MOPixelIndex, 0, width * height * sizeof(uint32_t));
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    // create a context with RGBA MOPixelIndex
    CGContextRef context = CGBitmapContextCreate(MOPixelIndex, width, height, 8, width * sizeof(uint32_t), colorSpace, 
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
	
    // paint the bitmap to our context which will fill in the MOPixelIndex array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [source CGImage]);
	
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &MOPixelIndex[y * width + x];
			
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
			
            // set the MOPixelIndex to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
	
    // create a new CGImageRef from our context with the modified MOPixelIndex
    CGImageRef image = CGBitmapContextCreateImage(context);
	
    // we're done with the context, color space, and MOPixelIndex
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(MOPixelIndex);

	UIImage *resultUIImage = nil;
	if(scale > 1)
	{
		resultUIImage = [UIImage imageWithCGImage:image scale:scale orientation:UIImageOrientationUp];
	}
	else
	{
		// make a new UIImage to return
		resultUIImage = [UIImage imageWithCGImage:image];
	}
	
	
    // we're done with image now too
    CGImageRelease(image);
	
    return resultUIImage;
}


-(UIImage*)imageByScaleToSize:(CGSize)size
{
	return MOResizeImage(self, size);
}

-(UIImage*)imageByScaleToPercent:(CGFloat)scale
{
	CGSize size = self.size;
	size.width *= scale;
	size.height *= scale;
	return MOResizeImage(self, size);
}


+ (UIImage *)imageNotCache:(NSString *)filename {
    NSString *imageFile = [[NSString alloc] initWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filename];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imageFile];
   
    return image;
}

+ (UIImage *)scaleImage:(UIImage *)image ToSize:(CGSize)size
{
    // Scalling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
	@synchronized (image)
	{
        if(image!=nil && image.imageOrientation == UIImageOrientationRight)
        {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -size.height, 0.0f);
            CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), image.CGImage);
        }
        else
            CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image.CGImage);
	}
    CGImageRef scaledImage=CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
	
    UIImage *img = [UIImage imageWithCGImage: scaledImage];
    
    CGImageRelease(scaledImage);
    
	
    return img;

}

+(UIImage*)imageWithData:(NSData*)data forceScale:(CGFloat)forceScale
{
	if(data != nil)
	{
		if(forceScale == 1)
		{
			return [UIImage imageWithData:data];
		}
		else
		{
			UIImage* original = [UIImage imageWithData:data];
			UIImage* image = [UIImage alloc];
			if([image respondsToSelector:@selector(initWithCGImage:scale:orientation:)])
			{
				image = [image initWithCGImage:original.CGImage scale:forceScale orientation:UIImageOrientationUp];
			}
			else
			{
				image = [image initWithCGImage:original.CGImage];
			}
			return image;
		}
	}
	else 
	{
		return nil;
	}

}

-(UIImage*)imageByGrayscalingSelf
{
	return MOGrayscaledImage(self);
}

- (UIImage *) resizableImageWithSize:(CGSize)size
{
    if( [self respondsToSelector:@selector(resizableImageWithCapInsets:)] )
    {
        return [self resizableImageWithCapInsets:UIEdgeInsetsMake(size.height, size.width, size.height, size.width)];
    } else {
        return [self stretchableImageWithLeftCapWidth:size.width topCapHeight:size.height];
    }
}

+(UIImage *)imageWithColor:(UIColor *)color withHeight:(CGFloat)nHeight withWidth:(CGFloat)nWidth
{
	CGRect rect = CGRectMake(0.0f, 0.0f, nWidth, nHeight);
    
	UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return image;
}

- (UIImage *)adjustColor:(UIColor*)color
{
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    
    return flippedImage;

}

-(UIImage *)grayImage
{
    int bitmapInfo = kCGImageAlphaNone;
    int width = self.size.width;
    int height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context,
                       CGRectMake(0, 0, width, height), self.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}


@end
