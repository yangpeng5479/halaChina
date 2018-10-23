//
//  GDSuperADPanelView.m
//  Greadeal
//
//  Created by Elsa on 15/5/15.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDSuperADPanelView.h"

@implementation GDSuperADPanelView

- (void)setRecentItems:(NSArray *)keys
{
    self.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *colorArr = [[NSMutableArray alloc] init];
    [colorArr addObject:colorFromHexString(@"c95871")];
    [colorArr addObject:colorFromHexString(@"e13e18")];
    [colorArr addObject:colorFromHexString(@"52a000")];
    [colorArr addObject:colorFromHexString(@"9b34c3")];
    [colorArr addObject:colorFromHexString(@"76ecd9")];
    [colorArr addObject:colorFromHexString(@"8dd12f")];
    [colorArr addObject:colorFromHexString(@"f0980e")];
    
    self.imageHeight = 44;
    self.imageWidth  = 44;
    
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
            NSString*  image_url     = dict[@"vendor_image"];
            NSString*  name          = dict[@"vendor_name"];
            NSString* area;
            NSString* city;
            SET_IF_NOT_NULL(area,dict[@"zone_area_name"]);
            SET_IF_NOT_NULL(city,dict[@"zone_name"]);
            NSString* summer = [NSString stringWithFormat:@"%@, %@",area!=nil?area:@"",city!=nil?city:@""];
            
            UIView*   button = [[UIView alloc] initWithFrame:CGRectMake(0, 0, butWidth, butHeight)];
            button.backgroundColor = [UIColor whiteColor];
            
            button.userInteractionEnabled = YES;
            [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)]];
            button.tag = nIndex;
            //MODebugLayer(button, 1.f, [UIColor redColor].CGColor);
            
            float offsetY = 5;
            
            UILabel* titleLabel =  MOCreateLabelAutoRTL();
            titleLabel.frame=CGRectMake(8, offsetY, butWidth-10, 25);
            titleLabel.textAlignment =  NSTextAlignmentLeft;
            titleLabel.font = MOLightFont(14);
            titleLabel.textColor = [colorArr objectAtIndex:nIndex%colorArr.count];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.text = name;
            [button addSubview:titleLabel];
            MODebugLayer(titleLabel, 1.f, [UIColor redColor].CGColor);
            
            offsetY+=titleLabel.frame.size.height;
            
            UILabel* nameLabel =  MOCreateLabelAutoRTL();
            nameLabel.textAlignment =  NSTextAlignmentLeft;
            nameLabel.frame = CGRectMake(8, offsetY, butWidth-15-self.imageWidth, 45);
            nameLabel.font = MOLightFont(12);
            nameLabel.textColor = [UIColor grayColor];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.text = summer;
            nameLabel.numberOfLines = 0;
            [button addSubview:nameLabel];
            MODebugLayer(nameLabel, 1.f, [UIColor redColor].CGColor);

            offsetY=33;
            
            UIImageView * iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(nameLabel.frame.size.width+nameLabel.frame.origin.x+5, offsetY, self.imageWidth, self.imageHeight)];
            iconImage.contentMode = UIViewContentModeScaleAspectFill;
            [iconImage setClipsToBounds:YES];
            [iconImage sd_setImageWithURL: [NSURL URLWithString:[image_url encodeUTF]] placeholderImage:[UIImage imageNamed:@"live_store_default.png"]];
            [button addSubview:iconImage];
            iconImage.layer.cornerRadius =self.imageHeight/2.0;
            MODebugLayer(iconImage, 1.f, [UIColor blackColor].CGColor);
            
            offsetY+= self.LineHeight;
            
            [itemButtons addObject:button];
            
            [self addSubview:button];
            
            CGRect br = button.frame;
            
            UIImageView* topLine = [[UIImageView alloc] init];
            topLine.image = [[UIImage imageNamed:@"productLline.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
            topLine.frame= CGRectMake(br.origin.x, 0,
                                             br.size.width, 0.5);
            [button addSubview:topLine];
            
            if (nIndex==items.count-1 || nIndex==items.count-2)
            {
                UIImageView* footLine = [[UIImageView alloc] init];
                footLine.image = [[UIImage imageNamed:@"productLline.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
                footLine.frame= CGRectMake(br.origin.x, br.size.height,
                                          br.size.width, 0.5);
                [button addSubview:footLine];
            }
            
            UIImageView* verticalLine = [[UIImageView alloc] init];
            verticalLine.image = [[UIImage imageNamed:@"horizontalLine.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
            verticalLine.frame= CGRectMake(br.size.width-1, 0,
                                      1, br.size.height);
            [button addSubview:verticalLine];
            
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
