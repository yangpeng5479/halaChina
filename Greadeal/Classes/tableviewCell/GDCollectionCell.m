//
//  GDCollectionCell.m
//  Greadeal
//
//  Created by Elsa on 15/6/3.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDCollectionCell.h"
#define PhotoHeight    200
#define PhoneWidth     150

#define AEDHeight 20

#define xMargin  5
#define yMargin  8

@implementation GDCollectionCell

@synthesize photoView = _photoView;
@synthesize titleLabel = _titleLabel;
@synthesize salePrice = _salePrice;
@synthesize originPrice = _originPrice;
@synthesize discount = _discount;
@synthesize cartBut = _cartBut;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _photoView = [[UIImageView alloc] init];
        _photoView.contentMode = UIViewContentModeScaleAspectFill;
        _photoView.clipsToBounds = YES;
        [self addSubview:_photoView];
        
        _titleLabel = MOCreateLabelAutoRTL();
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = MOColor33Color();
        _titleLabel.font = MOLightFont(12);
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        _salePrice = MOCreateLabelAutoRTL();
        _salePrice.backgroundColor = [UIColor whiteColor];
        _salePrice.textColor = MOColorSaleFontColor();
        _salePrice.font = MOLightFont(20);
        [self addSubview:_salePrice];

        _originPrice = [[LPLabel alloc] init];
        _originPrice.backgroundColor = [UIColor clearColor];
        _originPrice.textColor = colorFromHexString(@"999999");
        _originPrice.font = MOLightFont(14);
        [self addSubview:_originPrice];
        
        _discount = MOCreateLabelAutoRTL();
        _discount.backgroundColor = colorFromHexString(@"64A300");//
        _discount.textColor = [UIColor whiteColor];
        _discount.font = MOLightFont(14);
        _discount.numberOfLines = 0;
        _discount.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_discount];

        _cartBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cartBut setBackgroundImage:[[UIImage imageNamed:@"cartIcon_normal.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
        //[self addSubview:_cartBut];
        
    }
    return self;
}

- (void)adjustFont
{
    float offsetX = xMargin;
    float offsetY = PhotoHeight*[GDPublicManager instance].screenScale+self.titleLabel.frame.size.height;
    offsetY+=yMargin;
    
    [self.salePrice findCurrency:CurrencyFontSize];
    [self.originPrice findCurrency:CurrencyFontSize];
    [self.discount findOff];
    
    UIFont *Font = MOLightFont(20);
    CGSize  titleSize = [self.salePrice.text moSizeWithFont:Font withWidth:100];
    
    CGRect saleFrame = self.salePrice.frame;
    saleFrame.origin.x = offsetX;
    saleFrame.origin.y = offsetY;
    saleFrame.size.width = titleSize.width;
    saleFrame.size.height = 20;
    self.salePrice.frame = saleFrame;
    
    offsetX+=self.salePrice.frame.size.width+xMargin;
    Font = MOLightFont(14);
    titleSize = [self.originPrice.text moSizeWithFont:Font withWidth:100];
    
    CGRect originFrame = self.originPrice.frame;
    originFrame.origin.x = offsetX;
    originFrame.origin.y = offsetY;
    originFrame.size.width = titleSize.width;
    originFrame.size.height = 20;
    self.originPrice.frame = originFrame;
    
    self.discount.frame = CGRectMake(xMargin, 0, 40,40);
    if ([self.originPrice.text isEqualToString:self.salePrice.text])
    {
        self.originPrice.hidden=YES;
        self.discount.hidden = YES;
    }
    else
    {
        self.originPrice.hidden=NO;
        self.discount.hidden = NO;
    }
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect r = self.bounds;
        
        CGRect  tempRect = self.salePrice.frame;
        tempRect.origin.x =r.size.width-tempRect.size.width-xMargin;
        self.salePrice.frame = tempRect;
        
        tempRect = self.originPrice.frame;
        tempRect.origin.x = self.salePrice.frame.origin.x - tempRect.size.width - xMargin;
        self.originPrice.frame = tempRect;
        
        tempRect = self.cartBut.frame;
        tempRect.origin.x = xMargin;
        self.cartBut.frame = tempRect;
        
    }
    
}
- (void)layoutSubviews {
    
    MODebugLayer(self.photoView, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.titleLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.salePrice, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.originPrice, 1.f, [UIColor redColor].CGColor);
// 
    CGRect r = self.bounds;
    self.photoView.frame = CGRectMake((r.size.width-PhoneWidth*[GDPublicManager instance].screenScale)/2, r.origin.y, PhoneWidth*[GDPublicManager instance].screenScale,PhotoHeight*[GDPublicManager instance].screenScale);
    
    self.titleLabel.frame = CGRectMake(xMargin, PhotoHeight*[GDPublicManager instance].screenScale+yMargin/2,r.size.width-xMargin*2, r.size.height - self.photoView.frame.origin.y - self.photoView.frame.size.height - yMargin - AEDHeight);
    
    [self adjustFont];

}


@end
