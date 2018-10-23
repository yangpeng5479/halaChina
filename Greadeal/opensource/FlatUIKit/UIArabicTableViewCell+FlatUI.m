//
//  UIArabicTableViewCell+FlatUI.m
//  Mozat
//
//  Created by taotao on 8/22/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import "UIArabicTableViewCell+FlatUI.h"
#import "FUICellBackgroundView.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@implementation UIArabicTableViewCell (FlatUI)

@dynamic cornerRadius, strokeWidth, selectedBackgroundColor;

+ (UIArabicTableViewCell*) getFlatCellWithColor:(UIColor *)color selectedColor:(UIColor *)selectedColor style:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier cornerRadius:(float)r strokeWith:(float)w strokeColor:(UIColor *)strokeColor forClass:(Class)c {
    UIArabicTableViewCell* cell = [[c alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    cell.backgroundColor = color;
    
	//Don't mess with the appearance for iOS7.
	if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1)
	{
		FUICellBackgroundView* backgroundView = [FUICellBackgroundView new];
		backgroundView.type = FUICellBackgroundViewTypeDefault;
		backgroundView.backgroundColor = color;
		backgroundView.separatorColor = strokeColor;
		cell.backgroundView = backgroundView;
	
		
		FUICellBackgroundView* selectedBackgroundView = [FUICellBackgroundView new];
		selectedBackgroundView.type = FUICellBackgroundViewTypeSelected;
		selectedBackgroundView.backgroundColor = selectedColor;
		selectedBackgroundView.separatorColor = strokeColor;
		cell.selectedBackgroundView = selectedBackgroundView;
		
		
		//The labels need a clear background color or they will look very funky
		cell.textLabel.backgroundColor = [UIColor clearColor];
		if ([cell respondsToSelector:@selector(detailTextLabel)])
			cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		
//		cell.textLabel.textColor = MOColorDarkTextColor();
//		cell.textLabel.highlightedTextColor = MOColorDarkTextColor();
//		if ([cell respondsToSelector:@selector(detailTextLabel)]) {
//			cell.detailTextLabel.textColor = MOColorDetailTextColor();
		
//		}
		
		cell.cornerRadius = r;
		cell.strokeWidth = w;
	}
    
    return cell;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
	//Don't mess with the appearance for iOS7.
	if([self.backgroundView isKindOfClass:[FUICellBackgroundView class]])
	{
		[(FUICellBackgroundView*)self.backgroundView setCornerRadius:cornerRadius];
	}
	if([self.selectedBackgroundView isKindOfClass:[FUICellBackgroundView class]])
	{
		[(FUICellBackgroundView*)self.selectedBackgroundView setCornerRadius:cornerRadius];
	}
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
	//Don't mess with the appearance for iOS7.
	if([self.backgroundView isKindOfClass:[FUICellBackgroundView class]])
	{
		[(FUICellBackgroundView*)self.backgroundView setStrokeWidth:strokeWidth];
	}
	if([self.selectedBackgroundView isKindOfClass:[FUICellBackgroundView class]])
	{
		[(FUICellBackgroundView*)self.selectedBackgroundView setStrokeWidth:strokeWidth];
	}
}

- (void)setStrokeColor:(UIColor *)strokeColor {
	//Don't mess with the appearance for iOS7.
	if([self.backgroundView isKindOfClass:[FUICellBackgroundView class]])
	{
		[(FUICellBackgroundView*)self.backgroundView setSeparatorColor:strokeColor];
	}
	if([self.selectedBackgroundView isKindOfClass:[FUICellBackgroundView class]])
	{
		[(FUICellBackgroundView*)self.selectedBackgroundView setSeparatorColor:strokeColor];
	}
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
	//Don't mess with the appearance for iOS7.
	if([self.selectedBackgroundView isKindOfClass:[FUICellBackgroundView class]])
	{
		[(FUICellBackgroundView*)self.selectedBackgroundView setBackgroundColor:selectedBackgroundColor];
	}
}

@end