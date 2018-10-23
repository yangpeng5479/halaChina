//
//  GDShopDetailsTableViewCel.m
//  Greadeal
//
//  Created by Elsa on 15/6/3.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDShopDetailsTableViewCell.h"
#define xMargin  15
#define yMargin  10

#define titleHeight 20
#define titleWidth  300

@implementation GDShopDetailsTableViewCell

@synthesize titleLabel  = _titleLabel;
@synthesize saleLabel   = _saleLabel;
@synthesize originLabel = _originLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        _titleLabel = MOCreateLabelAutoRTL();
        _titleLabel.font = MOLightFont(14);
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
       
        _originLabel = [[LPLabel alloc] init];
        _originLabel.backgroundColor = [UIColor clearColor];
        _originLabel.textColor = colorFromHexString(@"999999");
        _originLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _originLabel.font = MOLightFont(14);
        [self addSubview:_originLabel];
        
        _saleLabel = MOCreateLabelAutoRTL();
        _saleLabel.backgroundColor = [UIColor clearColor];
        _saleLabel.textColor = MOColorSaleFontColor();
        _saleLabel.font = MOLightFont(20);
        [self addSubview:_saleLabel];
        
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect r = self.bounds;
    
    float offsetX = xMargin;
    float offsetY = 0;
    
    self.titleLabel.frame = CGRectMake(offsetX, offsetY,
                                       [GDPublicManager instance].screenWidth-xMargin*2, titleHeight*2);
    offsetY += self.titleLabel.frame.size.height+5;
    
    MODebugLayer(self.titleLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.originLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.saleLabel, 1.f, [UIColor redColor].CGColor);
    
    [self.originLabel findCurrency:CurrencyFontSize];
    [self.saleLabel findCurrency:CurrencyFontSize];
    
    UIFont *Font = MOLightFont(20);
    CGSize  titleSize = [self.saleLabel.text moSizeWithFont:Font withWidth:150];
    
    CGRect saleFrame = self.saleLabel.frame;
    saleFrame.origin.x = offsetX;
    saleFrame.origin.y = offsetY;
    saleFrame.size.width = titleSize.width;
    saleFrame.size.height = titleHeight;
    self.saleLabel.frame = saleFrame;
    
    offsetX=self.saleLabel.frame.origin.x+80;
    

    Font = MOLightFont(14);
    titleSize = [self.originLabel.text moSizeWithFont:Font withWidth:100];
    
    CGRect originFrame = self.originLabel.frame;
    originFrame.origin.x = offsetX;
    originFrame.origin.y = offsetY+2;
    originFrame.size.width = titleSize.width;
    originFrame.size.height = titleHeight;
    self.originLabel.frame = originFrame;
    
   
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = self.titleLabel.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width-xMargin;
        self.titleLabel.frame = tempRect;
        
        tempRect = self.saleLabel.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width-xMargin;
        self.saleLabel.frame = tempRect;
        
    }
    if ([self.originLabel.text isEqualToString:self.saleLabel.text])
    {
        self.originLabel.hidden=YES;
    }
    else
    {
        self.originLabel.hidden=NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
