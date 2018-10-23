//
//  GDLiveProductListCell.h
//  Greadeal
//
//  Created by Elsa on 15/8/7.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LPLabel.h"

#define titleHeight 20

@interface GDLiveProductListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *productImage;

@property (nonatomic, strong) UILabel *vendorLabel;
@property (nonatomic, assign) int     nDist;
@property (nonatomic, strong) UILabel *distanceLabel;

@property (nonatomic, strong) UIImageView *rateImage;
@property (nonatomic, strong) UILabel *rateLabel;

@property (nonatomic, strong) TTTAttributedLabel *productLabel;
@property (nonatomic, strong) UIImageView *lineImage;
@property (nonatomic, strong) UILabel *couponLabel;

@property (nonatomic, strong) LPLabel *originLabel;
@property (nonatomic, strong) UILabel *saleLabel;
@property (nonatomic, strong) UILabel *soldLabel;

@property (nonatomic, strong) UIImageView *savingImage;
@property (nonatomic, strong) UILabel *savingLabel;

@property (nonatomic, assign) BOOL    haveBlue;
@property (nonatomic, assign) BOOL    haveGold;
@property (nonatomic, assign) BOOL    havePlatinum;

@property (nonatomic, strong) UIImageView *blueImage;
@property (nonatomic, strong) UIImageView *goldImage;
@property (nonatomic, strong) UIImageView *platinumImage;
@property (nonatomic, strong) UILabel *memberLabel;

@property (nonatomic, strong) UILabel *nonMember;
@property (nonatomic, strong) UILabel *member;

@property (nonatomic, assign) BOOL    showVendorDist;

@end
