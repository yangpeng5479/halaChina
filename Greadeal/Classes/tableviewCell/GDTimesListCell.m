//
//  GDTimesListCell.m
//  Greadeal
//
//  Created by Elsa on 16/6/22.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDTimesListCell.h"

@implementation GDTimesListCell

@synthesize  rTimeLabel = _rTimeLabel;
@synthesize  dTimeLabel = _dTimeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        _rTimeLabel = MOCreateLabelAutoRTL();
        _rTimeLabel.textAlignment = NSTextAlignmentCenter;
        _rTimeLabel.backgroundColor = [UIColor clearColor];
        _rTimeLabel.textColor = MOColor66Color();
        _rTimeLabel.font = MOLightFont(12);
        [self addSubview:_rTimeLabel];
        
        _dTimeLabel =  MOCreateLabelAutoRTL();
        _dTimeLabel.textAlignment = NSTextAlignmentCenter;
        _dTimeLabel.font = MOLightFont(12);
        _dTimeLabel.textColor = MOColor66Color();
        _dTimeLabel.numberOfLines = 0;
        [self addSubview:_dTimeLabel];
        
    }
    return self;
}


- (void)layoutSubviews
{
    //MODebugLayer(self.rTimeLabel, 1.f, [UIColor redColor].CGColor);
    //MODebugLayer(self.dTimeLabel, 1.f, [UIColor redColor].CGColor);
    
    [super layoutSubviews];
    
    CGRect r = self.bounds;
    
    self.rTimeLabel.frame = CGRectMake(0, 0,
                                         r.size.width/2, r.size.height);
    
    
    self.dTimeLabel.frame = CGRectMake(r.size.width/2, 0,
                                         r.size.width/2, r.size.height);
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
