//
//  GDMarketListCell.m
//  Greadeal
//
//  Created by Elsa on 15/6/17.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDRateListCell.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

#define titleHeight 20
#define xMargin 8
#define yMargin 8

#define  numberOfLine 4
#define  photosHeight (([[UIScreen mainScreen] bounds].size.width-80.0)/numberOfLine)

@implementation GDRateListCell

@synthesize userImage = _userImage;
@synthesize userLabel = _userLabel;
@synthesize rateLabel = _rateLabel;
@synthesize dateLabel = _dateLabel;
@synthesize contentLabel = _contentLabel;
@synthesize imageArrar  = _imageArrar;
@synthesize translationBut = _translationBut;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
         _imageArrar = [[NSMutableArray alloc] init];
        
        self.backgroundColor =  [UIColor whiteColor];
        
        _userImage = [[UIImageView alloc] init];
        _userImage.contentMode = UIViewContentModeScaleAspectFill;
        [_userImage setClipsToBounds:YES];
        [self addSubview:_userImage];
        
        _userLabel = MOCreateLabelAutoRTL();
        _userLabel.backgroundColor = [UIColor clearColor];
        _userLabel.textColor = [UIColor blackColor];
        _userLabel.font = MOLightFont(14);
        [self addSubview:_userLabel];
        
        _rateLabel = MOCreateLabelAutoRTL();
        _rateLabel.layer.cornerRadius = 4;
        _rateLabel.clipsToBounds = YES;
        _rateLabel.backgroundColor = MOColorSaleFontColor();
        _rateLabel.textColor = [UIColor whiteColor];
        _rateLabel.font = MOLightFont(12);
        _rateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_rateLabel];
        
        _dateLabel = MOCreateLabelAutoRTL();
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor grayColor];
        _dateLabel.font = MOLightFont(12);
        _dateLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_dateLabel];
        
        _contentLabel = MOCreateLabelAutoRTL();
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor grayColor];
        _contentLabel.font = MOLightFont(12);
        _contentLabel.numberOfLines = 0;
        [self addSubview:_contentLabel];
        
        _translationBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        [_translationBut setStyleType:ACPButtonGrey];
        [_translationBut setTitle: @"翻译成中文" forState:UIControlStateNormal];
        [_translationBut setLabelFont:MOLightFont(14)];
        //[self addSubview:_translationBut];
        _translationBut.hidden = YES;

    }
    return self;
}

- (void)tapImageView:(UIGestureRecognizer *)tapGesture
{
    UIImageView *button = (UIImageView *)tapGesture.view;
    int index = (int)button.tag;
    
    if (index>=0)
    {
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity: [self.imageArrar count]];
        for (int i = 0; i < [self.imageArrar count]; i++) {
            NSString* getImageStrUrl = [self.imageArrar objectAtIndex:i];
            
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString: [getImageStrUrl encodeUTF]];
            [photos addObject:photo];
        }
        
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init:NO];
        browser.currentPhotoIndex = index;
        browser.photos = photos;
        [browser show];
    }
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    MODebugLayer(self.userImage, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.userLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.rateLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.dateLabel, 1.f, [UIColor redColor].CGColor);
    MODebugLayer(self.contentLabel, 1.f, [UIColor redColor].CGColor);
   
    float offsetY = xMargin;
    float offsetX = 10;
    
    self.userImage.frame = CGRectMake(offsetX, offsetY,30, 30);
    self.userLabel.frame = CGRectMake(offsetX+30+offsetX, offsetY,
                                        [GDPublicManager instance].screenWidth-offsetX*3-30, titleHeight);
    
    offsetY+=titleHeight;
    

    self.rateLabel.frame=CGRectMake(self.userLabel.frame.origin.x, offsetY, 70, titleHeight);
    self.dateLabel.frame=CGRectMake([GDPublicManager instance].screenWidth-offsetX-150, offsetY, 150, titleHeight);
    
    offsetY+=titleHeight+xMargin;
    
    CGSize titleSize = [self.contentLabel.text moSizeWithFont:self.contentLabel.font withWidth:[GDPublicManager instance].screenWidth-self.userLabel.frame.origin.x-offsetX];
    
    self.contentLabel.frame = CGRectMake(self.userLabel.frame.origin.x, offsetY, [GDPublicManager instance].screenWidth-self.userLabel.frame.origin.x-offsetX, titleSize.height);
    
 
    for (UIView *view in self.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    if (self.imageArrar.count>0)
    {
        CGRect r = self.bounds;
        
        int nCount = 0;
        offsetX = self.userLabel.frame.origin.x;
        offsetY+=titleSize.height;
        
        float imageWidth = photosHeight - 4;

        offsetY+=8;
        
        for (NSString* strName in self.imageArrar)
        {
            UIImageView* iconImage = [[UIImageView alloc] init];
            iconImage.backgroundColor = [UIColor clearColor];
            iconImage.contentMode = UIViewContentModeScaleAspectFill;
            [iconImage setClipsToBounds:YES];
            iconImage.image = [UIImage imageNamed:@"vouchers.png"];
            [iconImage sd_setImageWithURL:[NSURL URLWithString:[strName encodeUTF]]
                                 placeholderImage:[UIImage imageNamed:@"live_product_default.png"]];
            
            iconImage.frame = CGRectMake(offsetX, offsetY,
                                         imageWidth, imageWidth);
            [self.contentView addSubview:iconImage];
            
            iconImage.userInteractionEnabled = YES;
            iconImage.tag = nCount;
            [iconImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)]];
            
            if ([GDSettingManager instance].isRightToLeft)
            {
                CGRect tempRect = iconImage.frame;
                tempRect.origin.x = r.size.width-tempRect.origin.x-imageWidth;
                iconImage.frame = tempRect;
            }
            
            offsetX+=8+imageWidth;
          
            nCount++;
            if (nCount>=4)
                break;
        }
        offsetY += photosHeight;
    }
    else
    {
        offsetY += titleSize.height+yMargin;
    }
    
    
    _translationBut.frame = CGRectMake([GDPublicManager instance].screenWidth-120 , offsetY, 100, 25);
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect r = self.bounds;
        
        CGRect tempRect = self.userImage.frame;
        tempRect.origin.x = r.size.width-tempRect.size.width - xMargin;
        self.userImage.frame = tempRect;
        
        tempRect = self.userLabel.frame;
        tempRect.origin.x = self.userImage.frame.origin.x-tempRect.size.width - xMargin;
        self.userLabel.frame = tempRect;
        
        tempRect = self.rateLabel.frame;
        tempRect.origin.x = self.userImage.frame.origin.x-tempRect.size.width - xMargin;
        self.rateLabel.frame = tempRect;
        
        tempRect = self.contentLabel.frame;
        tempRect.origin.x = self.userImage.frame.origin.x-tempRect.size.width - xMargin;
        self.contentLabel.frame = tempRect;
        
        tempRect = self.dateLabel.frame;
        tempRect.origin.x = 14;
        self.dateLabel.frame = tempRect;
        _dateLabel.textAlignment = NSTextAlignmentLeft;

    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
