//
//  GDAddressCell.m
//  Greadeal
//
//  Created by Elsa on 15/6/5.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDAddressCell.h"

#define xMargin  15
#define yMargin  8

#define titleHeight 20
#define titleWidth  ([[UIScreen mainScreen] bounds].size.width-90)

@implementation GDAddressCell

@synthesize name = _name;
@synthesize phone = _phone;
@synthesize address = _address;
@synthesize defaultAddress = _defaultAddress;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _name = MOCreateLabelAutoRTL();
        _name.backgroundColor = [UIColor clearColor];
        _name.textColor = [UIColor blackColor];
        _name.font = MOLightFont(14);
        _name.numberOfLines = 0;
        [self addSubview:_name];
        
        _phone = MOCreateLabelAutoRTL();
        _phone.backgroundColor = [UIColor clearColor];
        _phone.textColor = [UIColor blackColor];
        _phone.font = MOLightFont(14);
        _phone.numberOfLines = 0;
        [self addSubview:_phone];
        
        _address = MOCreateLabelAutoRTL();
        _address.backgroundColor = [UIColor clearColor];
        _address.textColor = [UIColor blackColor];
        _address.font = MOLightFont(12);
        _address.numberOfLines = 0;
        [self addSubview:_address];
        
        _defaultAddress = MOCreateLabelAutoRTL();
        _defaultAddress.backgroundColor = [UIColor clearColor];
        _defaultAddress.textColor = [UIColor redColor];
        _defaultAddress.font = MOLightFont(12);
        _defaultAddress.text = NSLocalizedString(@"[Default]", @"[默认]");
        [self addSubview:_defaultAddress];
        
    }
    return self;
}


-(void)layoutSubviews
{
    MODebugLayer(self.name, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.phone, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.address, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.defaultAddress, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    CGRect r = self.bounds;
    
    float offsetX = xMargin;
    float offsetY = yMargin;
    
    self.name.frame = CGRectMake(offsetX, offsetY,
                                       150*[GDPublicManager instance].screenScale, titleHeight);
    
    self.phone.frame = CGRectMake(offsetX+self.name.frame.size.width, offsetY,
                                 130*[GDPublicManager instance].screenScale, titleHeight);
    
    offsetY += self.name.frame.size.height;
    
    if (self.defaultAddress.hidden)
    {
        self.address.frame = CGRectMake(offsetX, offsetY, titleWidth, titleHeight*2);
    }
    else
    {
        CGSize titleSize = [self.defaultAddress.text moSizeWithFont:self.defaultAddress.font withWidth:100*[GDPublicManager instance].screenScale];
        
        self.defaultAddress.frame = CGRectMake(offsetX, offsetY+2, titleSize.width, titleHeight);
        self.address.frame = CGRectMake(offsetX+titleSize.width, offsetY, titleWidth, titleHeight*2);
    }
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = self.name.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin - 20;
        self.name.frame = tempRect;
        
        tempRect = self.phone.frame;
        tempRect.origin.x = self.name.frame.origin.x-tempRect.size.width-xMargin;
        self.phone.frame = tempRect;
        
        if (self.defaultAddress.hidden)
        {
            tempRect = self.address.frame;
            tempRect.origin.x = r.size.width-tempRect.size.width-xMargin- 20;
            self.address.frame = tempRect;
        }
        else
        {
            tempRect = self.defaultAddress.frame;
            tempRect.origin.x = r.size.width-tempRect.size.width-xMargin- 20;
            self.defaultAddress.frame = tempRect;
            
            tempRect = self.address.frame;
            tempRect.origin.x = self.defaultAddress.frame.origin.x-tempRect.size.width-xMargin;
            self.address.frame = tempRect;
        }
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
