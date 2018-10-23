//
//  GDVoucherListCell.h
//  Greadeal
//
//  Created by Elsa on 15/5/14.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LPLabel.h"

#define photoWidth  70
#define photoHeigth 70

#define titleHeight 20

@interface GDVoucherListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *productImage;
@property (nonatomic, strong) UILabel *productLabel;

@property (nonatomic, strong) LPLabel *originLabel;
@property (nonatomic, strong) UILabel *saleLabel;
@property (nonatomic, strong) UILabel *soldLabel;

@property (nonatomic, assign) BOOL    haveBlue;
@property (nonatomic, assign) BOOL    haveGold;
@property (nonatomic, assign) BOOL    havePlatinum;

@property (nonatomic, strong) UIImageView *blueImage;
@property (nonatomic, strong) UIImageView *goldImage;
@property (nonatomic, strong) UIImageView *platinumImage;
@property (nonatomic, strong) UILabel *memberLabel;

@property (nonatomic, strong) UILabel *nonMember;
@property (nonatomic, strong) UILabel *member;

@end
