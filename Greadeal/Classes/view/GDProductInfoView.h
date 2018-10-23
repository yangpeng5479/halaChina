//
//  GDProductInfoView.h
//  Greadeal
//
//  Created by Elsa on 15/6/4.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDPanelView.h"

#define  infotextSize   12

#define  titleMaxWidth     80
#define  detailsMaxWidth   200

#define  yMargin  5

@interface GDProductInfoView : GDPanelView

- (void)setRecentItems:(NSArray *)keys;

@end
