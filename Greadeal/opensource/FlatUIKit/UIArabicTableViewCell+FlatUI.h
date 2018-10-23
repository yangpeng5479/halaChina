//
//  UIArabicTableViewCell+FlatUI.h
//  Mozat
//
//  Created by taotao on 8/22/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import "UIArabicTableViewCell.h"

@interface UIArabicTableViewCell (FlatUI)
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic) UIColor *selectedBackgroundColor;

+ (UIArabicTableViewCell*) getFlatCellWithColor:(UIColor *)color selectedColor:(UIColor *)selectedColor style:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier cornerRadius:(float)r strokeWith:(float)w strokeColor:(UIColor *)strokeColor forClass:(Class)c;

- (void)setCornerRadius:(CGFloat)cornerRadius;
- (void)setStrokeWidth:(CGFloat)strokeWidth;
- (void)setStrokeColor:(UIColor *)strokeColor;

@end
