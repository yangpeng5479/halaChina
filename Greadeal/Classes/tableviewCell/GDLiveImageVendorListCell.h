//
//  GDLiveImageVendorListCell.h
//  Greadeal
//
//  Created by Elsa on 16/1/27.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface GDLiveImageVendorListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *productImage;

@property (nonatomic, strong) UILabel *vendorLabel;
@property (nonatomic, assign) int     nDist;
@property (nonatomic, strong) UILabel *distanceLabel;

@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UILabel *rateLabel;

@property (nonatomic, strong) UILabel *addressLabel;

@end
