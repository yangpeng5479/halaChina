//
//  UIOperationADView.m
//  Greadeal
//
//  Created by Elsa on 16/8/2.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "UIOperationADView.h"

#define xspaceing  12
#define yspaceing  15

#define imageWidth  95
#define imageHeight 130

@implementation UIOperationADView

- (void)setRecentItems:(NSArray *)keys
{
    self.backgroundColor = [UIColor whiteColor];
    
    self.pagingEnabled = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    @synchronized(self)
    {
        items = [NSMutableArray arrayWithCapacity:keys.count];
        [items addObjectsFromArray:keys];
        
        float butWidth  = imageWidth;
        float butHeight = imageHeight;
        
        int   nIndex = 0;
        float xOffset = xspaceing;
        
        for (NSDictionary *dict in items)
        {
            NSString*  image_url = dict[@"image"];
            NSString*  title     = dict[@"title"];
            
            UIView*   button = [[UIView alloc] initWithFrame:CGRectMake(xOffset, yspaceing, butWidth, butHeight)];
            
            button.userInteractionEnabled = YES;
            [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)]];
            button.tag = nIndex;
            MODebugLayer(button, 1.f, [UIColor redColor].CGColor);
            
         
            UIImageView * iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
            iconImage.contentMode = UIViewContentModeScaleAspectFill;
            [iconImage setClipsToBounds:YES];
           
            [iconImage sd_setImageWithURL: [NSURL URLWithString:[image_url encodeUTF]] placeholderImage:[UIImage imageNamed:@"live_icon_default.png"]];
            
            [button addSubview:iconImage];
            //iconImage.layer.cornerRadius =self.imageHeight/2.0;
            //MODebugLayer(iconImage, 1.f, [UIColor blackColor].CGColor);
            
            UILabel* iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, imageWidth, 40)];
            iconLabel.textAlignment = NSTextAlignmentCenter;
            iconLabel.font = MOBlodFont(13.0);
            iconLabel.textColor = [UIColor whiteColor];
            iconLabel.backgroundColor = [UIColor clearColor];
            iconLabel.text = title;
            iconLabel.numberOfLines = 0;
            [button addSubview:iconLabel];
            MODebugLayer(iconLabel, 1.f, [UIColor redColor].CGColor);
           
//            CGSize titleSize = [iconLabel.text moSizeWithFont:iconLabel.font withWidth:butWidth];
//            CGRect size = iconLabel.frame;
//            size.size.height = titleSize.height<30?titleSize.height:30;
//            iconLabel.frame = size;
            
            [self addSubview:button];
            
            nIndex++;
            
            xOffset = button.frame.origin.x+button.frame.size.width;
            xOffset += xspaceing;
        }
        
        self.contentSize = CGSizeMake(xOffset, imageHeight);
        
    }
    
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
