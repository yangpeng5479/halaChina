//
//  GDBeautyCell.h
//  Greadeal
//
//  Created by Elsa on 15/5/29.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPLabel.h"

@interface GDBeautyCell : UITableViewCell

@property (nonatomic, strong) UIImageView *productImage;
@property (nonatomic, strong) UIButton *cartBut;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) LPLabel *originPrice;
@property (nonatomic, strong) UILabel *salePrice;
@property (nonatomic, strong) UILabel *discount;
@property (nonatomic, strong) UILabel *detail;
@property (nonatomic, strong) UILabel *viewed;

@end
