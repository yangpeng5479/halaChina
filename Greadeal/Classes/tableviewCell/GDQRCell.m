//
//  GDQRCell.m
//  haomama
//
//  Created by tao tao on 24/05/13.
//  Copyright (c) 2013年 tao tao. All rights reserved.
//

#import "GDQRCell.h"

#define photoHeight 120

#define titleHeight 20

#define xMargin  10
#define yMargin  8

@implementation GDQRCell

@synthesize bgView       =_bgView;
@synthesize QRView       =_QRView;
@synthesize numberLabel  =_numberLabel;
@synthesize isExpire     =_isExpire;
@synthesize titleLabel   =_titleLabel;
@synthesize expireLabel  =_expireLabell;
@synthesize memberExpireLabel = _memberExpireLabel;

@synthesize originPriceLabel   =_originPriceLabel;
@synthesize priceLabel  =_priceLabel;
@synthesize usedImage   =_usedImage;
@synthesize couponLabel =_couponLabel;

@synthesize vendorLabel = _vendorLabel;

@synthesize actionBut = _actionBut;
@synthesize shareBut = _shareBut;

@synthesize maskView = _maskView;

- (void)tapImageView:(UIGestureRecognizer *)tapGesture
{
    [_maskView removeFromSuperview];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        _QRView = [[UIImageView alloc] init];
        _QRView.backgroundColor = [UIColor clearColor];
        _QRView.contentMode = UIViewContentModeScaleAspectFill;
        _QRView.clipsToBounds = YES;
        [self addSubview:_QRView];
        
        _maskView = [[UIImageView alloc] init];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.contentMode = UIViewContentModeScaleAspectFill;
        _maskView.clipsToBounds = YES;
        _maskView.userInteractionEnabled = YES;
        [self addSubview:_maskView];
        _maskView.image = [[UIImage imageNamed:@"mask_qr.png"]stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)]];
        [self addSubview:_maskView];
        
        tapShow =  [[UIImageView alloc] init];
        tapShow.backgroundColor = [UIColor clearColor];
        tapShow.image = [UIImage imageNamed:@"tap_qr.png"];
        [_maskView addSubview:tapShow];
        
        textLabel = MOCreateLabelAutoRTL();
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.font = MOLightFont(14);
        textLabel.textAlignment = NSTextAlignmentCenter;
        [_maskView addSubview:textLabel];
        
        _vendorLabel = MOCreateLabelAutoRTL();
        _vendorLabel.backgroundColor = [UIColor clearColor];
        _vendorLabel.textColor = MOColor33Color();
        _vendorLabel.font = MOLightFont(16);
        [self addSubview:_vendorLabel];

        _numberLabel = MOCreateLabelAutoRTL();
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.textColor = MOColor66Color();
        _numberLabel.font = MOLightFont(14);
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_numberLabel];
        
        _usedImage = [[UIImageView alloc] init];
        _usedImage.backgroundColor = [UIColor clearColor];
        _usedImage.contentMode = UIViewContentModeScaleAspectFill;
        _usedImage.clipsToBounds = YES;
        [self addSubview:_usedImage];
        
        _originPriceLabel = [[LPLabel alloc] init];
        _originPriceLabel.backgroundColor = [UIColor clearColor];
        _originPriceLabel.textColor = MOColor66Color();
        _originPriceLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _originPriceLabel.font = MOLightFont(16);
        //[self addSubview:_originPriceLabel];
        
        _priceLabel = MOCreateLabelAutoRTL();
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.textColor = MOColorSaleFontColor();
        _priceLabel.font = MOLightFont(16);
        _priceLabel.numberOfLines = 0;
        [self addSubview:_priceLabel];
        
        _titleLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = MOColor66Color();
        _titleLabel.font = MOLightFont(12);
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
        if ([GDSettingManager instance].isRightToLeft)
        {
            _titleLabel.textAlignment = NSTextAlignmentRight;
        }
        
        _expireLabell = MOCreateLabelAutoRTL();
        _expireLabell.backgroundColor = [UIColor clearColor];
        _expireLabell.textColor = MOColor66Color();
        _expireLabell.font = MOLightFont(12);
        [self addSubview:_expireLabell];
        
