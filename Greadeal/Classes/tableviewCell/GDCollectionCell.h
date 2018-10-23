//
//  GDCollectionCell.h
//  Greadeal
//
//  Created by Elsa on 15/6/3.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "TMQuiltViewCell.h"
#import "LPLabel.h"
@interface GDCollectionCell : TMQuiltViewCell

@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) LPLabel *originPrice;
@property (nonatomic, strong) UILabel *salePrice;

@property (nonatomic, strong) UILabel *discount;
@property (nonatomic, strong) UIButton *cartBut;

- (void)adjustFont;

@end
