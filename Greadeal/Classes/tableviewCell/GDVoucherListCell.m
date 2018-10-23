//
//  GDProductListCell.m
//  Greadeal
//
//  Created by Elsa on 15/5/14.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDVoucherListCell.h"

#define xMargin 6
#define yMargin 8

@implementation GDVoucherListCell

@synthesize productLabel  = _productLabel;

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

@synthesize nonMember   = _nonMember;
@synthesize member   = _member;

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
        
        _productLabel = MOCreateLabelAutoRTL();
        _productLabel.backgroundColor = [UIColor clearColor];
        _productLabel.textColor = MOColor66Color();
        _productLabel.font = MOLightFont(12);
        _productLabel.numberOfLines = 0;
        [self addSubview:_productLabel];
        
        _originLabel = [[LPLabel alloc] init];
        _originLabel.backgroundColor = [UIColor clearColor];
        _originLabel.textColor = MOColor66Color();
        _originLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _originLabel.font = MOLightFont(12);
        //[self addSubview:_originLabel];
        
        _saleLabel = MOCreateLabelAutoRTL();
        _saleLabel.backgroundColor = [UIColor clearColor];
        _saleLabel.textColor = colorFromHexString(@"f80e3a");
        _saleLabel.font = MOLightFont(16);
        [self addSubview:_saleLabel];
        
        _soldLabel = MOCreateLabelAutoRTL();
        _soldLabel.backgroundColor = [UIColor clearColor];
        _soldLabel.textColor = MOColor66Color();
        _soldLabel.font = MOLightFont(12);
        [self addSubview:_soldLabel];
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
        _memberLabel.font = MOLightFont(16);
        [self addSubview:_memberLabel];
        
        _nonMember = MOCreateLabelAutoRTL();
        _nonMember.backgroundColor = [UIColor clearColor];
        _nonMember.textColor = MOColor66Color();
        _nonMember.font = MOLightFont(14);
        _nonMember.text = NSLocalizedString(@"Non Member", @"非会员");
        [self addSubview:_nonMember];
        
        _member= MOCreateLabelAutoRTL();
        _member.backgroundColor = [UIColor clearColor];
        _member.textColor = MOColor66Color();
        _member.font = MOLightFont(14);
        _member.text = NSLocalizedString(@"Gold Member", @"金卡会员");
        [self addSubview:_member];

        self.haveBlue = NO;
        self.haveGold = NO;
        self.havePlatinum = NO;
    }
    return self;
}


- (void)layoutSubviews
{
    MODebugLayer(self.productImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.productLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.originLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.saleLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.blueImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.goldImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.platinumImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.memberLabel, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    CGRect r = self.bounds;
    
    self.productImage.frame = CGRectMake(xMargin, yMargin,
                                         photoWidth, photoHeigth);
    
    float offsetX = photoWidth  + xMargin*2 ;
    float offsetY = yMargin;
    
    self.productLabel.frame = CGRectMake(offsetX, offsetY,
                                         [GDPublicManager instance].screenWidth-offsetX-xMargin, titleHeight*2);
    
    
    offsetY+=titleHeight*2;
    
    //[self.originLabel findCurrency:CurrencyFontSize];
    [self.saleLabel findCurrency:CurrencyFontSize];
    
    CGRect saleFrame = self.saleLabel.frame;
    saleFrame.origin.x = offsetX;
    saleFrame.origin.y = offsetY;
    saleFrame.size.width = 80*[GDPublicManager instance].screenScale;
    saleFrame.size.height = titleHeight;
    self.saleLabel.frame = saleFrame;
    
    offsetX+=self.saleLabel.frame.size.width;
    self.nonMember.frame = CGRectMake(offsetX, offsetY,
                                      100, titleHeight);
 
    
    self.soldLabel.frame = CGRectMake([GDPublicManager instance].screenWidth-xMargin-70, offsetY,70, titleHeight);
    
    int vaildCardNumber = 0;
    if (self.haveBlue) vaildCardNumber++;
    if (self.haveGold) vaildCardNumber++;
    if (self.havePlatinum) vaildCardNumber++;
    
    offsetY += titleHeight+5;
    offsetX=self.saleLabel.frame.origin.x;
    //offsetX+=[GDPublicManager instance].screenWidth-5-offsetX-memberIconSize*vaildCardNumber-15-40;
    
    //    CGRect originFrame = self.originLabel.frame;
    //    originFrame.origin.x = offsetX;
    //    originFrame.origin.y = offsetY;
    //    originFrame.size.width = 80*[GDPublicManager instance].screenScale;
    //    originFrame.size.height = titleHeight;
    //    self.originLabel.frame = originFrame;
    if (self.haveBlue || self.haveGold || self.havePlatinum)
    {
        self.memberLabel.text = NSLocalizedString(@"FREE",@"免费");
        CGRect memberFrame = self.memberLabel.frame;
        memberFrame.origin.x = offsetX;
        memberFrame.origin.y = offsetY;
        memberFrame.size.width = 50;
        memberFrame.size.height = titleHeight;
        self.memberLabel.frame = memberFrame;
    }

    offsetX+=self.memberLabel.frame.size.width;
    self.member.frame = CGRectMake(offsetX, offsetY,
                                   80, titleHeight);
    
    offsetX+=self.member.frame.size.width;
  
    
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
     
        tempRect = self.nonMember.frame;
        tempRect.origin.x = self.saleLabel.frame.origin.x-tempRect.size.width-xMargin;
        self.nonMember.frame = tempRect;
        
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
//        tempRect = self.originLabel.frame;
//        tempRect.origin.x = offsetX - tempRect.size.width - xMargin;
//        self.originLabel.frame = tempRect;
//        
//        tempRect = self.soldLabel.frame;
//        tempRect.origin.x =  xMargin;
//        self.soldLabel.frame = tempRect;
        
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