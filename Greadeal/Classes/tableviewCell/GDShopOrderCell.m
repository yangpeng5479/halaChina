//
//  GDShopOrderCell.m
//  Greadeal
//
//  Created by Elsa on 16/2/19.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDShopOrderCell.h"

#define titleHeight 20
#define titleWidth  ([[UIScreen mainScreen] bounds].size.width/320.0*220)

#define nonSalePhotoHeigth ([[UIScreen mainScreen] bounds].size.width/320.0*50)
#define nonSaleOffsetY 10

#define photoHeigth 75
#define photoWidth  75

#define xMargin  10
#define yMargin  5

@implementation GDShopOrderCell

@synthesize photoView;
@synthesize title;
@synthesize price;
@synthesize total_qty;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        photoView = [[UIImageView alloc] init];
        photoView.backgroundColor = [UIColor clearColor];
        photoView.contentMode = UIViewContentModeScaleAspectFill;
        photoView.clipsToBounds = YES;
        [self addSubview:photoView];
        
        title = MOCreateLabelAutoRTL();
        title.backgroundColor = [UIColor clearColor];
        title.font = MOLightFont(14);
        title.textColor = MOColor33Color();
        title.numberOfLines =0;
        [self addSubview:title];
        
        total_qty =  MOCreateLabelAutoRTL();
        total_qty.textColor = MOColor66Color();
        total_qty.backgroundColor = [UIColor clearColor];
        total_qty.font = MOLightFont(14);
        [self addSubview:total_qty];
        
        price =  MOCreateLabelAutoRTL();
        price.textColor = MOColorSaleFontColor();
        price.backgroundColor = [UIColor clearColor];
        price.font = MOLightFont(16);
        [self addSubview:price];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    MODebugLayer(self.photoView, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.title, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.total_qty, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.price, 1.f, [UIColor redColor].CGColor);
    
    CGRect r = self.bounds;
    
    self.photoView.frame = CGRectMake(xMargin, yMargin,
                                      photoWidth, photoHeigth);
    
    float offsetX = photoWidth + xMargin + xMargin;
    float offsetY = yMargin;
    
    self.title.frame = CGRectMake(offsetX, offsetY,
                                  titleWidth, titleHeight*2.5);
    
    
    offsetY += self.title.frame.size.height+5;
    
    [self.price findCurrency:CurrencyFontSize];
    [self.total_qty findCurrency:CurrencyFontSize];
    
    UIFont* Font = MOLightFont(14);
    CGSize  titleSize = [self.total_qty.text moSizeWithFont:Font withWidth:190];
    
    CGRect qtyFrame = self.total_qty.frame;
    qtyFrame.origin.x = offsetX;
    qtyFrame.origin.y = offsetY;
    qtyFrame.size.width = titleSize.width;
    qtyFrame.size.height = titleHeight;
    self.total_qty.frame = qtyFrame;
    
    offsetX += self.total_qty.frame.size.width+xMargin;
    Font = MOLightFont(20);
    titleSize = [self.price.text moSizeWithFont:Font withWidth:230];
    CGRect priceFrame = self.price.frame;
    priceFrame.origin.x = offsetX;
    priceFrame.origin.y = offsetY;
    priceFrame.size.width = titleSize.width;
    priceFrame.size.height = titleHeight;
    self.price.frame = priceFrame;
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = self.photoView.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.photoView.frame = tempRect;
        
        tempRect = self.title.frame;
        tempRect.origin.x = self.photoView.frame.origin.x-tempRect.size.width - xMargin;
        self.title.frame = tempRect;
        
        tempRect = self.total_qty.frame;
        tempRect.origin.x = self.photoView.frame.origin.x-tempRect.size.width - xMargin;
        self.total_qty.frame = tempRect;
        
        tempRect = self.price.frame;
        tempRect.origin.x = self.total_qty.frame.origin.x - tempRect.size.width - xMargin;
        self.price.frame = tempRect;
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
@end
