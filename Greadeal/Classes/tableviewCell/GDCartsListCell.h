//
//  GDCartsListCell.h
//  Greadeal
//
//  Created by Elsa on 15/5/16.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LPLabel.h"

@interface GDCartsListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *productImage;
@property (nonatomic, strong) UIImageView *modiImage;

@property (nonatomic, strong) TTTAttributedLabel *titleLabel;
@property (nonatomic, strong) LPLabel *originPrice;
@property (nonatomic, strong) UILabel *salePrice;

@property (nonatomic, strong) UIButton *deleteBut;

@property (nonatomic, strong) UILabel *subLabel;

@property (nonatomic, strong) UIButton *subtractionBut;
@property (nonatomic, strong) UIButton *addBut;
@property (nonatomic, strong) UILabel *qtyLabel;
@property (nonatomic, strong) UILabel *discount;

@end
