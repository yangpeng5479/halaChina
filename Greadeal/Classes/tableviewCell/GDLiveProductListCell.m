//
//  GDLiveProductListCell.m
//  Greadeal
//
//  Created by Elsa on 15/8/7.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDLiveProductListCell.h"

#define xMargin 6
#define yMargin 8

#define photoWidth  75
#define photoHeigth 75

@implementation GDLiveProductListCell

@synthesize vendorLabel   = _vendorLabel;
@synthesize distanceLabel = _distanceLabel;
@synthesize nDist = nDist;

@synthesize rateImage     = _rateImage;
@synthesize rateLabel     = _rateLabel;

@synthesize productLabel  = _productLabel;
@synthesize couponLabel   = _couponLabel;

@synthesize saleLabel     = _saleLabel;
@synthesize originLabel   = _originLabel;
@synthesize soldLabel     = _soldLabel;

@synthesize blueImage     = _blueImage;
@synthesize goldImage     = _goldImage;
@synthesize platinumImage = _platinumImage;
@synthesize memberLabel   = _memberLabel;

@synthesize haveBlue      = _haveBlue;
@synthesize haveGold      = _haveGold;
@synthesize havePlatinum  = _havePlatinum;

@synthesize nonMember     = _nonMember;
@synthesize member        = _member;

@synthesize savingLabel   = _savingLabel;
@synthesize savingImage   = _savingImage;

@synthesize lineImage     = _lineImage;
@synthesize showVendorDist= _showVendorDist;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        _showVendorDist = YES;
        
        _productImage = [[UIImageView alloc] init];
        _productImage.backgroundColor = [UIColor clearColor];
        _productImage.contentMode = UIViewContentModeScaleAspectFill;
        _productImage.clipsToBounds = YES;
        [self addSubview:_productImage];
        
        _vendorLabel = MOCreateLabelAutoRTL();
        _vendorLabel.backgroundColor = [UIColor clearColor];
        _vendorLabel.textColor = MOColor33Color();
        _vendorLabel.font = MOLightFont(16);
        [self addSubview:_vendorLabel];
        
        _distanceLabel = MOCreateLabelAutoRTL();
        _distanceLabel.backgroundColor = [UIColor clearColor];
        _distanceLabel.textColor = MOColor66Color();
        _distanceLabel.font = MOLightFont(12);
        _distanceLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_distanceLabel];
        
        _rateImage = [[UIImageView alloc] init];
        _rateImage.backgroundColor = [UIColor clearColor];