//        _memberExpireLabel = MOCreateLabelAutoRTL();
//        _memberExpireLabel.backgroundColor = [UIColor clearColor];
//        _memberExpireLabel.textColor = MOColor66Color();
//        _memberExpireLabel.font = MOLightFont(12);
//        [self addSubview:_memberExpireLabel];
        
//        _couponLabel = MOCreateLabelAutoRTL();
//        _couponLabel.backgroundColor = [UIColor clearColor];
//        _couponLabel.textColor = MOColorSaleFontColor();
//        _couponLabel.font = MOBlodFont(14);
//        _couponLabel.text = NSLocalizedString(@"COUPON PRICE", @"优惠券价格)");
//        [self addSubview:_couponLabel];
        
        _actionBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        [_actionBut setLabelTextColor:[UIColor whiteColor] highlightedColor:[UIColor whiteColor] disableColor:nil];
        [_actionBut setLabelFont:MOLightFont(14)];
        [_actionBut setCornerRadius:1];
        [self addSubview:_actionBut];
        
        _shareBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        [_shareBut setLabelTextColor:[UIColor whiteColor] highlightedColor:[UIColor whiteColor] disableColor:nil];
        [_shareBut setCornerRadius:1];
        [self addSubview:_shareBut];
    }
    return self;
}


