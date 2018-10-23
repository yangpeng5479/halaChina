//
//  UITableViewCell+FlatUI.h
//  FlatUIKitExample
//
//  Created by Maciej Swic on 2013-05-31.
//
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (FlatUI)

@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic) UIColor *selectedBackgroundColor;

+ (UITableViewCell*) getFlatCellWithColor:(UIColor *)color selectedColor:(UIColor *)selectedColor style:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier cornerRadius:(float)r strokeWith:(float)w strokeColor:(UIColor *)strokeColor;

- (void)setCornerRadius:(CGFloat)cornerRadius;
- (void)setStrokeWidth:(CGFloat)strokeWidth;
- (void)setStrokeColor:(UIColor *)strokeColor;

@end
