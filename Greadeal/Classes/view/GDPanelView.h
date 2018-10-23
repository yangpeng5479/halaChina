//
//  GDPanelView.h
//  Greadeal
//
//  Created by Elsa on 15/5/15.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GDPanelView : UIView
{
    NSArray   *items;
    NSMutableArray   *itemButtons;
}

@property (assign) id  target;
@property (assign) SEL callback;

//- (void)setRecentItems:(NSArray *)keys;
- (void)rearrangeButtons;
- (float)getFrameHeight;

@property (nonatomic, assign) float LineHeight;
@property (nonatomic, assign) float xspaceing;
@property (nonatomic, assign) float yspaceing;

@property (nonatomic, assign) float imageWidth;
@property (nonatomic, assign) float imageHeight;

@property (nonatomic, assign) int ItemOfPage;
@property (nonatomic, assign) int ItemOfLine;

@end
