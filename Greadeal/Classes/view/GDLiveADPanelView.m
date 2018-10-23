//
//  GDLiveADPanelView.m
//  Greadeal
//
//  Created by Elsa on 15/5/15.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDLiveADPanelView.h"
#import "LPLabel.h"

#define textHeight 20

@implementation GDLiveADPanelView

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
       
        float butHeight = [self getFrameHeight];
        
        int  nIndex = 0;
        
        self.imageHeight = butHeight - textHeight*2-10;
        
        for (NSDictionary *dict in items)
        {
            NSString*  image_url     = dict[@"image"];
            NSString*  title         = dict[@"name"];
            NSString*  sprice         = dict[@"sprice"];
            NSString*  oprice   = dict[@"oprice"];
            
            UIView*   button = [[UIView alloc] initWithFrame:CGRectMake(0, 0, butWidth, butHeight)];
            
            button.userInteractionEnabled = YES;
            [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)]];
            button.tag = nIndex;
            MODebugLayer(button, 1.f, [UIColor redColor].CGColor);
            
            float offsetY = 0;
            
            UIImageView * iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, offsetY, butWidth, butWidth/1.33)];

            iconImage.contentMode = UIViewContentModeScaleAspectFill;
            [iconImage setClipsToBounds:YES];
            [iconImage sd_setImageWithURL: [NSURL URLWithString:[image_url encodeUTF]]];
            [button addSubview:iconImage];
            MODebugLayer(iconImage, 1.f, [UIColor blackColor].CGColor);
            
            offsetY+= butWidth/1.33+5;
            float    labelRealHeight = 30*[GDPublicManager instance].screenScale;
            float    iconHeight = 30;//*[GDPublicManager instance].screenScale;
            
            UILabel* iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, offsetY+(labelRealHeight-iconHeight)/2, butWidth, iconHeight)];
            iconLabel.textAlignment = NSTextAlignmentCenter;
            iconLabel.font = MOLightFont(12.0);
            iconLabel.textColor = [UIColor grayColor];
            iconLabel.backgroundColor = [UIColor clearColor];
            iconLabel.text = title;
            iconLabel.numberOfLines = 0;
            [button addSubview:iconLabel];
            MODebugLayer(iconLabel, 1.f, [UIColor redColor].CGColor);
            
            offsetY+=iconLabel.frame.size.height+self.yspaceing+(labelRealHeight-iconHeight)/2;
            
            UILabel* priceLabel = [[UILabel alloc] init];
            priceLabel.textAlignment =  NSTextAlignmentRight;
            priceLabel.font = MOLightFont(14.0);
            priceLabel.textColor = MOColorSaleFontColor();
            priceLabel.backgroundColor = [UIColor clearColor];
            priceLabel.text = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].currency, sprice];
            [button addSubview:priceLabel];
            MODebugLayer(priceLabel, 1.f, [UIColor redColor].CGColor);

            LPLabel* originLabel = [[LPLabel alloc] init];
            originLabel.backgroundColor = [UIColor clearColor];
            originLabel.textColor = [UIColor grayColor];
            originLabel.font = MOLightFont(10.0);
            originLabel.textAlignment =  NSTextAlignmentLeft;
            originLabel.text = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].currency, oprice];
            [button addSubview:originLabel];
            MODebugLayer(iconLabel, 1.f, [UIColor blackColor].CGColor);

            [priceLabel  findCurrency:CurrencyFontSize];
            //[originLabel findCurrency];
            
            float  saleWidth = 0;
            float  originWidth = 0;
            
            UIFont *Font = MOLightFont(14);
            CGSize  titleSize = [priceLabel.text moSizeWithFont:Font withWidth:80*[GDPublicManager instance].screenScale];
            saleWidth = titleSize.width;
            
            Font = MOLightFont(12);
            titleSize = [originLabel.text moSizeWithFont:Font withWidth:80*[GDPublicManager instance].screenScale];
            originWidth = titleSize.width;
            
            float offsetX = (butWidth - saleWidth - originWidth)/2;
            
            priceLabel.frame = CGRectMake(offsetX, offsetY, saleWidth, textHeight);
           
            originLabel.frame = CGRectMake(priceLabel.frame.size.width+2+offsetX, offsetY+2, originWidth, textHeight);
            
            
            titleSize = [iconLabel.text moSizeWithFont:iconLabel.font withWidth:butWidth];
            CGRect size = iconLabel.frame;
            size.size.height = titleSize.height<iconHeight?titleSize.height:iconHeight;
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