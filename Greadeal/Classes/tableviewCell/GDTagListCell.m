//
//  GDTagListCell.m
//  Greadeal
//
//  Created by Elsa on 15/10/24.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "GDTagListCell.h"
#define titleHeight 20

#define xMargin  15
#define yMargin  5

@implementation GDTagListCell

@synthesize tickImage     = _tickImage;
@synthesize serveiceLabel = _serveiceLabel;


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
        
        _tickImage = [[UIImageView alloc] init];
        _tickImage.contentMode = UIViewContentModeScaleAspectFill;
        _tickImage.clipsToBounds = YES;
        [self addSubview:_tickImage];
        
        _serveiceLabel = MOCreateLabelAutoRTL();
        _serveiceLabel.backgroundColor = [UIColor clearColor];
        _serveiceLabel.textColor = MOColor66Color();
        _serveiceLabel.font = MOLightFont(12);
        [self addSubview:_serveiceLabel];
        
    }
    return self;
}

- (void)layoutSubviews
{
    MODebugLayer(self.tickImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.serveiceLabel, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    float offsetX = xMargin;
    
    self.tickImage.frame = CGRectMake(offsetX, yMargin, titleHeight ,titleHeight);
    
    offsetX+=self.tickImage.frame.size.width+xMargin;
    self.serveiceLabel.frame = CGRectMake(offsetX, yMargin, [GDPublicManager instance].screenWidth-offsetX-xMargin,titleHeight);
    
    if ([GDSettingManager instance].isRightToLeft)
    {
            CGRect tempRect = self.serveiceLabel.frame;
            tempRect.origin.x = self.tickImage.frame.origin.x;
            self.serveiceLabel.frame = tempRect;
            
            tempRect = self.tickImage.frame;
            tempRect.origin.x = self.frame.size.width-tempRect.size.width - xMargin;
            self.tickImage.frame = tempRect;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
