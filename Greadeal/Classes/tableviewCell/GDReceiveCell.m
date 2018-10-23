//
//  GDReceiveCell.m
//  Greadeal
//
//  Created by Elsa on 15/6/6.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDReceiveCell.h"

#define xMargin  10
#define yMargin  10

#define titleHeight 20
#define titleWidth  ([[UIScreen mainScreen] bounds].size.width/320.0*260)

@implementation GDReceiveCell

@synthesize name    = _name;
@synthesize phone   = _phone;
@synthesize address = _address;

@synthesize nameImage    = _nameImage;
@synthesize addressImage = _addressImage;
@synthesize phoneImage   = _phoneImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor =  [UIColor whiteColor];
        
        _nameImage = [[UIImageView alloc] init];
        _nameImage.contentMode = UIViewContentModeScaleAspectFill;
        _nameImage.clipsToBounds = YES;
        _nameImage.image = [UIImage imageNamed:@"custmer.png"];
        [self addSubview:_nameImage];
        
        _phoneImage = [[UIImageView alloc] init];
        _phoneImage.contentMode = UIViewContentModeScaleAspectFill;
        _phoneImage.clipsToBounds = YES;
        _phoneImage.image = [UIImage imageNamed:@"phonenumer.png"];
        [self addSubview:_phoneImage];
        
        _addressImage = [[UIImageView alloc] init];
        _addressImage.contentMode = UIViewContentModeScaleAspectFill;
        _addressImage.clipsToBounds = YES;
        _addressImage.image = [UIImage imageNamed:@"redlocation.png"];
        [self addSubview:_addressImage];
        
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
        _address.font = MOLightFont(14);
        _address.numberOfLines = 0;
        [self addSubview:_address];
        
    }
    return self;
}


-(void)layoutSubviews
{
    MODebugLayer(self.name, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.phone, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.address, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.nameImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.phoneImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.addressImage, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    CGRect r = self.bounds;
    
    float offsetX = xMargin;
    float offsetY = yMargin;
    
    float cellAccessoryOffsetX = 0;
    if (self.accessoryView != UITableViewCellAccessoryNone)
    {
        cellAccessoryOffsetX = 20;
    }
    
    self.nameImage.frame = CGRectMake(offsetX, offsetY,
                                 14, 13);
    
    self.name.frame = CGRectMake(offsetX+25, offsetY,
                                 [GDPublicManager instance].screenWidth-40, titleHeight);
    
    offsetY+=titleHeight+5;
    self.phoneImage.frame = CGRectMake(offsetX, offsetY,
                                      10, 14);
    self.phone.frame = CGRectMake(offsetX+25, offsetY,
                                  [GDPublicManager instance].screenWidth-40, titleHeight);
    
    offsetY+=titleHeight+5;
    self.addressImage.frame = CGRectMake(offsetX, offsetY+10,
                                    10, 15);
    self.address.frame =  CGRectMake(offsetX+25,offsetY,
                                     [GDPublicManager instance].screenWidth-40, titleHeight*2.5);

    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = self.nameImage.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width-xMargin;
        self.nameImage.frame = tempRect;
        
        tempRect = self.addressImage.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width-xMargin;
        self.addressImage.frame = tempRect;
        
        tempRect = self.phoneImage.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width-xMargin;
        self.phoneImage.frame = tempRect;
        
        tempRect = self.name.frame;
        tempRect.origin.x = self.nameImage.frame.origin.x-tempRect.size.width - xMargin;
        self.name.frame = tempRect;
        
        tempRect = self.phone.frame;
        tempRect.origin.x = xMargin;
        self.phone.frame = tempRect;
        
        tempRect = self.address.frame;
        tempRect.origin.x = self.nameImage.frame.origin.x-tempRect.size.width - xMargin;
        self.address.frame = tempRect;
        
        CGRect accessoryFrame = self.accessoryView.frame;
        accessoryFrame.origin.x = 0;
        self.accessoryView.frame = accessoryFrame;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
