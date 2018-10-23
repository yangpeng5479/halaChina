//
//  GDShipsCell.m
//  Greadeal
//
//  Created by Elsa on 15/8/10.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDShipsCell.h"

#define xMargin  10
#define yMargin  6

#define titleHeight 20
#define titleWidth  ([[UIScreen mainScreen] bounds].size.width/320.0*270)

@implementation GDShipsCell

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
        
        _fees = MOCreateLabelAutoRTL();
        _fees.backgroundColor = [UIColor clearColor];
        _fees.textColor = MOColorSaleFontColor();
        _fees.font = MOLightFont(12);
        _fees.numberOfLines = 0;
        [self addSubview:_fees];
        
        _details = MOCreateLabelAutoRTL();
        _details.backgroundColor = [UIColor clearColor];
        _details.textColor = [UIColor grayColor];
        _details.font = MOLightFont(12);
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
    MODebugLayer(self.fees, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    
    CGRect iFrame = self.iconImage.frame;
    iFrame.origin.x = 10*[GDPublicManager instance].screenScale;
    iFrame.origin.y = 5;
    iFrame.size.width = 50;
    iFrame.size.height = 50;
    self.iconImage.frame = iFrame;
    
    iFrame = self.title.frame;
    iFrame.origin.x = 70*[GDPublicManager instance].screenScale;
    iFrame.size.width = 220*[GDPublicManager instance].screenScale;
    iFrame.size.height = 20;
    self.title.frame = iFrame;
    
    iFrame = self.fees.frame;
    iFrame.origin.x = 70*[GDPublicManager instance].screenScale;
    iFrame.origin.y = 25;
    iFrame.size.width = 220*[GDPublicManager instance].screenScale;
    iFrame.size.height = 20;
    self.fees.frame = iFrame;
    
    iFrame = self.details.frame;
    iFrame.origin.x = 70*[GDPublicManager instance].screenScale;
    iFrame.origin.y = 45;
    iFrame.size.width = 220*[GDPublicManager instance].screenScale;
    iFrame.size.height = 20;
    self.details.frame = iFrame;
    
    [self.fees findCurrency:CurrencyFontSize];
    
    if ([GDSettingManager instance].isRightToLeft)
    {
    
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
