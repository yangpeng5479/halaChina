//
//  GDDeliverListCell.h
//  Greadeal
//
//  Created by Elsa on 16/2/18.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWStarRateView.h"

@interface GDDeliverListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *productImage;

@property (nonatomic, strong) UILabel *vendorLabel;
@property (nonatomic, assign) int     nDist;
@property (nonatomic, strong) UILabel *distanceLabel;

@property (nonatomic, strong) UILabel *deliveryChargeLabel;

@property (nonatomic, strong) UILabel *minorderLabel;
@property (nonatomic, strong) UILabel *deliverytimeLabel;
@property (nonatomic, strong) UILabel *openhoursLabel;

@property (nonatomic, strong) UIImageView *saleImage;
@property (nonatomic, strong) UILabel *saleLabel;

@property (nonatomic, strong) UIImageView *dtImage;
@property (nonatomic, strong) UIImageView *opImage;

@property (nonatomic, strong) UIImageView *closeImage;

@property (nonatomic, strong) CWStarRateView *starRateView;

@end
