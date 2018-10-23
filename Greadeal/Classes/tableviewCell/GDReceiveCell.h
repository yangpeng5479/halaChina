//
//  GDReceiveCell.h
//  Greadeal
//
//  Created by Elsa on 15/6/6.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDReceiveCell : UITableViewCell

@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *address;
@property (nonatomic, strong) UILabel *phone;

@property (nonatomic, strong) UIImageView *nameImage;
@property (nonatomic, strong) UIImageView *addressImage;
@property (nonatomic, strong) UIImageView *phoneImage;

@end
