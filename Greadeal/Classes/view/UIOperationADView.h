//
//  UIOperationADView.h
//  Greadeal
//
//  Created by Elsa on 16/8/2.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIOperationADView : UIScrollView
{
    NSMutableArray    *items;
}

- (void)setRecentItems:(NSArray *)keys;

@property (assign) id  target;
@property (assign) SEL callback;

@end
