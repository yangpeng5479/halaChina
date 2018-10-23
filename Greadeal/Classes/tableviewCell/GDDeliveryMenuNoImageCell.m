//
//  GDDeliveryMenuNoImageCell.m
//  Greadeal
//
//  Created by Elsa on 16/4/6.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDDeliveryMenuNoImageCell.h"

#define titleHeight 25

#define xMargin 6
#define yMargin 8


#define kRightWidth [[UIScreen mainScreen] bounds].size.width-100
#define titleWidth  kRightWidth-xMargin*2

@implementation GDDeliveryMenuNoImageCell

@synthesize detailsLabel = _detailsLabel;
@synthesize menuLabel    = _menuLabel;
@synthesize saleLabel    = _saleLabel;

@synthesize modiImage = _modiImage;
@synthesize subtractionBut = _subtractionBut;
@synthesize qtyLabel       = _qtyLabel;
@synthesize addBut         = _addBut;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        _detailsLabel = MOCreateLabelAutoRTL();
        _detailsLabel.backgroundColor = [UIColor clearColor];
        _detailsLabel.textColor = MOColor66Color();
        _detailsLabel.font = MOLightFont(12);
        _detailsLabel.numberOfLines = 0;
        [self addSubview:_detailsLabel];
        
        _modiImage = [[UIImageView alloc] init];
        _modiImage.image = [UIImage imageNamed:@"box.png"];
        [self addSubview:_modiImage];
        
        _menuLabel = MOCreateLabelAutoRTL();
        _menuLabel.backgroundColor = [UIColor clearColor];
        _menuLabel.textColor = MOColor33Color();
        _menuLabel.font = MOLightFont(14);
        [self addSubview:_menuLabel];
        
        _saleLabel = MOCreateLabelAutoRTL();
        _saleLabel.backgroundColor = [UIColor clearColor];
        _saleLabel.textColor = MOColorSaleFontColor();
        _saleLabel.font = MOLightFont(16);
        [self addSubview:_saleLabel];
        
        _subtractionBut=[UIButton buttonWithType:UIButtonTypeCustom];
        [_subtractionBut setImage:[UIImage imageNamed:@"redu_normal.png"] forState:UIControlStateNormal];
        [self addSubview:_subtractionBut];
        
        _addBut=[UIButton buttonWithType:UIButtonTypeCustom];
        [_addBut setImage:[UIImage imageNamed:@"plus_normal.png"]  forState:UIControlStateNormal];
        [self addSubview:_addBut];
        
        _qtyLabel = MOCreateLabelAutoRTL();
        _qtyLabel.textAlignment = NSTextAlignmentCenter;
        _qtyLabel.backgroundColor = [UIColor clearColor];
        _qtyLabel.textColor = MOColor33Color();
        _qtyLabel.font = MOLightFont(14);
        [self addSubview:_qtyLabel];
        
    }
    return self;
}


- (void)layoutSubviews
{
    MODebugLayer(self.detailsLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.menuLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.saleLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.qtyLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.addBut, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.subtractionBut, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    
    CGRect r = self.bounds;
    
    float offsetX = xMargin;
    float offsetY = 0;
    
    self.menuLabel.frame = CGRectMake(offsetX, offsetY,
                                      titleWidth, titleHeight);
    offsetY += self.menuLabel.frame.size.height;
    
    CGSize titleSize = [self.detailsLabel.text moSizeWithFont:self.detailsLabel.font withWidth:titleWidth];
    if (titleSize.height>18)
        titleSize.height += 8;
    
    self.detailsLabel.frame = CGRectMake(xMargin, offsetY,
                                          titleWidth,titleSize.height);
    
   
    offsetY += titleSize.height+5;
    
    [self.saleLabel findCurrency:CurrencyFontSize];
    
    CGRect saleFrame = self.saleLabel.frame;
    saleFrame.origin.x = offsetX;
    saleFrame.origin.y = offsetY;
    saleFrame.size.width = 70;
    saleFrame.size.height = titleHeight;
    self.saleLabel.frame = saleFrame;
    
    offsetX = titleWidth-saleFrame.size.width-xMargin*2;
    float moveX = kRightWidth - offsetX - 84;
    
    CGRect modiFrame = self.modiImage.frame;
    modiFrame.origin.x = offsetX+moveX;
    modiFrame.origin.y = offsetY;
    modiFrame.size.width = 80;
    modiFrame.size.height = 26;
    self.modiImage.frame = modiFrame;
    
    CGRect subFrame = self.subtractionBut.frame;
    subFrame.origin.x = modiFrame.origin.x-xMargin-4;
    subFrame.origin.y = modiFrame.origin.y-yMargin;
    subFrame.size.width = 50;
    subFrame.size.height = 40;
    self.subtractionBut.frame = subFrame;
    
    offsetX = subFrame.origin.x+40;
    self.qtyLabel.frame = CGRectMake(offsetX, modiFrame.origin.y,
                                     80/3.0, modiFrame.size.height);
    
    offsetX = subFrame.origin.x+50+xMargin/2;
    self.addBut.frame = CGRectMake(offsetX, modiFrame.origin.y-yMargin,
                                   50, 40);
    
    
    offsetX = r.size.width-60;
    
    if ([GDSettingManager instance].isRightToLeft)
    {
    
        CGRect tempRect = self.saleLabel.frame;
        tempRect.origin.x = kRightWidth - self.saleLabel.frame.size.width - xMargin;
        self.saleLabel.frame = tempRect;
        
        tempRect = self.modiImage.frame;
        tempRect.origin.x = xMargin*2;
        self.modiImage.frame = tempRect;
        
        tempRect = self.subtractionBut.frame;
        tempRect.origin.x = xMargin-xMargin/2;
        self.subtractionBut.frame = tempRect;
        
        tempRect = self.qtyLabel.frame;
        tempRect.origin.x = self.subtractionBut.frame.origin.x+self.subtractionBut.frame.size.width-xMargin-xMargin;
        self.qtyLabel.frame = tempRect;
        
        tempRect = self.addBut.frame;
        tempRect.origin.x = self.qtyLabel.frame.origin.x+self.qtyLabel.frame.size.width-xMargin-xMargin;
        self.addBut.frame = tempRect;
        
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
