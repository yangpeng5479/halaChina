//
//  GDDetailsTableViewCell.h
//  Greadeal
//
//  Created by Elsa on 15/6/3.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPLabel.h"
@interface GDDetailsTableViewCell : UITableViewCell

@property (nonatomic, strong) TTTAttributedLabel *titleLabel;
@property (nonatomic, strong) UILabel *useLabel;

@property (nonatomic, strong) LPLabel *originLabel;
@property (nonatomic, strong) UILabel *saleLabel;

@property (nonatomic, assign) BOOL    haveBlue;
@property (nonatomic, assign) BOOL    haveGold;
@property (nonatomic, assign) BOOL    havePlatinum;

@property (nonatomic, strong) UIImageView *blueImage;
@property (nonatomic, strong) UIImageView *goldImage;
@property (nonatomic, strong) UIImageView *platinumImage;
@property (nonatomic, strong) UILabel *memberLabel;

@property (nonatomic, strong) UILabel *nonMember;
@property (nonatomic, strong) UILabel *member;

@property (nonatomic, strong) UILabel *couponLabel;

@property (nonatomic, strong) UILabel* stockLabel;
@property (nonatomic, strong) UILabel* soldLabel;

@end
