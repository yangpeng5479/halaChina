//
//  GDShopDetailsTableViewCell.h
//  Greadeal
//
//  Created by Elsa on 15/6/3.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPLabel.h"
@interface GDShopDetailsTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) LPLabel *originLabel;
@property (nonatomic, strong) UILabel *saleLabel;

@end
