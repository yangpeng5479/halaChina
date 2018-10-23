//
//  GDOpenHourListCell.m
//  Greadeal
//
//  Created by Elsa on 15/10/24.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "GDOpenHourListCell.h"

#define titleHeight 20

#define xMargin  15
#define yMargin  5

@implementation GDOpenHourListCell

@synthesize dayLabel  = _dayLabel;
@synthesize timeLabel = _timeLabel;


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

        _dayLabel = MOCreateLabelAutoRTL();
        _dayLabel.backgroundColor = [UIColor clearColor];
        _dayLabel.textColor = MOAppTextBackColor();
        _dayLabel.font = MOLightFont(12);
        _dayLabel.layer.cornerRadius=8;
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        _dayLabel.clipsToBounds = YES;
        _dayLabel.layer.borderWidth = 1;
        _dayLabel.layer.borderColor = [MOAppTextBackColor() CGColor];
        [self addSubview:_dayLabel];
        
        _timeLabel = MOCreateLabelAutoRTL();
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = MOColor66Color();
        _timeLabel.font = MOLightFont(12);
        [self addSubview:_timeLabel];
        
    }
    return self;
}

- (void)layoutSubviews
{
    MODebugLayer(self.dayLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.timeLabel, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    float offsetX = xMargin;
    
    self.dayLabel.frame = CGRectMake(offsetX, yMargin, 40 ,titleHeight);
    
    offsetX+=self.dayLabel.frame.size.width+xMargin;
    self.timeLabel.frame = CGRectMake(offsetX, yMargin, [GDPublicManager instance].screenWidth-offsetX-xMargin,titleHeight);
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = self.timeLabel.frame;
        tempRect.origin.x = self.dayLabel.frame.origin.x;
        self.timeLabel.frame = tempRect;
            
        tempRect = self.dayLabel.frame;
        tempRect.origin.x = self.frame.size.width-tempRect.size.width - xMargin;
        self.dayLabel.frame = tempRect;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
