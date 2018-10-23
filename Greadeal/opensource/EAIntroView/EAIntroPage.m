//
//  EAIntroPage.m
//  EAIntroView
//
//  Copyright (c) 2013 Evgeny Aleksandrov.
//

#import "EAIntroPage.h"

@implementation EAIntroPage

+ (EAIntroPage *)page:(UIColor*)textColor withFont:(BOOL)isSwitch
{
    EAIntroPage *newPage = [[EAIntroPage alloc] init];
    newPage.imgPositionY    = 50.0f;
    newPage.titlePositionY  = [[UIScreen mainScreen] bounds].size.height-35;
    newPage.descPositionY   = [[UIScreen mainScreen] bounds].size.height-70;
    
    newPage.titleColor = textColor;
    newPage.descColor = textColor;
    
    newPage.titleFont = MOLightFont(20);
    newPage.descFont = MOLightFont(16);
    
    return newPage;
}

+ (EAIntroPage *)pageWithCustomView:(UIView *)customV {
    EAIntroPage *newPage = [[EAIntroPage alloc] init];
    newPage.customView = customV;
    
    return newPage;
}

@end
