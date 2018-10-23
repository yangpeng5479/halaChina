//
//  GDProductListCell.h
//  Greadeal
//
//  Created by Elsa on 16/8/3.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPLabel.h"

@interface GDProductListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *productImage;
@property (nonatomic, strong) UIView *backImage;

@property (nonatomic, strong) UILabel *vendorLabel;
@property (nonatomic, strong) TTTAttributedLabel *productLabel;

@property (nonatomic, strong) UIImageView *locationImage;
@property (nonatomic, strong) UILabel     *cityLabel;

@property (nonatomic, strong) UIView *textBackImage;

@property (nonatomic, strong) UILabel *currencyLabel;
@property (nonatomic, strong) UILabel *couponLabel;

@property (nonatomic, strong) LPLabel *originLabel;
@property (nonatomic, strong) UILabel *saleLabel;

@property (nonatomic, assign) int    membership_level;
@end
