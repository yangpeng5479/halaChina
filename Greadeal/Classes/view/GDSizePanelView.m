//
//  GDSizePanelView.m
//  Greadeal
//
//  Created by Elsa on 15/6/3.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDSizePanelView.h"

#define normal  100
#define choosed 101
@implementation GDSizePanelView

- (void)setRecentItems:(NSArray *)keys
{
    self.backgroundColor = [UIColor whiteColor];
    firstChoosed = -1;
    @synchronized(self)
    {
        items = keys;
        //default
        //itemSelected = [NSMutableArray arrayWithCapacity:items.count];
        
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
            NSString*  title     =@"";
            //不在看选项库存，看总库存
            //int        quantity  = [dict[@"quantity"] intValue];
            int        quantity = self.pro_quantity;
            SET_IF_NOT_NULL(title, dict[@"option_value_name"]);
       
            UIView*   button = [[UIView alloc] initWithFrame:CGRectMake(0, 0, butWidth, butHeight)];
            if (quantity>0)
            {
                button.backgroundColor = [UIColor whiteColor];
                button.userInteractionEnabled = YES;
                
                if (firstChoosed<0)
                    firstChoosed = nIndex;
            }
            else
            {
                button.backgroundColor = [UIColor colorWithRed:236/255.0 green:237/255.0 blue:240/255.0 alpha:1.0];
                button.userInteractionEnabled = NO;
            }
            
            [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)]];
            button.tag = nIndex;
            //MODebugLayer(button, 1.f, [UIColor redColor].CGColor);
            
            UIImageView* normalLine = [[UIImageView alloc] init];
            normalLine.frame= CGRectMake(0, 0, butWidth, butHeight);
            normalLine.image = [[UIImage imageNamed:@"size_normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 1.0f)];
            
            normalLine.tag = normal;
            [button addSubview:normalLine];

            UIImageView* selectLine = [[UIImageView alloc] init];
            selectLine.frame= CGRectMake(0, 0, butWidth, butHeight);
            selectLine.image = [[UIImage imageNamed:@"size_selected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f)];
            
            selectLine.tag = choosed;
            [button addSubview:selectLine];
            selectLine.hidden = YES;
            
            UIImageView* tick = [[UIImageView alloc] init];
            tick.image = [UIImage imageNamed:@"make_tick.png"];
            tick.frame= CGRectMake(butWidth-15, butHeight-15, 15, 15);
            [selectLine addSubview:tick];
                       
            UILabel* titleLabel =  MOCreateLabelAutoRTL();
            titleLabel.frame=CGRectMake(0, 0, butWidth, butHeight);
            titleLabel.textAlignment =  NSTextAlignmentCenter;
            titleLabel.font = MOLightFont(12);
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.text = title;
            [button addSubview:titleLabel];
            
            [itemButtons addObject:button];
            //[itemSelected addObject:[NSNumber numberWithBool:NO]];
        
            [self addSubview:button];
            
            nIndex++;
        }
    }
    
    [self rearrangeButtons];
    
    if (itemButtons.count > firstChoosed)
    {
        UIButton *button = [itemButtons objectAtIndex:firstChoosed];
        int index = (int)button.tag;
        [self defaultChoosed:index withChoosed:button];
    }
    
}

- (void)defaultChoosed:(int)index withChoosed:(UIView *)button
{
    NSDictionary *dict = [items objectAtIndex:index];
    
    if ([self.target respondsToSelector:self.callback])
    {
        [self.target performSelector:self.callback withObject:dict afterDelay:0];
    }
    
    //clear choose
    for (UIButton *b in itemButtons)
    {
        for (UILabel *label in b.subviews)
        {
            if ([label isKindOfClass:[UILabel class]])
            {
                label.textColor = [UIColor blackColor];
            }
        }
        
        for (UIImageView *image in b.subviews)
        {
            if ([image isKindOfClass:[UIImageView class]])
            {
                if (image.tag == normal)
                    image.hidden = NO;
                else if (image.tag == choosed)
                    image.hidden = YES;
            }
        }
    }
    //tick choose
    for (UIImageView *image in button.subviews)
    {
        if ([image isKindOfClass:[UIImageView class]])
        {
            if (image.tag == normal)
                image.hidden = YES;
            else if (image.tag == choosed)
                image.hidden = NO;
        }
    }
    for (UILabel *label in button.subviews)
    {
        if ([label isKindOfClass:[UILabel class]])
        {
            label.textColor = MOAppTextBackColor();
        }
    }

}
- (void)tapView:(UIGestureRecognizer *)tapGesture
{
    UIView *button = (UIView *)tapGesture.view;
    int index = (int)button.tag;
    
    [self defaultChoosed:index withChoosed:button];
}


@end
