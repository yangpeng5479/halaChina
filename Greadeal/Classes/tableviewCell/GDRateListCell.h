//
//  GDRateListCell.h
//  Greadeal
//
//  Created by Elsa on 15/6/17.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDRateListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *userImage;

@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UILabel *rateLabel;

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) NSArray *imageArrar;

@property (nonatomic, strong) ACPButton *translationBut;

@end
