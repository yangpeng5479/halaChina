//
//  UIArabicTableViewCell.m
//  Mozat
//
//  Created by taotao on 8/22/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import "UIArabicTableViewCell.h"

@implementation UIArabicTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        saveStyle = style;
        _accessoryOffset = 0;
        _setImageSize = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if([GDSettingManager instance].isRightToLeft)
	{
        //ios 9 support arabic layout by itself
        
//		float cellRealWidth;
//	    cellRealWidth = self.bounds.size.width;
//		float cellAccessoryOffsetX = _accessoryOffset;
//		if (self.accessoryType != UITableViewCellAccessoryNone)
//		{
//			if (!(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1))
//			{
//				cellAccessoryOffsetX = 20;
//			}
//		}
//        else
//        {
//            if ([[UIDevice currentDevice] systemVersion].floatValue < 7.0)
//            {
//                cellAccessoryOffsetX = 20;
//            }
//        }
//		
//		UIView *tv = self;
//		while (tv && ![tv isKindOfClass:[UITableView class]]) tv = tv.superview;
//		UITableViewStyle style = [(UITableView *)tv style];
//		if (style == UITableViewStyleGrouped)
//			if (self.accessoryType != UITableViewCellAccessoryNone) {
//            cellRealWidth -= 20;
//			}
//		
//		CGRect textFrame   = self.textLabel.frame;
//		CGRect detailFrame = self.detailTextLabel.frame;
//		CGRect imageFrame =  self.imageView.frame;
//		
//		if (saveStyle == UITableViewCellStyleSubtitle)
//		{
//			detailFrame.origin.x = cellRealWidth  + imageFrame.size.width +imageFrame.origin.x - detailFrame.origin.x - detailFrame.size.width - cellAccessoryOffsetX;
//			textFrame.origin.x = cellRealWidth  + imageFrame.size.width +imageFrame.origin.x - textFrame.origin.x - textFrame.size.width - cellAccessoryOffsetX;
//		}
//		else
//		{
//			if (self.detailTextLabel.text.length<=0) //have not detail
//			{
//				textFrame.origin.x = cellRealWidth  + imageFrame.size.width +imageFrame.origin.x - textFrame.origin.x - textFrame.size.width - cellAccessoryOffsetX;
//			}
//			else
//			{
//				float  tempDetailX = detailFrame.origin.x;
//				detailFrame.origin.x = textFrame.origin.x;
//				textFrame.origin.x = tempDetailX + detailFrame.size.width - textFrame.size.width;
//			}
//		}
//		if (self.accessoryType == UITableViewCellAccessoryNone)
//		{
//			textFrame.origin.x += self.contentOffsetX;
//			detailFrame.origin.x += self.contentOffsetX;
//		}
//		
//		//textFrame.origin.x = 0;
//		self.textLabel.frame = textFrame;
//		self.detailTextLabel.frame = detailFrame;
//        
//        self.textLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
//        self.detailTextLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
//        
//		MODebugLayer(self.textLabel, 1.f, [UIColor redColor].CGColor);
//		MODebugLayer(self.detailTextLabel, 1.f, [UIColor redColor].CGColor);
//		if (self.accessoryView!=nil)
//		{
//			CGRect accessoryFrame   = self.accessoryView.frame;
//			accessoryFrame.origin.x = 20;
//			self.accessoryView.frame = accessoryFrame;
//		}
	}
    
    if (CGRectIsEmpty(self.frame)) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
    }

}

- (void)setContentOffsetX:(NSInteger)contentOffsetX
{
    _contentOffsetX = contentOffsetX;
    [self setNeedsDisplay];
}

- (void)setAccessoryOffset:(NSInteger)accessoryOffset
{
    _accessoryOffset = accessoryOffset;
    [self setNeedsDisplay];
}



@end
