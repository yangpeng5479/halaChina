//
//  OTPageView.h
//  OTPageScrollView
//
//  Created by yechunxiao on 14-12-10.
//  Copyright (c) 2014年 Oolong Tea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTPageScrollView.h"

@interface OTPageView : UIView

@property (nonatomic,strong) OTPageScrollView *pageScrollView;
@property (nonatomic,strong) UIPageControl    *pageControl;
@property (nonatomic,strong) UILabel          *pageLabel;

@end