//
//  GDPanelView.m
//  Greadeal
//
//  Created by Elsa on 15/5/15.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDPanelView.h"

@implementation GDPanelView

@synthesize xspaceing = _xspaceing;
@synthesize yspaceing = _yspaceing;

@synthesize imageWidth =  _imageWidth;
@synthesize imageHeight= _imageHeight;
@synthesize ItemOfLine = _ItemOfLine;

@synthesize ItemOfPage = _ItemOfPage;
@synthesize LineHeight = _LineHeight;

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        //default
        _xspaceing = 0;
        _yspaceing = 0;
        
        _imageWidth = 40;
        _imageHeight= 40;
        _ItemOfLine = 4;
        
        _ItemOfPage = 8;
        _LineHeight = 70;
    }
    return self;
}

- (float)getFrameHeight
{
    int   lineOfPage = 0;
    if (self.ItemOfPage % self.ItemOfLine == 0)
        lineOfPage = self.ItemOfPage/self.ItemOfLine;
    else
        lineOfPage = self.ItemOfPage/self.ItemOfLine + 1;
    float butHeight= (self.bounds.size.height-self.yspaceing*(lineOfPage+1))/lineOfPage;
    return butHeight;
}

- (void)rearrangeButtons
{
    @synchronized(itemButtons)
    {
        if (itemButtons.count > 0)
        {
            UIButton *first = [itemButtons objectAtIndex:0];
            
            CGRect    buttonRect = first.frame;

            CGSize    fullButtonSize;
            
            fullButtonSize = CGSizeMake(buttonRect.size.width, buttonRect.size.height);
            
            int xspace = _xspaceing, yspace = _yspaceing;
            int iconPerLine = _ItemOfLine;
            
            if (iconPerLine > 0)
            {
                int current = 0;
                for (UIButton *b in itemButtons)
                {
                    int x = current % iconPerLine;
                    int y = floor(current / iconPerLine);
                    if (x == 0)
                    {
                        xspace = _xspaceing;
                    }
                    
                    if ([GDSettingManager instance].isRightToLeft)
                    {
                        float cellwidth = self.bounds.size.width;
                        buttonRect.origin.x = cellwidth - (x+1) * fullButtonSize.width - xspace;
                        xspace += _xspaceing;
                    }
                    else
                    {
                        buttonRect.origin.x = x * fullButtonSize.width + xspace;
                        xspace += _xspaceing;
                    }
                    
                    buttonRect.origin.y = y * fullButtonSize.height;
                    buttonRect.origin.y += yspace;
                    if (y > 0)
                    {
                        buttonRect.origin.y += _yspaceing*y;
                    }
                    
                    //LOG(@"%d,%d,%d,%f,%f",current,iconPerLine,y,buttonRect.origin.x,buttonRect.size.height);
                    b.frame = buttonRect;
                    ++current;
                }
            }
        }
    }
}


@end
