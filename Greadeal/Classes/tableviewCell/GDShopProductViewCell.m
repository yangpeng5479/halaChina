//
//  GDShopProductViewCell.m
//  Greadeal
//
//  Created by Elsa on 16/2/1.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDShopProductViewCell.h"

#define xMargin 6
#define yMargin 8

#define photoWidth  75
#define photoHeigth 75

@implementation GDShopProductViewCell

@synthesize productImage  = _productImage;
@synthesize productLabel  = _productLabel;

@synthesize saleLabel     = _saleLabel;
@synthesize originLabel   = _originLabel;
@synthesize soldLabel     = _soldLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        _productImage = [[UIImageView alloc] init];
        _productImage.backgroundColor = [UIColor clearColor];
        _productImage.contentMode = UIViewContentModeScaleAspectFill;
        _productImage.clipsToBounds = YES;
        [self addSubview:_productImage];
        
        _productLabel =  MOCreateLabelAutoRTL();
        _productLabel.font = MOLightFont(14);
        _productLabel.textColor = MOColor66Color();
        _productLabel.numberOfLines = 0;
        [self addSubview:_productLabel];
       
        _originLabel = [[LPLabel alloc] init];
        _originLabel.backgroundColor = [UIColor clearColor];
        _originLabel.textColor = MOColor66Color();
        _originLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _originLabel.font = MOLightFont(14);
        [self addSubview:_originLabel];
        
        _saleLabel = MOCreateLabelAutoRTL();
        _saleLabel.backgroundColor = [UIColor clearColor];
        _saleLabel.textColor = MOColorSaleFontColor();
        _saleLabel.font = MOLightFont(18);
        [self addSubview:_saleLabel];
        
        _soldLabel = MOCreateLabelAutoRTL();
        _soldLabel.backgroundColor = [UIColor clearColor];
        _soldLabel.textColor = MOColor66Color();
        _soldLabel.font = MOLightFont(12);
        [self addSubview:_soldLabel];
        _soldLabel.textAlignment = NSTextAlignmentRight;
     
    }
    return self;
}


- (void)layoutSubviews
{
    MODebugLayer(self.productImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.productLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.originLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.saleLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.soldLabel, 1.f, [UIColor redColor].CGColor);
   
    [super layoutSubviews];
    CGRect r = self.bounds;
    
    self.productImage.frame = CGRectMake(xMargin, yMargin,
                                         photoWidth, photoHeigth);
    
    float offsetX = xMargin;
    float offsetY = yMargin*2+photoHeigth;
    
    
    offsetX = photoWidth  + xMargin*2 ;
    offsetY = yMargin;
    
    self.productLabel.frame = CGRectMake(offsetX, offsetY,
                                         [GDPublicManager instance].screenWidth-offsetX-xMargin, titleHeight*3);
    offsetY+=titleHeight*3+10;
    
    [self.originLabel findCurrency:CurrencyFontSize];
    [self.saleLabel   findCurrency:CurrencyFontSize];
    
    CGRect saleFrame = self.saleLabel.frame;
    saleFrame.origin.x = offsetX;
    saleFrame.origin.y = offsetY;
    saleFrame.size.width = 80;
    saleFrame.size.height = titleHeight;
    self.saleLabel.frame = saleFrame;
    
    offsetX+=self.saleLabel.frame.size.width;
    
    CGRect originFrame = self.originLabel.frame;
    originFrame.origin.x = offsetX;
    originFrame.origin.y = offsetY;
    originFrame.size.width = 80;
    originFrame.size.height = titleHeight;
    self.originLabel.frame = originFrame;
    
    self.soldLabel.frame = CGRectMake([GDPublicManager instance].screenWidth-xMargin-80, offsetY,80, titleHeight);
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = self.productImage.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.productImage.frame = tempRect;
        
        tempRect = self.productLabel.frame;
        tempRect.origin.x = self.productImage.frame.origin.x-tempRect.size.width - xMargin;
        self.productLabel.frame = tempRect;
        
        tempRect = self.saleLabel.frame;
        tempRect.origin.x = self.productImage.frame.origin.x-tempRect.size.width-xMargin;
        self.saleLabel.frame = tempRect;
        
    }
    
    if ([self.originLabel.text isEqualToString:self.saleLabel.text])
    {
        self.originLabel.hidden=YES;
    }
    else
    {
        self.originLabel.hidden=NO;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
