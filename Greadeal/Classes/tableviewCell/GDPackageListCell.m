//
//  GDPackageListCell.m
//  Greadeal
//
//  Created by Elsa on 15/5/30.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDPackageListCell.h"

#define titleHeight 30

#define xMargin  15
#define yMargin  5


@implementation GDPackageListCell

@synthesize nameLabel = _nameLabel;
@synthesize numberLabel = _numberLabel;
@synthesize priceLabel = _priceLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            [self setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, self.bounds.size.width)];
        }
        
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, self.bounds.size.width)];
        }
        
        _nameLabel = MOCreateLabelAutoRTL();
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = MOColor66Color();
        _nameLabel.font = MOLightFont(12);
        _nameLabel.numberOfLines = 0;
        [self addSubview:_nameLabel];
        
        _numberLabel = MOCreateLabelAutoRTL();
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.textColor = MOColor66Color();
        _numberLabel.font = MOLightFont(12);
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_numberLabel];
        
        _priceLabel = MOCreateLabelAutoRTL();
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.textColor = MOColor66Color();
        _priceLabel.font = MOLightFont(12);
        [self addSubview:_priceLabel];
        
    }
    return self;
}

- (void)layoutSubviews
{
    MODebugLayer(self.nameLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.numberLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.priceLabel, 1.f, [UIColor redColor].CGColor);

    [super layoutSubviews];
    float offsetX = xMargin;
   
    self.nameLabel.frame = CGRectMake(offsetX, yMargin, 200*[GDPublicManager instance].screenScale,titleHeight);
    
    offsetX+=self.nameLabel.frame.size.width;
    self.numberLabel.frame = CGRectMake(offsetX, yMargin, 52*[GDPublicManager instance].screenScale,titleHeight);
    
    offsetX+=self.numberLabel.frame.size.width;
    self.priceLabel.frame = CGRectMake(offsetX, yMargin, 52*[GDPublicManager instance].screenScale,titleHeight);
    
    [self.priceLabel findCurrency:CurrencyFontSize];
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect r = self.bounds;
        
        CGRect tempRect = self.nameLabel.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.nameLabel.frame = tempRect;
        
        tempRect = self.numberLabel.frame;
        tempRect.origin.x = self.nameLabel.frame.origin.x-tempRect.size.width;
        self.numberLabel.frame = tempRect;
        
        tempRect = self.priceLabel.frame;
        tempRect.origin.x = 0;
        self.priceLabel.frame = tempRect;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
