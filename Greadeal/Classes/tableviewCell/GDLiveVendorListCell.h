//
//  GDLiveVendorListCell.h
//  Greadeal
//
//  Created by Elsa on 15/10/11.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

#define photoWidth  75
#define photoHeigth 75

#define titleHeight 20
#define ySpace 10

@interface GDLiveVendorListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *productImage;

@property (nonatomic, strong) UIImageView *categoryImage;
@property (nonatomic, strong) UIImageView *locationImage;

@property (nonatomic, strong) UILabel *vendorLabel;
@property (nonatomic, assign) int     nDist;
@property (nonatomic, strong) UILabel *distanceLabel;

@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UILabel *rateLabel;

@property (nonatomic, strong) UILabel *addressLabel;

@property (nonatomic, strong) NSMutableArray *productArrar;

@end
