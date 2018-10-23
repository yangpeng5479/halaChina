//
//  MOColor.m
//  ntlniph
//
//  Created by tao tao on 4/19/13.
//
//

#import "MOColor.h"

UIColor* MOAppTextBackColor()
{
    return  colorFromHexString(@"3ed37a");
}

UIColor* MOColor33Color()
{
    return  colorFromHexString(@"333333");
}

UIColor* MOColor66Color(){
    return  colorFromHexString(@"666666");
}

UIColor* MOColorYellowColor()
{
    return  colorFromHexString(@"ef8803");
}

UIColor* MOColorSaleFontColor()
{
    return  colorFromHexString(@"3ed37a");
   // return  colorFromHexString(@"f16d2b");
}

UIColor* MOColorAppBackgroundColor()
{
    return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
}

UIColor* MOLiveBackgroundColor()
{
    return [UIColor colorWithRed:(242/255.0) green:(244/255.0) blue:(246/255.0) alpha:1.0];
}

UIColor* MOColorSaleProductBackgroundColor()
{
    return [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
}

UIColor* MOColorTextFieldColor()
{
    return [UIColor colorWithRed:(0x32/255.0) green:(0x4f/255.0) blue:(0x85/255.0) alpha:1.0];
}

UIColor* MOColorPageIndicator()
{
   return [UIColor colorWithRed:(231/255.0) green:(23/255.0) blue:(72/255.0) alpha:1.0];
}

UIColor* MOSectionBackgroundColor()
{
   return [UIColor colorWithRed:(245/255.0) green:(245/255.0) blue:(245/255.0) alpha:1.0];
}

UIColor* MOBarItemTintColor()
{
    return [UIColor colorWithRed:(103/255.0) green:(103/255.0) blue:(103/255.0) alpha:1.0];
}

UIColor* colorFromHexString(NSString *hexString) {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

NSString* hexStringFromColor(UIColor *color) {
    NSString *webColor = nil;
    
    // This method only works for RGB colors
    if (color &&
        CGColorGetNumberOfComponents(color.CGColor) == 4)
    {
        // Get the red, green and blue components
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        
        // These components range from 0.0 till 1.0 and need to be converted to 0 till 255
        CGFloat red, green, blue;
        red = roundf(components[0] * 255.0);
        green = roundf(components[1] * 255.0);
        blue = roundf(components[2] * 255.0);
        
        // Convert with %02x (use 02 to always get two chars)
        webColor = [NSString stringWithFormat:@"%02x%02x%02x", (int)red, (int)green, (int)blue];
    }
    
    return webColor;
}


UIColor* MOColorBlueBlack()
{
    return [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
}

UIColor* MOColorGray()
{
    return [UIColor colorWithRed:137/255.0 green:137/255.0 blue:137/255.0 alpha:1.0];
}
