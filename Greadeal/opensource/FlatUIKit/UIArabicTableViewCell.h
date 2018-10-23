//
//  UIArabicTableViewCell.h
//  Mozat
//
//  Created by taotao on 8/22/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIArabicTableViewCell : UITableViewCell
{
	UITableViewCellStyle saveStyle;
}

@property (assign, nonatomic) BOOL setImageSize;
@property (assign, nonatomic) NSInteger contentOffsetX;
@property (nonatomic, assign) NSInteger accessoryOffset;

@end
