//
//  GDProductInfoView.m
//  Greadeal
//
//  Created by Elsa on 15/6/4.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDProductInfoView.h"

@implementation GDProductInfoView

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
        
        float butHeight;
        
        int  nIndex = 0;
        float offsetY = 0;
        UIFont* titleFont = MOLightFont(infotextSize);
        
        for (NSDictionary *dict in items)
        {
            NSString*  title         = dict[@"name"];
            NSString*  details       = dict[@"text"];
            
            CGSize titleSize = [title moSizeWithFont:titleFont withWidth:titleMaxWidth];
            CGSize deatilsSize = [details moSizeWithFont:titleFont withWidth:detailsMaxWidth];
       
            if (deatilsSize.height>titleSize.height)
                butHeight=deatilsSize.height;
            else
                butHeight=titleSize.height;
            
            UIView*   button = [[UIView alloc] initWithFrame:CGRectMake(self.xspaceing, offsetY, butWidth, butHeight)];
            button.backgroundColor = [UIColor clearColor];
            
            UILabel* titleLabel =  MOCreateLabelAutoRTL();
            titleLabel.frame=CGRectMake(0, 0, titleMaxWidth, titleSize.height);
            titleLabel.font = titleFont;
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.text = title;
            titleLabel.numberOfLines = 0;
            [button addSubview:titleLabel];
            
            UILabel* deatilsLabel =  MOCreateLabelAutoRTL();
            deatilsLabel.frame=CGRectMake(titleMaxWidth+10, 0, butWidth-titleMaxWidth-10, deatilsSize.height);
            deatilsLabel.font = titleFont;
            deatilsLabel.textColor = [UIColor grayColor];
            deatilsLabel.backgroundColor = [UIColor clearColor];
            deatilsLabel.text = details;
            deatilsLabel.numberOfLines = 0;
            [button addSubview:deatilsLabel];
            
            [itemButtons addObject:button];
            
            [self addSubview:button];
            
            nIndex++;
            
            offsetY+=butHeight+yMargin;
           
             //MODebugLayer(button, 1.f, [UIColor redColor].CGColor);
             MODebugLayer(titleLabel, 1.f, [UIColor redColor].CGColor);
             MODebugLayer(deatilsLabel, 1.f, [UIColor redColor].CGColor);
            
            if ([GDSettingManager instance].isRightToLeft)
            {
                CGRect tempRect = titleLabel.frame;
                tempRect.origin.x = butWidth-tempRect.size.width;
                titleLabel.frame = tempRect;
                
                tempRect = deatilsLabel.frame;
                tempRect.origin.x = 0;
                deatilsLabel.frame = tempRect;
            }
        }
    }
}


@end