- (void)layoutSubviews
{
    MODebugLayer(self.QRView, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.numberLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.usedImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.titleLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.expireLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.shareBut, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.vendorLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.actionBut, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    
    textLabel.text = [[GDSettingManager instance] isSwitchChinese]?@"单击显示":@"Reveal";
    
    float offsetX = 0;
    float offsetY = 0;
    
    self.bgView.frame = CGRectMake(offsetX, offsetY,
                                   self.frame.size.width, self.frame.size.height);
    
    self.QRView.frame = CGRectMake(offsetX, yMargin,
                                         photoHeight, photoHeight);
    
    self.maskView.frame = CGRectMake(offsetX, yMargin,
                                   photoHeight, photoHeight);
    
    tapShow.frame = CGRectMake((photoHeight-41)/2, (photoHeight-41)/2,
                               41, 41);
    
    textLabel.frame = CGRectMake(0, (photoHeight-41)/2+50,
                                 photoHeight, 20);
    
    offsetX += photoHeight + xMargin;
    offsetY += yMargin;
    
    self.numberLabel.frame = CGRectMake(0, yMargin+photoHeight,
                                        photoHeight, titleHeight);
  
    
    if (_isExpire==2)
    {
        if ([[GDSettingManager instance] isChinese])
            self.usedImage.image = [UIImage imageNamed:@"cn_expired.png"];
        else
            self.usedImage.image = [UIImage imageNamed:@"en_expired.png"];
    }
    else if (_isExpire==1)
    {
        if ([[GDSettingManager instance] isChinese])
            self.usedImage.image = [UIImage imageNamed:@"cn_used.png"];
        else
            self.usedImage.image = [UIImage imageNamed:@"en_used.png"];
    }
    else
    {
        self.usedImage.image = nil;
    }
    
    self.usedImage.frame = CGRectMake([GDPublicManager instance].screenWidth-xMargin-86, offsetY,86, 81);
    
    self.vendorLabel.frame = CGRectMake(offsetX, offsetY,
                                        [GDPublicManager instance].screenWidth-offsetX-xMargin, titleHeight);
    
    offsetY+=titleHeight;
    self.titleLabel.frame = CGRectMake(offsetX, offsetY,
                                          [GDPublicManager instance].screenWidth-offsetX-xMargin, titleHeight*2.5);
    
    offsetY+=titleHeight*2.5;
    
//    self.couponLabel.frame = CGRectMake(offsetX, offsetY,
//                                        [GDPublicManager instance].screenWidth-offsetX-xMargin*2, titleHeight);
//    offsetY+=titleHeight;
//    
    [self.originPriceLabel findCurrency:CurrencyFontSize];
    [self.priceLabel findCurrency:CurrencyFontSize];
    
    CGRect saleFrame = self.priceLabel.frame;
    saleFrame.origin.x = offsetX;
    saleFrame.origin.y = offsetY;
    saleFrame.size.width = 80*[GDPublicManager instance].screenScale;
    saleFrame.size.height = titleHeight;
    self.priceLabel.frame = saleFrame;
    
    offsetX+=self.priceLabel.frame.size.width;
    
    CGRect originFrame = self.originPriceLabel.frame;
    originFrame.origin.x = offsetX;
    originFrame.origin.y = offsetY;
    originFrame.size.width = 80*[GDPublicManager instance].screenScale;
    originFrame.size.height = titleHeight;
    self.originPriceLabel.frame = originFrame;
    
    //offsetY+=titleHeight;
    offsetX = photoHeight + xMargin;
    
    self.expireLabel.frame = CGRectMake(offsetX, offsetY,
                                       [GDPublicManager instance].screenWidth-offsetX-xMargin, titleHeight);
    
    offsetY+=titleHeight*2;
    
    self.shareBut.frame = CGRectMake([GDPublicManager instance].screenWidth-32-xMargin,offsetY, 32, 32);
    
    self.actionBut.frame = CGRectMake(offsetX,offsetY, [GDPublicManager instance].screenWidth-32-xMargin*2-offsetX, 32);
    
//    if (self.memberExpireLabel.text>0)
//    {
//        offsetY+=titleHeight;
//        self.memberExpireLabel.frame = CGRectMake(offsetX, offsetY,
//                                        [GDPublicManager instance].screenWidth-offsetX-xMargin*2, titleHeight);
//    
//    }
    
    if ([GDSettingManager instance].isRightToLeft)
    {
//        CGRect r = self.bounds;
//        
//        CGRect tempRect = self.QRView.frame;
//        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
//        self.QRView.frame = tempRect;
//        
//        tempRect = self.usedImage.frame;
//        tempRect.origin.x = xMargin;
//        self.usedImage.frame = tempRect;
//        
//        tempRect = self.numberLabel.frame;
//        tempRect.origin.x = self.QRView.frame.origin.x-tempRect.size.width-xMargin;
//        self.numberLabel.frame = tempRect;
//        
//        tempRect = self.couponLabel.frame;
//        tempRect.origin.x = self.QRView.frame.origin.x-tempRect.size.width - xMargin;
//        self.couponLabel.frame = tempRect;
//        
//        tempRect = self.usedLabel.frame;
//        tempRect.origin.x = xMargin;
//        self.usedLabel.frame = tempRect;
//        
//        tempRect = self.titleLabel.frame;
//        tempRect.origin.x = self.QRView.frame.origin.x - tempRect.size.width - xMargin;
//        self.titleLabel.frame = tempRect;
//        
//        tempRect = self.priceLabel.frame;
//        tempRect.origin.x =  self.QRView.frame.origin.x - tempRect.size.width - xMargin ;
//        self.priceLabel.frame = tempRect;
//        
//        float offsetX = tempRect.origin.x;
//        
//        tempRect = self.originPriceLabel.frame;
//        tempRect.origin.x = offsetX-tempRect.size.width-xMargin;
//        self.originPriceLabel.frame = tempRect;
//        
//        tempRect = self.expireLabel.frame;
//        tempRect.origin.x = self.QRView.frame.origin.x-tempRect.size.width-xMargin;
//        self.expireLabel.frame = tempRect;
//        
//        if (self.memberExpireLabel.text>0)
//        {
//            tempRect = self.memberExpireLabel.frame;
//            tempRect.origin.x = self.QRView.frame.origin.x-tempRect.size.width-xMargin;
//            self.memberExpireLabel.frame = tempRect;
//        }
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
