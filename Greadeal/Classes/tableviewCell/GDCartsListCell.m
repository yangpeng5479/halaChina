//
//  GDCartsListCell.m
//  Greadeal
//
//  Created by Elsa on 15/5/16.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDCartsListCell.h"

#define xMargin  8
#define yMargin  6

#define nonSalePhotoHeigth ([[UIScreen mainScreen] bounds].size.width/320.0*54)
#define nonSaleOffsetY 20

#define photoHeigth 75
#define photoWidth  75

#define titleHeight 20
#define titleWidth  ([[UIScreen mainScreen] bounds].size.width/320.0*225)

#define xSpace  6

@implementation GDCartsListCell

@synthesize productImage = _productImage;
@synthesize titleLabel   = _titleLabel;
@synthesize originPrice  = _originPrice;
@synthesize salePrice    = _salePrice;

@synthesize subtractionBut = _subtractionBut;
@synthesize qtyLabel       = _qtyLabel;
@synthesize addBut         = _addBut;

@synthesize modiImage = _modiImage;
@synthesize subLabel  = _subLabel;

@synthesize discount    =_discount;

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
        
        _modiImage = [[UIImageView alloc] init];
        _modiImage.image = [UIImage imageNamed:@"box.png"];
        [self addSubview:_modiImage];
        
        _titleLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = MOColor33Color();
        _titleLabel.font = MOLightFont(14);
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
        if ([GDSettingManager instance].isRightToLeft)
        {
            _titleLabel.textAlignment = NSTextAlignmentRight;
        }
        
        _originPrice = [[LPLabel alloc] init];
        _originPrice.backgroundColor = [UIColor clearColor];
        _originPrice.textColor = colorFromHexString(@"999999");
        _originPrice.font = MOLightFont(14);
        //[self addSubview:_originPrice];
        
        _salePrice = MOCreateLabelAutoRTL();
        _salePrice.backgroundColor = [UIColor clearColor];
        _salePrice.textColor = MOColorSaleFontColor();
        _salePrice.font = MOLightFont(18);
        [self addSubview:_salePrice];
        
        _deleteBut=[UIButton buttonWithType:UIButtonTypeCustom];
       [_deleteBut setImage:[UIImage imageNamed:@"del_normal.png"]  forState:UIControlStateNormal];
        [self addSubview:_deleteBut];
       
        _subtractionBut=[UIButton buttonWithType:UIButtonTypeCustom];
        [_subtractionBut setImage:[UIImage imageNamed:@"redu_normal.png"] forState:UIControlStateNormal];
        [self addSubview:_subtractionBut];
        
        _addBut=[UIButton buttonWithType:UIButtonTypeCustom];
        [_addBut setImage:[UIImage imageNamed:@"plus_normal.png"]  forState:UIControlStateNormal];
        [self addSubview:_addBut];

        _qtyLabel = MOCreateLabelAutoRTL();
        _qtyLabel.textAlignment = NSTextAlignmentCenter;
        _qtyLabel.backgroundColor = [UIColor clearColor];
        _qtyLabel.textColor = MOAppTextBackColor();
        _qtyLabel.font = MOLightFont(16);
        [self addSubview:_qtyLabel];
    
        _discount = MOCreateLabelAutoRTL();
        _discount.backgroundColor = colorFromHexString(@"64A300");
        _discount.textColor = [UIColor whiteColor];
        _discount.font = MOLightFont(12);
        [self addSubview:_discount];
    }
    return self;
}


