//
//  GDDetailsTableViewCell.m
//  Greadeal
//
//  Created by Elsa on 15/6/3.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDDetailsTableViewCell.h"
#define xMargin  10
#define yMargin  10

#define titleHeight 20
#define titleWidth  300

@implementation GDDetailsTableViewCell

@synthesize titleLabel  = _titleLabel;
@synthesize saleLabel   = _saleLabel;
@synthesize originLabel = _originLabel;
@synthesize useLabel    = _useLabel;

@synthesize blueImage     = _blueImage;
@synthesize goldImage     = _goldImage;
@synthesize platinumImage = _platinumImage;
@synthesize memberLabel   = _memberLabel;

@synthesize haveBlue      = _haveBlue;
@synthesize haveGold      = _haveGold;
@synthesize havePlatinum  = _havePlatinum;

@synthesize nonMember   = _nonMember;
@synthesize member      = _member;

@synthesize stockLabel  = _stockLabel;
@synthesize soldLabel   = _soldLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        _titleLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = MOLightFont(14);
        _titleLabel.textColor = MOColor66Color();
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
        if ([GDSettingManager instance].isRightToLeft)
        {
            _titleLabel.textAlignment = NSTextAlignmentRight;
        }
        
        _couponLabel = MOCreateLabelAutoRTL();
        _couponLabel.backgroundColor = [UIColor clearColor];
        _couponLabel.textColor = MOColorSaleFontColor();
        _couponLabel.font = MOBlodFont(14);
        _couponLabel.text = NSLocalizedString(@"COUPON PRICE", @"优惠券价格)");
        //[self addSubview:_couponLabel];
        
        _originLabel = [[LPLabel alloc] init];
        _originLabel.backgroundColor = [UIColor clearColor];
        _originLabel.textColor = colorFromHexString(@"999999");
        _originLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _originLabel.font = MOLightFont(14);
        //[self addSubview:_originLabel];
        
        _saleLabel = MOCreateLabelAutoRTL();
        _saleLabel.backgroundColor = [UIColor clearColor];
        _saleLabel.textColor = MOColorSaleFontColor();
        _saleLabel.font = MOLightFont(23);
        [self addSubview:_saleLabel];
        
        _useLabel = MOCreateLabelAutoRTL();
        _useLabel.backgroundColor = colorFromHexString(@"64A300");
        _useLabel.textColor = [UIColor whiteColor];
        _useLabel.font = MOLightFont(12);
        //[self addSubview:_useLabel];
        
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
        _memberLabel.font = MOLightFont(20);
        //[self addSubview:_memberLabel];
        
        _nonMember = MOCreateLabelAutoRTL();
        _nonMember.backgroundColor = [UIColor clearColor];
        _nonMember.textColor = MOColor66Color();
        _nonMember.font = MOLightFont(12);
        _nonMember.text = NSLocalizedString(@"Non Member", @"非会员");
        //[self addSubview:_nonMember];
        
        _member= MOCreateLabelAutoRTL();
        _member.backgroundColor = [UIColor clearColor];
        _member.textColor = MOColor66Color();
        _member.font = MOLightFont(12);
        _member.text = NSLocalizedString(@"Gold Member", @"金卡会员");
        //[self addSubview:_member];
        
        self.haveBlue = NO;
        self.haveGold = NO;
        self.havePlatinum = NO;
        
        _stockLabel= MOCreateLabelAutoRTL();
        _stockLabel.backgroundColor = [UIColor clearColor];
        _stockLabel.textColor = MOColor66Color();
        _stockLabel.font = MOLightFont(12);
        [self addSubview:_stockLabel];
        
        _soldLabel= MOCreateLabelAutoRTL();
        _soldLabel.backgroundColor = [UIColor clearColor];
        _soldLabel.textColor = MOColor66Color();
        _soldLabel.font = MOLightFont(12);
        [self addSubview:_soldLabel];
       
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
//    CGRect r = self.bounds;
    
    float offsetX = xMargin;
    float offsetY = 0;
    
    self.titleLabel.frame = CGRectMake(offsetX, offsetY,
                                       [GDPublicManager instance].screenWidth-xMargin*2, titleHeight*3);
    offsetY += self.titleLabel.frame.size.height+10;
    
