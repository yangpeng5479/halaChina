//
//  GDShopProductViewCell.h
//  Greadeal
//
//  Created by Elsa on 16/2/1.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LPLabel.h"

#define titleHeight 20

@interface GDShopProductViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *productImage;

@property (nonatomic, strong) UILabel *productLabel;

@property (nonatomic, strong) LPLabel *originLabel;
@property (nonatomic, strong) UILabel *saleLabel;
@property (nonatomic, strong) UILabel *soldLabel;

@end
