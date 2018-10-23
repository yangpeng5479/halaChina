//
//  GDDeliverListCell.m
//  Greadeal
//
//  Created by Elsa on 16/2/18.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDDeliverListCell.h"

#define titleHeight 20

#define xMargin 6
#define yMargin 8

#define iconSize 10
#define iconSpace 15

#define photoWidth  125
#define photoHeigth 92

@implementation GDDeliverListCell

@synthesize productImage       = _productImage;
@synthesize vendorLabel        = _vendorLabel;
@synthesize distanceLabel      = _distanceLabel;
@synthesize nDist = nDist;

@synthesize deliveryChargeLabel= _deliveryChargeLabel;

@synthesize minorderLabel      = _minorderLabel;
@synthesize deliverytimeLabel  = _deliverytimeLabel;
@synthesize openhoursLabel     = _openhoursLabel;

@synthesize saleImage   = _saleImage;
@synthesize saleLabel = _saleLabel;

@synthesize dtImage   = _dtImage;
@synthesize opImage   = _opImage;

@synthesize closeImage    = _closeImage;

@synthesize starRateView  = _starRateView;

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
        _vendorLabel.textColor = colorFromHexString(@"404040");
        _vendorLabel.font = MOLightFont(14);
        [self addSubview:_vendorLabel];
        
        _deliveryChargeLabel =  MOCreateLabelAutoRTL();
        _deliveryChargeLabel.font = MOLightFont(12);
        _deliveryChargeLabel.textColor = colorFromHexString(@"969696");
        _deliveryChargeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _deliveryChargeLabel.numberOfLines = 0;
        [self addSubview:_deliveryChargeLabel];
      
        _minorderLabel = MOCreateLabelAutoRTL();
        _minorderLabel.backgroundColor = [UIColor clearColor];
        _minorderLabel.textColor = colorFromHexString(@"969696");
        _minorderLabel.font = MOLightFont(12);
        [self addSubview:_minorderLabel];
        
        _dtImage = [[UIImageView alloc] init];
        _dtImage.contentMode = UIViewContentModeScaleAspectFill;
        _dtImage.clipsToBounds = YES;
        _dtImage.image = [UIImage imageNamed:@"list_delivery.png"];
        [self addSubview:_dtImage];

        _opImage = [[UIImageView alloc] init];
        _opImage.contentMode = UIViewContentModeScaleAspectFill;
        _opImage.clipsToBounds = YES;
        _opImage.image = [UIImage imageNamed:@"list_openhour.png"];
        [self addSubview:_opImage];
        
        _saleImage = [[UIImageView alloc] init];
        _saleImage.contentMode = UIViewContentModeScaleAspectFill;
        _saleImage.clipsToBounds = YES;
        [self addSubview:_saleImage];
        
        _saleLabel = MOCreateLabelAutoRTL();
        _saleLabel.textAlignment = NSTextAlignmentCenter;
        _saleLabel.backgroundColor = [UIColor clearColor];
        _saleLabel.textColor = [UIColor whiteColor];
        _saleLabel.font = MOLightFont(14);
        [_saleImage addSubview:_saleLabel];
        
        _closeImage = [[UIImageView alloc] init];
        _closeImage.contentMode = UIViewContentModeScaleAspectFill;
        _closeImage.clipsToBounds = YES;
        [self addSubview:_closeImage];
        
        _distanceLabel = MOCreateLabelAutoRTL();
        _distanceLabel.backgroundColor = [UIColor clearColor];
        _distanceLabel.textColor = colorFromHexString(@"969696");
        _distanceLabel.font = MOLightFont(12);
        _distanceLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_distanceLabel];
        
        _starRateView = [[CWStarRateView alloc] initWithFrame:CGRectMake(260,157,80,20) numberOfStars:5];
        _starRateView.allowIncompleteStar = YES;
        _starRateView.hasAnimation = NO;
        _starRateView.allowChange = NO;
        [self addSubview:_starRateView];
        
        _deliverytimeLabel = MOCreateLabelAutoRTL();
        _deliverytimeLabel.backgroundColor = [UIColor clearColor];
        _deliverytimeLabel.textColor = MOColor66Color();
        _deliverytimeLabel.font = MOLightFont(12);
        [self addSubview:_deliverytimeLabel];
        
        _openhoursLabel = MOCreateLabelAutoRTL();
        _openhoursLabel.backgroundColor = [UIColor clearColor];
        _openhoursLabel.textColor = MOColor66Color();
        _openhoursLabel.font = MOLightFont(12);
        [self addSubview:_openhoursLabel];
        
    }
    return self;
}


- (void)layoutSubviews
{
    MODebugLayer(self.productImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.vendorLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.distanceLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.starRateView, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.minorderLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.deliverytimeLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.openhoursLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.saleImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.dtImage, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];

    CGRect r = self.bounds;
    
    self.productImage.frame = CGRectMake(xMargin, yMargin,
                                         photoWidth, photoHeigth);
    
    
    float offsetX = xMargin;
    float offsetY = photoHeigth-titleHeight;
  
    self.closeImage.frame = CGRectMake(photoWidth-13, photoHeigth-10,13, 13);

    self.saleImage.frame = CGRectMake(xMargin, photoHeigth-10, 65, 15);
    self.saleLabel.frame = CGRectMake(0, 0, 65, 15);
 
    if (nDist < 1000)
    {
        self.distanceLabel.text = [NSString stringWithFormat:@"%dm",nDist];
    }
    else
    {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1fkm",nDist*1.0/1000];
    }
    
    offsetX = photoWidth+xMargin*2;
    offsetY = yMargin;
    
    self.vendorLabel.frame = CGRectMake(offsetX, offsetY,
                                            r.size.width-photoWidth-xMargin*3, titleHeight);
  
        
    offsetY+=titleHeight;
    
    self.starRateView.frame = CGRectMake(offsetX, offsetY,80, 20);
    
    self.distanceLabel.frame = CGRectMake(r.size.width-xMargin-60, offsetY, 60, titleHeight);
    
    offsetY+=titleHeight;
    
    self.deliveryChargeLabel.frame = CGRectMake(offsetX, offsetY,
                                                r.size.width-photoWidth-xMargin*3, titleHeight);
    offsetY+=titleHeight;

    self.minorderLabel.frame = CGRectMake(offsetX, offsetY,
                                           r.size.width-170, titleHeight);
    
    offsetY+=titleHeight;
    
    self.dtImage.frame = CGRectMake(offsetX,offsetY+5,
                                    12, iconSize);
    self.deliverytimeLabel.frame = CGRectMake(offsetX+iconSpace, offsetY,
                                           70, titleHeight);
    
    self.opImage.frame = CGRectMake(r.size.width-75-xMargin-iconSpace,offsetY+5,iconSize, iconSize);
    self.openhoursLabel.frame = CGRectMake(r.size.width-75-xMargin, offsetY,75, titleHeight);
    
    
//    if ([GDSettingManager instance].isRightToLeft)
//    {
//    
//        CGRect tempRect = self.distanceLabel.frame;
//        tempRect.origin.x = xMargin;
//        self.distanceLabel.frame = tempRect;
//        
//        tempRect = self.vendorLabel.frame;
//        tempRect.origin.x = self.distanceLabel.frame.origin.x + self.distanceLabel.frame.size.width + xMargin;
//        self.vendorLabel.frame = tempRect;
//        
//    }
   
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
