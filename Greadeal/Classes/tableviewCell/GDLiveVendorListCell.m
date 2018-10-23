//
//  GDLiveVendorListCell.m
//  Greadeal
//
//  Created by Elsa on 15/10/11.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "GDLiveVendorListCell.h"

#define xMargin 6
#define yMargin 8

@implementation GDLiveVendorListCell

@synthesize vendorLabel   = _vendorLabel;
@synthesize distanceLabel = _distanceLabel;
@synthesize nDist = nDist;

@synthesize categoryLabel = _categoryLabel;
@synthesize rateLabel     = _rateLabel;

@synthesize addressLabel  = _addressLabel;

@synthesize productArrar  = _productArrar;

@synthesize categoryImage = _categoryImage;
@synthesize locationImage = _locationImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        _productArrar = [[NSMutableArray alloc] init];
        
//        _productImage = [[UIImageView alloc] init];
//        _productImage.backgroundColor = [UIColor clearColor];
//        _productImage.contentMode = UIViewContentModeScaleAspectFill;
//        _productImage.clipsToBounds = YES;
        //[self addSubview:_productImage];
        
        _categoryImage = [[UIImageView alloc] init];
        _categoryImage.backgroundColor = [UIColor clearColor];
        _categoryImage.image = [UIImage imageNamed:@"list_category.png"];
         [self addSubview:_categoryImage];
        
        _locationImage = [[UIImageView alloc] init];
        _locationImage.backgroundColor = [UIColor clearColor];
        _locationImage.image = [UIImage imageNamed:@"list_location.png"];
        [self addSubview:_locationImage];

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
    
    self.vendorLabel.frame = CGRectMake(offsetX, offsetY,
                                        [GDPublicManager instance].screenWidth-offsetX-xMargin, titleHeight);
    offsetY+=titleHeight;
    
    float  rateWidth = 30;
    
    self.categoryImage.frame = CGRectMake(offsetX, offsetY+5,
                                           10, 10);
    
    self.categoryLabel.frame = CGRectMake(offsetX+13, offsetY,
                                          [GDPublicManager instance].screenWidth-offsetX-xMargin-13, titleHeight);
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
    self.locationImage.frame = CGRectMake(offsetX, offsetY+5,
                                          9, 11);
    self.addressLabel.frame = CGRectMake(offsetX+12, offsetY,
                                         [GDPublicManager instance].screenWidth-offsetX-xMargin-12-distWidth, titleHeight);
    
    self.distanceLabel.frame = CGRectMake([GDPublicManager instance].screenWidth-xMargin-distWidth, offsetY,distWidth, titleHeight);
    
    offsetY+=titleHeight+ySpace;
    
//    for (UIView *view in self.contentView.subviews)
//    {
//        [view removeFromSuperview];
//    }
//
//    
//    if (self.productArrar.count>0)
//    {
//        UIImageView* backgroundView = [[UIImageView alloc] init];
//        backgroundView.image = [[UIImage imageNamed:@"productLline.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
//        backgroundView.frame= CGRectMake(offsetX, offsetY,
//                                     r.size.width, 0.5);
//        [self.contentView addSubview:backgroundView];
//        
//        offsetY+=yMargin;
//        
//        for (NSDictionary* dict in self.productArrar)
//        {
//            NSString* name = dict[@"name"];
//            NSString* type = dict[@"type"];
//            
//            float imageWidth = 15;
//            
//            UIImageView* iconImage = [[UIImageView alloc] init];
//            iconImage.backgroundColor = [UIColor clearColor];
//            if ([type isEqualToString:@"coupon"])
//                iconImage.image = [UIImage imageNamed:@"vouchers.png"];
//            else
//                iconImage.image = [UIImage imageNamed:@"pakages.png"];
//            iconImage.frame = CGRectMake(offsetX, offsetY,
//                                            imageWidth, imageWidth);
//            [self.contentView addSubview:iconImage];
//            
//            UILabel* productLabel = MOCreateLabelAutoRTL();
//            productLabel.backgroundColor = [UIColor clearColor];
//            productLabel.textColor = colorFromHexString(@"666666");
//            productLabel.font = MOLightFont(12);
//            productLabel.text = name;
//            productLabel.numberOfLines = 0;
//            [self.contentView addSubview:productLabel];
//
//            productLabel.frame = CGRectMake(offsetX+imageWidth+5, offsetY-8,
//                                                 [GDPublicManager instance].screenWidth-offsetX-xMargin-imageWidth-5, titleHeight*2);
//            
//            offsetY+=titleHeight*2;
//            MODebugLayer(productLabel, 1.f, [UIColor redColor].CGColor);
//            
//            if ([GDSettingManager instance].isRightToLeft)
//            {
//                CGRect tempRect = iconImage.frame;
//                tempRect.origin.x = r.size.width-tempRect.size.width - photoWidth- xMargin*2;
//                iconImage.frame = tempRect;
//                
//                tempRect = productLabel.frame;
//                tempRect.origin.x = iconImage.frame.origin.x -tempRect.size.width- xMargin;
//                productLabel.frame = tempRect;
//            }
//        }
//        
//    }
//    
    if ([GDSettingManager instance].isRightToLeft)
    {
//        CGRect tempRect = self.productImage.frame;
//        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
//        self.productImage.frame = tempRect;
//        
        CGRect tempRect = self.vendorLabel.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.vendorLabel.frame = tempRect;
        
        tempRect = self.distanceLabel.frame;
        tempRect.origin.x = xMargin;
        self.distanceLabel.frame = tempRect;
        
        tempRect = self.rateLabel.frame;
        tempRect.origin.x = self.distanceLabel.frame.origin.x;
        self.rateLabel.frame = tempRect;
        
        tempRect = self.categoryLabel.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin-self.categoryImage.frame.size.width;
        self.categoryLabel.frame = tempRect;
        
        tempRect = self.categoryImage.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.categoryImage.frame = tempRect;
        
        tempRect = self.addressLabel.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin-self.locationImage.frame.size.width;
        self.addressLabel.frame = tempRect;
        
        tempRect = self.locationImage.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.locationImage.frame = tempRect;
        
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
