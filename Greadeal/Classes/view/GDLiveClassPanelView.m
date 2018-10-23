//
//  GDLiveClassPanelView.m
//  Greadeal
//
//  Created by Elsa on 15/5/15.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDLiveClassPanelView.h"

#define textHeight 20

@implementation GDLiveClassPanelView

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
        
        float butWidth = (self.bounds.size.width-self.xspaceing*(self.ItemOfLine+1))/self.ItemOfLine;
        //self.bounds.size.height;
        float butHeight = [self getFrameHeight];
        
        int  nIndex = 0;
        
        for (NSDictionary *dict in items)
        {
            NSString*  image_url = dict[@"image"];
            NSString*  title     = dict[@"title"];
            int        category_id = [dict[@"category_id"] intValue];
            
            UIView*   button = [[UIView alloc] initWithFrame:CGRectMake(0, 0, butWidth, butHeight)];
            
            button.userInteractionEnabled = YES;
            [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)]];
            button.tag = nIndex;
            //MODebugLayer(button, 1.f, [UIColor redColor].CGColor);
            
            float offsetX = (butWidth-self.imageWidth)/2;
            //float offsetY = (self.LineHeight-self.imageHeight-textHeight)/2;
            float offsetY = 5;
            
            UIImageView * iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(offsetX, offsetY, self.imageWidth, self.imageHeight)];
            iconImage.contentMode = UIViewContentModeScaleAspectFill;
            [iconImage setClipsToBounds:YES];
            if (category_id == 100000)
                iconImage.image = [UIImage imageNamed:@"all_categories.png"];
            else
                [iconImage sd_setImageWithURL: [NSURL URLWithString:[image_url encodeUTF]] placeholderImage:[UIImage imageNamed:@"live_icon_default.png"]];
            
            [button addSubview:iconImage];
            //iconImage.layer.cornerRadius =self.imageHeight/2.0;
            //MODebugLayer(iconImage, 1.f, [UIColor blackColor].CGColor);
            
            offsetY+=self.imageHeight+self.yspaceing;
            UILabel* iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, offsetY, butWidth, 30)];
            iconLabel.textAlignment = NSTextAlignmentCenter;
            iconLabel.font = MOLightFont(12.0);
            iconLabel.textColor = MOColor33Color();
            iconLabel.backgroundColor = [UIColor clearColor];
            iconLabel.text = title;
            iconLabel.numberOfLines = 0;
            [button addSubview:iconLabel];
            MODebugLayer(iconLabel, 1.f, [UIColor redColor].CGColor);
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
