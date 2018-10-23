//
//  GDVendorCell.m
//  Greadeal
//
//  Created by Elsa on 15/8/7.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDVendorCell.h"

@implementation GDVendorCell

@synthesize titleLabel;
@synthesize iconImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor =  [UIColor whiteColor];
        
        iconImage = [[UIImageView alloc] init];
        [self addSubview:iconImage];
        
        titleLabel = MOCreateLabelAutoRTL();
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = MOLightFont(12);
        titleLabel.numberOfLines = 0;
        [self addSubview:titleLabel];
        
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    MODebugLayer(self.titleLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.iconImage, 1.f, [UIColor redColor].CGColor);
    
    CGRect r = self.bounds;
    float offsetx = 15;
    
    self.titleLabel.frame=CGRectMake(offsetx+30, 0, r.size.width-55, 50);
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = self.iconImage.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - 15;
        self.iconImage.frame = tempRect;
        
        tempRect = self.titleLabel.frame;
        tempRect.origin.x = offsetx;
        self.titleLabel.frame = tempRect;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
