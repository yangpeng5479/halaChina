//
//  GDQRCell.h
//  haomama
//
//  Created by tao tao on 24/05/13.
//  Copyright (c) 2013年 tao tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPLabel.h"
#import "ACPButton.h"

@interface GDQRCell : UITableViewCell
{
    UIImageView* tapShow;
    UILabel* textLabel;
}
@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) UIImageView *QRView;

@property (nonatomic, strong) UIImageView *maskView;

@property (nonatomic, strong) UILabel     *vendorLabel;

@property (nonatomic, strong) UILabel     *numberLabel;
@property (nonatomic, assign) int         isExpire; //0没使用 //1使用  //2过期
@property (nonatomic, strong) UIImageView *usedImage;

@property (nonatomic, strong) TTTAttributedLabel     *titleLabel;

@property (nonatomic, strong) LPLabel     *originPriceLabel;
@property (nonatomic, strong) UILabel     *priceLabel;

@property (nonatomic, strong) UILabel     *expireLabel;
@property (nonatomic, strong) UILabel     *memberExpireLabel;

@property (nonatomic, strong) UILabel     *couponLabel;

@property (nonatomic, strong) ACPButton   *actionBut;
@property (nonatomic, strong) ACPButton   *shareBut;

@end