//      _rateImage.contentMode = UIViewContentModeScaleAspectFill;
//      _rateImage.clipsToBounds = YES;
        _rateImage.image = [UIImage imageNamed:@"rate_back.png"];
        [self addSubview:_rateImage];
        
        _rateLabel = MOCreateLabelAutoRTL();
        _rateLabel.layer.cornerRadius = 4;
        _rateLabel.clipsToBounds = YES;
        _rateLabel.backgroundColor =[UIColor clearColor];
        _rateLabel.textColor = [UIColor whiteColor];
        _rateLabel.font = MOLightFont(12);
        _rateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_rateLabel];
        _rateLabel.hidden = YES;
        
        _productLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _productLabel.font = MOLightFont(12);
        _productLabel.textColor = MOColor66Color();
        _productLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _productLabel.numberOfLines = 0;
        [self addSubview:_productLabel];
        if ([GDSettingManager instance].isRightToLeft)
        {
            _productLabel.textAlignment = NSTextAlignmentRight;
        }
        
        _couponLabel = MOCreateLabelAutoRTL();
        _couponLabel.backgroundColor = [UIColor clearColor];
        _couponLabel.textColor = MOColorSaleFontColor();
        _couponLabel.font = MOBlodFont(14);
        _couponLabel.text = NSLocalizedString(@"COUPON PRICE", @"优惠券价格)");
        //[self addSubview:_couponLabel];
        
        _originLabel = [[LPLabel alloc] init];
        _originLabel.backgroundColor = [UIColor clearColor];
        _originLabel.textColor = MOColor66Color();
        _originLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _originLabel.font = MOLightFont(12);
        //[self addSubview:_originLabel];
        
        _saleLabel = MOCreateLabelAutoRTL();
        _saleLabel.backgroundColor = [UIColor clearColor];
        _saleLabel.textColor = MOColorSaleFontColor();
        _saleLabel.font = MOLightFont(14);
        [self addSubview:_saleLabel];
        
        _soldLabel = MOCreateLabelAutoRTL();
        _soldLabel.backgroundColor = [UIColor clearColor];
        _soldLabel.textColor = MOColor66Color();
        _soldLabel.font = MOLightFont(12);
        //[self addSubview:_soldLabel];
        _soldLabel.textAlignment = NSTextAlignmentRight;
        
        _blueImage = [[UIImageView alloc] init];
        _blueImage.backgroundColor = [UIColor clearColor];
        _blueImage.contentMode = UIViewContentModeScaleAspectFill;
        _blueImage.clipsToBounds = YES;
        //[self addSubview:_blueImage];
        
        _goldImage = [[UIImageView alloc] init];
        _goldImage.backgroundColor = [UIColor clearColor];
        _goldImage.contentMode = UIViewContentModeScaleAspectFill;
        _goldImage.clipsToBounds = YES;
        //[self addSubview:_goldImage];
        
        _platinumImage = [[UIImageView alloc] init];
        _platinumImage.backgroundColor = [UIColor clearColor];
        _platinumImage.contentMode = UIViewContentModeScaleAspectFill;
        _platinumImage.clipsToBounds = YES;
        //[self addSubview:_platinumImage];
        
        _memberLabel = MOCreateLabelAutoRTL();
        _memberLabel.backgroundColor = [UIColor clearColor];
        _memberLabel.textColor = MOColorSaleFontColor();
        _memberLabel.font = MOLightFont(14);
        [self addSubview:_memberLabel];
        
        _nonMember = MOCreateLabelAutoRTL();
        _nonMember.backgroundColor = [UIColor clearColor];
        _nonMember.textColor = MOColor66Color();
        _nonMember.font = MOLightFont(12);
        _nonMember.text = NSLocalizedString(@"Non Member", @"(非会员)");
        [self addSubview:_nonMember];
        
        _member= MOCreateLabelAutoRTL();
        _member.backgroundColor = [UIColor clearColor];
        _member.textColor = MOColor66Color();
        _member.font = MOLightFont(12);
        _member.text = NSLocalizedString(@"Gold Member", @"(金卡会员)");
        [self addSubview:_member];

        self.haveBlue = NO;
        self.haveGold = NO;
        self.havePlatinum = NO;
        
        _productImage = [[UIImageView alloc] init];
        _productImage.backgroundColor = [UIColor clearColor];
        _productImage.contentMode = UIViewContentModeScaleAspectFill;
        _productImage.clipsToBounds = YES;
        [self addSubview:_productImage];
        
        _savingImage = [[UIImageView alloc] init];
        _savingImage.backgroundColor = [UIColor clearColor];
        _savingImage.contentMode = UIViewContentModeScaleAspectFill;
        _savingImage.clipsToBounds = YES;
        _savingImage.image = [UIImage imageNamed:@"saving.png"];
        [self addSubview:_savingImage];
        
        _savingLabel = MOCreateLabelAutoRTL();
        _savingLabel.textAlignment = NSTextAlignmentCenter;
        _savingLabel.backgroundColor = [UIColor clearColor];
        _savingLabel.textColor = colorFromHexString(@"ef8803");
        _savingLabel.font = MOLightFont(10);
        [self addSubview:_savingLabel];
        
        _lineImage = [[UIImageView alloc] init];
        _lineImage.backgroundColor = [UIColor clearColor];
        _lineImage.contentMode = UIViewContentModeScaleAspectFill;
        _lineImage.clipsToBounds = YES;
        _lineImage.image = [[UIImage imageNamed:@"couponLine.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [self addSubview:_lineImage];
    }
    return self;
}