- (void)layoutSubviews
{
    MODebugLayer(self.productImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.titleLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.originPrice, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.salePrice, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.discount, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.addBut, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.subtractionBut, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.deleteBut, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    
    CGRect r = self.bounds;
    
    self.productImage.frame = CGRectMake(xMargin, yMargin,
                                         photoWidth,photoHeigth);
    
    
    float offsetX = photoWidth + xMargin*2;
    float offsetY = yMargin;
    
    self.titleLabel.frame = CGRectMake(offsetX, offsetY,
                                       titleWidth, titleHeight*3);
    offsetY += self.titleLabel.frame.size.height;
    
    [self.salePrice findCurrency:CurrencyFontSize];
    [self.originPrice findCurrency:CurrencyFontSize];
    [self.discount findOff];
    
    CGRect saleFrame = self.salePrice.frame;
    saleFrame.origin.x = offsetX;
    saleFrame.origin.y = offsetY;
    saleFrame.size.width = 80*[GDPublicManager instance].screenScale;
    saleFrame.size.height = titleHeight;
    self.salePrice.frame = saleFrame;
    
    offsetX+=self.salePrice.frame.size.width +xSpace;
    

    CGRect originFrame = self.originPrice.frame;
    originFrame.origin.x = offsetX;
    originFrame.origin.y = offsetY;
    originFrame.size.width = 75*[GDPublicManager instance].screenScale;
    originFrame.size.height = titleHeight;
    self.originPrice.frame = originFrame;
    
    offsetX+=self.originPrice.frame.size.width+xSpace;
    
    CGRect discountFrame = self.discount.frame;
    discountFrame.origin.x = offsetX;
    discountFrame.origin.y = offsetY;
    if (self.discount.text.length>0)
    {
        discountFrame.size.width = 50*[GDPublicManager instance].screenScale;
    }
    else
    {
        discountFrame.size.width = 0;
    }
    discountFrame.size.height = titleHeight;
    self.discount.frame = discountFrame;
 
    offsetY +=titleHeight+yMargin;
    offsetX = photoWidth + xMargin*2;
    CGRect modiFrame = self.modiImage.frame;
    modiFrame.origin.x = offsetX;
    modiFrame.origin.y = offsetY;
    modiFrame.size.width = 80;
    modiFrame.size.height = 26;
    self.modiImage.frame = modiFrame;
    
    CGRect subFrame = self.subtractionBut.frame;
    subFrame.origin.x = modiFrame.origin.x-xMargin-4;
    subFrame.origin.y = modiFrame.origin.y-yMargin;
    subFrame.size.width = 50;
    subFrame.size.height = 40;
    self.subtractionBut.frame = subFrame;
    
    offsetX = subFrame.origin.x+40;
    self.qtyLabel.frame = CGRectMake(offsetX, modiFrame.origin.y,
                                     80/3.0, modiFrame.size.height);
    
    offsetX = subFrame.origin.x+50+xMargin/2;
    self.addBut.frame = CGRectMake(offsetX, modiFrame.origin.y-yMargin,
                                           50, 40);
   
    
    offsetX = r.size.width-60;
   
    self.deleteBut.frame = CGRectMake(offsetX, offsetY-yMargin,
                                       60, 40);

    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = self.productImage.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.productImage.frame = tempRect;
        
        tempRect = self.titleLabel.frame;
        tempRect.origin.x = self.productImage.frame.origin.x-tempRect.size.width-xMargin;
        self.titleLabel.frame = tempRect;
        
        tempRect = self.salePrice.frame;
        tempRect.origin.x = self.productImage.frame.origin.x-tempRect.size.width-xMargin;
        self.salePrice.frame = tempRect;
        
        tempRect = self.originPrice.frame;
        tempRect.origin.x = self.salePrice.frame.origin.x - tempRect.size.width-xSpace;
        self.originPrice.frame = tempRect;
        
        offsetX = tempRect.origin.x;
        tempRect = self.discount.frame;
        tempRect.origin.x =  offsetX - tempRect.size.width - xSpace;
        self.discount.frame = tempRect;

        tempRect = self.modiImage.frame;
        tempRect.origin.x = self.productImage.frame.origin.x-tempRect.size.width-xMargin;
        self.modiImage.frame = tempRect;
        
        tempRect = self.subtractionBut.frame;
        tempRect.origin.x = self.modiImage.frame.origin.x-xMargin-xMargin/2;
        self.subtractionBut.frame = tempRect;
        
        tempRect = self.qtyLabel.frame;
        tempRect.origin.x = self.subtractionBut.frame.origin.x+self.subtractionBut.frame.size.width-xMargin-xMargin/2;
        self.qtyLabel.frame = tempRect;

        tempRect = self.addBut.frame;
        tempRect.origin.x = self.qtyLabel.frame.origin.x+self.qtyLabel.frame.size.width-xMargin-xMargin/2;
        self.addBut.frame = tempRect;

        tempRect = self.deleteBut.frame;
        tempRect.origin.x = xMargin;
        self.deleteBut.frame = tempRect;
        
        self.originPrice.textAlignment = NSTextAlignmentRight;
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
