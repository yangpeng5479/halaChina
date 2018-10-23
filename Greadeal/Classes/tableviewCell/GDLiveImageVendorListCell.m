//
//  GDLiveImageVendorListCell.m
//  Greadeal
//
//  Created by Elsa on 16/1/27.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDLiveImageVendorListCell.h"

#define photoWidth  75
#define photoHeigth 75

#define titleHeight 20
#define ySpace 10

#define xMargin 6
#define yMargin 8

@implementation GDLiveImageVendorListCell

@synthesize vendorLabel   = _vendorLabel;
@synthesize distanceLabel = _distanceLabel;
@synthesize nDist = nDist;

@synthesize categoryLabel = _categoryLabel;
@synthesize rateLabel     = _rateLabel;

@synthesize addressLabel  = _addressLabel;

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
        
        _vendorLabel = MOCreateLabelAutoRTL();
        _vendorLabel.backgroundColor = [UIColor clearColor];
        _vendorLabel.textColor = MOColor33Color();
        _vendorLabel.font = MOLightFont(16);
        _vendorLabel.numberOfLines = 0;
        [self addSubview:_vendorLabel];
        
        _distanceLabel = MOCreateLabelAutoRTL();
        _distanceLabel.backgroundColor = [UIColor clearColor];
        _distanceLabel.textColor = MOColor66Color();
        _distanceLabel.font = MOLightFont(12);
        _distanceLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_distanceLabel];
        
        _categoryLabel = MOCreateLabelAutoRTL();
        _categoryLabel.backgroundColor = [UIColor clearColor];
        _categoryLabel.textColor = MOColor66Color();
        _categoryLabel.font = MOLightFont(12);
        [self addSubview:_categoryLabel];
        
        _rateLabel = MOCreateLabelAutoRTL();
        _rateLabel.layer.cornerRadius = 4;
        _rateLabel.clipsToBounds = YES;
        _rateLabel.backgroundColor = MOColorSaleFontColor();
        _rateLabel.textColor = [UIColor whiteColor];
        _rateLabel.font = MOLightFont(12);
        _rateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_rateLabel];
        _rateLabel.hidden = YES;
        
        _addressLabel = MOCreateLabelAutoRTL();
        _addressLabel.backgroundColor = [UIColor clearColor];
        _addressLabel.textColor = MOColor66Color();
        _addressLabel.font = MOLightFont(12);
        _addressLabel.numberOfLines = 0;
        [self addSubview:_addressLabel];
        
    }
    return self;
}


- (void)layoutSubviews
{
    MODebugLayer(self.productImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.vendorLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.distanceLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.categoryLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.rateLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.addressLabel, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    CGRect r = self.bounds;
    
    float offsetX = xMargin;
    float offsetY = yMargin;
    
    self.productImage.frame = CGRectMake(xMargin, yMargin,
                                         photoWidth, photoHeigth);
    
    offsetX +=photoWidth+xMargin;
    self.vendorLabel.frame = CGRectMake(offsetX, offsetY,
                                        [GDPublicManager instance].screenWidth-offsetX-xMargin, titleHeight*2);
    offsetY+=titleHeight*2;
    
    float  rateWidth = 30;
    
    self.categoryLabel.frame = CGRectMake(offsetX, offsetY,
                                          [GDPublicManager instance].screenWidth-offsetX-xMargin*2-rateWidth, titleHeight);
    self.rateLabel.frame = CGRectMake([GDPublicManager instance].screenWidth-xMargin-rateWidth, offsetY,rateWidth, titleHeight);
    
    if ([self.rateLabel.text intValue]>0)
        self.rateLabel.hidden = NO;
    
    if (nDist < 1000)
    {
        if (nDist<=0)
            self.distanceLabel.hidden = YES;
        else
            self.distanceLabel.text = [NSString stringWithFormat:@"%dm",nDist];
    }
    else
    {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1fkm",nDist*1.0/1000];
    }
    
    CGSize size = [self.distanceLabel.text moSizeWithFont:self.distanceLabel.font withWidth:60];
    float  distWidth = size.width;
    
    
    offsetY+=titleHeight;
     self.addressLabel.frame = CGRectMake(offsetX, offsetY,
                                         [GDPublicManager instance].screenWidth-offsetX-xMargin-distWidth, titleHeight);
    
    self.distanceLabel.frame = CGRectMake([GDPublicManager instance].screenWidth-xMargin-distWidth, offsetY,distWidth, titleHeight);
    
    offsetY+=titleHeight+ySpace;
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = self.productImage.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.productImage.frame = tempRect;
        
        tempRect = self.vendorLabel.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.vendorLabel.frame = tempRect;
        
        tempRect = self.distanceLabel.frame;
        tempRect.origin.x = xMargin;
        self.distanceLabel.frame = tempRect;
        
        tempRect = self.rateLabel.frame;
        tempRect.origin.x = self.distanceLabel.frame.origin.x;
        self.rateLabel.frame = tempRect;
        
        tempRect = self.categoryLabel.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.categoryLabel.frame = tempRect;
        
        tempRect = self.addressLabel.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.addressLabel.frame = tempRect;
        
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
