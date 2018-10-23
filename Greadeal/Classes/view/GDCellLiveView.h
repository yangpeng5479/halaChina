//
//  GDCellSuperView
//  Greadeal
//
//  Created by Elsa on 15/5/13.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCTopic.h"

#define bannerHeight   100
#define sectionHeight  40

#define cellDataHeight 80

#define numbersOfCell  2

@interface GDCellLiveView : UIView<JCTopicDelegate>
{
    JCTopic          *bannerView;
    UILabel          *titleLable;
    
    NSMutableArray   *bannerData;
    NSMutableArray   *cellData;
}

@property (nonatomic, weak)  id superNav;

@property (nonatomic, strong)  NSMutableArray* bannerData;
@property (nonatomic, strong)  NSMutableArray* cellData;

- (float)getViewHeight;
- (void)makeMainView;

@end