//    self.couponLabel.frame = CGRectMake(offsetX, offsetY,
//                                        [GDPublicManager instance].screenWidth-offsetX-xMargin, titleHeight);
//    offsetY+=titleHeight;

    
    MODebugLayer(self.titleLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.useLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.originLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.saleLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.blueImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.goldImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.platinumImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.memberLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.stockLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.soldLabel, 1.f, [UIColor redColor].CGColor);
    
    [self.originLabel findCurrency:CurrencyFontSize];
    [self.saleLabel findCurrency:CurrencyFontSize];
    
    CGRect saleFrame = self.saleLabel.frame;
    saleFrame.origin.x = offsetX;
    saleFrame.origin.y = offsetY;
    saleFrame.size.width = 150*[GDPublicManager instance].screenScale;
    saleFrame.size.height = titleHeight;
    self.saleLabel.frame = saleFrame;
    
    offsetX+=self.saleLabel.frame.size.width;
    self.stockLabel.frame = CGRectMake(offsetX, offsetY,
                                      80*[GDPublicManager instance].screenScale, titleHeight);
    offsetX+=self.stockLabel.frame.size.width;
    self.soldLabel.frame = CGRectMake(offsetX, offsetY,
                                      70*[GDPublicManager instance].screenScale, titleHeight);
    
    offsetX+=self.saleLabel.frame.size.width;
    self.nonMember.frame = CGRectMake(offsetX, offsetY,
                                       100, titleHeight);
    
  
    
    int vaildCardNumber = 0;
    if (self.haveBlue) vaildCardNumber++;
    if (self.haveGold) vaildCardNumber++;
    if (self.havePlatinum) vaildCardNumber++;
    
    offsetX=self.saleLabel.frame.origin.x;
    offsetY +=titleHeight;
    
    if (self.haveBlue || self.haveGold || self.havePlatinum)
    {
        self.memberLabel.text = NSLocalizedString(@"FREE",@"免费");
    }
    else
    {
        self.memberLabel.text = self.saleLabel.text;
        [self.memberLabel findCurrency:CurrencyFontSize];
    }
    
    UIFont *Font = MOLightFont(20);
    CGSize titleSize = [self.memberLabel.text moSizeWithFont:Font withWidth:150];
    
    CGRect memberFrame = self.memberLabel.frame;
    memberFrame.origin.x = offsetX;
    memberFrame.origin.y = offsetY;
    memberFrame.size.width = titleSize.width;
    memberFrame.size.height = titleHeight;
    self.memberLabel.frame = memberFrame;
    
    
    offsetX+=self.memberLabel.frame.size.width;
    self.member.frame = CGRectMake(offsetX, offsetY,
                                      80, titleHeight);
    
    
    //offsetX+=self.member.frame.size.width;
    offsetX=[GDPublicManager instance].screenWidth - 115;
    if (self.haveBlue)
    {
        self.blueImage.image     = [UIImage imageNamed:@"blue.png"];
        self.blueImage.frame     = CGRectMake(offsetX, offsetY,
                                              memberIconWidth, memberIconHeight);
        
        offsetX+=self.blueImage.frame.size.width+5;
    }
    
    if (self.haveGold)
    {
        self.goldImage.image     = [UIImage imageNamed:@"gold.png"];
        self.goldImage.frame     = CGRectMake(offsetX, offsetY,
                                              memberIconWidth, memberIconHeight);
        
        offsetX+=self.goldImage.frame.size.width+5;
    }
    
    if (self.havePlatinum)
    {
        self.platinumImage.image = [UIImage imageNamed:@"platinum.png"];
        self.platinumImage.frame     = CGRectMake(offsetX, offsetY,
                                                  memberIconWidth, memberIconHeight);
        
        offsetX+=self.platinumImage.frame.size.width+5;
    }

//   Font = MOLightFont(14);
//   titleSize = [self.originLabel.text moSizeWithFont:Font withWidth:100];
    
//    CGRect originFrame = self.originLabel.frame;
//    originFrame.origin.x = offsetX;
//    originFrame.origin.y = offsetY+2;
//    originFrame.size.width = titleSize.width;
//    originFrame.size.height = titleHeight;
//    self.originLabel.frame = originFrame;
    
   
    if ([GDSettingManager instance].isRightToLeft)
    {
//        CGRect tempRect = self.titleLabel.frame;
//        tempRect.origin.x = r.size.width-tempRect.size.width-xMargin;
//        self.titleLabel.frame = tempRect;
//        
//        tempRect = self.saleLabel.frame;
//        tempRect.origin.x = r.size.width-tempRect.size.width-xMargin;
//        self.saleLabel.frame = tempRect;
//        
//        tempRect = self.nonMember.frame;
//        tempRect.origin.x = self.saleLabel.frame.origin.x-tempRect.size.width-xMargin;
//        self.nonMember.frame = tempRect;
//        
//        tempRect = self.memberLabel.frame;
//        tempRect.origin.x = r.size.width-tempRect.size.width-xMargin;
//        self.memberLabel.frame = tempRect;
//        
//        tempRect = self.member.frame;
//        tempRect.origin.x = self.memberLabel.frame.origin.x-tempRect.size.width-xMargin;
//        self.member.frame = tempRect;
//        
//        tempRect = self.blueImage.frame;
//        tempRect.origin.x = self.member.frame.origin.x-20;
//        self.blueImage.frame = tempRect;
//        
//        tempRect = self.goldImage.frame;
//        tempRect.origin.x = self.blueImage.frame.origin.x-tempRect.size.width-5;
//        self.goldImage.frame = tempRect;
//        
//        tempRect = self.platinumImage.frame;
//        tempRect.origin.x = self.goldImage.frame.origin.x-tempRect.size.width-5;
//        self.platinumImage.frame = tempRect;
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
