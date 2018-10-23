//
//  GDDeliveryMenuCell.h
//  Greadeal
//
//  Created by Elsa on 16/2/18.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDDeliveryMenuCell : UITableViewCell

@property (nonatomic, strong) UIImageView *productImage;
@property (nonatomic, strong) UILabel *menuLabel;
@property (nonatomic, strong) UILabel *saleLabel;

@property (nonatomic, strong) UIImageView *modiImage;
@property (nonatomic, strong) UIButton *subtractionBut;
@property (nonatomic, strong) UIButton *addBut;
@property (nonatomic, strong) UILabel *qtyLabel;

@end
