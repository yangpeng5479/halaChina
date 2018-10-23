//
//  GDProductListCell.m
//  Greadeal
//
//  Created by Elsa on 16/8/3.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDProductListCell.h"

#define xMargin 8
#define yMargin 0

#define photoWidth  [[UIScreen mainScreen] bounds].size.width-xMargin*2
#define photoHeigth 180

#define textWidth  [[UIScreen mainScreen] bounds].size.width-xMargin*4

@implementation GDProductListCell

@synthesize productImage   = _productImage;
@synthesize backImage = _backImage;
@synthesize vendorLabel = _vendorLabel;

@synthesize productLabel  = _productLabel;

@synthesize saleLabel     = _saleLabel;
@synthesize originLabel   = _originLabel;

@synthesize textBackImage = _textBackImage;

@synthesize locationImage = _locationImage;
@synthesize cityLabel     = _cityLabel;
@synthesize currencyLabel = _currencyLabel;
@synthesize couponLabel   = _couponLabel;

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
        
        _backImage = [[UIView alloc] init];
        _backImage.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.5];
        [self addSubview:_backImage];
        
        _vendorLabel = MOCreateLabelAutoRTL();
        _vendorLabel.backgroundColor = [UIColor clearColor];
        _vendorLabel.textColor = [UIColor whiteColor];
        _vendorLabel.font = MOBlodFont(16);
        [self addSubview:_vendorLabel];
        
        _productLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _productLabel.font = MOLightFont(13);
        _productLabel.textColor = [UIColor whiteColor];
        _productLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _productLabel.numberOfLines = 0;
        [self addSubview:_productLabel];
        if([GDSettingManager instance].isRightToLeft)
        {
            _productLabel.textAlignment = NSTextAlignmentRight;
        }
        else
        {
            _productLabel.textAlignment = NSTextAlignmentLeft;
        }
        
        _textBackImage = [[UIView alloc] init];
        _textBackImage.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        [self addSubview:_textBackImage];
        
        _locationImage = [[UIImageView alloc] init];
        _locationImage.backgroundColor = [UIColor clearColor];
        _locationImage.contentMode = UIViewContentModeScaleAspectFill;
        _locationImage.clipsToBounds = YES;
        _locationImage.image = [UIImage imageNamed:@"loction_list.png"];
        [self addSubview:_locationImage];
        
        _cityLabel = MOCreateLabelAutoRTL();
        _cityLabel.backgroundColor = [UIColor clearColor];
        _cityLabel.textColor = MOColor66Color();
        _cityLabel.font = MOLightFont(12);
        [self addSubview:_cityLabel];
        
        _currencyLabel = MOCreateLabelAutoRTL();
        _currencyLabel.backgroundColor = [UIColor clearColor];
        _currencyLabel.textColor = MOColor66Color();
        _currencyLabel.font = MOBlodFont(14);
        _currencyLabel.text = [GDPublicManager instance].currency;
        [self addSubview:_currencyLabel];
        
        _couponLabel = MOCreateLabelAutoRTL();
        _couponLabel.backgroundColor = [UIColor clearColor];
        _couponLabel.textColor = MOColorSaleFontColor();
        _couponLabel.font = MOBlodFont(14);
        _couponLabel.text = NSLocalizedString(@"Free Coupon", @"免费优惠券");
        [self addSubview:_couponLabel];
        
        _originLabel = [[LPLabel alloc] init];
        _originLabel.backgroundColor = [UIColor clearColor];
        _originLabel.textColor = MOColor66Color();
        _originLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _originLabel.font = MOLightFont(12);
        [self addSubview:_originLabel];
        
        _saleLabel = MOCreateLabelAutoRTL();
        _saleLabel.backgroundColor = [UIColor clearColor];
        _saleLabel.textColor = MOColorSaleFontColor();
        _saleLabel.font = MOBlodFont(20);
        [self addSubview:_saleLabel];
        
    }
    return self;
}


- (void)layoutSubviews
{
    MODebugLayer(self.productImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.vendorLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.vendorLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.productLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.locationImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.cityLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.currencyLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.couponLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.originLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.saleLabel, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    
    self.productImage.frame = CGRectMake(xMargin, yMargin,
                                         photoWidth, photoHeigth);
    
    float offsetY = yMargin+photoHeigth;
   
    CGSize vendorSize = [self.vendorLabel.text moSizeWithFont:self.vendorLabel.font withWidth:textWidth];
    CGSize productSize = [self.productLabel.text moSizeWithFont:self.productLabel.font withWidth:textWidth];
    
    offsetY=offsetY-vendorSize.height-productSize.height-xMargin;
    
    self.backImage.frame = CGRectMake(xMargin, offsetY,
                                         photoWidth, photoHeigth-offsetY);
    
    self.vendorLabel.frame  = CGRectMake(xMargin*2, offsetY,
                                        textWidth, vendorSize.height);
    
    offsetY+=vendorSize.height+xMargin/2;
    
    self.productLabel.frame = CGRectMake(xMargin*2, offsetY,
                                        textWidth, productSize.height);
    
    
    
    offsetY = yMargin*2+photoHeigth+xMargin;
    
    self.textBackImage.frame = CGRectMake(xMargin, offsetY-xMargin,
                                 photoWidth, 32);
    
    float offsetX = xMargin*2;
    self.locationImage.frame= CGRectMake(offsetX, offsetY+2,
                                     16, 16);
    offsetX+=self.locationImage.frame.size.width+5;
    
    if (self.membership_level!=needPayType)
    {
        self.cityLabel.frame = CGRectMake(offsetX, offsetY,[[UIScreen mainScreen] bounds].size.width-150, 20);
        offsetX+=self.cityLabel.frame.size.width+10;
  
        
        self.couponLabel.frame = CGRectMake(offsetX, offsetY,95, 20);
        
        self.couponLabel.hidden = NO;
        self.currencyLabel.hidden = YES;
        self.originLabel.hidden = YES;
        self.saleLabel.hidden = YES;
    }
    else
    {
        if ([self.originLabel.text intValue]>0)
        {
            self.cityLabel.frame = CGRectMake(offsetX, offsetY,[[UIScreen mainScreen] bounds].size.width-185, 20);
            offsetX+=self.cityLabel.frame.size.width+10;
            
            self.currencyLabel.frame = CGRectMake(offsetX, offsetY,35, 20);
            offsetX+=self.currencyLabel.frame.size.width;
            
            self.originLabel.frame = CGRectMake(offsetX, offsetY,40, 20);
            offsetX+=self.originLabel.frame.size.width;
            self.originLabel.hidden = NO;
        }
        else
        {
            self.cityLabel.frame = CGRectMake(offsetX, offsetY,[[UIScreen mainScreen] bounds].size.width-150, 20);
            offsetX+=self.cityLabel.frame.size.width+10;
            
            self.currencyLabel.frame = CGRectMake(offsetX, offsetY,35, 20);
            offsetX+=self.currencyLabel.frame.size.width;
      
            self.originLabel.hidden = YES;
        }
        self.saleLabel.frame = CGRectMake(offsetX, offsetY,55, 20);
        
        self.couponLabel.hidden = YES;
        self.currencyLabel.hidden = NO;
      
        self.saleLabel.hidden = NO;

    }
    
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
