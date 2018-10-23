//
//  GDSaleSoonrCell.m
//  haomama
//
//  Created by tao tao on 21/05/13.
//  Copyright (c) 2013年 tao tao. All rights reserved.
//

#import "GDSaleSoonrCell.h"

#define PhotoHeight    110
#define TEXT_FONT_SIZE 14
#define kyMargin  2.5

@implementation GDSaleSoonrCell

@synthesize photoView = _photoView;
@synthesize titleLabel = _titleLabel;
@synthesize strPrice = _strPrice;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (UIImageView *)photoView {
    if (!_photoView) {
        _photoView = [[UIImageView alloc] init];
        _photoView.contentMode = UIViewContentModeScaleAspectFill;
        _photoView.clipsToBounds = YES;
        [self addSubview:_photoView];
    }
    return _photoView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = MOCreateLabelAutoRTL();
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = colorFromHexString(@"666666");
        _titleLabel.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)strPrice {
    if (!_strPrice) {
        _strPrice = [[UILabel alloc] init];
        _strPrice.backgroundColor = [UIColor clearColor];
        _strPrice.textColor = colorFromHexString(@"fe0100");
        _strPrice.textAlignment = NSTextAlignmentCenter;
        _strPrice.font = [UIFont systemFontOfSize:16];
        [self addSubview:_strPrice];
    }
    return _strPrice;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGRect r = self.bounds;
    self.photoView.frame = CGRectMake(r.origin.x, r.origin.y, r.size.width,PhotoHeight);
    self.titleLabel.frame = CGRectMake(r.origin.x, PhotoHeight+kyMargin,
                                       r.size.width, 20);
    self.strPrice.frame = CGRectMake(r.origin.x, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height,r.size.width, 20);

}

@end
