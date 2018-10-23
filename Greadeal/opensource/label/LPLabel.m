//
//  LPLabel.m
//  label上画横线
//
//  Created by Li Pan on 14-6-30.
//  Copyright (c) 2014年 Pan Li. All rights reserved.
//

#import "LPLabel.h"

@implementation LPLabel

- (id)init
{
    self = [super init];
    if (self) {
        self.strikeThroughEnabled = YES;
        self.strikeThroughColor = [UIColor grayColor];
        self.strikeHeight  = 0.5;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.strikeThroughEnabled = YES;
        self.strikeThroughColor = [UIColor grayColor];
        self.strikeHeight  = 0.5;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
 
}
*/

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:rect];
    
    CGSize textSize = [[self text] moSizeWithFont:[self font] withWidth:rect.size.width];
    
    CGFloat strikeWidth = textSize.width;
    
    CGRect lineRect;
    
    if ([self textAlignment] == NSTextAlignmentRight)
    {
        // 画线居中
        lineRect = CGRectMake(rect.size.width - strikeWidth, rect.size.height/2, strikeWidth, self.strikeHeight);
        
        // 画线居下
        //lineRect = CGRectMake(rect.size.width - strikeWidth, rect.size.height/2 + textSize.height/2, strikeWidth, 1);
    }
    else if ([self textAlignment] == NSTextAlignmentCenter)
    {
        // 画线居中
        lineRect = CGRectMake(rect.size.width/2 - strikeWidth/2, rect.size.height/2, strikeWidth, self.strikeHeight);
        
        // 画线居下
        //lineRect = CGRectMake(rect.size.width/2 - strikeWidth/2, rect.size.height/2 + textSize.height/2, strikeWidth, 1);
    }
    else
    {
        // 画线居中
        lineRect = CGRectMake(0, rect.size.height/2, strikeWidth, self.strikeHeight);
        
        // 画线居下
        //lineRect = CGRectMake(0, rect.size.height/2 + textSize.height/2, strikeWidth, 1);
    }
    
    if (self.strikeThroughEnabled)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [self strikeThroughColor].CGColor);
        
        CGContextFillRect(context, lineRect);
    }
}

@end
