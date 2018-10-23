//
//  GDDeliverCell.m
//  Greadeal
//
//  Created by Elsa on 15/6/6.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDDeliverCell.h"

@implementation GDDeliverCell

#define xMargin  10
#define yMargin  6

#define titleHeight 20
#define titleWidth  ([[UIScreen mainScreen] bounds].size.width/320.0*250)

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        _iconImage = [[UIImageView alloc] init];
        _iconImage.contentMode = UIViewContentModeScaleAspectFill;
        _iconImage.clipsToBounds = YES;
        [self addSubview:_iconImage];
        
        _title = MOCreateLabelAutoRTL();
        _title.backgroundColor = [UIColor clearColor];
        _title.textColor = [UIColor blackColor];
        _title.font = MOLightFont(14);
        _title.numberOfLines = 0;
        [self addSubview:_title];
        
        _details = MOCreateLabelAutoRTL();
        _details.backgroundColor = [UIColor clearColor];
        _details.textColor = [UIColor blackColor];
        _details.font = MOLightFont(14);
        _details.numberOfLines = 0;
        [self addSubview:_details];
        
    }
    return self;
}


-(void)layoutSubviews
{
    MODebugLayer(self.iconImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.title, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.details, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    
    
    float offsetX = xMargin;
    float offsetY = yMargin;
    
    self.iconImage.frame = CGRectMake(18, 0,
                                     12, self.bounds.size.height);
    
    self.title.frame = CGRectMake(offsetX+20+xMargin, offsetY,
                                 titleWidth, titleHeight);
    
    self.details.frame = CGRectMake(offsetX+20+xMargin, offsetY+titleHeight,
                                  titleWidth, titleHeight);
    
    
    if ([GDSettingManager instance].isRightToLeft)
    {
//        CGRect tempRect = self.iconImage.frame;
//        self.iconImage.frame = CGRectMake(r.size.width-tempRect.size.width-xMargin, offsetY,
//                                         22, 33);
//        self.iconImage.frame = tempRect;
//        
//        tempRect = self.title.frame;
//        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin - 20;
//        self.title.frame = tempRect;
//        
//        tempRect = self.details.frame;
//        tempRect.origin.x = self.title.frame.origin.x-tempRect.size.width-xMargin;
//        self.details.frame = tempRect;
//        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
