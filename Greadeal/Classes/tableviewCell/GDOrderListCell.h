//
//  GDOrderListCell.h
//  JUMPSTAR
//
//  Created by tao tao on 16/4/15.
//  Copyright (c) 2015 tao tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDOrderListCell : UITableViewCell
{
    UIImageView    *photoView;
    TTTAttributedLabel        *title;
    UILabel        *total_qty;
    UILabel        *price;
    UILabel        *couponLabel;
}

@property(nonatomic,strong) UIImageView *photoView;
@property(nonatomic,strong) TTTAttributedLabel *title;
@property(nonatomic,strong) UILabel *total_qty;
@property(nonatomic,strong) UILabel *price;
@property(nonatomic,strong) UILabel *couponLabel;

@end
