//
//  UACellBackgroundView.m
//  FlatUI
//
//  Created by Maciej Swic on 2013-05-30.
//  Licensed under the MIT license.

#import "FUICellBackgroundView.h"
#import "GDSettingManager.h"

@implementation FUICellBackgroundView {
    UIColor *_bgColor;
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.cornerRadius = 3.0f;
        self.strokeWidth = 1.0f;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.clipsToBounds = YES;
	}

	return self;
}


- (BOOL)isOpaque {
	return NO;
}

-(id)findInSuper:(UIView*)root forType:(Class)class
{
	if(!root || [root isKindOfClass:class])
		return (UITableViewCell*)root;
	return [self findInSuper:root.superview forType:class];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //Determine position
    UITableView* tableView = nil;
    NSIndexPath* indexPath = nil;
	//Disabled. iOS7 has inconsistent behaviors for different Betas so we now use a flexible algorithm to find it.
//	if(IOS_MIN(@"7"))
//	{
//		tableView = (UITableView*)self.superview.superview.superview;
//		indexPath = [tableView indexPathForCell:(UITableViewCell*)self.superview.superview];
//	}
//	else
	{
		tableView = (UITableView*)[self findInSuper:self.superview.superview forType:[UITableView class]];//(UITableView*)self.superview.superview;
		indexPath = [tableView indexPathForCell:(UITableViewCell*)[self findInSuper:self.superview forType:[UITableViewCell class]]];
	}
	
    
    if ([tableView numberOfRowsInSection:indexPath.section] == 1) {
        self.position = FUICellBackgroundViewPositionSingle;
    }
    else if (indexPath.row == 0) {
        self.position = FUICellBackgroundViewPositionTop;
    }
    else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        self.position = FUICellBackgroundViewPositionBottom;
    }
    else {
        self.position = UACellBackgroundViewPositionMiddle;
    }
    
    //self.separatorColor = tableView.separatorColor;
}

- (void)drawRect:(CGRect)aRect {
    //Determine tableView style
    UITableView* tableView = (UITableView*)self.superview.superview;
    if (tableView.style != UITableViewStyleGrouped) {
        self.cornerRadius = 0.f;
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
	int lineWidth = 1;

	CGRect rect = [self bounds];
	CGFloat minX = CGRectGetMinX(rect), midX = CGRectGetMidX(rect), maxX = CGRectGetMaxX(rect);
	CGFloat minY = CGRectGetMinY(rect), midY = CGRectGetMidY(rect), maxY = CGRectGetMaxY(rect);
	minY -= 1;

	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGContextSetStrokeColorWithColor(c, [[UIColor grayColor] CGColor]);
	CGContextSetLineWidth(c, lineWidth);
	CGContextSetAllowsAntialiasing(c, YES);
	CGContextSetShouldAntialias(c, YES);

	if (self.position == FUICellBackgroundViewPositionTop) {
		minY += 1;
        
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, minX, maxY);
		CGPathAddArcToPoint(path, NULL, minX, minY, midX, minY, self.cornerRadius);
		CGPathAddArcToPoint(path, NULL, maxX, minY, maxX, maxY, self.cornerRadius);
		CGPathAddLineToPoint(path, NULL, maxX, maxY);
		CGPathAddLineToPoint(path, NULL, minX, maxY);
		CGPathCloseSubpath(path);

		CGContextSaveGState(c);
		CGContextAddPath(c, path);
        CGContextClip(c);

        CGContextAddPath(c, path);
        CGContextSetLineWidth(c, self.strokeWidth);
        CGContextSetStrokeColorWithColor(c, self.separatorColor.CGColor);
        CGContextSetFillColorWithColor(c, self.backgroundColor.CGColor);
        CGContextDrawPath(c, kCGPathFillStroke);

		CGPathRelease(path);
        CGContextRestoreGState(c);
	} else if (self.position == FUICellBackgroundViewPositionBottom) {
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, minX, minY);
		CGPathAddArcToPoint(path, NULL, minX, maxY, midX, maxY, self.cornerRadius);
		CGPathAddArcToPoint(path, NULL, maxX, maxY, maxX, minY, self.cornerRadius);
		CGPathAddLineToPoint(path, NULL, maxX, minY);
		CGPathAddLineToPoint(path, NULL, minX, minY);
		CGPathCloseSubpath(path);

		CGContextSaveGState(c);
		CGContextAddPath(c, path);
		CGContextClip(c);
        
        CGContextAddPath(c, path);
        CGContextSetLineWidth(c, self.strokeWidth);
        CGContextSetStrokeColorWithColor(c, self.separatorColor.CGColor);
        CGContextSetFillColorWithColor(c, self.backgroundColor.CGColor);
        CGContextDrawPath(c, kCGPathFillStroke);
		
		CGPathRelease(path);
		CGContextRestoreGState(c);
	} else if (self.position == UACellBackgroundViewPositionMiddle) {
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, minX, minY);
		CGPathAddLineToPoint(path, NULL, maxX, minY);
		CGPathAddLineToPoint(path, NULL, maxX, maxY);
		CGPathAddLineToPoint(path, NULL, minX, maxY);
		CGPathAddLineToPoint(path, NULL, minX, minY);
		CGPathCloseSubpath(path);

		CGContextSaveGState(c);
		CGContextAddPath(c, path);
		CGContextClip(c);

		CGContextAddPath(c, path);
        CGContextSetLineWidth(c, self.strokeWidth);
        CGContextSetStrokeColorWithColor(c, self.separatorColor.CGColor);
        CGContextSetFillColorWithColor(c, self.backgroundColor.CGColor);
        CGContextDrawPath(c, kCGPathFillStroke);
        
		CGPathRelease(path);
		CGContextRestoreGState(c);
	} else if (self.position == FUICellBackgroundViewPositionSingle) {
		minY += 1;

		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, minX, midY);
		CGPathAddArcToPoint(path, NULL, minX, minY, midX, minY, self.cornerRadius);
		CGPathAddArcToPoint(path, NULL, maxX, minY, maxX, midY, self.cornerRadius);
		CGPathAddArcToPoint(path, NULL, maxX, maxY, midX, maxY, self.cornerRadius);
		CGPathAddArcToPoint(path, NULL, minX, maxY, minX, midY, self.cornerRadius);
		CGPathCloseSubpath(path);

		CGContextSaveGState(c);
		CGContextAddPath(c, path);
		CGContextClip(c);

		CGContextAddPath(c, path);
        CGContextSetLineWidth(c, self.strokeWidth);
        CGContextSetStrokeColorWithColor(c, self.separatorColor.CGColor);
        CGContextSetFillColorWithColor(c, self.backgroundColor.CGColor);
        CGContextDrawPath(c, kCGPathFillStroke);
        
		CGPathRelease(path);
		CGContextRestoreGState(c);
	}

	CGColorSpaceRelease(colorspace);
}

- (void)setPosition:(FUICellBackgroundViewPosition)position {
    _position = position;
    
    [self setNeedsDisplay];
}


- (UIColor *)backgroundColor {
    UITableViewCell *cell = (UITableViewCell *)self.superview;
    if (self.type == FUICellBackgroundViewTypeSelected) {
        return _bgColor;
    } else {
        return cell.backgroundColor;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _bgColor = backgroundColor;
}

@end
