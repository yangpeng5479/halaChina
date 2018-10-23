//
//  GDDeliveryOrderCell.h
//  Greadeal
//
//  Created by Elsa on 16/2/19.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDDeliveryOrderCell : UITableViewCell
{
    UIImageView    *photoView;
    UILabel        *title;
    UILabel        *total_qty;
    UILabel        *price;

}

@property(nonatomic,strong) UIImageView *photoView;
@property(nonatomic,strong) UILabel *title;
@property(nonatomic,strong) UILabel *total_qty;
@property(nonatomic,strong) UILabel *price;
@property(nonatomic,strong) UILabel *couponLabel;

@end
