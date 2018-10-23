//
//  GDMarketCategoryViewController.h
//  Greadeal
//
//  Created by Elsa on 15/8/4.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDMarketCategoryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    UITableView      *leftTablew;
    UITableView      *rightTableView;
   
    int              vendorId;
    int              selectIndex;
    
    BOOL             isLoadData;
    
    NSMutableArray   *leftData;
    NSMutableArray   *rightData;
}

/*
 *  左边背景颜色
 */
@property(strong,nonatomic) UIColor * leftBgColor;
/*
 *  左边点中文字颜色
 */
@property(strong,nonatomic) UIColor * leftSelectColor;
/*
 *  左边点中背景颜色
 */
@property(strong,nonatomic) UIColor * leftSelectBgColor;
/*
 *  左边未点中文字颜色
 */
@property(strong,nonatomic) UIColor * leftUnSelectColor;
/*
 *  左边未点中背景颜色
 */
@property(strong,nonatomic) UIColor * leftUnSelectBgColor;
/*
 *  tablew 的分割线
 */
@property(strong,nonatomic) UIColor * leftSeparatorColor;

- (id)init:(int)vendor_id withIndex:(int)aIndex;

@end
