//
//  GDBeautyCell.m
//  Greadeal
//
//  Created by Elsa on 15/5/29.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDBeautyCell.h"

#define photoWidth  90
#define photoHeigth 120

#define titleHeight 20
#define titleWidth  200

#define xMargin  10
#define yMargin  5

@implementation GDBeautyCell

@synthesize productImage = _productImage;
@synthesize titleLabel = _titleLabel;
@synthesize originPrice = _originPrice;
@synthesize salePrice = _salePrice;
@synthesize discount = _discount;
@synthesize detail = _detail;
@synthesize cartBut = _cartBut;
@synthesize viewed = _viewed;

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
        
        _cartBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cartBut setBackgroundImage:[[UIImage imageNamed:@"cartIcon.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
        [self addSubview:_cartBut];
        
        _titleLabel = MOCreateLabelAutoRTL();
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
        
        _originPrice = [[LPLabel alloc] init];
        _originPrice.backgroundColor = [UIColor clearColor];
        _originPrice.textColor = [UIColor grayColor];
        //_originPrice.textColor = colorFromHexString(@"99999");
        _originPrice.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _originPrice.font = [UIFont systemFontOfSize:12];
        [self addSubview:_originPrice];
        
        _salePrice = MOCreateLabelAutoRTL();
        _salePrice.backgroundColor = [UIColor clearColor];
        _salePrice.textColor = colorFromHexString(@"f80e3a");
        _salePrice.font = [UIFont systemFontOfSize:14];
        [self addSubview:_salePrice];
        
        _discount = MOCreateLabelAutoRTL();
         _discount.backgroundColor = colorFromHexString(@"64A300");// colorFromHexString(@"41873f");
        _discount.textColor = [UIColor whiteColor];
        _discount.font = [UIFont systemFontOfSize:12];
        [self addSubview:_discount];
        
        _viewed = MOCreateLabelAutoRTL();
        _viewed.backgroundColor = [UIColor clearColor];
        _viewed.textColor = [UIColor grayColor];
        _viewed.font = [UIFont systemFontOfSize:12];
        [self addSubview:_viewed];
        
        _detail = MOCreateLabelAutoRTL();
        _detail.backgroundColor = [UIColor clearColor];
        _detail.textColor = [UIColor grayColor];
        _detail.font = [UIFont systemFontOfSize:12];
         _detail.numberOfLines = 0;
        [self addSubview:_detail];
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect r = self.bounds;
    self.productImage.frame = CGRectMake(xMargin, yMargin,
                                         photoWidth, photoHeigth);
    
    float offsetX = photoWidth + xMargin*2;
    float offsetY = yMargin;
    
    self.titleLabel.frame = CGRectMake(offsetX, offsetY,
                                       titleWidth, titleHeight*2);
   
//  MODebugLayer(self.productImage, 1.f, [UIColor redColor].CGColor);
//  MODebugLayer(self.titleLabel, 1.f, [UIColor redColor].CGColor);
//  MODebugLayer(self.salePrice, 1.f, [UIColor redColor].CGColor);
//  MODebugLayer(self.originPrice, 1.f, [UIColor redColor].CGColor);
//  MODebugLayer(self.discount, 1.f, [UIColor redColor].CGColor);
  
    offsetY += self.titleLabel.frame.size.height + yMargin;
    
    [self.salePrice findCurrency:CurrencyFontSize];
    [self.originPrice findCurrency:CurrencyFontSize];

    UIFont *Font = [UIFont systemFontOfSize:14];
    CGSize  titleSize = [self.salePrice.text moSizeWithFont:Font withWidth:150];
    
    //float cutLen = (currencyLen*2)*[GDPublicManager instance].currency.length;

    CGRect saleFrame = self.salePrice.frame;
    saleFrame.origin.x = offsetX;
    saleFrame.origin.y = offsetY;
    saleFrame.size.width = titleSize.width;
    saleFrame.size.height = titleHeight;
    self.salePrice.frame = saleFrame;
    
    offsetX+=self.salePrice.frame.size.width;
    
    Font = [UIFont systemFontOfSize:12];
    titleSize = [self.originPrice.text moSizeWithFont:Font withWidth:100];
    
    CGRect originFrame = self.originPrice.frame;
    originFrame.origin.x = offsetX;
    originFrame.origin.y = offsetY;
    originFrame.size.width = titleSize.width;
    originFrame.size.height = titleHeight;
    self.originPrice.frame = originFrame;

    offsetX+=self.originPrice.frame.size.width+currencyLen*2;
    
    titleSize = [self.discount.text moSizeWithFont:self.discount.font withWidth:100];
    CGRect discountFrame = self.discount.frame;
    discountFrame.origin.x = offsetX;
    discountFrame.origin.y = offsetY;
    discountFrame.size.width = titleSize.width;
    discountFrame.size.height = titleHeight;
    self.discount.frame = discountFrame;

    offsetX = photoWidth + xMargin*2;
    offsetY += discountFrame.size.height + yMargin/2;
    self.viewed.frame = CGRectMake(offsetX, offsetY,
                                   titleWidth, titleHeight);
    
    offsetY += self.viewed.frame.size.height + yMargin/2;
   
    self.detail.frame = CGRectMake(offsetX, offsetY,
                                     titleWidth, titleHeight*2);
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = self.productImage.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.productImage.frame = tempRect;
        
        tempRect = self.titleLabel.frame;
        tempRect.origin.x = xMargin;
        self.titleLabel.frame = tempRect;
        
        tempRect = self.salePrice.frame;
        tempRect.origin.x = self.productImage.frame.origin.x-tempRect.size.width-xMargin;
        self.salePrice.frame = tempRect;
        
        float offsetX = tempRect.origin.x;
        
        tempRect = self.originPrice.frame;
        tempRect.origin.x = offsetX - tempRect.size.width;
        self.originPrice.frame = tempRect;
        
        offsetX = tempRect.origin.x;
        tempRect = self.discount.frame;
        tempRect.origin.x =  offsetX - tempRect.size.width - xMargin;
        self.discount.frame = tempRect;
        
        tempRect = self.detail.frame;
        tempRect.origin.x = xMargin;
        self.detail.frame = tempRect;
        
        tempRect = self.viewed.frame;
        tempRect.origin.x = xMargin;
        self.viewed.frame = tempRect;
    }
    
    if ([self.originPrice.text isEqualToString:self.salePrice.text])
    {
        self.originPrice.hidden=YES;
    }
    else
    {
        self.originPrice.hidden=NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
