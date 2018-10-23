//
//  GDLiveAllClassView.m
//  Greadeal
//
//  Created by Elsa on 15/6/3.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDLiveAllClassView.h"

@implementation GDLiveAllClassView

- (void)setRecentItems:(NSArray *)keys
{
    self.backgroundColor = MOColorSaleProductBackgroundColor();
    
    @synchronized(self)
    {
        items = keys;
        
        if (!itemButtons)
        {
            itemButtons = [NSMutableArray arrayWithCapacity:items.count];
        }
        else
        {
            for (UIButton *btn in itemButtons)
            {
                [btn removeFromSuperview];
            }
            
            [itemButtons removeAllObjects];
        }
        
        float butWidth = (self.bounds.size.width-self.xspaceing*(self.ItemOfLine+1))/self.ItemOfLine;
        
        float butHeight = [self getFrameHeight];
        
        int  nIndex = 0;
        
        for (NSDictionary *dict in items)
        {
            NSString*  title         = dict[@"name"];
            
            UIView*   button = [[UIView alloc] initWithFrame:CGRectMake(0, 0, butWidth, butHeight)];
            button.backgroundColor = [UIColor whiteColor];
            button.layer.cornerRadius = 4;//
            //button.layer.borderWidth = 0.5;
            //button.layer.borderColor = [[UIColor blackColor] CGColor];
            button.userInteractionEnabled = YES;
            [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)]];
            button.tag = nIndex;
            //MODebugLayer(button, 1.f, [UIColor redColor].CGColor);
            
            UILabel* titleLabel =  MOCreateLabelAutoRTL();
            titleLabel.frame=CGRectMake(0, 0, butWidth, butHeight);
            titleLabel.textAlignment =  NSTextAlignmentCenter;
            titleLabel.font = MOLightFont(12.0);
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.text = title;
            titleLabel.numberOfLines = 0;
            [button addSubview:titleLabel];
            
            [itemButtons addObject:button];
            
            [self addSubview:button];
            
            nIndex++;
        }
    }
    
    [self rearrangeButtons];
    
}

- (void)tapView:(UIGestureRecognizer *)tapGesture
{
    UIView *button = (UIView *)tapGesture.view;
    int index = (int)button.tag;
    
    NSDictionary *dict = [items objectAtIndex:index];
    
    if ([self.target respondsToSelector:self.callback])
    {
        [self.target performSelector:self.callback withObject:dict afterDelay:0];
    }
    
}

@end
