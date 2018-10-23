//
//  GDProductIntroView.m
//  Greadeal
//
//  Created by Elsa on 15/6/4.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDProductIntroView.h"
#define  yMargin  3

@implementation GDProductIntroView

- (void)setRecentItems:(NSArray *)keys
{
    self.backgroundColor = [UIColor clearColor];
    
    @synchronized(self)
    {
        items = keys;
        
        if (!itemButtons)
        {
            itemButtons = [NSMutableArray arrayWithCapacity:items.count];
        }
        else
        {
            for (UIView *btn in itemButtons)
            {
                [btn removeFromSuperview];
            }
            
            [itemButtons removeAllObjects];
        }
        
        float butWidth = (self.bounds.size.width-self.xspaceing*(self.ItemOfLine+1))/self.ItemOfLine;
        
        float butHeight=0.0;
        
        int  nIndex = 0;
        float offsetY = 0;
        UIFont* titleFont =  MOLightFont(12);
        
        for (NSDictionary *dict in items)
        {
            NSString*  title         = dict[@"name"];
            NSString*  details       = dict[@"text"];
            
            CGSize titleSize = [title moSizeWithFont:titleFont withWidth:[GDPublicManager instance].screenWidth-30];
            CGSize deatilsSize = [details moSizeWithFont:titleFont withWidth:[GDPublicManager instance].screenWidth-30];
            
            butHeight+=titleSize.height;
            butHeight+=deatilsSize.height;
            butHeight+=yMargin*2;
            
            
            UIView*   button = [[UIView alloc] initWithFrame:CGRectMake(self.xspaceing, offsetY, butWidth, butHeight)];
            button.backgroundColor = [UIColor clearColor];
            
            UILabel* titleLabel =  MOCreateLabelAutoRTL();
            titleLabel.frame=CGRectMake(0, 0, [GDPublicManager instance].screenWidth-30, titleSize.height);
            titleLabel.font = titleFont;
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.text = title;
            titleLabel.numberOfLines = 0;
            [button addSubview:titleLabel];
            MODebugLayer(titleLabel, 1.f, [UIColor redColor].CGColor);
            
            UILabel* deatilsLabel =  MOCreateLabelAutoRTL();
            deatilsLabel.frame=CGRectMake(0, titleSize.height+yMargin, [GDPublicManager instance].screenWidth-30, deatilsSize.height);
            deatilsLabel.font = titleFont;
            deatilsLabel.textColor = [UIColor grayColor];
            deatilsLabel.backgroundColor = [UIColor clearColor];
            deatilsLabel.text = details;
            deatilsLabel.numberOfLines = 0;
            [button addSubview:deatilsLabel];
            MODebugLayer(deatilsLabel, 1.f, [UIColor redColor].CGColor);
            [itemButtons addObject:button];
            
            [self addSubview:button];
            
            nIndex++;
            
            offsetY+=butHeight+yMargin;
            
        }
    }
}

@end
