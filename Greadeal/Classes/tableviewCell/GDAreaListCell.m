//
//  GDAreaListCell.m
//  Greadeal
//
//  Created by Elsa on 16/6/21.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDAreaListCell.h"

#define titleHeight 20

#define xMargin 6
#define yMargin 8

#define iconSize 10
#define iconSpace 15

#define photoWidth  105
#define photoHeigth 70

@implementation GDAreaListCell

@synthesize productImage     = _productImage;
@synthesize areaLabel        = _areaLabel;
@synthesize areaSubLabel     = _areaSubLabel;

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
        
        _areaLabel = MOCreateLabelAutoRTL();
        _areaLabel.backgroundColor = [UIColor clearColor];
        _areaLabel.textColor = colorFromHexString(@"4F4F4F");
        _areaLabel.font = MOLightFont(16);
        [self addSubview:_areaLabel];
        
        _areaSubLabel =  MOCreateLabelAutoRTL();
        _areaSubLabel.font = MOLightFont(13);
        _areaSubLabel.textColor = colorFromHexString(@"6A6A6A");
        _areaSubLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _areaSubLabel.numberOfLines = 0;
        [self addSubview:_areaSubLabel];
        
    }
    return self;
}


- (void)layoutSubviews
{
    MODebugLayer(self.productImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.areaLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.areaSubLabel, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    
    CGRect r = self.bounds;
    
    float offsetX = xMargin;
    float offsetY = 0;
   
    self.productImage.frame = CGRectMake(xMargin, yMargin,
                                         photoWidth, photoHeigth);
    
    
    offsetX += photoWidth+xMargin*2;
    offsetY += 20;
    self.areaLabel.frame = CGRectMake(offsetX, offsetY,
                                        r.size.width-photoWidth-45, titleHeight);
    
    
    offsetY+=titleHeight;
    
    self.areaSubLabel.frame = CGRectMake(offsetX, offsetY,
                                                r.size.width-photoWidth-45, titleHeight);
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
