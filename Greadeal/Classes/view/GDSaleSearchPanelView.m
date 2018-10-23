//
//  GDSaleSearchPanelView.m
//  Greadeal
//
//  Created by Elsa on 15/5/21.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDSaleSearchPanelView.h"

#define textHeight 20

@implementation GDSaleSearchPanelView

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
            for (UIButton *btn in itemButtons)
            {
                [btn removeFromSuperview];
            }
            
            [itemButtons removeAllObjects];
        }
        //LOG(@"self.bounds.size.width=%f",self.bounds.size.width);
        float butWidth = (self.bounds.size.width-self.xspaceing*(self.ItemOfLine+1))/self.ItemOfLine;
        
        float butHeight = [self getFrameHeight];
        int  nIndex = 0;
        
        for (NSDictionary *dict in items)
        {
            NSString*  image_url = dict[@"image"];
            NSString*  title     = dict[@"name"];
            
            UIView*   button = [[UIView alloc] initWithFrame:CGRectMake(0, 0, butWidth, butHeight)];
            
            button.userInteractionEnabled = YES;
            [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)]];
            button.tag = nIndex;
            MODebugLayer(button, 1.f, [UIColor redColor].CGColor);
            
            float offsetX = (butWidth-self.imageWidth)/2;
            float offsetY = (self.LineHeight-self.imageHeight-textHeight)/2;
            
            UIImageView * iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(offsetX, 0, self.imageWidth, self.imageHeight)];
            iconImage.contentMode = UIViewContentModeScaleAspectFill;
            [iconImage setClipsToBounds:YES];
            [iconImage sd_setImageWithURL: [NSURL URLWithString:[image_url encodeUTF]] placeholderImage:[UIImage imageNamed: @"sale_category_default.png"]];
            [button addSubview:iconImage];
            MODebugLayer(iconImage, 1.f, [UIColor blackColor].CGColor);
            
            offsetY=self.imageHeight+self.yspaceing;
            UILabel* iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, offsetY, butWidth, 30)];
            iconLabel.textAlignment = NSTextAlignmentCenter;
            iconLabel.font = MOLightFont(12);
            iconLabel.textColor = MOColor33Color();
            iconLabel.backgroundColor = [UIColor clearColor];
            iconLabel.text = title;
            iconLabel.numberOfLines = 0;
            [button addSubview:iconLabel];
            MODebugLayer(iconLabel, 1.f, [UIColor blueColor].CGColor);
           
            CGSize titleSize = [iconLabel.text moSizeWithFont:iconLabel.font withWidth:butWidth];
            CGRect size = iconLabel.frame;
            size.size.height = titleSize.height<30?titleSize.height:30;
            iconLabel.frame = size;
        
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
