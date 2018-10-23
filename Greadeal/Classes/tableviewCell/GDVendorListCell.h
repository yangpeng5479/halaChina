//
//  GDVendorListCell.h
//  Greadeal
//
//  Created by Elsa on 16/6/21.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWStarRateView.h"

@interface GDVendorListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *productImage;

@property (nonatomic, strong) UILabel *vendorLabel;
@property (nonatomic, strong) UILabel *serviceLabel;

@property (nonatomic, strong) CWStarRateView *starRateView;


@end
