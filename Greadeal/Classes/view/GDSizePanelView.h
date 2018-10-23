//
//  GDSizePanelView.h
//  Greadeal
//
//  Created by Elsa on 15/6/3.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDPanelView.h"

@interface GDSizePanelView : GDPanelView
{
    // NSMutableArray *itemSelected;
    int  firstChoosed;
}

@property (assign) int  pro_quantity;

- (void)setRecentItems:(NSArray *)keys;

@end