- (void)layoutSubviews
{
    MODebugLayer(self.productImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.vendorLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.distanceLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.rateLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.productLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.originLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.saleLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.soldLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.blueImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.goldImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.platinumImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.memberLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.couponLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.savingImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.savingLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.rateImage, 1.f, [UIColor redColor].CGColor);

    [super layoutSubviews];
    CGRect r = self.bounds;
    
    self.productImage.frame = CGRectMake(xMargin, yMargin,
                                         photoWidth, photoHeigth);
    
    float offsetX = xMargin;
    float offsetY = yMargin*2+photoHeigth;
    
    
    if (self.savingLabel.text.length>0)
    {
        self.savingImage.frame = CGRectMake(4, offsetY,79, 15);
        self.savingLabel.frame = CGRectMake(4, offsetY,79, 15);
    }
    
    offsetX = photoWidth  + xMargin*2 ;
    offsetY = yMargin;
    
    if (_showVendorDist)
    {
        if (nDist < 1000)
        {
            self.distanceLabel.text = [NSString stringWithFormat:@"%dm",nDist];
        }
        else
        {
            self.distanceLabel.text = [NSString stringWithFormat:@"%.1fkm",nDist*1.0/1000];
        }
    
        CGSize size = [self.distanceLabel.text moSizeWithFont:self.distanceLabel.font withWidth:60];
        float  distWidth = size.width;
    
        self.vendorLabel.frame = CGRectMake(offsetX, offsetY,
                                       [GDPublicManager instance].screenWidth-offsetX-xMargin*2-distWidth, titleHeight);
        self.distanceLabel.frame = CGRectMake([GDPublicManager instance].screenWidth-xMargin-distWidth, offsetY,distWidth, titleHeight);
    
        offsetY+=titleHeight;
    }
    
    self.productLabel.frame = CGRectMake(offsetX, offsetY,
                                        [GDPublicManager instance].screenWidth-offsetX-xMargin, titleHeight*2);
    

    offsetY+=titleHeight*2;
    
    self.lineImage.frame= CGRectMake(offsetX, offsetY,
                                   [GDPublicManager instance].screenWidth-offsetX-xMargin, 1);
    
    
    offsetY+=yMargin;
    float  rateWidth = 30;
    
    self.rateImage.frame = CGRectMake([GDPublicManager instance].screenWidth-xMargin-rateWidth-5, offsetY,35, 14);
    
    self.rateLabel.frame = CGRectMake([GDPublicManager instance].screenWidth-xMargin-rateWidth+4, offsetY,rateWidth, 14);
    
    if ([self.rateLabel.text intValue]>0)
        self.rateLabel.hidden = NO;
    
   
    self.couponLabel.frame = CGRectMake(offsetX, offsetY,
                                         [GDPublicManager instance].screenWidth-offsetX-xMargin, titleHeight);
    offsetY+=titleHeight;
    
    
    [self.originLabel findCurrency:CurrencyFontSize];
    [self.saleLabel   findCurrency:CurrencyFontSize];
    
    CGRect saleFrame = self.saleLabel.frame;
    saleFrame.origin.x = offsetX;
    saleFrame.origin.y = offsetY;
    saleFrame.size.width = 80;//*[GDPublicManager instance].screenScale;
    saleFrame.size.height = titleHeight;
    self.saleLabel.frame = saleFrame;
    
    offsetX+=self.saleLabel.frame.size.width;
    self.nonMember.frame = CGRectMake(offsetX, offsetY,
                                      100, titleHeight);
   
    
   // self.soldLabel.frame = CGRectMake([GDPublicManager instance].screenWidth-xMargin-60, offsetY,60, titleHeight);
    
   // offsetX+=self.saleLabel.frame.size.width;
    int vaildCardNumber = 0;
    if (self.haveBlue) vaildCardNumber++;
    if (self.haveGold) vaildCardNumber++;
    if (self.havePlatinum) vaildCardNumber++;
    
   // offsetX+=[GDPublicManager instance].screenWidth-5-offsetX-memberIconSize*vaildCardNumber-15-40;
//    CGRect originFrame = self.originLabel.frame;
//    originFrame.origin.x = offsetX;
//    originFrame.origin.y = offsetY;
//    originFrame.size.width = 80*[GDPublicManager instance].screenScale;
//    originFrame.size.height = titleHeight;
//    self.originLabel.frame = originFrame;
    
    offsetX=self.saleLabel.frame.origin.x;
    offsetY+= titleHeight + 5;
    
    CGRect memberFrame = self.memberLabel.frame;
    memberFrame.origin.x = offsetX;
    memberFrame.origin.y = offsetY;
    memberFrame.size.width = 80;
    memberFrame.size.height = titleHeight;
    self.memberLabel.frame = memberFrame;
    
    if (self.haveBlue || self.haveGold || self.havePlatinum)
    {
        self.memberLabel.text = NSLocalizedString(@"FREE",@"免费");
    }
    else
    {
        self.memberLabel.text = self.saleLabel.text;
        [self.memberLabel findCurrency:CurrencyFontSize];
    }
    
    offsetX+=self.memberLabel.frame.size.width;
    self.member.frame = CGRectMake(offsetX, offsetY,
                                   80, titleHeight);
    
    offsetX+=self.member.frame.size.width;
    
    float memberOffset = [GDPublicManager instance].screenWidth-offsetX-105;
    offsetX+=memberOffset;
    
    if (self.haveBlue)
    {
        self.blueImage.image     = [UIImage imageNamed:@"blue.png"];
        self.blueImage.frame     = CGRectMake(offsetX, offsetY,
                                          memberIconWidth, memberIconHeight);
    
        offsetX+=self.blueImage.frame.size.width+5;
        self.blueImage.hidden = NO;
    }
    else
        self.blueImage.hidden = YES;
    
    if (self.haveGold)
    {
        self.goldImage.image     = [UIImage imageNamed:@"gold.png"];
        self.goldImage.frame     = CGRectMake(offsetX, offsetY,
                                          memberIconWidth, memberIconHeight);
    
        offsetX+=self.goldImage.frame.size.width+5;
        self.goldImage.hidden = NO;
    }
    else
        self.goldImage.hidden = YES;
    
    if (self.havePlatinum)
    {
        self.platinumImage.image = [UIImage imageNamed:@"platinum.png"];
        self.platinumImage.frame     = CGRectMake(offsetX, offsetY,
                                          memberIconWidth, memberIconHeight);
    
        offsetX+=self.platinumImage.frame.size.width+5;
        self.platinumImage.hidden = NO;
    }
    else
        self.platinumImage.hidden = YES;
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = self.productImage.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.productImage.frame = tempRect;
        
        tempRect = self.savingImage.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.savingImage.frame = tempRect;
        
        tempRect = self.savingLabel.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.savingLabel.frame = tempRect;

        tempRect = self.vendorLabel.frame;
        tempRect.origin.x = self.productImage.frame.origin.x-tempRect.size.width - xMargin;
        self.vendorLabel.frame = tempRect;
        
        tempRect = self.saleLabel.frame;
        tempRect.origin.x = self.productImage.frame.origin.x-tempRect.size.width-xMargin;
        self.saleLabel.frame = tempRect;
        
        tempRect = self.nonMember.frame;
        tempRect.origin.x = self.saleLabel.frame.origin.x-tempRect.size.width-xMargin;
        self.nonMember.frame = tempRect;

        float offsetX = tempRect.origin.x;
        
//        tempRect = self.originLabel.frame;
//        tempRect.origin.x = offsetX - tempRect.size.width - xMargin;
//        self.originLabel.frame = tempRect;
//        
        offsetX = tempRect.origin.x;
        tempRect = self.distanceLabel.frame;
        tempRect.origin.x = xMargin;
        self.distanceLabel.frame = tempRect;
        
        tempRect = self.rateImage.frame;
        tempRect.origin.x = self.distanceLabel.frame.origin.x;
        self.rateImage.frame = tempRect;
        
        tempRect = self.rateLabel.frame;
        tempRect.origin.x = self.distanceLabel.frame.origin.x+8;
        self.rateLabel.frame = tempRect;
        
        tempRect = self.productLabel.frame;
        tempRect.origin.x = self.productImage.frame.origin.x-tempRect.size.width - xMargin;
        self.productLabel.frame = tempRect;
        
        tempRect = self.couponLabel.frame;
        tempRect.origin.x = self.productImage.frame.origin.x-tempRect.size.width - xMargin;
        self.couponLabel.frame = tempRect;
        
        tempRect = self.memberLabel.frame;
        tempRect.origin.x = self.productImage.frame.origin.x-tempRect.size.width-xMargin;
        self.memberLabel.frame = tempRect;

        tempRect = self.member.frame;
        tempRect.origin.x = self.memberLabel.frame.origin.x-tempRect.size.width-xMargin;
        self.member.frame = tempRect;

        tempRect = self.blueImage.frame;
        tempRect.origin.x = self.member.frame.origin.x-20;
        self.blueImage.frame = tempRect;
        
        tempRect = self.goldImage.frame;
        tempRect.origin.x = self.blueImage.frame.origin.x-tempRect.size.width-5;
        self.goldImage.frame = tempRect;
        
        tempRect = self.platinumImage.frame;
        tempRect.origin.x = self.goldImage.frame.origin.x-tempRect.size.width-5;
        self.platinumImage.frame = tempRect;
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
