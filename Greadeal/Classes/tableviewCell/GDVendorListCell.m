//
//  GDVendorListCell.m
//  Greadeal
//
//  Created by Elsa on 16/6/21.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDVendorListCell.h"
#define titleHeight 20

#define xMargin 6
#define yMargin 8

#define iconSize 10
#define iconSpace 15

#define photoWidth  125
#define photoHeigth 92


@implementation GDVendorListCell

@synthesize productImage       = _productImage;
@synthesize vendorLabel        = _vendorLabel;
@synthesize serviceLabel       = _serviceLabel;
@synthesize starRateView       = _starRateView;

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
        _vendorLabel.font = MOLightFont(15);
        _vendorLabel.numberOfLines = 0;
        [self addSubview:_vendorLabel];
        
        _serviceLabel =  MOCreateLabelAutoRTL();
        _serviceLabel.font = MOLightFont(12);
        _serviceLabel.textColor = colorFromHexString(@"999999");
        _serviceLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_serviceLabel];
        
        _starRateView = [[CWStarRateView alloc] initWithFrame:CGRectMake(260,157,80,20) numberOfStars:5];
        _starRateView.allowIncompleteStar = YES;
        _starRateView.hasAnimation = NO;
        _starRateView.allowChange = NO;
        [self addSubview:_starRateView];
        
    }
    return self;
}


- (void)layoutSubviews
{
    MODebugLayer(self.productImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.vendorLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.serviceLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.starRateView, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    
    CGRect r = self.bounds;
    
    self.productImage.frame = CGRectMake(xMargin, yMargin,
                                         photoWidth, photoHeigth);
    
    
    float offsetX = xMargin;
    float offsetY = photoHeigth-titleHeight;
    
    
    offsetX = photoWidth+xMargin*2;
    offsetY = yMargin;
    
    self.vendorLabel.frame = CGRectMake(offsetX, offsetY,
                                        r.size.width-photoWidth-xMargin*3, titleHeight*2);
    
    offsetY+=titleHeight*2+5;
    
    self.serviceLabel.frame = CGRectMake(offsetX, offsetY,
                                         r.size.width-photoWidth-xMargin*3, titleHeight);

    offsetY+=titleHeight+5;
    
    self.starRateView.frame = CGRectMake(offsetX, offsetY,80, 20);
    
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
